# Docker Host Module Outputs

output "vm_name" {
  description = "Name of the Docker host VM"
  value       = azurerm_linux_virtual_machine.docker_host.name
}

output "vm_id" {
  description = "ID of the Docker host VM"
  value       = azurerm_linux_virtual_machine.docker_host.id
}

output "private_ip_address" {
  description = "Private IP address of the Docker host"
  value       = azurerm_network_interface.docker_host.private_ip_address
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.docker_host.id
}

output "admin_username" {
  description = "Admin username for SSH access"
  value       = azurerm_linux_virtual_machine.docker_host.admin_username
}

output "ssh_command" {
  description = "SSH command to connect to Docker host"
  value       = "ssh ${azurerm_linux_virtual_machine.docker_host.admin_username}@${azurerm_network_interface.docker_host.private_ip_address}"
}

output "portainer_url" {
  description = "Portainer web UI URL"
  value       = "http://${azurerm_network_interface.docker_host.private_ip_address}:9000"
}

output "services" {
  description = "Services running on Docker host"
  value = {
    samba_ad        = "smb://${azurerm_network_interface.docker_host.private_ip_address}"
    sql_server      = "${azurerm_network_interface.docker_host.private_ip_address}:1433"
    postgresql      = "${azurerm_network_interface.docker_host.private_ip_address}:5432"
    nginx           = "http://${azurerm_network_interface.docker_host.private_ip_address}"
    portainer       = "http://${azurerm_network_interface.docker_host.private_ip_address}:9000"
    gitlab          = "http://${azurerm_network_interface.docker_host.private_ip_address}:8080"
  }
}

