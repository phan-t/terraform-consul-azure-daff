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

  location         = "Australia Central"

  network_type     = "hub"
  address_space    = "10.0.0.0/16"
  subnet_functions = [
    "firewall",
    "gateway",
    "management"
  ]
}

module "spoke-sydney" {
  source = "./modules/infra/azure-hub-spoke"

  deployment_id    = local.deployment_id
  owner            = var.owner

  location         = "Australia East"

  network_type     = "spoke"
  address_space    = "10.1.0.0/16"
  subnet_functions = [
    "web",
    "test"
  ]

  hub_rg_name        = module.hub-canberra.rg_name
  hub_vnet_name      = module.hub-canberra.vnet_name
  hub_afw_private_ip = module.hub-canberra.afw_private_ip
  peer_vnet_id       = module.hub-canberra.vnet_id
}

module "spoke-melbourne" {
  source = "./modules/infra/azure-hub-spoke"

  deployment_id    = local.deployment_id
  owner            = var.owner

  location         = "Australia Southeast"

  network_type     = "spoke"
  address_space    = "10.2.0.0/16"
  subnet_functions = [
    "database",
    "test"
  ]

  hub_rg_name        = module.hub-canberra.rg_name
  hub_vnet_name      = module.hub-canberra.vnet_name
  hub_afw_private_ip = module.hub-canberra.afw_private_ip
  peer_vnet_id       = module.hub-canberra.vnet_id
}