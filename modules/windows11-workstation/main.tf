# Windows 11 Workstation Module

# Network Interface
resource "azurerm_network_interface" "workstation" {
  name                = "${var.environment_name}-${var.workstation_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Windows 11 VM
resource "azurerm_windows_virtual_machine" "workstation" {
  name                = "${var.environment_name}-${var.workstation_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.workstation.id,
  ]

  os_disk {
    name                 = "${var.environment_name}-${var.workstation_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-23h2-ent"
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
resource "azurerm_dev_test_global_vm_shutdown_schedule" "workstation" {
  count              = var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_windows_virtual_machine.workstation.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled = false
  }
}

