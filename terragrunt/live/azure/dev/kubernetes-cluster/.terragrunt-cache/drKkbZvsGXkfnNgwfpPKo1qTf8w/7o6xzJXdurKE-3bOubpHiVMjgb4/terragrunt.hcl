# ----------------------------------------------------------------------------
# Azure dev — Kubernetes cluster (AKS)
# ----------------------------------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/kubernetes-cluster.hcl"
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../terraform_cluster/modules/aks"
}

inputs = {
  # Use the pre-existing resource group GaytriRG instead of creating one.
  resource_group_name   = "GaytriRG"
  create_resource_group = false

  # Networking
  vnet_address_space = ["10.40.0.0/16"]
  aks_subnet_cidr    = "10.40.0.0/22"
  pod_cidr           = "10.244.0.0/16"
  service_cidr       = "10.50.0.0/16"
  dns_service_ip     = "10.50.0.10"

  # Identity & RBAC
  enable_workload_identity = true
  enable_azure_rbac        = true
  admin_group_object_ids   = []

  # API server
  private_cluster_enabled = false
  authorized_ip_ranges    = []

  # Observability
  log_analytics_retention_days = 30
  enable_monitor_metrics       = false
}
