resource "consul_node" "this" {
  name    = azurerm_postgresql_server.this.name
  address = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}

resource "consul_service" "this" {
  name    = azurerm_postgresql_server.this.name
  node    = azurerm_postgresql_server.this.name
  port    = 5432
  tags    = ["flask", "database", "postgresql"]

  meta = {
    "deployment_id"    = var.deployment_id
    "application_id"   = "ahs-flask-dev-001"
    "landing_zone_id"  = var.landing_zone_id
    "environment"      = "development"
    "location"         = lookup(local.friendly_location, var.location)
    "private_endpoint" = true
  }

  depends_on = [
    consul_node.this
  ]
}