resource "azurerm_kubernetes_cluster" "aks_cluster_thesis_hdm_25" {
  name                = "thesis-aks-cluster-hdm-25"
  location            = azurerm_resource_group.rg-thesis.location
  resource_group_name = azurerm_resource_group.rg-thesis.name
  dns_prefix          = "thesisaks"

  default_node_pool {
    name = "default"
    node_count = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id

    auto_scaling_enabled = true
    min_count            = 2
    max_count            = 2

    node_labels = {
      "node-type" = "aks-vm"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  }

  depends_on = [
    azurerm_virtual_network.aks_vnet,
    azurerm_subnet.aks_subnet,
    azurerm_subnet.aci_subnet
  ]
}

resource "null_resource" "enable_aci_connector" {
  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25,
    azurerm_role_assignment.aci_subnet_contributor,
    azurerm_role_assignment.aci_container_instance_contributor,
    azurerm_subnet.aci_subnet
  ]

  provisioner "local-exec" {
    command = "az aks enable-addons --addons virtual-node --resource-group ${azurerm_resource_group.rg-thesis.name} --name ${azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.name} --subnet-name ${azurerm_subnet.aci_subnet.name}"
  }
}