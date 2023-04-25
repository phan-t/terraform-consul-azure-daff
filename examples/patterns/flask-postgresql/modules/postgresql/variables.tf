variable "landing_zone_id" {
  description = "Landing zone id"
  type        = string
}

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

variable "source_subnet" {
  description = "Source subnet"
  type        = string
}