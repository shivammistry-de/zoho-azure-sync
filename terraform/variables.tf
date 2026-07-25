variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
  default     = null
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
  default     = null
}

variable "location" {
  type        = string
  description = "Azure Region"
  default     = "centralindia"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
  default     = "rg-12taste-lakehouse-prod"
}

variable "storage_prefix" {
  type        = string
  description = "Prefix for Storage Accounts"
  default     = "smistry12t"
}

variable "databricks_workspace_name" {
  type        = string
  description = "Databricks Workspace Name"
  default     = "dbw-12taste-prod"
}