output "Public IP of the server" {
  value = azurerm_public_ip.pubip-app.ip_address
}
