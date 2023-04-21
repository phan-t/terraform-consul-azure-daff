// generic variables

variable "deployment_name" {
  description = "Deployment name, used to prefix resources"
  type        = string
  default     = "test"
}

// HashiCorp identification variables

variable "owner" {
  description = "Resource owner identified using an email address"
  type        = string
  default     = ""
}

variable "my_ip" {
  type        = string
  default     = ""
}

// azure variables