# Azure Key Vault Module
# Centralized secret management for VM credentials and sensitive data

data "azurerm_client_config" "current" {}

# Key Vault
resource "azurerm_key_vault" "lab" {
  name                = "${var.environment_name}-kv-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  
  # Security settings
  enabled_for_deployment          = true  # VMs can retrieve secrets
  enabled_for_template_deployment = true  # ARM templates can retrieve secrets
  purge_protection_enabled        = true  # Prevent permanent deletion
  soft_delete_retention_days      = 7
  
  # Network restrictions
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    
    # Allow access from VNet (optional - can be more restrictive)
    virtual_network_subnet_ids = var.allowed_subnet_ids
    
    # Allow current deployment IP
    ip_rules = var.allowed_ip_addresses
  }
  
  tags = var.tags
}

# Access Policy for Terraform Service Principal
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.lab.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]
  
  certificate_permissions = [
    "Get",
    "List",
    "Create",
    "Delete"
  ]
  
  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete"
  ]
}

# Store VM Administrator Password
resource "azurerm_key_vault_secret" "admin_password" {
  count = var.admin_password != "" ? 1 : 0
  
  name         = "vm-admin-password"
  value        = var.admin_password
  key_vault_id = azurerm_key_vault.lab.id
  
  content_type = "password"
  
  tags = merge(var.tags, {
    Purpose = "VM Administrator Password"
  })
  
  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Store SQL Admin Password
resource "azurerm_key_vault_secret" "sql_admin_password" {
  count = var.sql_admin_password != "" ? 1 : 0
  
  name         = "sql-admin-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.lab.id
  
  content_type = "password"
  
  tags = merge(var.tags, {
    Purpose = "SQL Server Administrator Password"
  })
  
  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Store Linux Admin Password
resource "azurerm_key_vault_secret" "linux_admin_password" {
  count = var.linux_admin_password != "" ? 1 : 0
  
  name         = "linux-admin-password"
  value        = var.linux_admin_password
  key_vault_id = azurerm_key_vault.lab.id
  
  content_type = "password"
  
  tags = merge(var.tags, {
    Purpose = "Linux Administrator Password"
  })
  
  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Store SSH Private Key (if provided)
resource "azurerm_key_vault_secret" "ssh_private_key" {
  count = var.ssh_private_key != "" ? 1 : 0
  
  name         = "ssh-private-key"
  value        = var.ssh_private_key
  key_vault_id = azurerm_key_vault.lab.id
  
  content_type = "application/x-pem-file"
  
  tags = merge(var.tags, {
    Purpose = "Linux SSH Private Key"
  })
  
  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Diagnostic Settings for Audit Logging
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0
  
  name                       = "keyvault-diagnostics"
  target_resource_id         = azurerm_key_vault.lab.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  enabled_log {
    category = "AuditEvent"
  }
  
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

