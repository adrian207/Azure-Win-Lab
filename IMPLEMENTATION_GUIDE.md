# Phase 2 & 3 Implementation Guide

This guide provides step-by-step instructions for implementing the remaining features from the roadmap.

## ✅ Phase 1 Complete (Implemented)

The following features are now available:

1. ✅ **Remote State Management** - `bootstrap/` directory
2. ✅ **Azure Key Vault Module** - `modules/keyvault/`
3. ✅ **Log Analytics & Monitoring** - `modules/monitoring/`
4. ✅ **Quick Wins** - `Makefile`, `.pre-commit-config.yaml`, `.env.example`

## 🚀 Quick Start with New Features

### Using Remote State

```bash
# 1. Bootstrap state storage (one-time)
cd bootstrap
terraform init
terraform apply
cd ..

# 2. Configure backend (copy from bootstrap output)
# Edit backend.tf (uncomment and fill in storage account name)

# 3. Migrate state
terraform init -migrate-state
```

### Using Key Vault

Add to `main.tf`:
```hcl
module "keyvault" {
  source = "./modules/keyvault"
  
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  environment_name    = var.environment_name
  suffix              = random_string.suffix.result
  
  admin_password      = var.admin_password
  sql_admin_password  = var.sql_admin_password
  
  allowed_subnet_ids  = [module.networking.server_subnet_id]
  tags                = azurerm_resource_group.lab.tags
}
```

### Using Monitoring

Add to `main.tf`:
```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  resource_group_name    = azurerm_resource_group.lab.name
  location               = azurerm_resource_group.lab.location
  environment_name       = var.environment_name
  suffix                 = random_string.suffix.result
  
  alert_email_addresses  = var.alert_email_addresses
  vm_ids                 = concat(
    [for s in module.windows_servers : s.vm_id],
    [module.windows11_workstation.vm_id],
    [module.sql_server.vm_id],
    [for l in module.redhat_linux : l.vm_id]
  )
  
  tags = azurerm_resource_group.lab.tags
}
```

### Using Makefile

```bash
# Format and validate
make fmt validate

# Plan and deploy
make plan
make apply

# Security scan
make security

# Clean up
make destroy
```

---

## 📋 Phase 2: Resilience & Automation

### Feature 5: Automated Backups

**Implementation Steps:**

1. Create `modules/backup/main.tf`:

```hcl
resource "azurerm_recovery_services_vault" "lab" {
  name                = "${var.environment_name}-vault-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  
  soft_delete_enabled = true
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "daily" {
  name                = "daily-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.lab.name
  
  timezone = var.timezone
  
  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  
  retention_daily {
    count = 7
  }
  
  retention_weekly {
    count    = 4
    weekdays = ["Sunday"]
  }
  
  retention_monthly {
    count    = 12
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
}

resource "azurerm_backup_protected_vm" "vms" {
  count               = length(var.vm_ids)
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.lab.name
  source_vm_id        = var.vm_ids[count.index]
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}
```

2. Add to `main.tf`:

```hcl
module "backup" {
  source = "./modules/backup"
  
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  environment_name    = var.environment_name
  suffix              = random_string.suffix.result
  
  vm_ids = concat(
    [for s in module.windows_servers : s.vm_id],
    [module.windows11_workstation.vm_id],
    [module.sql_server.vm_id],
    [for l in module.redhat_linux : l.vm_id]
  )
  
  tags = azurerm_resource_group.lab.tags
}
```

---

### Feature 6: Availability Zones

**Implementation Steps:**

1. Update `modules/windows-server/main.tf`:

```hcl
resource "azurerm_windows_virtual_machine" "server" {
  # Add zone assignment
  zones = var.enable_availability_zones ? [var.zone_number] : null
  
  # Use zone-redundant storage
  os_disk {
    storage_account_type = var.enable_availability_zones ? "Premium_ZRS" : "Premium_LRS"
  }
}
```

2. Add variable to module:

