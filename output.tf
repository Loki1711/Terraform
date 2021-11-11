
output "RG-output" {
  value = azurerm_resource_group.RG.id
}

output "PIP-output" {
  value = azurerm_public_ip.PIP.ip_address
}
