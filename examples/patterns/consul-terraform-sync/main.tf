data "terraform_remote_state" "azure" {
  backend = "local"

  config = {
    path = "../../../terraform.tfstate"
  }
}

resource "random_uuid" "consul-initial-acl-token" { }

resource "local_file" "consul-ent-license" {
  content  = var.consul_ent_license
  filename = "${path.root}/consul-ent-license.hclic"
}

module "consul-server" {
  source = "./modules/consul-server"

  deployment_id     = data.terraform_remote_state.azure.outputs.deployment_id
  location          = "Australia Central"
  network_type      = "hub"
  image_name        = var.azure_image_name_consul
  
  initial_acl_token = random_uuid.consul-initial-acl-token.result
}

module "consul-terraform-sync" {
  source = "./modules/consul-terraform-sync"

  deployment_id         = data.terraform_remote_state.azure.outputs.deployment_id
  location              = "Australia Central"
  network_type          = "hub"
  image_name            = var.azure_image_name_consul_terraform_sync

  consul_server_address = module.consul-server.private_ip

  terraform_cloud_host  = var.terraform_cloud_host
  terraform_cloud_org   = var.terraform_cloud_org
  terraform_cloud_token = var.terraform_cloud_token

  depends_on = [
    module.consul-server
  ]
}