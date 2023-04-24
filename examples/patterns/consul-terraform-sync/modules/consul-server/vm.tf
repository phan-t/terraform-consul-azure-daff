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
  name                = "${var.deployment_id}-consul-server-pip"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "this" {
  name                = "${var.deployment_id}-consul-server-nic"
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

resource "azurerm_network_security_rule" "this" {
  name                       = "consul-http-https-api"
  priority                   = 1010
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "8500-8502"
  source_address_prefix      = "203.123.99.211"
  destination_address_prefix = "*"
  
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = data.azurerm_network_security_group.this.name
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = "${var.deployment_id}-consul-server-vm"
  location                        = data.azurerm_resource_group.this.location
  resource_group_name             = data.azurerm_resource_group.this.name
  network_interface_ids           = [azurerm_network_interface.this.id]
  size                            = "Standard_DS1_v2"
  admin_username                  = "ubuntu"
  admin_password                  = "HashiCorp1!"
  disable_password_authentication = false
  source_image_id                 = data.azurerm_image.this.id

  os_disk {
    name                 = "${var.deployment_id}-consul-server-disk-1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "local_file" "consul-server-config" {
  content = templatefile("../../../examples/templates/consul-server-config.json", {
    deployment_name       = "${join("-", slice(split("-", var.deployment_id), 0, 2))}-azure"
    node_name             = azurerm_linux_virtual_machine.this.name
    initial_acl_token     = var.initial_acl_token
    })
  filename = "${path.module}/configs/server-config.json.tmp"
}

resource "null_resource" "this" {
  connection {
    host          = azurerm_linux_virtual_machine.this.public_ip_address
    user          = "ubuntu"
    password      = "HashiCorp1!"
    agent         = false
  }

  provisioner "file" {
    content     = local_file.consul-server-config.content
    destination = "/tmp/server-config.json"
  }

  provisioner "file" {
    source      = "${path.root}/consul-ent-license.hclic"
    destination = "/tmp/consul-ent-license.hclic"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/server-config.json /opt/consul/config/config.json",
      "sudo cp /tmp/consul-ent-license.hclic /opt/consul/bin/consul-ent-license.hclic",
      "sudo /opt/consul/bin/run-consul"
    ]
  }

  depends_on = [
    local_file.consul-server-config
  ]
}