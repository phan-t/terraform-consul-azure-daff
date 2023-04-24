output "id" {
  value = azurerm_linux_web_app.this.id
}

output "public_url" {
  value = "https://${azurerm_linux_web_app.this.default_hostname}"
}