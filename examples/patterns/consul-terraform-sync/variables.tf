// hashicorp self-managed consul variables

variable "consul_ent_license" {
  description = "Consul enterprise license"
  type        = string
  default     = ""
}

variable "azure_image_name_consul" {
  description = "Image name"
  type        = string
}

// hashicorp self-managed consul-terraform-sync variables

variable "azure_image_name_consul_terraform_sync" {
  description = "Image name"
  type        = string
}

//hashicorp terraform cloud variables

variable "terraform_cloud_host" {
  description = "Terraform cloud host"
  type        = string
  default     = "https://app.terraform.io"
}

variable "terraform_cloud_org" {
  description = "Terraform cloud organisation"
  type        = string
}

variable "terraform_cloud_token" {
  description = "Terraform cloud token"
  type        = string
}