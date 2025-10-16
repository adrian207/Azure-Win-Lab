# Variables for Azure Windows Server Lab

variable "environment_name" {
  description = "Name of the environment (e.g., standard, dev, demo)"
  type        = string
  default     = "standard"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "admin_username" {
  description = "Admin username for all VMs"
  type        = string
  default     = "labadmin"
}

variable "admin_password" {
  description = "Admin password for all VMs (use secure method in production)"
  type        = string
  sensitive   = true
}

variable "sql_admin_username" {
  description = "SQL Server admin username"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}

variable "server_vm_size" {
  description = "VM size for Windows Servers"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "workstation_vm_size" {
  description = "VM size for Windows 11 workstation"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "sql_vm_size" {
  description = "VM size for SQL Server"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown to save costs"
  type        = bool
  default     = true
}

variable "auto_shutdown_time" {
  description = "Time for auto-shutdown (24hr format, e.g., 1900 for 7 PM)"
  type        = string
  default     = "1900"
}

variable "auto_shutdown_timezone" {
  description = "Timezone for auto-shutdown"
  type        = string
  default     = "Eastern Standard Time"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Windows Server Lab"
    Purpose     = "Testing and Demos"
    AutoShutdown = "Enabled"
  }
}

