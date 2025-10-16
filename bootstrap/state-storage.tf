# Bootstrap - Remote State Storage
# Run this ONCE before main deployment to create Terraform state backend

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
  features {}
}

# Random ID for unique storage account name
resource "random_id" "storage_account" {
  byte_length = 4
}

# Resource Group for Terraform State
resource "azurerm_resource_group" "tfstate" {
  name     = "terraform-state-rg"
  location = var.location

  tags = {
    Purpose   = "Terraform State Management"
    ManagedBy = "Terraform"
  }
}

# Storage Account for Terraform State
resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${random_id.storage_account.hex}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "GRS" # Geo-redundant for disaster recovery
  
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  
  blob_properties {
    versioning_enabled = true # State file version history
    
    delete_retention_policy {
      days = 30
    }
  }

  tags = {
    Purpose   = "Terraform State Files"
    ManagedBy = "Terraform"
  }
}

# Container for State Files
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# Lock table using Storage Account for state locking
# Azure Storage backend uses blob leases for locking automatically

