output "cluster_id" {
  description = "AKS cluster resource ID."
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "resource_group_name" {
  description = "Resource group hosting the cluster."
  value       = local.rg_name
}

output "location" {
  description = "Azure region."
  value       = local.rg_location
}

output "kube_config_raw" {
  description = "Raw kubeconfig (sensitive)."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "Kubelet managed identity (use for ACR pull, KV access)."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL (for workload identity federation)."
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "node_resource_group" {
  description = "Auto-managed node RG (MC_*)."
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID."
  value       = azurerm_log_analytics_workspace.this.id
}

output "vnet_id" {
  description = "VNet ID."
  value       = azurerm_virtual_network.this.id
}

output "aks_subnet_id" {
  description = "AKS subnet ID."
  value       = azurerm_subnet.aks.id
}
