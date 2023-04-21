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

data "azurerm_image" "consul" {
  name                = var.image_name_consul
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "consul-server-pip" {
  name                = "${var.deployment_id}-consul-server-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "consul-server" {
  name                = "${var.deployment_id}-consul-server-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "vmipconfig"
    subnet_id                     = data.azurerm_subnet.management.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.consul-server-pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "consul-server" {
  network_interface_id      = azurerm_network_interface.consul-server.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}

resource "local_file" "consul-server-config" {
  content = templatefile("../../../examples/templates/consul-server-config.json", {
    deployment_name       = "${var.deployment_name}-azure"
    node_name             = azurerm_linux_virtual_machine.consul-server.name
    initial_acl_token     = var.initial_acl_token
    })
  filename = "${path.module}/server-config.json.tmp"
}

resource "azurerm_linux_virtual_machine" "consul-server" {
  name                            = "${var.deployment_id}-consul-server-vm"
  location                        = data.azurerm_resource_group.rg.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.consul-server.id]
  size                            = "Standard_DS1_v2"
  admin_username                  = "ubuntu"
  admin_password                  = "HashiCorp1!"
  disable_password_authentication = false
  source_image_id                 = data.azurerm_image.consul.id

  os_disk {
    name                 = "${var.deployment_id}-consul-server-disk-1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "null_resource" "consul-server-config" {
  connection {
    host          = azurerm_linux_virtual_machine.consul-server.public_ip_address
    user          = "ubuntu"
    password      = "HashiCorp1!"
    agent         = false
  }

  provisioner "file" {
    source      = "${path.module}/server-config.json.tmp"
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