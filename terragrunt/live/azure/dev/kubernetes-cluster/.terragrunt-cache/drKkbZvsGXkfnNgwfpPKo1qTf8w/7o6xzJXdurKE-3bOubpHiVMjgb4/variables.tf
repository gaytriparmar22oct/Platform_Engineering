############################
# Naming & location
############################
variable "name" {
  description = "Base name used for the AKS cluster and related resources."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group to deploy into. Created if create_resource_group = true."
  type        = string
}

variable "create_resource_group" {
  description = "Create the resource group instead of using an existing one."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

############################
# Networking
############################
variable "vnet_address_space" {
  description = "Address space for the VNet."
  type        = list(string)
  default     = ["10.40.0.0/16"]
}

variable "aks_subnet_cidr" {
  description = "CIDR for the AKS nodes subnet."
  type        = string
  default     = "10.40.0.0/22"
}

variable "pod_cidr" {
  description = "CIDR for pods (Azure CNI Overlay)."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  description = "Kubernetes service CIDR. Must not overlap VNet."
  type        = string
  default     = "10.50.0.0/16"
}

variable "dns_service_ip" {
  description = "Cluster DNS service IP. Must be inside service_cidr."
  type        = string
  default     = "10.50.0.10"
}

variable "authorized_ip_ranges" {
  description = "CIDRs allowed to reach the API server. Empty = open to internet (dev only)."
  type        = list(string)
  default     = []
}

############################
# Cluster
############################
variable "kubernetes_version" {
  description = "AKS Kubernetes version. Null = AKS default."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "AKS SKU tier (Free, Standard, Premium)."
  type        = string
  default     = "Standard"
}

variable "private_cluster_enabled" {
  description = "Make the API server private."
  type        = bool
  default     = false
}

############################
# System node pool (control-plane workloads only)
############################
variable "system_node_vm_size" {
  description = "VM size for the system node pool."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "system_node_count" {
  description = "System node pool count (fixed; small)."
  type        = number
  default     = 2
}

############################
# User node pool (your microservices)
############################
variable "user_node_vm_size" {
  description = "VM size for the user node pool. D4s_v5 = 4 vCPU / 16 GB."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "user_node_min_count" {
  description = "Minimum nodes in user pool."
  type        = number
  default     = 3
}

variable "user_node_max_count" {
  description = "Maximum nodes in user pool (autoscaler upper bound)."
  type        = number
  default     = 6
}

variable "user_node_max_pods" {
  description = "Max pods per node."
  type        = number
  default     = 60
}

############################
# Identity & RBAC
############################
variable "enable_workload_identity" {
  description = "Enable OIDC issuer + workload identity (recommended for IDP)."
  type        = bool
  default     = true
}

variable "enable_azure_rbac" {
  description = "Use Azure RBAC for Kubernetes authorization."
  type        = bool
  default     = true
}

variable "admin_group_object_ids" {
  description = "Entra ID group object IDs granted cluster-admin via Azure AD integration."
  type        = list(string)
  default     = []
}

############################
# Observability
############################
variable "log_analytics_retention_days" {
  description = "Retention for Log Analytics workspace."
  type        = number
  default     = 30
}

variable "enable_monitor_metrics" {
  description = "Enable Azure Monitor managed Prometheus (off by default; we use kube-prometheus-stack via Helm)."
  type        = bool
  default     = false
}
