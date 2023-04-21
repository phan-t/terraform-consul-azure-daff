variable "deployment_name" {
  description = "Deployment name, used to prefix resources"
  type        = string
}

variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "image_name_consul_terraform_sync" {
  description = "Image name"
  type        = string
}

variable "server_private_ip" {
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