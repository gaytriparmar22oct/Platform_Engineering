# ----------------------------------------------------------------------------
# AWS dev — Kubernetes cluster (EKS)
# ----------------------------------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/kubernetes-cluster.hcl"
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../terraform_cluster/modules/eks"
}

inputs = {
  # AWS-specific
  vpc_cidr               = "10.40.0.0/16"
  private_subnet_cidrs   = ["10.40.0.0/20", "10.40.16.0/20", "10.40.32.0/20"]
  public_subnet_cidrs    = ["10.40.48.0/22", "10.40.52.0/22", "10.40.56.0/22"]
  availability_zones     = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # API server
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  authorized_ip_ranges            = []

  # IAM
  enable_irsa = true
}
