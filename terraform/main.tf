terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote backend using the container bootstrapped in Step 1
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

# 3. Medallion Layer Containers (Silver and Gold)
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

# 4. Azure Databricks Workspace (Premium required for Unity Catalog)
resource "azurerm_databricks_workspace" "databricks" {
  name                = var.databricks_workspace_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "premium"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
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

# 7. Grant Storage Permissions to Unity Catalog's Identity
resource "azurerm_role_assignment" "uc_storage_assignment" {
  scope                = data.azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.uc_connector.identity[0].principal_id
}