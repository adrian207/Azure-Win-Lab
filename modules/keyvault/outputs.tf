# Key Vault Module Outputs

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.lab.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.lab.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.lab.vault_uri
}

output "admin_password_secret_id" {
  description = "Secret ID for admin password"
  value       = try(azurerm_key_vault_secret.admin_password[0].id, "")
}

output "sql_admin_password_secret_id" {
  description = "Secret ID for SQL admin password"
  value       = try(azurerm_key_vault_secret.sql_admin_password[0].id, "")
}

output "linux_admin_password_secret_id" {
  description = "Secret ID for Linux admin password"
  value       = try(azurerm_key_vault_secret.linux_admin_password[0].id, "")
}

