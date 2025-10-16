# Docker Host Module - Linux VM for Container Workloads
# Replaces: Windows Servers, SQL Server, RHEL VMs

# Network Interface
resource "azurerm_network_interface" "docker_host" {
  name                = "${var.environment_name}-docker-host-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.static_ip
  }
}

# Linux Docker Host VM
resource "azurerm_linux_virtual_machine" "docker_host" {
  name                = "${var.environment_name}-docker-host"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  # SSH key authentication (recommended for Linux)
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # Also support password authentication if SSH key not provided
  disable_password_authentication = var.ssh_public_key != "" ? true : false
  admin_password                  = var.ssh_public_key == "" ? var.admin_password : null

  network_interface_ids = [
    azurerm_network_interface.docker_host.id,
  ]

  os_disk {
    name                 = "${var.environment_name}-docker-host-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128  # Larger for Docker images/volumes
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  # Cloud-init for Docker setup
  custom_data = base64encode(templatefile("${path.module}/scripts/cloud-init.yaml", {
    hostname            = "${var.environment_name}-docker-host"
    admin_username      = var.admin_username
    docker_compose_file = file("${path.module}/scripts/docker-compose.yml")
    domain_name         = var.domain_name
    domain_password     = var.domain_admin_password
    sql_sa_password     = var.sql_sa_password
  }))
}

# Data disk for Docker volumes (persistent storage)
resource "azurerm_managed_disk" "docker_data" {
  name                 = "${var.environment_name}-docker-data-disk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256  # For databases, volumes
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "docker_data" {
  managed_disk_id    = azurerm_managed_disk.docker_data.id
  virtual_machine_id = azurerm_linux_virtual_machine.docker_host.id
  lun                = 0
  caching            = "ReadWrite"
}

# Auto-shutdown schedule (optional, for cost savings)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "docker_host" {
  count              = var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_linux_virtual_machine.docker_host.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled = false
  }
}

