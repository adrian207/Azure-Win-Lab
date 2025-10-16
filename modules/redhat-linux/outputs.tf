# Red Hat Linux Module Outputs

output "vm_name" {
  description = "Name of the VM"
  value       = azurerm_linux_virtual_machine.linux.name
}

output "vm_id" {
  description = "ID of the VM"
  value       = azurerm_linux_virtual_machine.linux.id
}

output "private_ip_address" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.linux.private_ip_address
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.linux.id
}

output "admin_username" {
  description = "Admin username for SSH access"
  value       = azurerm_linux_virtual_machine.linux.admin_username
}

