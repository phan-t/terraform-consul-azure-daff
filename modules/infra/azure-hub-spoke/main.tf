locals {
  prefix = "${var.deployment_id}-${var.name_prefix}"
  friendly_location = {
    "Australia Central"   = "canberra",
    "Australia East"      = "sydney",
    "Australia Southeast" = "melbourne"
  }
  subnet_functions = [ for v in var.subnet_functions: lower(v) ]
}

resource "azurerm_resource_group" "this" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags = {
    "DoNotDelete" = "True"
    "owner"       = var.owner
    "location"  = lookup(local.friendly_location, var.location)
  }
}

resource "azurerm_virtual_network" "this" {
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "${local.prefix}-vnet"
  address_space       = [var.address_space]
  tags = {
    "location" = lookup(local.friendly_location, var.location)
  }
}

resource "azurerm_subnet" "this" {
  for_each = toset(local.subnet_functions)

  name     = each.value == "firewall" ? "AzureFirewallSubnet" : "${each.value}-snet"
  address_prefixes = [
    cidrsubnet(azurerm_virtual_network.this.address_space[0], 8, index(local.subnet_functions, each.value))
  ]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name

  dynamic "delegation" {
    for_each = each.value == "web" ? [1] : []

    content {
      name = "webapp"

      service_delegation {
        name = "Microsoft.Web/serverFarms"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action",
        ]
      }
    }
  }
}

resource "azurerm_public_ip" "this" {
  count = contains(local.subnet_functions, "firewall") ? 1 : 0

  name                = "${local.prefix}-firewall-ip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "this" {
  count = contains(local.subnet_functions, "firewall") ? 1: 0

  name                = "${local.prefix}-firewall"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.this["firewall"].id
    public_ip_address_id = azurerm_public_ip.this[0].id
  }
}

resource "azurerm_route_table" "this" {
  count = var.network_type == "spoke" ? 1 : 0

  name                          = "${local.prefix}-rt"
  location                      = azurerm_virtual_network.this.location
  resource_group_name           = azurerm_resource_group.this.name
  disable_bgp_route_propagation = false

  route {
    name           = "default_route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = var.peer_ip
  }
}

resource "azurerm_virtual_network_peering" "spoke-hub" {
  count = var.network_type == "spoke" ? 1 : 0

  name                         = "${local.prefix}-peer"
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = var.peer_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "hub-spoke" {
  count = var.network_type == "spoke" ? 1 : 0

  name                         = "${local.prefix}-peer"
  resource_group_name          = var.hub_rg_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.this.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}