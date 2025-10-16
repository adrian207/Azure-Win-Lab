# Key Vault Module Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
}

variable "suffix" {
  description = "Random suffix for unique naming"
  type        = string
}

variable "admin_password" {
  description = "VM administrator password to store"
  type        = string
  sensitive   = true
  default     = ""
}

variable "sql_admin_password" {
  description = "SQL administrator password to store"
  type        = string
  sensitive   = true
  default     = ""
}

variable "linux_admin_password" {
  description = "Linux administrator password to store"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_private_key" {
  description = "SSH private key to store (optional)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access Key Vault"
  type        = list(string)
  default     = []
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access Key Vault"
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

