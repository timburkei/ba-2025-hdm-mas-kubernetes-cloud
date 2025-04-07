resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "log-workspace-thesis"
  location            = azurerm_resource_group.rg-thesis.location
  resource_group_name = azurerm_resource_group.rg-thesis.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "aks_monitoring" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.rg-thesis.location
  resource_group_name   = azurerm_resource_group.rg-thesis.name
  workspace_resource_id = azurerm_log_analytics_workspace.log_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}