output "application_url" {
  description = "Where to reach the application in a browser."
  value       = local.app_public_url
}

output "sign_in_as" {
  description = "The identities that can sign in, and the application role each holds. Sign in as one of these at the application's sign-in page."
  value = merge(
    { for u in var.write_users : u => "Customers.Write" },
    { for u in var.read_users : u => "Customers.Read" },
    { for s in var.write_service_principals : s => "Customers.Write" },
    { for s in var.read_service_principals : s => "Customers.Read" },
  )
}

output "resource_group" {
  description = "The resource group containing the deployed resources."
  value       = azurerm_resource_group.saml.name
}

output "acr_login_server" {
  description = "ACR login server the image is imported into and pulled from (<name>.dockhand.locally:5667)."
  value       = azurerm_container_registry.saml.login_server
}
