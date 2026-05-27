# ----------------------------------------------------------------------------
# GKE module (STUB — implement to match the aks/ interface)
# ----------------------------------------------------------------------------
# Recommended implementation: wrap terraform-google-modules/kubernetes-engine
# (private-cluster submodule) and expose the variables declared in variables.tf.
# ----------------------------------------------------------------------------

locals {
  cluster_name = "gke-${var.name}"
  base_tags = merge(
    {
      "managed-by" = "terraform"
      "platform"   = "idp"
      "component"  = "gke"
    },
    var.tags,
  )
}

# TODO: VPC + subnet + secondary ranges for pods/services
# TODO: GKE cluster (regional, private nodes) via terraform-google-modules
# TODO: Node pools (system + apps) using var.system_node_vm_size / var.user_node_vm_size
# TODO: Workload Identity binding
