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

variable "psql_server_address" {
  description = "Postresql server address"
  type        = string
}

variable "psql_server_name" {
  description = "Postgresql server name"
  type        = string
}

variable "psql_db_name" {
  description = "Postgresql database name"
  type        = string
}

variable "psql_user" {
  description = "Postgresql username"
  type        = string
}

variable "psql_pass" {
  description = "Postgresql password"
  type        = string
}

variable "app_secret_key" {
  description = "Application secret key"
  type        = string
  default     = "95e53821243e2d782122c0790c17c4c6a135cec21ac40dc4f02f02ca04c124d0"
}