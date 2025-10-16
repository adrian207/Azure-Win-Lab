# Outputs for Azure Hybrid Lab - Docker Edition

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

# Docker Host Outputs
output "docker_host_name" {
  description = "Name of the Docker host VM"
  value       = module.docker_host.vm_name
}

output "docker_host_ip" {
  description = "IP address of Docker host"
  value       = module.docker_host.private_ip_address
}

output "docker_services" {
  description = "Services running on Docker host"
  value       = module.docker_host.services
}

output "portainer_url" {
  description = "Portainer web UI URL"
  value       = module.docker_host.portainer_url
}

# Windows 11 Workstation Outputs
output "windows11_workstation_name" {
  description = "Name of the Windows 11 workstation"
  value       = module.windows11_workstation.vm_name
}

output "windows11_workstation_private_ip" {
  description = "Private IP address of Windows 11 workstation"
  value       = module.windows11_workstation.private_ip_address
}

output "connection_instructions" {
  description = "Instructions for connecting to the lab environment"
  value = <<-EOT
    ╔═══════════════════════════════════════════════════════════════════╗
    ║     Azure Hybrid Lab - DOCKER EDITION - Connection Info          ║
    ╚═══════════════════════════════════════════════════════════════════╝
    
    Resource Group: ${azurerm_resource_group.lab.name}
    Location: ${azurerm_resource_group.lab.location}
    
    🐳 DOCKER HOST (All services run here):
    ─────────────────────────────────────────
    Host: ${module.docker_host.vm_name}
    IP: ${module.docker_host.private_ip_address}
    
    SSH Access:
      ${module.docker_host.ssh_command}
      (Via Azure Bastion or direct SSH)
    
    📊 Management UIs:
    ─────────────────────────────────────────
    Portainer (Docker GUI):  ${module.docker_host.portainer_url}
    GitLab:                  http://${module.docker_host.private_ip_address}:8080
    Jenkins:                 http://${module.docker_host.private_ip_address}:8081
    Adminer (DB GUI):        http://${module.docker_host.private_ip_address}:8082
    
    🗄️ Database Services:
    ─────────────────────────────────────────
    SQL Server:    ${module.docker_host.services.sql_server}
                   User: sa / Password: [from terraform.tfvars]
    
    PostgreSQL:    ${module.docker_host.services.postgresql}
                   User: postgres / Password: [from .env]
    
    MongoDB:       IP:27017
                   User: admin / Password: [from .env]
    
    Redis:         IP:6379
    
    🌐 Web & Network Services:
    ─────────────────────────────────────────
    Nginx:         ${module.docker_host.services.nginx}
    Samba AD DC:   ${module.docker_host.services.samba_ad}
                   Domain: ${var.domain_name}
    
    💻 WINDOWS 11 WORKSTATION (RDP via Bastion):
    ─────────────────────────────────────────
    Name: ${module.windows11_workstation.vm_name}
    IP: ${module.windows11_workstation.private_ip_address}
    
    1. Go to Azure Portal
    2. Navigate to Windows 11 VM
    3. Click "Connect" > "Bastion"
    4. Enter credentials: ${var.admin_username} / [password]
    
    📋 Docker Commands (on Docker Host):
    ─────────────────────────────────────────
    lab status          - Show all containers
    lab logs [service]  - View service logs
    lab shell [name]    - Open shell in container
    lab restart         - Restart all services
    
    Or use Docker Compose directly:
      cd /opt/lab
      docker-compose ps
      docker-compose logs -f
    
    💰 COST SAVINGS:
    ─────────────────────────────────────────
    Previous architecture: ~$270/month
    Hybrid architecture:   ~$70/month
    Savings: 74% ($200/month)
    
    ╔═══════════════════════════════════════════════════════════════════╗
    ║  All Windows Server, SQL, and Linux workloads now run in Docker  ║
    ║  Access via Portainer UI or SSH to Docker host                   ║
    ╚═══════════════════════════════════════════════════════════════════╝
  EOT
}
