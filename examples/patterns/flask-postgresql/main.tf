data "terraform_remote_state" "azure" {
  backend = "local"

  config = {
    path = "../../../terraform.tfstate"
  }
}

data "terraform_remote_state" "consul-terraform-sync" {
  backend = "local"

  config = {
    path = "../consul-terraform-sync/terraform.tfstate"
  }
}

locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}


module "web-app" {
  source = "./modules/web-app"

  landing_zone_id     = data.terraform_remote_state.azure.outputs.deployment_id
  deployment_id       = local.deployment_id
  location            = "Australia East"
  network_type        = "spoke"
  psql_server_address = module.postgresql.private_endpoint_ip
  psql_server_name    = module.postgresql.name
  psql_db_name        = module.postgresql.db_name
  psql_user           = module.postgresql.admin_user
  psql_pass           = module.postgresql.admin_pass
}

module "postgresql" {
  source = "./modules/postgresql"
  providers = {
    consul = consul
   }

  landing_zone_id = data.terraform_remote_state.azure.outputs.deployment_id
  deployment_id   = local.deployment_id
  location        = "Australia Southeast"
  network_type    = "spoke"
  source_subnet   = module.web-app.subnet
}

# module "flask" {
#   source = "./modules/flask"

#   web_app_id = module.web-app.id
#   repo_url   = "https://github.com/phan-t/msdocs-flask-postgresql-sample-app"
# }