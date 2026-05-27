# ----------------------------------------------------------------------------
# Argo CD installer (cloud-agnostic).
# Reads kubeconfig from the cluster output and installs Argo CD via Helm.
# ----------------------------------------------------------------------------
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../terraform_cluster/modules/argocd"
}

dependency "cluster" {
  config_path = "../kubernetes-cluster"

  mock_outputs = {
    cluster_name        = "aks-mock"
    resource_group_name = "rg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

# Override the auto-generated provider to point helm/kubernetes at the AKS cluster.
generate "provider_k8s" {
  path      = "provider_k8s.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    data "azurerm_kubernetes_cluster" "this" {
      name                = "aks-idp-dev"
      resource_group_name = "GaytriRG"
    }

    provider "kubernetes" {
      host                   = data.azurerm_kubernetes_cluster.this.kube_config[0].host
      client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
      client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_key)
      cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
    }

    provider "helm" {
      kubernetes {
        host                   = data.azurerm_kubernetes_cluster.this.kube_config[0].host
        client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
        client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_key)
        cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
      }
    }

    # azurerm provider is needed for the data source above; declare required_providers here.
    terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
      }
    }
  EOF
}

inputs = {
  chart_version = "7.6.12"
  namespace     = "argocd"
}
