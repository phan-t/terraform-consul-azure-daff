packer {
  required_version = ">= 1.5.4"
}

variable "azure_region" {
  type    = string
  default = "australiacentral"
}

variable "azure_rg_name" {
  type    = string
}

variable "consul_version" {
  type    = string
  default = "1.15.1+ent"
}

variable "consul_download_url" {
  type    = string
  default = "${env("CONSUL_DOWNLOAD_URL")}"
}

source "azure-arm" "ubuntu20-arm" {
  use_azure_cli_auth                = true
  image_offer                       = "0001-com-ubuntu-server-focal"
  image_publisher                   = "Canonical"
  image_sku                         = "20_04-lts-gen2"
  location                          = "${var.azure_region}"
  managed_image_name                = "consul-ubuntu-${formatdate("YYYYMMDDhhmm", timestamp())}"
  managed_image_resource_group_name = "${var.azure_rg_name}"
  os_type                           = "Linux"
  vm_size                           = "Standard_DS2_v2"
  azure_tags = {
    application     = "consul"
    consul_version  = "${var.consul_version}"
    owner           = "tphan@hashicorp.com"
    packer_source   = "https://github.com/phan-t/terraform-consul-azure-daff/blob/master/examples/images/consul/consul.pkr.hcl"
  }
}

build {
  sources = ["source.azure-arm.ubuntu20-arm"]

  provisioner "shell" {
    inline = ["mkdir -p /tmp/terraform-consul-azure-daff/"]
  }

  provisioner "shell" {
    inline       = ["git clone https://github.com/phan-t/terraform-consul-azure-daff.git /tmp/terraform-consul-azure-daff"]
    pause_before = "30s"
  }

  provisioner "shell" {
    inline       = ["if test -n \"${var.consul_download_url}\"; then", "/tmp/terraform-consul-azure-daff/examples/scripts/install-consul --download-url ${var.consul_download_url};", "else", "/tmp/terraform-consul-azure-daff/examples/scripts/install-consul --version ${var.consul_version};", "fi"]
    pause_before = "30s"
  }
  
  provisioner "shell" {
    inline       = ["/tmp/terraform-consul-azure-daff/examples/scripts/setup-systemd-resolved"]
    pause_before = "30s"
  }
}