output "rg_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  value = { for v in azurerm_subnet.this: v.name => v.id }
}

output "afw_private_ip" {
  value = contains(local.subnet_functions, "firewall") ? azurerm_firewall.this[0].ip_configuration[0].private_ip_address : "No firewall created"
}