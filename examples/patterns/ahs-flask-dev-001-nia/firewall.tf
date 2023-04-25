resource "azurerm_firewall_network_rule_collection" "this" {
  for_each = local.meta_attributes

  name                = each.value.deployment_id
  azure_firewall_name = "${each.value.landing_zone_id}-hub-canberra-afw"
  resource_group_name = "${each.value.landing_zone_id}-hub-canberra-rg"
  priority            = 100
  action              = "Allow"

  rule {
    name = "postgresql"

    source_addresses = ["${each.value.source_subnet}"]
    destination_ports = local.service_ports
    destination_addresses = local.service_ip_addresses
    protocols = ["TCP"]
  }
}