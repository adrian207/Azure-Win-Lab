# Azure Hybrid Infrastructure Platform

<div align="center">

**Enterprise-Grade Infrastructure as Code for Hybrid Cloud Environments**

[![Terraform](https://img.shields.io/badge/Terraform-≥1.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.1-blue.svg)](https://github.com/adrian207/Azure-Win-Lab/releases)

</div>

---

## Executive Summary

> **💡 NEW - Cost-Optimized Alternative Available**  
> Looking to save 74% on costs? Check out our [`hybrid-docker`](../../tree/hybrid-docker) branch that uses Docker containers instead of VMs ($70/month vs $270/month). See [BRANCH_GUIDE.md](BRANCH_GUIDE.md) for detailed comparison.

This Infrastructure as Code (IaC) solution delivers a production-ready, hybrid cloud environment on Microsoft Azure, combining Windows Server, Linux, and database workloads in a secure, segmented, and highly automated architecture. Built with Terraform, it enables rapid deployment of complex multi-OS infrastructures for testing, development, demonstrations, and proof-of-concept scenarios.

**Key Value Propositions:**
- **Zero-Touch Deployment**: Complete infrastructure provisioning in <20 minutes
- **Security-First Design**: Azure Bastion-only access, network segmentation, zero public IP exposure on workloads
- **Cost Optimization**: Automated shutdown schedules reduce operational costs by ~65%
- **Enterprise Scalability**: Modular architecture enables rapid environment replication
- **Hybrid Capability**: Native Windows and Linux support for modern application stacks

---

## Table of Contents

- [Architecture](#architecture)
- [Security Posture](#security-posture)
- [Infrastructure Components](#infrastructure-components)
- [Prerequisites](#prerequisites)
- [Deployment](#deployment)
- [Configuration Management](#configuration-management)
- [Security Analysis](#security-analysis)
- [Performance Optimization](#performance-optimization)
- [Cost Management](#cost-management)
- [Operations Guide](#operations-guide)
- [Compliance & Governance](#compliance--governance)
- [Troubleshooting](#troubleshooting)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [Support](#support)

---

## Architecture

### Infrastructure Overview

This solution deploys a complete hybrid infrastructure environment consisting of seven virtual machines across five network segments, managed through a centralized Azure Bastion service for secure administrative access.

```
┌────────────────────────────────────────────────────────────────────────┐
│                    Azure Resource Group                                 │
│                    Location: Configurable (Default: East US)           │
├────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐ │
│  │              Azure Virtual Network (10.0.0.0/16)                 │ │
│  ├──────────────────────────────────────────────────────────────────┤ │
│  │                                                                   │ │
│  │  Management Layer                                                 │ │
│  │  ┌─────────────────────────────┐                                │ │
│  │  │  Azure Bastion Subnet       │  Secure RDP/SSH Gateway       │ │
│  │  │  10.0.1.0/26                │  - Standard SKU               │ │
│  │  │  ┌─────────────────────┐    │  - Static Public IP           │ │
│  │  │  │  Azure Bastion Host │    │  - TLS 1.2+ Enforced         │ │
│  │  │  └─────────────────────┘    │                                │ │
│  │  └─────────────────────────────┘                                │ │
│  │                                                                   │ │
│  │  Compute Layer                                                    │ │
│  │  ┌─────────────────────────────┐                                │ │
│  │  │  Server Subnet (10.0.2.0/24)│                                │ │
│  │  │  ┌────────┐ ┌────────┐ ┌────────┐                          │ │
│  │  │  │  DC1   │ │  DC2   │ │  DC3   │  Windows Server 2025     │ │
│  │  │  │ D2s_v3 │ │ D2s_v3 │ │ D2s_v3 │  Datacenter Edition      │ │
│  │  │  └────────┘ └────────┘ └────────┘                          │ │
│  │  └─────────────────────────────┘                                │ │
│  │                                                                   │ │
│  │  ┌─────────────────────────────┐                                │ │
│  │  │  Workstation Subnet         │                                │ │
│  │  │  (10.0.3.0/24)              │                                │ │
│  │  │  ┌────────┐                 │  Windows 11 Enterprise        │ │
│  │  │  │  WS01  │                 │  23H2                          │ │
│  │  │  │ D2s_v3 │                 │                                │ │
│  │  │  └────────┘                 │                                │ │
│  │  └─────────────────────────────┘                                │ │
│  │                                                                   │ │
│  │  Data Layer                                                       │ │
│  │  ┌─────────────────────────────┐                                │ │
│  │  │  Database Subnet            │                                │ │
│  │  │  (10.0.4.0/24)              │                                │ │
│  │  │  ┌────────┐                 │  SQL Server 2022              │ │
│  │  │  │ SQL01  │                 │  Developer Edition            │ │
│  │  │  │ D4s_v3 │                 │  - 256GB Data Disk            │ │
│  │  │  └────────┘                 │  - 128GB Log Disk             │ │
│  │  └─────────────────────────────┘  - SQL IaaS Extension        │ │
│  │                                                                   │ │
│  │  Linux Layer                                                      │ │
│  │  ┌─────────────────────────────┐                                │ │
│  │  │  Linux Subnet (10.0.5.0/24) │                                │ │
│  │  │  ┌────────┐ ┌────────┐      │  Red Hat Enterprise Linux     │ │
│  │  │  │ RHEL1  │ │ RHEL2  │      │  9.4                          │ │
│  │  │  │ D2s_v3 │ │ D2s_v3 │      │  - Cloud-init provisioning    │ │
│  │  │  └────────┘ └────────┘      │  - SSH key authentication     │ │
│  │  └─────────────────────────────┘                                │ │
│  └──────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  Security Layer (Network Security Groups)                             │
│  • Servers NSG: RDP, WinRM, SMB, AD DS protocols                      │
│  • Workstation NSG: RDP only                                           │
│  • Database NSG: RDP, SQL Server (1433)                                │
│  • Linux NSG: SSH, HTTP, HTTPS                                         │
│  • All traffic scoped to VirtualNetwork only                          │
└────────────────────────────────────────────────────────────────────────┘
```

### Design Principles

This infrastructure adheres to the following architectural principles:

1. **Defense in Depth**: Multiple security layers including network segmentation, NSG rules, and Bastion-only access
2. **Least Privilege**: Minimal required permissions with network-scoped security rules
3. **Immutable Infrastructure**: Declarative infrastructure enabling version control and repeatability
4. **Modularity**: Reusable components enabling rapid environment provisioning
5. **Cost Optimization**: Auto-shutdown schedules and right-sized compute resources
6. **Observability**: Boot diagnostics and structured tagging for monitoring and cost allocation

---

## Security Posture

### Security Architecture

This solution implements a **Zero Trust Network Architecture** with the following security controls:

#### Network Security
| Control | Implementation | Benefit |
|---------|----------------|---------|
| **Zero Public IP Exposure** | No public IPs on VMs; Bastion-only access | Eliminates direct internet exposure of workloads |
| **Network Segmentation** | 5 isolated subnets with dedicated NSGs | Contains lateral movement and blast radius |
| **Service Tags** | `VirtualNetwork` source restrictions | Prevents external access while enabling internal communication |
| **Azure Bastion** | Dedicated management subnet with Standard SKU | PCI-DSS compliant remote access |

#### Identity & Access Management
| Control | Implementation | Benefit |
|---------|----------------|---------|
| **SSH Key Authentication** | Public key infrastructure for Linux hosts | Eliminates password-based attacks |
| **Sensitive Variable Handling** | Terraform `sensitive = true` for credentials | Prevents accidental exposure in logs/outputs |
| **Unique Naming** | Random suffix generation | Prevents resource conflicts and enumeration attacks |

#### Data Protection
| Control | Implementation | Benefit |
|---------|----------------|---------|
| **Encryption at Rest** | Premium SSD with Azure Storage encryption | Meets compliance requirements (256-bit AES) |
| **Separation of Duties** | Isolated database subnet | Protects sensitive data from compromise |
| **Managed Disks** | Azure-managed disk lifecycle | Secure deletion and key rotation |

#### Compliance Alignment
- ✅ **CIS Microsoft Azure Foundations Benchmark**: Network segmentation, access controls
- ✅ **NIST Cybersecurity Framework**: Identity management, protective technologies
- ✅ **PCI-DSS**: Network segmentation, access control, encryption

### Security Best Practices Implemented

```terraform
# Example: NSG rules scope to VirtualNetwork only
security_rule {
  source_address_prefix      = "VirtualNetwork"  # Not "Internet" or "*"
  destination_address_prefix = "*"
  # Minimizes attack surface
}

# Example: Sensitive variable protection
variable "admin_password" {
  type      = string
  sensitive = true  # Prevents exposure in Terraform outputs
}

# Example: No public IPs on VMs
# Virtual machines only use private IPs within VNet
# Access controlled exclusively through Azure Bastion
```

---

## Infrastructure Components

### Virtual Machine Specifications

#### Windows Server 2025 Datacenter (3 instances)
- **Purpose**: Domain controllers, application servers, clustering scenarios
- **SKU**: `2025-datacenter-azure-edition`
- **Default Size**: Standard_D2s_v3 (2 vCPU, 8 GB RAM)
- **Storage**: Premium SSD (P10)
- **Patch Management**: AutomaticByPlatform
- **High Availability**: Deploy across availability zones (optional configuration)

#### Windows 11 Enterprise (1 instance)
- **Purpose**: Client workstation for management and testing
- **SKU**: `win11-23h2-ent`
- **Default Size**: Standard_D2s_v3 (2 vCPU, 8 GB RAM)
- **Storage**: Premium SSD (P10)
- **Use Cases**: Administrative tasks, client-server testing, application compatibility

#### SQL Server 2022 Developer (1 instance)
- **Purpose**: Relational database engine
- **SKU**: `sql2022-ws2022 / sqldev-gen2`
- **Default Size**: Standard_D4s_v3 (4 vCPU, 16 GB RAM)
- **Storage Configuration**:
  - OS Disk: Premium SSD (P10)
  - Data Disk: 256 GB Premium SSD (P15) - Read-Only caching
  - Log Disk: 128 GB Premium SSD (P10) - No caching
- **SQL IaaS Extension**: Automated patching, backup configuration
- **Data Paths**: `F:\SQLData`, `G:\SQLLog`

#### Red Hat Enterprise Linux 9.4 (2 instances)
- **Purpose**: Linux workloads, containerization, web services
- **SKU**: `RHEL 9_4`
- **Default Size**: Standard_D2s_v3 (2 vCPU, 8 GB RAM)
- **Authentication**: SSH key (preferred) or password fallback
- **Provisioning**: Cloud-init with base package installation
- **Installed Packages**: vim, git, wget, curl, net-tools, bind-utils

#### Azure Bastion (Standard SKU)
- **Purpose**: Secure RDP and SSH gateway
- **Deployment**: Dedicated AzureBastionSubnet (/26 minimum)
- **Public IP**: Static Standard SKU
- **Connectivity**: TLS-encrypted connections to VMs
- **Protocols**: RDP (3389), SSH (22)

---

## Prerequisites

### Required Software

| Software | Minimum Version | Purpose | Installation |
|----------|----------------|---------|--------------|
| **Terraform** | ≥ 1.0.0 | Infrastructure provisioning | [terraform.io/downloads](https://www.terraform.io/downloads) |
| **Azure CLI** | ≥ 2.30.0 | Azure authentication & management | [docs.microsoft.com/cli/azure](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) |
| **Git** | ≥ 2.0 | Version control | [git-scm.com](https://git-scm.com/downloads) |
| **jq** (optional) | ≥ 1.6 | JSON parsing in deployment scripts | [stedolan.github.io/jq](https://stedolan.github.io/jq/) |

### Azure Requirements

#### Subscription Permissions
- **Required Role**: `Contributor` or `Owner` at subscription or resource group level
- **Resource Provider Registration**: `Microsoft.Compute`, `Microsoft.Network`, `Microsoft.Storage`
- **API Permissions**: No special API permissions required

#### Service Quotas
Verify sufficient quota in target region:

| Resource | Required | Check Command |
|----------|----------|---------------|
| vCPUs (D-series) | 18 | `az vm list-usage --location eastus --query "[?name.value=='standardDSv3Family']"` |
| Public IPs | 1 | `az network list-usages --location eastus` |
| Virtual Networks | 1 | Standard quota: 1000 per region |

### Security Prerequisites

#### Credential Requirements

**Windows/SQL Credentials:**
- Length: 12-123 characters
- Complexity: 3 of 4 (uppercase, lowercase, numbers, symbols)
- Restrictions: No common words, no username

**SSH Key (Recommended for Linux):**
```bash
# Generate SSH key pair (if not exists)
ssh-keygen -t rsa -b 4096 -C "azure-lab-key" -f ~/.ssh/azure_lab_rsa

# Display public key for terraform.tfvars
cat ~/.ssh/azure_lab_rsa.pub
```

---

## Deployment

### Quick Start (5 Minutes)

```bash
# 1. Clone repository
git clone https://github.com/adrian207/Azure-Win-Lab.git
cd Azure-Win-Lab

# 2. Authenticate to Azure
az login
az account set --subscription "<subscription-name-or-id>"

# 3. Configure deployment
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your credentials
# Required changes: admin_password, sql_admin_password
# Optional: ssh_public_key for Linux hosts

# 4. Deploy infrastructure
./scripts/deploy.sh
```

### Manual Deployment (Advanced)

```bash
# Initialize Terraform
terraform init

# Review execution plan
terraform plan -out=tfplan

# Apply infrastructure
terraform apply tfplan

# View outputs
terraform output connection_instructions
```

### Deployment Timeline

| Phase | Duration | Activities |
|-------|----------|------------|
| Initialization | 30s | Provider plugin download, backend configuration |
| Planning | 45s | Resource graph generation, dependency calculation |
| Networking | 3min | VNet, subnets, NSGs, Bastion deployment |
| Compute | 12min | VM provisioning, disk attachment, extensions |
| Finalization | 2min | Output generation, state file update |
| **Total** | **~18min** | End-to-end deployment |

---

## Configuration Management

### Environment Configurations

The solution supports multiple pre-configured environments optimized for different use cases:

#### Standard Environment (Production-Like)
```hcl
# environments/standard/terraform.tfvars.example
environment_name    = "standard"
server_vm_size      = "Standard_D2s_v3"      # Balanced performance
linux_vm_size       = "Standard_D2s_v3"
sql_vm_size         = "Standard_D4s_v3"      # Database-optimized
enable_auto_shutdown = true                   # Cost optimization
```
**Use Case**: Production-like testing, long-term development environments

#### Development Environment (Cost-Optimized)
```hcl
# environments/dev/terraform.tfvars.example
environment_name    = "dev"
server_vm_size      = "Standard_B2s"          # Burstable, cost-effective
linux_vm_size       = "Standard_B2s"
sql_vm_size         = "Standard_D2s_v3"
auto_shutdown_time  = "1800"                  # Earlier shutdown (6 PM)
```
**Use Case**: Individual development, feature testing, CI/CD pipelines

#### Demo Environment (Performance-Optimized)
```hcl
# environments/demo/terraform.tfvars.example
environment_name    = "demo"
server_vm_size      = "Standard_D4s_v3"       # High performance
linux_vm_size       = "Standard_D4s_v3"
sql_vm_size         = "Standard_D8s_v3"       # Maximum responsiveness
enable_auto_shutdown = false                   # Always available for demos
```
**Use Case**: Customer demonstrations, executive presentations, POCs

### Variable Reference

#### Core Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment_name` | string | "standard" | Environment identifier, used in resource naming |
| `location` | string | "East US" | Azure region for all resources |
| `vnet_address_space` | list(string) | ["10.0.0.0/16"] | VNet CIDR block |
| `admin_username` | string | "labadmin" | Windows VM administrator account |
| `admin_password` | string | *required* | Administrator password (12+ chars) |
| `sql_admin_username` | string | "sqladmin" | SQL Server SA account |
| `sql_admin_password` | string | *required* | SQL SA password |
| `linux_admin_username` | string | "azureuser" | Linux SSH username |
| `ssh_public_key` | string | "" | SSH public key (empty = password auth) |

#### Compute Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `server_vm_size` | string | "Standard_D2s_v3" | Windows Server VM SKU |
| `workstation_vm_size` | string | "Standard_D2s_v3" | Windows 11 VM SKU |
| `sql_vm_size` | string | "Standard_D4s_v3" | SQL Server VM SKU |
| `linux_vm_size` | string | "Standard_D2s_v3" | Linux VM SKU |

#### Cost Management Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_auto_shutdown` | bool | true | Enable VM auto-shutdown |
| `auto_shutdown_time` | string | "1900" | Shutdown time (24h format, e.g., "1900" = 7 PM) |
| `auto_shutdown_timezone` | string | "Eastern Standard Time" | Timezone for auto-shutdown |

#### Tagging Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | map(string) | {...} | Resource tags for cost allocation and governance |

**Standard Tags:**
```hcl
tags = {
  Project      = "Hybrid Server Lab"
  Purpose      = "Testing and Demos"
  Environment  = "Standard"           # Automatically set from environment_name
  ManagedBy    = "Terraform"          # Automatically set
  Owner        = "<your-name>"        # User-defined
  CostCenter   = "<cost-center>"      # User-defined
  AutoShutdown = "Enabled"            # Based on enable_auto_shutdown
}
```

---

## Security Analysis

### Threat Model

#### Mitigated Threats

| Threat | Mitigation | Residual Risk |
|--------|------------|---------------|
| **Brute Force RDP/SSH** | No public IPs; Bastion-only access with TLS | **Low** - Requires Azure AD compromise |
| **Network Scanning** | VMs not internet-accessible; NSG VirtualNetwork scope | **Minimal** - Internal only |
| **Lateral Movement** | Network segmentation with dedicated subnets & NSGs | **Low** - Contained to subnet |
| **Credential Theft** | SSH keys for Linux; sensitive variable handling | **Medium** - Depends on key management |
| **Data Exfiltration** | No outbound internet; storage encryption at rest | **Low** - Requires internal compromise |

#### Security Enhancements (Optional)

For production deployments, consider:

```hcl
# 1. Azure Key Vault integration
data "azurerm_key_vault_secret" "admin_password" {
  name         = "vm-admin-password"
  key_vault_id = var.key_vault_id
}

# 2. Just-In-Time (JIT) VM Access
resource "azurerm_security_center_jit_network_access_policy" "lab" {
  # Time-bound access approvals
}

# 3. Azure Policy enforcement
resource "azurerm_policy_assignment" "require_encryption" {
  # Enforce encryption, tagging, etc.
}

# 4. Network Watcher & Flow Logs
resource "azurerm_network_watcher_flow_log" "nsg_flow_logs" {
  # Traffic analysis and threat detection
}

# 5. Azure Sentinel integration
# SIEM for security event correlation
```

### Compliance Considerations

#### Data Residency
All resources deploy to a single Azure region (configurable via `location` variable). For GDPR/data sovereignty:
```hcl
location = "North Europe"  # EU data residency
# or
location = "Canada Central"  # Canadian data residency
```

#### Audit Logging
Enable Azure Activity Log and Resource Logs:
```bash
# Enable diagnostic settings
az monitor diagnostic-settings create \
  --resource <resource-id> \
  --name "AuditLogs" \
  --logs '[{"category": "Administrative", "enabled": true}]' \
  --workspace <log-analytics-workspace-id>
```

---

## Performance Optimization

### Compute Optimization

#### VM Sizing Recommendations

| Workload Type | Current Default | Performance Tier | High-Performance Option |
|---------------|-----------------|------------------|-------------------------|
| **Domain Controllers** | D2s_v3 | General Purpose | D4s_v3 (high user count) |
| **Workstations** | D2s_v3 | General Purpose | D4s_v3 (graphics workloads) |
| **SQL Server** | D4s_v3 | General Purpose | **E4s_v3** (memory-optimized) or **M-series** (critical workloads) |
| **Linux Hosts** | D2s_v3 | General Purpose | **F4s_v2** (compute-optimized for containers) |

#### Storage Performance

**Current Configuration:**
- Premium SSD (P10/P15) - 120 IOPS, 25 MB/s (P10)
- SQL Data Disk: Read-Only caching for query performance
- SQL Log Disk: No caching for write consistency

**Performance Enhancements:**
```hcl
# Upgrade to larger Premium SSD for higher IOPS
os_disk {
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 128  # P10 → 500 IOPS
  caching              = "ReadWrite"
}

# Enable Write Accelerator for SQL log disk (M-series only)
# Reduces log write latency from ms to sub-ms
```

#### Network Performance

**Current**: Standard VM networking (~500-2000 Mbps depending on VM size)

**Enhancement Options:**
```hcl
# 1. Enable Accelerated Networking (SR-IOV)
resource "azurerm_network_interface" "server" {
  enable_accelerated_networking = true  # Up to 30 Gbps
  # Supported on D2s_v3 and larger
}

# 2. Proximity Placement Group (reduce latency)
resource "azurerm_proximity_placement_group" "lab" {
  name                = "${var.environment_name}-ppg"
  location            = var.location
  resource_group_name = azurerm_resource_group.lab.name
}

# 3. Availability Zones (HA with low latency)
resource "azurerm_linux_virtual_machine" "linux" {
  zones = ["1"]  # Deploy across zones
}
```

### Monitoring & Observability

```hcl
# Enable VM Insights (requires Log Analytics workspace)
resource "azurerm_monitor_diagnostic_setting" "vm" {
  name               = "VMDiagnostics"
  target_resource_id = azurerm_windows_virtual_machine.server.id
  
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

**Key Metrics to Monitor:**
- CPU utilization (>80% sustained indicates undersizing)
- Memory available (Windows: Performance Counters; Linux: /proc/meminfo)
- Disk IOPS (compare to Premium SSD limits)
- Network throughput

---

## Cost Management

### Cost Breakdown (Standard Environment - East US)

[Inference] Based on pay-as-you-go pricing:

| Resource | SKU | Quantity | Monthly Cost (24/7) | With Auto-Shutdown (12hrs) |
|----------|-----|----------|---------------------|----------------------------|
| Windows Server VMs | D2s_v3 | 3 | $210 | $105 |
| Windows 11 VM | D2s_v3 | 1 | $70 | $35 |
| SQL Server VM | D4s_v3 | 1 | $140 | $70 |
| Red Hat Linux VMs | D2s_v3 | 2 | $140 | $70 |
| Azure Bastion | Standard | 1 | $140 | $140 (always-on) |
| Storage (Premium SSD) | ~1TB | - | $60 | $60 (always billed) |
| Public IP | Static Standard | 1 | $4 | $4 |
| **Subtotal** | | | **$764** | **$484** |
| **Est. Monthly Cost** | | | **~$760/mo** | **~$270/mo** (65% savings) |

### Cost Optimization Strategies

#### 1. Auto-Shutdown Schedules
```hcl
enable_auto_shutdown = true
auto_shutdown_time   = "1900"  # 7 PM local time

# Advanced: Different schedules per environment
auto_shutdown_time = var.environment_name == "demo" ? "2100" : "1900"
```

#### 2. VM Sizing Optimization
```hcl
# Development: Use B-series burstable VMs
server_vm_size = "Standard_B2s"  # ~40% cost reduction vs D2s_v3
# Note: B-series CPU throttling if sustained >40% usage
```

#### 3. Reserved Instances (1-year commitment)
- **D2s_v3**: ~40% discount ($42/mo → $25/mo)
- **D4s_v3**: ~40% discount ($84/mo → $50/mo)
- **ROI**: Break-even at ~8 months of 24/7 usage

#### 4. Azure Hybrid Benefit
If you have Windows Server licenses with Software Assurance:
```hcl
# Add to windows_virtual_machine resource
license_type = "Windows_Server"  # ~40% discount on compute
```

#### 5. Spot Instances (Non-Production)
```hcl
# For dev/test environments only (can be evicted)
priority        = "Spot"
eviction_policy = "Deallocate"
max_bid_price   = 0.05  # Maximum price per hour
# Potential savings: 60-90%
```

#### 6. Storage Optimization
```bash
# Downgrade dev environment to Standard SSD
storage_account_type = "StandardSSD_LRS"  # ~60% cheaper than Premium
# Trade-off: Lower IOPS (120 vs 500)
```

### Cost Monitoring

```bash
# View current month costs by resource group
az consumption usage list \
  --start-date $(date -u -d '1 month ago' +%Y-%m-%d) \
  --end-date $(date -u +%Y-%m-%d) \
  --query "[?contains(resourceGroup, 'lab-rg')]" \
  --output table

# Set cost alert
az consumption budget create \
  --budget-name "lab-monthly-budget" \
  --amount 300 \
  --time-grain Monthly \
  --start-date $(date -u +%Y-%m-01) \
  --notifications actualCost=80 actualCost@user1=user1@contoso.com
```

---

## Operations Guide

### Daily Operations

#### Start Environment
```bash
# Start all VMs in resource group
az vm start --ids $(az vm list -g <resource-group-name> --query "[].id" -o tsv)
```

#### Stop Environment
```bash
# Deallocate all VMs (stops billing for compute)
az vm deallocate --ids $(az vm list -g <resource-group-name> --query "[].id" -o tsv)
```

#### Connect to VMs

**Windows (via Bastion):**
1. Navigate to Azure Portal → Virtual Machine
2. Click **Connect** → **Bastion**
3. Enter credentials from `terraform.tfvars`

**Linux (via Azure CLI + Bastion):**
```bash
# SSH via Bastion (password auth)
az network bastion ssh \
  --name <bastion-name> \
  --resource-group <rg-name> \
  --target-resource-id <vm-resource-id> \
  --auth-type password \
  --username azureuser

# SSH via Bastion (key auth)
az network bastion ssh \
  --name <bastion-name> \
  --resource-group <rg-name> \
  --target-resource-id <vm-resource-id> \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/azure_lab_rsa
```

### Infrastructure Modifications

#### Scale Windows Servers
```hcl
# Edit main.tf
module "windows_servers" {
  count = 5  # Changed from 3
  # ...
}

# Apply changes
terraform plan
terraform apply
```

#### Add Availability Zones
```hcl
# Edit modules/windows-server/main.tf
resource "azurerm_windows_virtual_machine" "server" {
  # Add zone assignment
  zones = [((var.server_index % 3) + 1)]  # Distribute across zones 1, 2, 3
  # ...
}
```

#### Update VM Sizes
```hcl
# Edit terraform.tfvars
server_vm_size = "Standard_D4s_v3"  # Upgrade from D2s_v3

# Resize (requires VM restart)
terraform apply
```

### Backup & Recovery

#### Manual VM Snapshot
```bash
# Create snapshot of OS disk
az snapshot create \
  --resource-group <rg-name> \
  --name vm-snapshot-$(date +%Y%m%d) \
  --source <os-disk-id>
```

#### Azure Backup Integration
```hcl
# Add to modules (example for windows-server)
resource "azurerm_backup_protected_vm" "server" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.recovery_vault_name
  source_vm_id        = azurerm_windows_virtual_machine.server.id
  backup_policy_id    = var.backup_policy_id
}
```

### Disaster Recovery

#### Infrastructure Recreation
```bash
# Infrastructure is code - redeploy from Git
git clone https://github.com/adrian207/Azure-Win-Lab.git
cd Azure-Win-Lab
cp terraform.tfvars.backup terraform.tfvars
terraform init
terraform apply

# Restore data from backups/snapshots
```

#### State File Management
```hcl
# Configure remote state (production recommendation)
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate<unique>"
    container_name       = "tfstate"
    key                  = "lab.terraform.tfstate"
  }
}
```

---

## Compliance & Governance

### Azure Policy Integration

```hcl
# Enforce tagging requirements
resource "azurerm_policy_assignment" "require_tags" {
  name                 = "require-tags"
  scope                = azurerm_resource_group.lab.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/require-tag-and-value"
  
  parameters = jsonencode({
    tagName  = { value = "CostCenter" }
    tagValue = { value = "IT" }
  })
}

# Enforce encryption
resource "azurerm_policy_assignment" "require_encryption" {
  name                 = "require-disk-encryption"
  scope                = azurerm_resource_group.lab.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/disk-encryption"
}
```

### Role-Based Access Control (RBAC)

```bash
# Grant limited access to users
az role assignment create \
  --assignee user@contoso.com \
  --role "Virtual Machine Contributor" \
  --resource-group <rg-name>

# Grant read-only access for auditors
az role assignment create \
  --assignee auditor@contoso.com \
  --role "Reader" \
  --resource-group <rg-name>
```

### Audit Logging

```bash
# Query Activity Log for changes
az monitor activity-log list \
  --resource-group <rg-name> \
  --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
  --query "[?authorization.action contains 'Microsoft.Compute/virtualMachines']" \
  --output table
```

---

## Troubleshooting

### Common Issues & Resolutions

#### Issue: Terraform Init Fails

**Symptom:**
```
Error: Failed to install provider
```

**Resolution:**
```bash
# Clear provider cache
rm -rf .terraform/
rm .terraform.lock.hcl

# Re-initialize
terraform init -upgrade
```

#### Issue: Quota Exceeded

**Symptom:**
```
Error: QuotaExceeded - Operation could not be completed as it results in exceeding approved quotas
```

**Resolution:**
```bash
# Check current quota
az vm list-usage --location eastus --query "[?currentValue >= limit]"

# Request quota increase
az support tickets create \
  --ticket-name "quota-increase-dsv3" \
  --severity "minimal" \
  --issue-type "quota"
```

#### Issue: Bastion Connection Timeout

**Symptom:**
Cannot connect to VM via Bastion after 5+ minutes

**Resolution:**
```bash
# 1. Verify Bastion deployment completed
az network bastion show --name <bastion-name> --resource-group <rg-name>

# 2. Check VM running state
az vm get-instance-view --name <vm-name> --resource-group <rg-name> --query "instanceView.statuses[?code=='PowerState/running']"

# 3. Verify NSG rules allow Bastion subnet
az network nsg rule list --nsg-name <nsg-name> --resource-group <rg-name> --query "[?sourceAddressPrefix=='10.0.1.0/26']"
```

#### Issue: SSH Key Authentication Fails

**Symptom:**
```
Permission denied (publickey)
```

**Resolution:**
```bash
# 1. Verify public key format (should start with ssh-rsa or ssh-ed25519)
cat ~/.ssh/azure_lab_rsa.pub

# 2. Ensure no trailing whitespace/newlines in terraform.tfvars
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E..."  # Single line

# 3. Use password auth as fallback
ssh_public_key = ""  # Empty = password authentication
```

#### Issue: Auto-Shutdown Not Working

**Symptom:**
VMs still running after scheduled shutdown time

**Resolution:**
```bash
# Verify shutdown schedule exists
az vm list --resource-group <rg-name> --show-details --query "[].{Name:name, PowerState:powerState}"

# Check DevTest Labs schedule (auto-shutdown backend)
az lab vm show --lab-name <lab-name> --name <vm-name> --resource-group <rg-name>

# Manual trigger for testing
az vm deallocate --name <vm-name> --resource-group <rg-name>
```

### Debug Mode

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log

terraform apply

# Review detailed logs
less terraform-debug.log
```

---

## API Reference

### Terraform Outputs

After successful deployment, the following outputs are available:

#### Output: `resource_group_name`
**Type:** string  
**Description:** Name of the deployed resource group  
**Example:** `standard-lab-rg-a1b2c3`

#### Output: `vnet_name`
**Type:** string  
**Description:** Name of the virtual network  
**Example:** `standard-lab-vnet`

#### Output: `bastion_host_name`
**Type:** string  
**Description:** Name of the Azure Bastion host  
**Example:** `standard-bastion`

#### Output: `windows_server_names`
**Type:** list(string)  
**Description:** List of Windows Server VM names  
**Example:** `["standard-dc1", "standard-dc2", "standard-dc3"]`

#### Output: `windows_server_private_ips`
**Type:** list(string)  
**Description:** Private IP addresses of Windows Servers  
**Example:** `["10.0.2.4", "10.0.2.5", "10.0.2.6"]`

#### Output: `linux_server_names`
**Type:** list(string)  
**Description:** List of Linux VM names  
**Example:** `["standard-rhel1", "standard-rhel2"]`

#### Output: `linux_server_private_ips`
**Type:** list(string)  
**Description:** Private IP addresses of Linux servers  
**Example:** `["10.0.5.4", "10.0.5.5"]`

#### Output: `connection_instructions`
**Type:** string  
**Description:** Formatted connection guide with all VM details and access methods  

### Module Interfaces

#### Module: `networking`
**Purpose:** Deploys VNet, subnets, and NSGs

**Inputs:**
- `resource_group_name` (string, required)
- `location` (string, required)
- `environment_name` (string, required)
- `vnet_address_space` (list(string), required)
- `tags` (map(string), optional)

**Outputs:**
- `vnet_id` - Virtual network resource ID
- `bastion_subnet_id` - Bastion subnet ID
- `server_subnet_id` - Server subnet ID
- `workstation_subnet_id` - Workstation subnet ID
- `database_subnet_id` - Database subnet ID
- `linux_subnet_id` - Linux subnet ID

#### Module: `windows-server`
**Purpose:** Deploys Windows Server 2025 VM

**Inputs:**
- `resource_group_name` (string, required)
- `location` (string, required)
- `environment_name` (string, required)
- `server_name` (string, required)
- `subnet_id` (string, required)
- `admin_username` (string, required)
- `admin_password` (string, required, sensitive)
- `vm_size` (string, default: "Standard_D2s_v3")
- `enable_auto_shutdown` (bool, default: true)

**Outputs:**
- `vm_name` - Virtual machine name
- `vm_id` - VM resource ID
- `private_ip_address` - VM private IP
- `network_interface_id` - NIC resource ID

---

## Contributing

### Development Workflow

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Push** to branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Code Standards

#### Terraform Formatting
```bash
# Format all .tf files
terraform fmt -recursive

# Validate syntax
terraform validate
```

#### Pre-Commit Hooks
```bash
# Install pre-commit
pip install pre-commit

# Setup hooks
cat > .pre-commit-config.yaml <<EOF
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.77.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
EOF

pre-commit install
```

#### Security Scanning
```bash
# Scan for security issues with tfsec
brew install tfsec
tfsec .

# Scan for misconfigurations with Checkov
pip install checkov
checkov -d .
```

### Pull Request Guidelines

- ✅ All Terraform files formatted (`terraform fmt`)
- ✅ No linting errors (`terraform validate`)
- ✅ Security scan passing (`tfsec`)
- ✅ Documentation updated (if adding features)
- ✅ Version number updated (if applicable)
- ✅ Tested in at least one Azure region

---

## Support

### Community Support

- **GitHub Issues**: [github.com/adrian207/Azure-Win-Lab/issues](https://github.com/adrian207/Azure-Win-Lab/issues)
- **Discussions**: [github.com/adrian207/Azure-Win-Lab/discussions](https://github.com/adrian207/Azure-Win-Lab/discussions)

### Professional Support

For enterprise support, consulting, or custom development:
- **Email**: support@example.com
- **Response Time**: 1-2 business days

### Documentation

- **Azure Documentation**: [docs.microsoft.com/azure](https://docs.microsoft.com/en-us/azure/)
- **Terraform Azure Provider**: [registry.terraform.io/providers/hashicorp/azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- **Infrastructure Best Practices**: [docs.microsoft.com/azure/architecture](https://docs.microsoft.com/en-us/azure/architecture/)

---

## Appendix

### A. Azure Region Selection

Recommended regions based on use case:

| Use Case | Recommended Regions | Considerations |
|----------|---------------------|----------------|
| **US East Coast** | East US, East US 2 | Lowest latency for East Coast users; mature region |
| **US West Coast** | West US 2, West US 3 | Latest hardware; good for West Coast |
| **Europe (GDPR)** | North Europe, West Europe | EU data residency compliance |
| **Asia Pacific** | Southeast Asia, East Asia | Latency optimization for APAC |
| **Cost Optimization** | South Central US, West US 2 | [Inference] Typically lower pricing |

### B. VM Size Comparison

| Series | vCPU | RAM | Use Case | Cost (approx.) |
|--------|------|-----|----------|----------------|
| **B2s** | 2 | 4 GB | Burstable, dev/test | $30/mo |
| **D2s_v3** | 2 | 8 GB | General purpose, standard workloads | $70/mo |
| **D4s_v3** | 4 | 16 GB | Moderate compute, databases | $140/mo |
| **E4s_v3** | 4 | 32 GB | Memory-optimized, large databases | $200/mo |
| **F4s_v2** | 4 | 8 GB | Compute-optimized, containers | $140/mo |

### C. Subnet CIDR Allocation

| Subnet | CIDR | Usable IPs | Max VMs | Notes |
|--------|------|------------|---------|-------|
| Bastion | 10.0.1.0/26 | 59 | N/A | Azure requirement: minimum /26 |
| Servers | 10.0.2.0/24 | 251 | ~240 | Room for domain controllers, app servers |
| Workstations | 10.0.3.0/24 | 251 | ~240 | Client machines, management stations |
| Database | 10.0.4.0/24 | 251 | ~240 | SQL, Oracle, PostgreSQL instances |
| Linux | 10.0.5.0/24 | 251 | ~240 | Linux workloads, containers, web servers |

### D. License Requirements

| Software | License Type | Acquisition |
|----------|--------------|-------------|
| **Windows Server 2025** | Included in Azure VM cost (PAYG) | Azure Marketplace |
| **Windows 11 Enterprise** | Included in Azure VM cost (PAYG) | Azure Marketplace |
| **SQL Server 2022 Developer** | Free (for non-production) | Azure Marketplace |
| **Red Hat Enterprise Linux 9.4** | Included in Azure VM cost (PAYG) | Azure Marketplace |

**Note**: For production SQL Server, switch to Standard or Enterprise editions via `sku` parameter.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **HashiCorp Terraform**: Infrastructure as Code platform
- **Microsoft Azure**: Cloud infrastructure provider
- **Azure Bastion**: Secure VM access solution
- **Community Contributors**: Open-source community feedback and enhancements

---

<div align="center">

**Built with ❤️ for Windows & Linux professionals**

[Report Bug](https://github.com/adrian207/Azure-Win-Lab/issues) · [Request Feature](https://github.com/adrian207/Azure-Win-Lab/issues) · [View Documentation](https://github.com/adrian207/Azure-Win-Lab/wiki)

**Made by Adrian Johnson** | [GitHub](https://github.com/adrian207)

</div>

