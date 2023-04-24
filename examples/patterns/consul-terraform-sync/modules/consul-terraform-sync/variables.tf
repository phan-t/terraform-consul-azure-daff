variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "network_type" {
  description = "Network type, one of 'hub' or 'spoke'."
  type        = string
}

variable "image_name" {
  description = "Image name"
  type        = string
}

variable "consul_server_address" {
  description = "Consul servers private ip"
  type        = string
}

variable "terraform_cloud_host" {
  description = "Terraform cloud host"
  type        = string
}

variable "terraform_cloud_org" {
  description = "Terraform cloud organisation"
  type        = string
}

variable "terraform_cloud_token" {
  description = "Terraform cloud token"
  type        = string
}