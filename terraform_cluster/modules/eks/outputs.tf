# Same shape as aks/outputs.tf so downstream Terragrunt dependencies stay
# cloud-agnostic.
output "cluster_name" {
  value = local.cluster_name
}

output "cluster_id" {
  value = null # TODO: replace with module.eks.cluster_arn
}

output "oidc_issuer_url" {
  value = null # TODO: replace with module.eks.cluster_oidc_issuer_url
}
