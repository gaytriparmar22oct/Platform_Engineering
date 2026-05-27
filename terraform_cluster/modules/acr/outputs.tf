output "acr_id" {
  value = azurerm_container_registry.this.id
}

output "acr_name" {
  value = azurerm_container_registry.this.name
}

output "login_server" {
  description = "ACR login server, e.g. acridpdev.azurecr.io. Use as image.repository prefix."
  value       = azurerm_container_registry.this.login_server
}
