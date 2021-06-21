output "Public_IP_of_the_server" {
  value = azurerm_public_ip.pubip-app.ip_address
}
