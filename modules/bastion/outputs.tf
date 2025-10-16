# Bastion Module Outputs

output "bastion_name" {
  description = "Name of the Azure Bastion host"
  value       = azurerm_bastion_host.lab.name
}

output "bastion_id" {
  description = "ID of the Azure Bastion host"
  value       = azurerm_bastion_host.lab.id
}

output "bastion_dns_name" {
  description = "DNS name of the Azure Bastion host"
  value       = azurerm_bastion_host.lab.dns_name
}

