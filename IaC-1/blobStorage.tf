resource "azurerm_storage_account" "hdm-25-stg-storage-acc" {
  name                     = "hdm25storageaccount"
  resource_group_name      = azurerm_resource_group.rg-thesis.name
  location                 = azurerm_resource_group.rg-thesis.location
  account_tier             = "Standard"
  account_kind             = "BlobStorage"
  account_replication_type = "LRS"
  access_tier              = "Hot"
}

resource "azurerm_storage_container" "input-container" {
  name                  = "hdm25inpuptcontainer"
  storage_account_id    = azurerm_storage_account.hdm-25-stg-storage-acc.id
  container_access_type = "container"
}

resource "azurerm_storage_container" "output-container" {
  name                  = "hdm25outputcontainer"
  storage_account_id    = azurerm_storage_account.hdm-25-stg-storage-acc.id
  container_access_type = "container"
}