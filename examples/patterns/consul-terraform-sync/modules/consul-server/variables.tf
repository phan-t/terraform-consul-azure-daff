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

variable "initial_acl_token" {
  description = "Initial acl token"
  type        = string
}