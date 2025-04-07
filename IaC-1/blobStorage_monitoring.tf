resource "azurerm_monitor_diagnostic_setting" "blob_storage_monitoring" {
  name                       = "blob-monitoring"
  target_resource_id         = "${azurerm_storage_account.hdm-25-stg-storage-acc.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  
  enabled_log {
    category_group = "audit"
  }
  
  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }
  
  metric {
    category = "Capacity"
    enabled  = true
  }
}