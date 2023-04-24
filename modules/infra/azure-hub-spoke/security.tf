resource "azurerm_network_security_group" "this" {
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
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}