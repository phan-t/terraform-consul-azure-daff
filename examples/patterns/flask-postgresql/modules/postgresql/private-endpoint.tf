resource "azurerm_private_endpoint" "this" {
  name                = "${var.deployment_id}-pep"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  subnet_id           = data.azurerm_subnet.database.id

  private_service_connection {
    name                           = "${azurerm_postgresql_server.this.name}-psc"
    private_connection_resource_id = azurerm_postgresql_server.this.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}