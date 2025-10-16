# Networking Module Outputs

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.lab_vnet.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.lab_vnet.id
}

output "bastion_subnet_id" {
  description = "ID of the Bastion subnet"
  value       = azurerm_subnet.bastion.id
}

output "server_subnet_id" {
  description = "ID of the servers subnet"
  value       = azurerm_subnet.servers.id
}

output "workstation_subnet_id" {
  description = "ID of the workstations subnet"
  value       = azurerm_subnet.workstations.id
}

output "database_subnet_id" {
  description = "ID of the database subnet"
  value       = azurerm_subnet.database.id
}

