variable "services" {
  description = "Consul services monitored by Consul-Terraform-Sync"
  type = map(
    object({
      id        = string
      name      = string
      kind      = string
      address   = string
      port      = number
      meta      = map(string)
      tags      = list(string)
      namespace = string
      status    = string

      node                  = string
      node_id               = string
      node_address          = string
      node_datacenter       = string
      node_tagged_addresses = map(string)
      node_meta             = map(string)

      cts_user_defined_meta = map(string)
    })
  )
}

locals {
  service_name         = [for name, attributes in var.services : attributes.name]
  service_ip_addresses = [for ip, attributes in var.services : attributes.address]
  service_ports        = [for port, attributes in var.services : attributes.port]

  meta_attributes = {
    for name, attributes in {
      for id, service in var.services : service.name => service.meta...
    } : name => merge(attributes...)
  }
}