output "application_url" {
  description = "Where to reach the application in a browser."
  value       = module.app-service-saml.application_url
}

output "sign_in_url" {
  description = "Where sign-in begins: Locally's SAML launch endpoint for this application."
  value       = module.app-service-saml.sign_in_url
}

output "sign_in_as" {
  description = "The identities that can sign in, and the application role each holds."
  value       = module.app-service-saml.sign_in_as
}
