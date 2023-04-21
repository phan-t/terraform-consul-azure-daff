variable "deployment_name" {
  description = "Deployment name, used to prefix resources"
  type        = string
}

variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "image_name_consul" {
  description = "Image name"
  type        = string
}

variable "initial_acl_token" {
  description = "Initial acl token"
  type        = string
}