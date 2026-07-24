variable "subscription_id" {
  type        = string
  description = "The Azure Subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "The Azure Tenant ID or Domain"
}

variable "location" {
  type        = string
  default     = "centralindia"
}

variable "resource_group_name" {
  type        = string
  default     = "rg-12taste-lakehouse-prod"
}

variable "storage_prefix" {
  type        = string
  default     = "smistry12t"
}

variable "databricks_workspace_name" {
  type        = string
  default     = "dbw-12taste-prod"
}