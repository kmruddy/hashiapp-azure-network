output "catapp_fqdn" {
  value = azurerm_public_ip.catapp_pip.fqdn
}

output "tfver" {
  value = var.tfver
}
