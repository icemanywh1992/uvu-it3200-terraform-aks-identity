data "azurerm_client_config" "current" {}

locals {
  suffix    = "uvu-it3200-${var.student_id}"
  namespace = "lab"
}

# --------------------------------------------------
# Azure Resource Group
# --------------------------------------------------

resource "azurerm_resource_group" "lab" {
  name     = "rg-${local.suffix}"
  location = var.location
}

# --------------------------------------------------
# Azure Container Registry (ACR)
# --------------------------------------------------

resource "azurerm_container_registry" "lab" {
  name                = "acruvuit3200${var.student_id}${var.acr_unique_suffix}"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  sku                 = "Basic"
  admin_enabled       = false
}

# --------------------------------------------------
# Azure Kubernetes Service (AKS)
# --------------------------------------------------

resource "azurerm_kubernetes_cluster" "lab" {
  name                              = "aks-${local.suffix}"
  location                          = azurerm_resource_group.lab.location
  resource_group_name               = azurerm_resource_group.lab.name
  dns_prefix                        = "aks-${local.suffix}"
  sku_tier                          = "Free"
  role_based_access_control_enabled = true
  local_account_disabled            = true

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  # Microsoft Entra ID authentication and Azure RBAC
  azure_active_directory_role_based_access_control {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled = true
  }
}

# --------------------------------------------------
# Microsoft Entra ID Application
# --------------------------------------------------

resource "azuread_application" "deployer" {
  display_name = "sp-${local.suffix}-deployer"
}

# --------------------------------------------------
# Microsoft Entra ID Service Principal
# --------------------------------------------------

resource "azuread_service_principal" "deployer" {
  client_id = azuread_application.deployer.client_id
}

# No client secret is created by Terraform.
# If needed for testing, create credentials separately
# and store them securely.

# --------------------------------------------------
# Grant AKS Kubelet Identity Access to ACR
# --------------------------------------------------

resource "azurerm_role_assignment" "kubelet_acr_pull" {
  scope                            = azurerm_container_registry.lab.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.lab.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

# --------------------------------------------------
# Allow Service Principal to Retrieve AKS Credentials
# --------------------------------------------------

resource "azurerm_role_assignment" "deployer_cluster_user" {
  scope                = azurerm_kubernetes_cluster.lab.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_service_principal.deployer.object_id
}

# --------------------------------------------------
# Give Service Principal AKS Read Access
# --------------------------------------------------

resource "azurerm_role_assignment" "deployer_reader" {
  scope                = azurerm_kubernetes_cluster.lab.id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = azuread_service_principal.deployer.object_id
}

# --------------------------------------------------
# Give Service Principal Namespace-Scoped Write Access
# --------------------------------------------------

# The lab namespace must be created by an authorized
# bootstrap identity before the service principal
# attempts to deploy workloads into it.

resource "azurerm_role_assignment" "deployer_namespace_writer" {
  scope                = "${azurerm_kubernetes_cluster.lab.id}/namespaces/${local.namespace}"
  role_definition_name = "Azure Kubernetes Service RBAC Writer"
  principal_id         = azuread_service_principal.deployer.object_id
}