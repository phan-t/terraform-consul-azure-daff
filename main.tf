locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}


module "hub-canberra" {
  source = "./modules/infra/azure-hub-spoke"

  deployment_id    = local.deployment_id
  owner            = var.owner
  my_ip            = var.my_ip

  location         = "Australia Central"

  network_type     = "hub"
  name_prefix      = "hub-canberra"
  address_space    = "10.0.0.0/16"
  subnet_functions = [
    "Firewall",
    "Management",
    "Gateway"
  ]
}

module "spoke-sydney" {
  source = "./modules/infra/azure-hub-spoke"

  deployment_id    = local.deployment_id
  owner            = var.owner

  location         = "Australia East"

  network_type     = "spoke"
  name_prefix      = "spoke-sydney"
  address_space    = "10.1.0.0/16"
  subnet_functions = [
    "web"
  ]

  hub_rg_name      = module.hub-canberra.management_resource_group_name
  hub_vnet_name    = module.hub-canberra.hub_virtual_network_name
  peer_ip          = module.hub-canberra.hub_firewall_private_ip
  peer_vnet_id     = module.hub-canberra.hub_virtual_network_id
}

module "spoke-melbourne" {
  source = "./modules/infra/azure-hub-spoke"

  deployment_id    = local.deployment_id
  owner            = var.owner

  location         = "Australia Southeast"

  network_type     = "spoke"
  name_prefix      = "spoke-melbourne"
  address_space    = "10.2.0.0/16"
  subnet_functions = [
    "database"
  ]

  hub_rg_name      = module.hub-canberra.management_resource_group_name
  hub_vnet_name    = module.hub-canberra.hub_virtual_network_name
  peer_ip          = module.hub-canberra.hub_firewall_private_ip
  peer_vnet_id     = module.hub-canberra.hub_virtual_network_id
}