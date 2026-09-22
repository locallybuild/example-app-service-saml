# ---------------------------------------------------------------------------
# App Service Plan - houses the App Service running the custom container.
# ---------------------------------------------------------------------------
resource "azurerm_service_plan" "saml" {
  name                = "${var.name_prefix}-plan"
  resource_group_name = azurerm_resource_group.saml.name
  location            = azurerm_resource_group.saml.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# ---------------------------------------------------------------------------
# Linux App Service - runs the SAML-powered CRM from the container registry.
#
# Unlike the Container Instance version of this example, the application does
# NOT serve HTTPS itself: App Service terminates TLS at the platform, so the
# browser always reaches it over HTTPS (…furnace.locally:5663) while the
# container serves plain HTTP on WEBSITES_PORT. That's why there's no TLS
# certificate to inject here - the front door already has one.
# ---------------------------------------------------------------------------
resource "azurerm_linux_web_app" "saml" {
  name                = local.web_app_name
  resource_group_name = azurerm_resource_group.saml.name
  location            = azurerm_service_plan.saml.location
  service_plan_id     = azurerm_service_plan.saml.id

  site_config {
    application_stack {
      docker_image_name        = local.image_name
      docker_registry_url      = "https://${azurerm_container_registry.saml.login_server}"
      docker_registry_username = azurerm_container_registry.saml.admin_username
      docker_registry_password = azurerm_container_registry.saml.admin_password
    }
  }

  app_settings = {
    # The port the container listens on. App Service routes the public
    # …furnace.locally:5663 traffic to the container on this port.
    "WEBSITES_PORT" = tostring(local.app_port)
    "LISTEN_ADDR"   = ":${local.app_port}"

    # The identifier the application is known by in SAML (its entity id / audience).
    "SAML_SP_ENTITY_ID" = local.entity_id

    # The public base URL the application is reached on. The application composes
    # its assertion consumer service and metadata URLs from this, so it must match
    # the reply URL registered on the application in 5-entra-application.tf. This is
    # the HTTPS address App Service publishes - the platform terminates TLS for us.
    "SAML_SP_ROOT_URL" = local.app_public_url

    # The identity provider's SAML metadata URL, fetched by the application at
    # startup. On Locally the authority is reached at its *.locally name so the
    # container can resolve and trust it (see var.authority_host); against Azure
    # this is https://login.microsoftonline.com.
    "SAML_IDP_METADATA_URL" = "${var.authority_host}/${data.azuread_client_config.current.tenant_id}/federationmetadata/2007-06/federationmetadata.xml"

    # Where the application's sign-in page sends the user to begin sign-in.
    # Sign-in is identity-provider-initiated: the app never redirects to the IdP,
    # so an unauthenticated visitor is shown a sign-in page whose button points
    # here, at Locally's SAML launch endpoint for this application. The IdP then
    # POSTs the assertion back to the reply URL registered on the application.
    "SIGN_IN_URL" = local.sign_in_url
  }

  # The image must exist in the registry before the App Service starts pulling it.
  depends_on = [terraform_data.import_image]
}
