# Monitoring Module Outputs

output "workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.lab.id
}

output "workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.lab.name
}

output "workspace_customer_id" {
  description = "Customer ID (workspace ID) for agent configuration"
  value       = azurerm_log_analytics_workspace.lab.workspace_id
}

output "workspace_primary_shared_key" {
  description = "Primary shared key for agent configuration"
  value       = azurerm_log_analytics_workspace.lab.primary_shared_key
  sensitive   = true
}

output "data_collection_rule_id" {
  description = "ID of the data collection rule"
  value       = azurerm_monitor_data_collection_rule.vms.id
}

output "action_group_id" {
  description = "ID of the alert action group"
  value       = azurerm_monitor_action_group.email.id
}

