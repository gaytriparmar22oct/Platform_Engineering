# ----------------------------------------------------------------------------
# GCP dev — Kubernetes cluster (GKE)
# ----------------------------------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/kubernetes-cluster.hcl"
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../terraform_cluster/modules/gke"
}

inputs = {
  # GCP-specific
  project_id   = "your-gcp-project-id"
  network_cidr = "10.40.0.0/16"
  subnet_cidr  = "10.40.0.0/22"
  pod_cidr     = "10.244.0.0/16"
  service_cidr = "10.50.0.0/16"

  # API server
  enable_private_nodes    = true
  enable_private_endpoint = false
  authorized_ip_ranges    = []

  # Identity
  enable_workload_identity = true
}
