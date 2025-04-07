resource "azurerm_load_test" "load_test" {
  name                = "loadTestService"
  resource_group_name = azurerm_resource_group.rg-thesis.name
  location            = azurerm_resource_group.rg-thesis.location
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "load_test_aks_monitoring_reader" {
  scope                = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_load_test.load_test.identity[0].principal_id
}
