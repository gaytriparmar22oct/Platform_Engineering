variable "name" {
  description = "Base name; ACR name will be derived (must be globally unique, alphanumeric)."
  type        = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  description = "ACR SKU (Basic, Standard, Premium)."
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Enable admin user (avoid in production; use AAD/managed identity instead)."
  type        = bool
  default     = false
}

variable "aks_kubelet_principal_id" {
  description = "kubelet identity principalId from the AKS module; granted AcrPull."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
