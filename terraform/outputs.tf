output "resource_group_name" { value = azurerm_resource_group.lab.name }
output "aks_name" { value = azurerm_kubernetes_cluster.lab.name }
output "acr_name" { value = azurerm_container_registry.lab.name }
output "acr_login_server" { value = azurerm_container_registry.lab.login_server }
output "tenant_id" { value = data.azurerm_client_config.current.tenant_id }
output "service_principal_client_id" { value = azuread_application.deployer.client_id }
output "service_principal_object_id" { value = azuread_service_principal.deployer.object_id }
output "kubelet_object_id" { value = azurerm_kubernetes_cluster.lab.kubelet_identity[0].object_id }