```hcl
variable "enable_availability_zones" {
  description = "Enable availability zones"
  type        = bool
  default     = false
}

variable "zone_number" {
  description = "Availability zone number (1, 2, or 3)"
  type        = number
  default     = 1
  validation {
    condition     = var.zone_number >= 1 && var.zone_number <= 3
    error_message = "Zone number must be 1, 2, or 3."
  }
}
```

3. Update `main.tf` to distribute across zones:

```hcl
module "windows_servers" {
  count = 3
  
  enable_availability_zones = true
  zone_number              = (count.index % 3) + 1  # Distribute: 1, 2, 3
}
```

---

### Feature 7: Active Directory Automation

**Implementation Steps:**

1. Create `scripts/install-adds.ps1`:

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$DomainName = "lab.local",
    
    [Parameter(Mandatory=$true)]
    [string]$SafeModePassword
)

# Install AD DS role
Write-Host "Installing AD DS role..."
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Promote to domain controller
Write-Host "Promoting to domain controller..."
$SafeModePwd = ConvertTo-SecureString $SafeModePassword -AsPlainText -Force

Install-ADDSForest `
  -DomainName $DomainName `
  -DomainNetbiosName ($DomainName.Split('.')[0].ToUpper()) `
  -SafeModeAdministratorPassword $SafeModePwd `
  -InstallDns `
  -Force `
  -NoRebootOnCompletion:$false

# Wait for reboot
Write-Host "Domain controller promotion initiated. System will reboot."
```

2. Create `scripts/join-domain.ps1`:

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$DomainName,
    
    [Parameter(Mandatory=$true)]
    [string]$DomainUser,
    
    [Parameter(Mandatory=$true)]
    [string]$DomainPassword
)

$Password = ConvertTo-SecureString $DomainPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($DomainUser, $Password)

Add-Computer -DomainName $DomainName -Credential $Credential -Restart -Force
```

3. Update `modules/windows-server/main.tf`:

```hcl
resource "azurerm_virtual_machine_extension" "install_adds" {
  count = var.is_domain_controller ? 1 : 0
  
  name                 = "InstallADDS"
  virtual_machine_id   = azurerm_windows_virtual_machine.server.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  
  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -Command \"& { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(file("${path.module}/../../scripts/install-adds.ps1"))}')) | Out-File -FilePath install-adds.ps1; ./install-adds.ps1 -DomainName '${var.domain_name}' -SafeModePassword '${var.dsrm_password}' }\""
  })
}
```

---

### Feature 8: Cost Management & Budgets

**Implementation Steps:**

1. Create `modules/cost-management/main.tf`:

```hcl
resource "azurerm_consumption_budget_resource_group" "monthly" {
  name              = "${var.environment_name}-monthly-budget"
  resource_group_id = var.resource_group_id
  
  amount     = var.monthly_budget_amount
  time_grain = "Monthly"
  
  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
  }
  
  # Alert at 80%
  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    contact_emails = var.notification_emails
    
    contact_roles = [
      "Owner",
      "Contributor"
    ]
  }
  
  # Alert at 100%
  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    contact_emails = var.notification_emails
    
    contact_roles = [
      "Owner",
      "Contributor"
    ]
  }
  
  # Alert at 120% (overspend)
  notification {
    enabled        = true
    threshold      = 120
    operator       = "GreaterThan"
    contact_emails = var.notification_emails
  }
}

# Cost anomaly alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "cost_spike" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0
  
  name                = "${var.environment_name}-cost-spike-alert"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  evaluation_frequency = "PT1H"
  window_duration      = "PT1H"
  scopes               = [var.log_analytics_workspace_id]
  severity             = 2
  
  criteria {
    query = <<-QUERY
      AzureActivity
      | where CategoryValue == "Administrative"
      | where OperationNameValue contains "Microsoft.Compute"
      | summarize count() by bin(TimeGenerated, 1h)
      | where count_ > 10
    QUERY
    
    time_aggregation_method = "Count"
    threshold               = 10
    operator                = "GreaterThan"
  }
  
  action {
    action_groups = var.action_group_ids
  }
}
```

---

## 📋 Phase 3: Advanced Features

