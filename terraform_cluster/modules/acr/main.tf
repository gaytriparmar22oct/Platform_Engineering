locals {
  # ACR name: alphanumeric only, 5-50 chars, globally unique.
  acr_name = lower(replace("acr${var.name}", "/[^a-z0-9]/", ""))

  base_tags = merge(
    {
      "managed-by" = "terraform"
      "platform"   = "idp"
      "component"  = "acr"
    },
    var.tags,
  )
}

resource "azurerm_container_registry" "this" {
  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  tags                = local.base_tags
}

# Grant AKS kubelet identity AcrPull so the cluster can pull images.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = var.aks_kubelet_principal_id
  skip_service_principal_aad_check = true
}
