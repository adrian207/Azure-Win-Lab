# SQL Server Module Outputs

output "vm_name" {
  description = "Name of the VM"
  value       = azurerm_windows_virtual_machine.sql.name
}

output "vm_id" {
  description = "ID of the VM"
  value       = azurerm_windows_virtual_machine.sql.id
}

output "private_ip_address" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.sql.private_ip_address
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.sql.id
}

output "sql_instance_name" {
  description = "SQL instance name"
  value       = azurerm_mssql_virtual_machine.sql.id
}

