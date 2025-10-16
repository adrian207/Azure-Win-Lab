# SQL Server Module Variables

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

variable "sql_server_name" {
  description = "Name of the SQL server"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "admin_username" {
  description = "VM Admin username"
  type        = string
}

variable "admin_password" {
  description = "VM Admin password"
  type        = string
  sensitive   = true
}

variable "sql_admin_username" {
  description = "SQL Admin username"
  type        = string
}

variable "sql_admin_password" {
  description = "SQL Admin password"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_D4s_v3"
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

