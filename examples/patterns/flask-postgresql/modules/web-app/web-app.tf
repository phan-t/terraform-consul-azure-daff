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

data "azurerm_subnet" "web" {
  name                 = "web-snet"
  virtual_network_name = data.azurerm_virtual_network.this.name
  resource_group_name  = data.azurerm_resource_group.this.name
}

resource "azurerm_service_plan" "this" {
  name                = "${var.deployment_id}-sp"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "this" {
  name                      = "${var.deployment_id}-app"
  location                  = data.azurerm_resource_group.this.location
  resource_group_name       = data.azurerm_resource_group.this.name
  service_plan_id           = azurerm_service_plan.this.id

  virtual_network_subnet_id = data.azurerm_subnet.web.id

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    "AZURE_POSTGRESQL_CONNECTIONSTRING" = "dbname=${var.psql_db_name} host=${var.psql_server_address} port=5432 sslmode=true user=${var.psql_user}@${var.psql_server_name} password=${var.psql_pass}"
    "SECRET_KEY"                        = var.app_secret_key
  }
}