output "happ_fqdn" {
  value = azurerm_public_ip.happ_pip.fqdn
}

output "tfver" {
  value = var.tfver
}
