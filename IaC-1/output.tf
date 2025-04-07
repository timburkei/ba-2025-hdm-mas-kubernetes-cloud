output "azure_blob_storage_connection_string" {
  description = "INPUT_AZURE_BLOB_STORAGE_CONNECTION_STRING"
  value       = azurerm_storage_account.hdm-25-stg-storage-acc.primary_connection_string
  sensitive   = true
}

output "input_azure_blob_storage_container_name" {
  description = "INPUT_AZURE_BLOB_STORAGE_CONTAINER_NAME"
  value       = azurerm_storage_container.input-container.name
}

output "output_azure_blob_storage_container_name" {
  description = "OUTPUT_AZURE_BLOB_STORAGE_CONTAINER_NAME"
  value       = azurerm_storage_container.output-container.name
}

output "input_service_bus_connection_string" {
  description = "INPUT_AZURE_SERVICE_BUS_CONNECTION_STRING"
  value       = azurerm_servicebus_queue_authorization_rule.input-queue-connection-string.primary_connection_string
  sensitive   = true
}

output "input_service_bus_queue_name" {
  description = "INPUT_AZURE_SERVICE_BUS_QUEUE_NAME"
  value       = azurerm_servicebus_queue.input-queue.name
}


output "kube_config" {
  value = {
    host                   = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].host
    client_certificate     = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].client_certificate
    client_key             = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].client_key
    cluster_ca_certificate = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].cluster_ca_certificate
  }
  sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.rg-thesis.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.name
}

output "location" {
  value = azurerm_resource_group.rg-thesis.location
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.log_workspace.id
}