# Docker Host Module Variables

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

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "static_ip" {
  description = "Static IP address for Docker host"
  type        = string
  default     = "10.0.2.10"
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password (used if SSH key not provided)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "domain_name" {
  description = "Active Directory domain name"
  type        = string
  default     = "lab.local"
}

variable "domain_admin_password" {
  description = "Domain administrator password for Samba AD"
  type        = string
  sensitive   = true
}

variable "sql_sa_password" {
  description = "SQL Server SA password"
  type        = string
  sensitive   = true
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown"
  type        = bool
  default     = true
}

variable "auto_shutdown_time" {
  description = "Auto-shutdown time"
  type        = string
  default     = "1900"
}

variable "auto_shutdown_timezone" {
  description = "Auto-shutdown timezone"
  type        = string
  default     = "Eastern Standard Time"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