### Feature 9: Azure Policy & Governance

Create `modules/governance/main.tf`:

```hcl
# Require specific tags
resource "azurerm_policy_assignment" "require_tags" {
  name                 = "require-mandatory-tags"
  scope                = var.scope_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
  
  parameters = jsonencode({
    tagNames = {
      value = ["Environment", "CostCenter", "Owner"]
    }
  })
}

# Deny public IPs on VMs
resource "azurerm_policy_assignment" "deny_vm_public_ip" {
  name                 = "deny-vm-public-ip"
  scope                = var.scope_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
}

# Require disk encryption
resource "azurerm_policy_assignment" "require_disk_encryption" {
  name                 = "require-disk-encryption"
  scope                = var.scope_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/702dd420-7fcc-42c5-afe8-4026edd20fe0"
}
```

---

### Feature 10: Network Watcher & Traffic Analytics

Create `modules/network-watcher/main.tf`:

```hcl
resource "azurerm_network_watcher" "lab" {
  name                = "${var.environment_name}-nw"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_storage_account" "flow_logs" {
  name                     = "flowlogs${var.suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "azurerm_network_watcher_flow_log" "nsg_flow_log" {
  for_each = var.nsg_ids
  
  network_watcher_name = azurerm_network_watcher.lab.name
  resource_group_name  = var.resource_group_name
  name                 = "flowlog-${each.key}"
  
  network_security_group_id = each.value
  storage_account_id        = azurerm_storage_account.flow_logs.id
  enabled                   = true
  version                   = 2
  
  retention_policy {
    enabled = true
    days    = 7
  }
  
  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = var.location
    workspace_resource_id = var.log_analytics_workspace_id
    interval_in_minutes   = 10
  }
}
```

---

### Feature 11: Docker/Podman Support

Update `modules/redhat-linux/scripts/cloud-init.yaml`:

```yaml
#cloud-config
hostname: ${hostname}

package_update: true
package_upgrade: false

packages:
  - vim
  - git
  - wget
  - curl
  - net-tools
  - bind-utils
  - podman
  - podman-docker
  - docker-compose

runcmd:
  # Enable and start Podman
  - systemctl enable podman
  - systemctl start podman
  
  # Add user to podman group
  - usermod -aG podman azureuser
  
  # Enable Podman socket for Docker compatibility
  - systemctl enable podman.socket
  - systemctl start podman.socket
  
  # Create Docker alias
  - ln -s /usr/bin/podman /usr/local/bin/docker
  
  # Pull common images
  - podman pull docker.io/library/nginx:latest
  - podman pull docker.io/library/redis:latest
  
  # Set timezone
  - timedatectl set-timezone America/New_York
  
  - echo "Container runtime initialized" >> /var/log/cloud-init-custom.log

timezone: America/New_York

final_message: "RHEL VM with Podman ready after $UPTIME seconds"
```

---

## 📊 Implementation Priority

Recommended implementation order:

1. **Week 1**: Backup + Availability Zones (resilience)
2. **Week 2**: AD DS Automation (productivity)
3. **Week 3**: Cost Management (cost control)
4. **Week 4**: Azure Policy + Network Watcher (governance)
5. **Week 5**: Docker/Podman (modern workloads)

---

## ✅ Testing Each Feature

### Test Backup
```bash
# Trigger manual backup
az backup protection backup-now \
  --resource-group <rg-name> \
  --vault-name <vault-name> \
  --container-name <vm-name> \
  --item-name <vm-name>
```

### Test Availability Zones
```bash
# Verify zone assignment
az vm show -g <rg-name> -n <vm-name> --query "zones"
```

### Test Monitoring
```bash
# Query logs
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "Perf | where CounterName == '% Processor Time' | take 10"
```

---

## 🆘 Support

For implementation questions, refer to:
- [Azure Terraform Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Feature Roadmap](FEATURE_ROADMAP.md)
- [Professional README](README.md)

---

**Next Steps**: Pick one feature from Phase 2 and implement it using this guide. Test thoroughly before moving to the next feature.

