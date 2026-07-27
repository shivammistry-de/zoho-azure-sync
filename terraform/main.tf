terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-12taste-lakehouse-prod"
    storage_account_name = "smistry12tlakehouse"
    container_name       = "bronze"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true

  subscription_id = var.subscription_id != "" ? var.subscription_id : null
  tenant_id       = var.tenant_id != "" ? var.tenant_id : null
}

# 1. Reference Existing Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# 2. Reference Existing Storage Account
data "azurerm_storage_account" "adls" {
  name                = "${var.storage_prefix}lakehouse"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# 3. Reference Existing Databricks Workspace
data "azurerm_databricks_workspace" "databricks" {
  name                = var.databricks_workspace_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# 4. Medallion Layer Containers
resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_name  = data.azurerm_storage_account.adls.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
  name                  = "gold"
  storage_account_name  = data.azurerm_storage_account.adls.name
  container_access_type = "private"
}

# 5. Access Connector for Azure Databricks (Managed Identity for Unity Catalog)
resource "azurerm_databricks_access_connector" "uc_connector" {
  name                = "ac-${var.storage_prefix}-uc"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  identity {
    type = "SystemAssigned"
  }
}

# 6. Dedicated Storage Container for Unity Catalog Root Metastore
resource "azurerm_storage_container" "uc_metastore_root" {
  name                  = "uc-metastore-root"
  storage_account_name  = data.azurerm_storage_account.adls.name
  container_access_type = "private"
}