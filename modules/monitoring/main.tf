# Log Analytics & Monitoring Module
# Centralized logging, monitoring, and alerting

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "lab" {
  name                = "${var.environment_name}-logs-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  
  tags = var.tags
}

# Log Analytics Solutions
resource "azurerm_log_analytics_solution" "vm_insights" {
  solution_name         = "VMInsights"
  workspace_resource_id = azurerm_log_analytics_workspace.lab.id
  workspace_name        = azurerm_log_analytics_workspace.lab.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }
  
  tags = var.tags
}

resource "azurerm_log_analytics_solution" "security_insights" {
  solution_name         = "Security"
  workspace_resource_id = azurerm_log_analytics_workspace.lab.id
  workspace_name        = azurerm_log_analytics_workspace.lab.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
  
  tags = var.tags
}

# Action Group for Alerts (Email notifications)
resource "azurerm_monitor_action_group" "email" {
  name                = "${var.environment_name}-email-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "emailalert"
  
  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
  
  tags = var.tags
}

# Saved Queries for Common Scenarios
resource "azurerm_log_analytics_saved_search" "failed_logins" {
  name                       = "FailedLoginAttempts"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id
  category                   = "Security"
  display_name               = "Failed Login Attempts"
  
  query = <<-QUERY
    SecurityEvent
    | where EventID == 4625  // Failed login
    | summarize FailedAttempts = count() by Computer, Account, bin(TimeGenerated, 1h)
    | where FailedAttempts > 5
    | order by TimeGenerated desc
  QUERY
}

resource "azurerm_log_analytics_saved_search" "high_cpu" {
  name                       = "HighCPUUsage"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id
  category                   = "Performance"
  display_name               = "High CPU Usage"
  
  query = <<-QUERY
    Perf
    | where CounterName == "% Processor Time" and InstanceName == "_Total"
    | where CounterValue > 80
    | summarize AvgCPU = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
    | order by TimeGenerated desc
  QUERY
}

resource "azurerm_log_analytics_saved_search" "low_memory" {
  name                       = "LowMemory"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id
  category                   = "Performance"
  display_name               = "Low Available Memory"
  
  query = <<-QUERY
    Perf
    | where CounterName == "Available MBytes"
    | where CounterValue < 500
    | summarize AvgMemory = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
    | order by TimeGenerated desc
  QUERY
}

resource "azurerm_log_analytics_saved_search" "disk_space" {
  name                       = "LowDiskSpace"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id
  category                   = "Performance"
  display_name               = "Low Disk Space"
  
  query = <<-QUERY
    Perf
    | where CounterName == "% Free Space"
    | where CounterValue < 10
    | summarize AvgFreeSpace = avg(CounterValue) by Computer, InstanceName, bin(TimeGenerated, 1h)
    | order by TimeGenerated desc
  QUERY
}

# Data Collection Rule for VMs (required for Azure Monitor Agent)
resource "azurerm_monitor_data_collection_rule" "vms" {
  name                = "${var.environment_name}-dcr-vms"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.lab.id
      name                  = "destination-log"
    }
  }
  
  data_flow {
    streams      = ["Microsoft-Perf", "Microsoft-Event"]
    destinations = ["destination-log"]
  }
  
  # Performance counters
  data_sources {
    performance_counter {
      name                          = "perfCounterDataSource"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes",
        "\\LogicalDisk(_Total)\\% Free Space",
        "\\LogicalDisk(_Total)\\Disk Reads/sec",
        "\\LogicalDisk(_Total)\\Disk Writes/sec",
        "\\Network Interface(*)\\Bytes Total/sec"
      ]
    }
    
    # Windows Event Logs
    windows_event_log {
      name    = "eventLogsDataSource"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "System!*[System[(Level=1 or Level=2 or Level=3)]]",
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
        "Security!*[System[(EventID=4625 or EventID=4624)]]"  // Login events
      ]
    }
  }
  
  tags = var.tags
}

# Metric Alert Rules
# High CPU Alert
resource "azurerm_monitor_metric_alert" "high_cpu" {
  name                = "${var.environment_name}-high-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_ids
  description         = "Alert when CPU exceeds 80% for 5 minutes"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }
  
  tags = var.tags
}

# Low Available Memory Alert
resource "azurerm_monitor_metric_alert" "low_memory" {
  name                = "${var.environment_name}-low-memory-alert"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_ids
  description         = "Alert when available memory is below 500 MB"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 524288000  # 500 MB in bytes
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }
  
  tags = var.tags
}

# VM Availability Alert
resource "azurerm_monitor_metric_alert" "vm_availability" {
  name                = "${var.environment_name}-vm-availability-alert"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_ids
  description         = "Alert when VM becomes unavailable"
  severity            = 1  # Critical
  frequency           = "PT1M"
  window_size         = "PT5M"
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }
  
  tags = var.tags
}

