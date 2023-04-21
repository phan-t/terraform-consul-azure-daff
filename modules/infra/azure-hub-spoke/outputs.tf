output "hub_firewall_private_ip" {
  value = contains(local.subnet_functions, "firewall") ? azurerm_firewall.this[0].ip_configuration[0].private_ip_address : "No firewall created"
}

output "hub_virtual_network_id" {
  value = azurerm_virtual_network.this.id
}

output "hub_virtual_network_name" {
  value = azurerm_virtual_network.this.name
}

output "management_resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "management_resource_group_location" {
  value = azurerm_resource_group.this.location
}

output "subnet_ids" {
  value = { for v in azurerm_subnet.this: v.name => v.id }
}