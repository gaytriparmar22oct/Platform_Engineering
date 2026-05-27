# ----------------------------------------------------------------------------
# Azure Container Registry (ACR) for the dev environment.
# Depends on the kubernetes-cluster component for the kubelet identity.
# ----------------------------------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../terraform_cluster/modules/acr"
}

dependency "cluster" {
  config_path = "../kubernetes-cluster"

  mock_outputs = {
    resource_group_name = "GaytriRG"
    kubelet_identity = [{
      object_id = "00000000-0000-0000-0000-000000000000"
    }]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

inputs = {
  resource_group_name      = dependency.cluster.outputs.resource_group_name
  aks_kubelet_principal_id = dependency.cluster.outputs.kubelet_identity[0].object_id

  sku           = "Standard"
  admin_enabled = false
}
