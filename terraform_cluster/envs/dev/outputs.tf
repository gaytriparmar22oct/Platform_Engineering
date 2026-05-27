output "cluster_name" {
  value = module.aks.cluster_name
}

output "resource_group_name" {
  value = module.aks.resource_group_name
}

output "node_resource_group" {
  value = module.aks.node_resource_group
}

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "get_credentials_cmd" {
  description = "Run this to configure kubectl."
  value       = "az aks get-credentials --resource-group ${module.aks.resource_group_name} --name ${module.aks.cluster_name} --overwrite-existing"
}
