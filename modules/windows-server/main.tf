# Windows Server 2025 Module

# Network Interface
resource "azurerm_network_interface" "server" {
  name                = "${var.environment_name}-${var.server_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Windows Server 2025 VM
resource "azurerm_windows_virtual_machine" "server" {
  name                = "${var.environment_name}-${var.server_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.server.id,
  ]

  os_disk {
    name                 = "${var.environment_name}-${var.server_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-azure-edition"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  # Enable automatic updates
  patch_mode = "AutomaticByPlatform"
  
  # Timezone
  timezone = "Eastern Standard Time"
}

# Auto-shutdown schedule (optional, for cost savings)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "server" {
  count              = var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_windows_virtual_machine.server.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled = false
  }
}

