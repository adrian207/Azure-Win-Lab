# Red Hat Enterprise Linux Module

# Network Interface
resource "azurerm_network_interface" "linux" {
  name                = "${var.environment_name}-${var.linux_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Red Hat Enterprise Linux VM
resource "azurerm_linux_virtual_machine" "linux" {
  name                = "${var.environment_name}-${var.linux_name}"
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
    azurerm_network_interface.linux.id,
  ]

  os_disk {
    name                 = "${var.environment_name}-${var.linux_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "9_4"  # RHEL 9.4 (latest stable)
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  # Custom data for initial setup (optional)
  custom_data = base64encode(templatefile("${path.module}/scripts/cloud-init.yaml", {
    hostname = "${var.environment_name}-${var.linux_name}"
  }))
}

# Auto-shutdown schedule (optional, for cost savings)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "linux" {
  count              = var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_linux_virtual_machine.linux.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled = false
  }
}

