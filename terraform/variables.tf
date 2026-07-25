variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
  default     = "0097149f-53b8-4433-869e-feb6129dbdc5"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID or Domain Name"
  default     = "jasperschouten12taste.onmicrosoft.com"
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