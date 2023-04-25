output "id" {
  value = azurerm_linux_web_app.this.id
}

output "subnet" {
  value = data.azurerm_subnet.web.address_prefixes[0]
}

output "public_url" {
  value = "https://${azurerm_linux_web_app.this.default_hostname}"
}