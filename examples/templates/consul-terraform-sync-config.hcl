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

// task {
//   name        = "learn-cts-example"
//   module      = "findkim/print/cts"

//   condition "services" {
//     regexp = "flask*"
//     filter = "Service.Tags contains \"postgresql\""
//   }
// }

task {
  name        = "ahs-flask-dev-001-nia"
  module      = "github.com/phan-t/terraform-consul-azure-daff/examples/patterns/ahs-flask-dev-001-nia"

  condition "services" {
    regexp = "flask*"
    filter = "Service.Tags contains \"postgresql\""
  }
}