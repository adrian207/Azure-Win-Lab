# Windows Server Module Outputs

output "vm_name" {
  description = "Name of the VM"
  value       = azurerm_windows_virtual_machine.server.name
}

output "vm_id" {
  description = "ID of the VM"
  value       = azurerm_windows_virtual_machine.server.id
}

output "private_ip_address" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.server.private_ip_address
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.server.id
}

