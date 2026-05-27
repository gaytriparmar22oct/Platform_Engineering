# ----------------------------------------------------------------------------
# Common inputs for the "kubernetes-cluster" service across clouds.
#
# Each cloud-specific module (aks, eks, gke) accepts the SAME variable names
# defined here. Cloud-specific knobs (resource_group_name, vpc_cidr, project_id)
# are supplied in the leaf terragrunt.hcl.
# ----------------------------------------------------------------------------

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  cloud    = local.env_vars.locals.cloud
  env      = local.env_vars.locals.env

  # Sensible mid-size defaults for ~10 microservices
  cluster_defaults = {
    kubernetes_version = null

    # System node pool — control-plane workloads only
    system_node_count = 2

    # User node pool — your microservices
    user_node_min_count = 3
    user_node_max_count = 6
    user_node_max_pods  = 60
  }

  # Per-cloud machine type mapping (≈ 2 vCPU / 8 GB for system, 4 vCPU / 16 GB for user)
  vm_sizes = {
    azure = {
      system = "Standard_D2s_v5"
      user   = "Standard_D4s_v5"
    }
    aws = {
      system = "m6i.large"   # 2 vCPU / 8 GB
      user   = "m6i.xlarge"  # 4 vCPU / 16 GB
    }
    gcp = {
      system = "e2-standard-2"
      user   = "e2-standard-4"
    }
  }
}

inputs = merge(
  local.cluster_defaults,
  {
    system_node_vm_size = local.vm_sizes[local.cloud].system
    user_node_vm_size   = local.vm_sizes[local.cloud].user
  },
)
