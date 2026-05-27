output "cluster_name" {
  value = local.cluster_name
}

output "cluster_id" {
  value = null # TODO: google_container_cluster.this.id
}

output "oidc_issuer_url" {
  value = null # GKE: workload identity pool URL
}
