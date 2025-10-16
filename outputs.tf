# Outputs for Azure Windows Server Lab

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.lab.name
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "bastion_host_name" {
  description = "Name of the Azure Bastion host"
  value       = module.bastion.bastion_name
}

output "windows_server_names" {
  description = "Names of the Windows Server 2025 VMs"
  value       = [for server in module.windows_servers : server.vm_name]
}

output "windows_server_private_ips" {
  description = "Private IP addresses of Windows Servers"
  value       = [for server in module.windows_servers : server.private_ip_address]
}

output "windows11_workstation_name" {
  description = "Name of the Windows 11 workstation"
  value       = module.windows11_workstation.vm_name
}

output "windows11_workstation_private_ip" {
  description = "Private IP address of Windows 11 workstation"
  value       = module.windows11_workstation.private_ip_address
}

output "sql_server_name" {
  description = "Name of the SQL Server VM"
  value       = module.sql_server.vm_name
}

output "sql_server_private_ip" {
  description = "Private IP address of SQL Server"
  value       = module.sql_server.private_ip_address
}

output "linux_server_names" {
  description = "Names of the Red Hat Linux VMs"
  value       = [for server in module.redhat_linux : server.vm_name]
}

output "linux_server_private_ips" {
  description = "Private IP addresses of Linux Servers"
  value       = [for server in module.redhat_linux : server.private_ip_address]
}

output "linux_admin_username" {
  description = "Admin username for Linux hosts"
  value       = var.linux_admin_username
}

output "connection_instructions" {
  description = "Instructions for connecting to the lab environment"
  value = <<-EOT
    ================================
    Azure Hybrid Server Lab - Connection Info
    ================================
    
    Resource Group: ${azurerm_resource_group.lab.name}
    Location: ${azurerm_resource_group.lab.location}
    
    WINDOWS SYSTEMS (RDP via Bastion):
    -----------------------------------
    1. Go to Azure Portal
    2. Navigate to the VM you want to access
    3. Click "Connect" > "Bastion"
    4. Enter credentials:
       - Username: ${var.admin_username}
       - Password: [Your configured password]
    
    Windows Servers:
    ${join("\n", [for idx, server in module.windows_servers : "  - ${server.vm_name}: ${server.private_ip_address}"])}
    
    Windows 11 Workstation:
      - ${module.windows11_workstation.vm_name}: ${module.windows11_workstation.private_ip_address}
    
    SQL Server:
      - ${module.sql_server.vm_name}: ${module.sql_server.private_ip_address}
      - SQL Admin: ${var.sql_admin_username}
    
    LINUX SYSTEMS (SSH via Bastion):
    -----------------------------------
    Red Hat Enterprise Linux Servers:
    ${join("\n", [for idx, server in module.redhat_linux : "  - ${server.vm_name}: ${server.private_ip_address}"])}
    
    Linux Admin Username: ${var.linux_admin_username}
    ${var.ssh_public_key != "" ? "Authentication: SSH Key" : "Authentication: Password"}
    
    To SSH via Bastion (from local machine):
      az network bastion ssh --name ${module.bastion.bastion_name} \
        --resource-group ${azurerm_resource_group.lab.name} \
        --target-resource-id <VM_RESOURCE_ID> \
        --auth-type ${var.ssh_public_key != "" ? "ssh-key" : "password"} \
        --username ${var.linux_admin_username}
    
    ================================
  EOT
}

