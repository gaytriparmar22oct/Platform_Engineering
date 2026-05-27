############################
# Locals
############################
locals {
  cluster_name = "aks-${var.name}"
  base_tags = merge(
    {
      "managed-by" = "terraform"
      "platform"   = "idp"
      "component"  = "aks"
    },
    var.tags
  )
}

############################
# Resource group
############################
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = local.base_tags
}

data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  rg_name     = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.existing[0].name
  rg_location = var.create_resource_group ? azurerm_resource_group.this[0].location : data.azurerm_resource_group.existing[0].location
}

############################
# Networking (VNet + Subnet)
############################
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  address_space       = var.vnet_address_space
  tags                = local.base_tags
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.name}"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aks_subnet_cidr]
}

############################
# Log Analytics for container insights
############################
resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.name}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  tags                = local.base_tags
}

############################
# AKS cluster
############################
resource "azurerm_kubernetes_cluster" "this" {
  name                              = local.cluster_name
  location                          = local.rg_location
  resource_group_name               = local.rg_name
  dns_prefix                        = "aks-${var.name}"
  kubernetes_version                = var.kubernetes_version
  sku_tier                          = var.sku_tier
  private_cluster_enabled           = var.private_cluster_enabled
  oidc_issuer_enabled               = var.enable_workload_identity
  workload_identity_enabled         = var.enable_workload_identity
  azure_policy_enabled              = true
  role_based_access_control_enabled = true

  # System pool — small, taints user workloads off
  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    node_count                   = var.system_node_count
    vnet_subnet_id               = azurerm_subnet.aks.id
    only_critical_addons_enabled = true
    orchestrator_version         = var.kubernetes_version
    os_disk_size_gb              = 64
    type                         = "VirtualMachineScaleSets"
    tags                         = local.base_tags
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "calico"
    load_balancer_sku   = "standard"
    pod_cidr            = var.pod_cidr
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    outbound_type       = "loadBalancer"
  }

  dynamic "api_server_access_profile" {
    for_each = length(var.authorized_ip_ranges) > 0 ? [1] : []
    content {
      authorized_ip_ranges = var.authorized_ip_ranges
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_azure_rbac ? [1] : []
    content {
      azure_rbac_enabled     = true
      admin_group_object_ids = var.admin_group_object_ids
    }
  }

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.this.id
    msi_auth_for_monitoring_enabled = true
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  dynamic "monitor_metrics" {
    for_each = var.enable_monitor_metrics ? [1] : []
    content {}
  }

  tags = local.base_tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version,
    ]
  }
}

############################
# User node pool — your microservices land here
############################
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "apps"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.user_node_vm_size
  vnet_subnet_id        = azurerm_subnet.aks.id
  orchestrator_version  = var.kubernetes_version

  auto_scaling_enabled = true
  min_count            = var.user_node_min_count
  max_count            = var.user_node_max_count
  max_pods             = var.user_node_max_pods

  os_disk_size_gb = 128
  os_disk_type    = "Managed"
  mode            = "User"

  node_labels = {
    "workload" = "apps"
  }

  upgrade_settings {
    max_surge = "33%"
  }

  tags = local.base_tags

  lifecycle {
    ignore_changes = [node_count]
  }
}
