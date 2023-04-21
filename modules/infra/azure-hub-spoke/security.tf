resource "azurerm_network_security_group" "this" {
  count = var.network_type == "hub" ? 1 : 0
  
  name                = "${local.prefix}-nsg"
  location            = azurerm_virtual_network.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "rdp"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "consul-http-https-api"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8500-8502"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }
}