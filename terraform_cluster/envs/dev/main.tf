module "aks" {
  source = "../../modules/aks"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Networking
  vnet_address_space = ["10.40.0.0/16"]
  aks_subnet_cidr    = "10.40.0.0/22"
  pod_cidr           = "10.244.0.0/16"
  service_cidr       = "10.50.0.0/16"
  dns_service_ip     = "10.50.0.10"

  # Cluster sizing — mid-size, handles ~10 microservices comfortably
  system_node_vm_size = "Standard_D2s_v5" # 2 vCPU /  8 GB
  system_node_count   = 2

  user_node_vm_size   = "Standard_D4s_v5" # 4 vCPU / 16 GB
  user_node_min_count = 3
  user_node_max_count = 6
  user_node_max_pods  = 60

  # Identity / RBAC
  enable_workload_identity = true
  enable_azure_rbac        = true
  admin_group_object_ids   = var.admin_group_object_ids

  # API server exposure
  private_cluster_enabled = false
  authorized_ip_ranges    = var.authorized_ip_ranges

  # Observability — using kube-prometheus-stack via Helm later, so disable managed Prom
  enable_monitor_metrics       = false
  log_analytics_retention_days = 30
}
