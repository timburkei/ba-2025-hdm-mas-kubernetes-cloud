terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.21.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscrition_id
}


provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster_thesis_hdm_25.kube_config[0].cluster_ca_certificate)
  }
}

resource "azurerm_resource_group" "rg-thesis" {
  name     = "thesis-25-hdm-stuttgart"
  location = "westeurope"
}
