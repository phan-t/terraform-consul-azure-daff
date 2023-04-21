output "public_ip" {
  description = "Public ip address"
  value = azurerm_linux_virtual_machine.consul-server.public_ip_address
}

output "private_ip" {
  description = "Private ip address"
  value       = azurerm_linux_virtual_machine.consul-server.private_ip_address
}