output "private_endpoint_ip" {
  value = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}

output "name" {
  value = azurerm_postgresql_server.this.name
}

output "db_name" {
  value = azurerm_postgresql_database.this.name
}

output "admin_user" {
  value = azurerm_postgresql_server.this.administrator_login
}

output "admin_pass" {
  value = azurerm_postgresql_server.this.administrator_login_password
}