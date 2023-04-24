locals {
  friendly_location = {
    "Australia Central"   = "canberra",
    "Australia East"      = "sydney",
    "Australia Southeast" = "melbourne"
  }
}

data "azurerm_resource_group" "this" {
  name = "${var.deployment_id}-${var.network_type}-${lookup(local.friendly_location, var.location)}-rg"
}

data "azurerm_subnet" "this" {
  name                 = "management-snet"
  virtual_network_name = "${var.deployment_id}-${var.network_type}-${lookup(local.friendly_location, var.location)}-vnet"
  resource_group_name  = data.azurerm_resource_group.this.name
}

data "azurerm_network_security_group" "this" {
  name                = "${var.deployment_id}-${var.network_type}-${lookup(local.friendly_location, var.location)}-nsg"
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azurerm_image" "this" {
  name                = var.image_name
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_public_ip" "this" {
  name                = "${var.deployment_id}-consul-terraform-sync-pip"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "this" {
  name                = "${var.deployment_id}-consul-terraform-sync-nic"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  ip_configuration {
    name                          = "vmipconfig"
    subnet_id                     = data.azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = data.azurerm_network_security_group.this.id
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = "${var.deployment_id}-consul-terraform-sync-vm"
  location                        = data.azurerm_resource_group.this.location
  resource_group_name             = data.azurerm_resource_group.this.name
  network_interface_ids           = [azurerm_network_interface.this.id]
  size                            = "Standard_DS1_v2"
  admin_username                  = "ubuntu"
  admin_password                  = "HashiCorp1!"
  disable_password_authentication = false
  source_image_id                 = data.azurerm_image.this.id

  os_disk {
    name                 = "${var.deployment_id}-consul-terraform-sync-disk-1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "local_file" "consul-client-config" {
  content = templatefile("../../../examples/templates/consul-client-config.json", {
    deployment_name       = "${join("-", slice(split("-", var.deployment_id), 0, 2))}-azure"
    node_name             = azurerm_linux_virtual_machine.this.name
    server_private_ip     = var.consul_server_address
    serf_lan_port         = 8301
    })
  filename = "${path.module}/configs/client-config.json.tmp"
}

resource "local_file" "consul-terraform-sync-config" {
  content = templatefile("../../../examples/templates/consul-terraform-sync-config.hcl", {
    host  = var.terraform_cloud_host
    org   = var.terraform_cloud_org
    token = var.terraform_cloud_token
    })
  filename = "${path.module}/configs/consul-terraform-sync-config.hcl.tmp"
}

resource "null_resource" "this" {
  connection {
    host          = azurerm_linux_virtual_machine.this.public_ip_address
    user          = "ubuntu"
    password      = "HashiCorp1!"
    agent         = false
  }

  provisioner "file" {
    content     = local_file.consul-client-config.content
    destination = "/tmp/client-config.json"
  }

  provisioner "file" {
    content     = local_file.consul-terraform-sync-config.content
    destination = "/tmp/consul-terraform-sync-config.hcl"
  }

  provisioner "file" {
    source      = "${path.root}/consul-ent-license.hclic"
    destination = "/tmp/consul-ent-license.hclic"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/client-config.json /opt/consul/config/config.json",
      "sudo cp /tmp/consul-terraform-sync-config.hcl /opt/consul-terraform-sync/config/config.hcl",
      "sudo cp /tmp/consul-ent-license.hclic /opt/consul/bin/consul-ent-license.hclic",
      "sudo /opt/consul/bin/run-consul",
      "sleep 30",
      "sudo /opt/consul-terraform-sync/bin/run-consul-terraform-sync"
    ]
  }

  depends_on = [
    local_file.consul-client-config,
    local_file.consul-terraform-sync-config
  ]
}