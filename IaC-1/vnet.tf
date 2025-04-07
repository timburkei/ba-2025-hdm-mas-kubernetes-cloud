resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg-thesis.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.240.0.0/24"]
}



resource "azurerm_subnet" "aci_subnet" {
  name                 = "aci-subnet"
  resource_group_name  = azurerm_resource_group.rg-thesis.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.240.1.0/24"]

  delegation {
    name = "aciDelegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_role_assignment" "aci_subnet_contributor" {
  scope                = azurerm_subnet.aci_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.identity[0].principal_id
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  address_space       = ["10.240.0.0/16"]
  location            = azurerm_resource_group.rg-thesis.location
  resource_group_name = azurerm_resource_group.rg-thesis.name
}

resource "azurerm_role_assignment" "aci_network_contributor" {
  scope                = azurerm_virtual_network.aks_vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.identity[0].principal_id
}


resource "azurerm_role_assignment" "aci_container_instance_contributor" {
  scope                = "/subscriptions/${var.azure_subscrition_id}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.identity[0].principal_id
}
