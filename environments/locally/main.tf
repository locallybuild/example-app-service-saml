provider "azuread" {}

provider "azurerm" {
  features {}
}

module "app-service-saml" {
  source = "../../modules/app-service-saml"

  name_prefix = "locally-example-saml"
  location    = "berlin"
  tags = {
    ProvisionedVia = "Terraform"
  }

  authority_host = "https://auth.locally:5677" # Locally's authority, using its *.locally name, so that the container can fetch the metadata itself

  # Unlike the Container Instance version of this example, there is no TLS
  # certificate to inject: App Service terminates HTTPS at the platform, so the
  # application is reached over https://<name>.furnace.locally:5663 with the
  # certificate Locally generates at setup, and sign-in works in every browser.

  write_users = [
    "ada.lovelace@default.tenants.locally",
  ]
  read_users = [
    "grace.hopper@default.tenants.locally",
  ]
  write_service_principals = [
    "Default Identity",
  ]
}
