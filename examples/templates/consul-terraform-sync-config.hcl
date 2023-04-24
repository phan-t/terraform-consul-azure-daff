## Global Config
log_level = "INFO"
working_dir = "/opt/consul-terraform-sync"
port = 8558

syslog {}

buffer_period {
  enabled = true
  min = "5s"
  max = "20s"
}

license {
  path = "/opt/consul/bin/consul-ent-license.hclic"
  auto_retrieval {
    enabled = false
  }
}


# Consul Block
consul {
  address = "localhost:8500"
}

# Driver block
driver "terraform-cloud" {
  hostname     = "${host}"
  organization = "${org}"
  token        = "${token}"
}


# Task Block

task {
  name        = "learn-cts-example"
  module      = "findkim/print/cts"

  condition "services" {
    names = ["postgresql"]
  }
}

// task {
//  name        = "learn-cts-example"
//  description = "Example task with two services"
//  module      = "findkim/print/cts"
//  version     = "0.1.0"
//  services    = ["fake-service"]
// }

// task {
//  name        = "terraform-azurerm-firewall-nia"
//  module      = "github.com/phan-t/terraform-azurerm-firewall-nia"
//  services    = ["fake-service"]
// }