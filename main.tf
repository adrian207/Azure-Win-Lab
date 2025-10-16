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

# Docker Host (replaces Windows Servers + SQL + RHEL)
module "docker_host" {
  source = "./modules/docker-host"

  resource_group_name   = azurerm_resource_group.lab.name
  location              = azurerm_resource_group.lab.location
  environment_name      = var.environment_name
  subnet_id             = module.networking.server_subnet_id
  static_ip             = "10.0.2.10"
  admin_username        = var.linux_admin_username
  ssh_public_key        = var.ssh_public_key
  admin_password        = var.admin_password
  vm_size               = var.docker_host_vm_size
  domain_name           = var.domain_name
  domain_admin_password = var.admin_password
  sql_sa_password       = var.sql_admin_password
  enable_auto_shutdown  = var.enable_auto_shutdown
  auto_shutdown_time    = var.auto_shutdown_time
  tags                  = azurerm_resource_group.lab.tags
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

# NOTE: SQL Server, RHEL workloads now run as Docker containers on docker_host
# See docker-compose.yml in modules/docker-host/scripts/
