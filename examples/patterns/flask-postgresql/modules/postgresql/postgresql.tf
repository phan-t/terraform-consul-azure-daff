locals {
  friendly_location = {
    "Australia Central"   = "canberra",
    "Australia East"      = "sydney",
    "Australia Southeast" = "melbourne"
  }
}

data "azurerm_resource_group" "this" {
  name = "${var.landing_zone_id}-${var.network_type}-${lookup(local.friendly_location, var.location)}-rg"
}

data "azurerm_virtual_network" "this" {
  name                = "${var.landing_zone_id}-${var.network_type}-${lookup(local.friendly_location, var.location)}-vnet"
  resource_group_name = data.azurerm_resource_group.this.name
}

data "azurerm_subnet" "database" {
  name                 = "database-snet"
  virtual_network_name = data.azurerm_virtual_network.this.name
  resource_group_name  = data.azurerm_resource_group.this.name
}

resource "azurerm_postgresql_server" "this" {
  name                = "${var.deployment_id}-psql"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  administrator_login          = "psqladmin"
  administrator_login_password = "HashiCorp1!"

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 10240

  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  auto_grow_enabled             = true

  public_network_access_enabled = true
  ssl_enforcement_enabled       = true
}

resource "azurerm_postgresql_database" "this" {
  name                = "flask-db"
  resource_group_name = data.azurerm_resource_group.this.name
  server_name         = azurerm_postgresql_server.this.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}