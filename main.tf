# Azure Windows Server Lab - Main Configuration
# This is the main entry point for deploying your standard lab environment

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "lab" {
  name     = "${var.environment_name}-lab-rg-${random_string.suffix.result}"
  location = var.location
  tags     = merge(var.tags, {
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  })
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  environment_name    = var.environment_name
  vnet_address_space  = var.vnet_address_space
  tags                = azurerm_resource_group.lab.tags
}

# Azure Bastion Module
module "bastion" {
  source = "./modules/bastion"

  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  environment_name    = var.environment_name
  bastion_subnet_id   = module.networking.bastion_subnet_id
  tags                = azurerm_resource_group.lab.tags
}

# Windows Server 2025 VMs (3 instances)
module "windows_servers" {
  source = "./modules/windows-server"

  count               = 3
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  environment_name    = var.environment_name
  server_name         = "dc${count.index + 1}"
  subnet_id           = module.networking.server_subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_size             = var.server_vm_size
  tags                = azurerm_resource_group.lab.tags
}

# Windows 11 Workstation
module "windows11_workstation" {
  source = "./modules/windows11-workstation"

  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  environment_name    = var.environment_name
  workstation_name    = "ws01"
  subnet_id           = module.networking.workstation_subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_size             = var.workstation_vm_size
  tags                = azurerm_resource_group.lab.tags
}

# SQL Server VM
module "sql_server" {
  source = "./modules/sql-server"

  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  environment_name    = var.environment_name
  sql_server_name     = "sql01"
  subnet_id           = module.networking.database_subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  sql_admin_username  = var.sql_admin_username
  sql_admin_password  = var.sql_admin_password
  vm_size             = var.sql_vm_size
  tags                = azurerm_resource_group.lab.tags
}

