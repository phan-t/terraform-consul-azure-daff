variable "deployment_id" {
  description = "Deployment id"
  type        = string
}

variable "owner" {
  description = "Resource owner identified using an email address"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "network_type" {
  description = "Network type, one of 'hub' or 'spoke'."
  type        = string
  validation {
    condition = var.network_type == "hub" || var.network_type == "spoke"
    error_message = "Value must be one of 'hub' or 'spoke'."
  }
}

variable "name_prefix" {
  type        = string
}

variable "address_space" {
  type        = string
}

variable "subnet_functions" {
  type        = list(string)
}

variable "hub_rg_name" {
  type        = string
  default     = ""
}

variable "hub_vnet_name" {
  type        = string
  default     = ""
}

variable "peer_ip" {
  type        = string
  default     = ""
}

variable "peer_vnet_id" {
  type        = string
  default     = ""
}

variable "my_ip" {
  type        = string
  default     = ""
}