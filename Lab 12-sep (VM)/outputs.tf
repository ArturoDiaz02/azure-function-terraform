output public_ip_address {
  value       = azurerm_linux_virtual_machine.VM.public_ip_address
  sensitive   = false
  description = "description"
}
