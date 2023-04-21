data "azurerm_resource_group" "rg" {
  name = "${var.deployment_id}-hub-canberra-rg"
}

data "azurerm_subnet" "management" {
  name                 = "management-snet"
  virtual_network_name = "${var.deployment_id}-hub-canberra-vnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_network_security_group" "nsg" {
  name                = "${var.deployment_id}-hub-canberra-nsg"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_image" "consul-terraform-sync" {
  name                = var.image_name_consul_terraform_sync
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "consul-terraform-sync-pip" {
  name                = "${var.deployment_id}-consul-terraform-sync-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "consul-terraform-sync" {
  name                = "${var.deployment_id}-consul-terraform-sync-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "vmipconfig"
    subnet_id                     = data.azurerm_subnet.management.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.consul-terraform-sync-pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "consul-terraform-sync" {
  network_interface_id      = azurerm_network_interface.consul-terraform-sync.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}

resource "local_file" "consul-client-config" {
  content = templatefile("../../../examples/templates/consul-client-config.json", {
    deployment_name       = "${var.deployment_name}-azure"
    node_name             = azurerm_linux_virtual_machine.consul-terraform-sync.name
    server_private_ip     = var.server_private_ip
    serf_lan_port         = 8301
    })
  filename = "${path.module}/client-config.json.tmp"
}

resource "local_file" "consul-terraform-sync-config" {
  content = templatefile("../../../examples/templates/consul-terraform-sync-config.hcl", {
    host  = var.terraform_cloud_host
    org   = var.terraform_cloud_org
    token = var.terraform_cloud_token
    })
  filename = "${path.module}/consul-terraform-sync-config.hcl.tmp"
}

resource "azurerm_linux_virtual_machine" "consul-terraform-sync" {
  name                            = "${var.deployment_id}-consul-terraform-sync-vm"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.consul-terraform-sync.id]
  size                            = "Standard_DS1_v2"
  admin_username                  = "ubuntu"
  admin_password                  = "HashiCorp1!"
  disable_password_authentication = false
  source_image_id                 = data.azurerm_image.consul-terraform-sync.id

  os_disk {
    name                 = "${var.deployment_id}-consul-terraform-sync-disk-1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "null_resource" "consul-client-config" {
  connection {
    host          = azurerm_linux_virtual_machine.consul-terraform-sync.public_ip_address
    user          = "ubuntu"
    password      = "HashiCorp1!"
    agent         = false
  }

  provisioner "file" {
    source      = "${path.module}/client-config.json.tmp"
    destination = "/tmp/client-config.json"
  }

  provisioner "file" {
    source      = "${path.module}/consul-terraform-sync-config.hcl.tmp"
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