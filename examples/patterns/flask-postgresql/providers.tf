terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.52.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.16.2"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "consul" {
  address        = "${data.terraform_remote_state.consul-terraform-sync.outputs.consul_server_public_ip}:8500"
  scheme         = "http"
  datacenter     = "${join("-", slice(split("-", data.terraform_remote_state.azure.outputs.deployment_id), 0, 2))}-azure"
  token          = data.terraform_remote_state.consul-terraform-sync.outputs.consul_initial_acl_token
}
