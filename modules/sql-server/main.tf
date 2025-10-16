# SQL Server Module

# Network Interface
resource "azurerm_network_interface" "sql" {
  name                = "${var.environment_name}-${var.sql_server_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# SQL Server VM
resource "azurerm_windows_virtual_machine" "sql" {
  name                = "${var.environment_name}-${var.sql_server_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.sql.id,
  ]

  os_disk {
    name                 = "${var.environment_name}-${var.sql_server_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2022-ws2022"
    sku       = "sqldev-gen2"
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

# Data disk for SQL data files
resource "azurerm_managed_disk" "sql_data" {
  name                 = "${var.environment_name}-${var.sql_server_name}-datadisk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "sql_data" {
  managed_disk_id    = azurerm_managed_disk.sql_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.sql.id
  lun                = 0
  caching            = "ReadOnly"
}

# Log disk for SQL log files
resource "azurerm_managed_disk" "sql_log" {
  name                 = "${var.environment_name}-${var.sql_server_name}-logdisk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "sql_log" {
  managed_disk_id    = azurerm_managed_disk.sql_log.id
  virtual_machine_id = azurerm_windows_virtual_machine.sql.id
  lun                = 1
  caching            = "None"
}

# SQL IaaS Extension
resource "azurerm_mssql_virtual_machine" "sql" {
  virtual_machine_id               = azurerm_windows_virtual_machine.sql.id
  sql_license_type                 = "PAYG"
  r_services_enabled               = false
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_username = var.sql_admin_username
  sql_connectivity_update_password = var.sql_admin_password

  auto_patching {
    day_of_week                            = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }

  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "GENERAL"

    data_settings {
      default_file_path = "F:\\SQLData"
      luns              = [azurerm_virtual_machine_data_disk_attachment.sql_data.lun]
    }

    log_settings {
      default_file_path = "G:\\SQLLog"
      luns              = [azurerm_virtual_machine_data_disk_attachment.sql_log.lun]
    }
  }

  tags = var.tags
}

# Auto-shutdown schedule (optional, for cost savings)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "sql" {
  count              = var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_windows_virtual_machine.sql.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled = false
  }
}

