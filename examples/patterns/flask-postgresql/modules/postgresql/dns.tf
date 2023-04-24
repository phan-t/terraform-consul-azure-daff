# resource "azurerm_private_dns_zone" "this" {
#   name                = "${var.deployment_id}.postgres.database.azure.com"
#   resource_group_name = data.azurerm_resource_group.this.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "this" {
#   name                  = "${var.deployment_id}-network-link"
#   private_dns_zone_name = azurerm_private_dns_zone.this.name
#   virtual_network_id    = data.azurerm_virtual_network.this.id
#   resource_group_name   = data.azurerm_resource_group.this.name
# }