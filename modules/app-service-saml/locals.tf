locals {
  # The application role values, which arrive in the assertion's roles claim.
  role_read  = "Customers.Read"
  role_write = "Customers.Write"

  # Fixed ids so an apply is deterministic and the app role assignments can name
  # a role without depending on the ordering of the app_role blocks.
  role_read_id  = "3a5b1c9e-7d24-4f61-9b0a-2e8c6d4f1a35"
  role_write_id = "9c2f7b41-05de-4a83-8f6d-1b7e3c9a2d64"

  # The identifier the application is known by in SAML. It is set as the
  # application's identifier URI, which populates the service principal's
  # servicePrincipalNames, the field the identity provider matches the
  # SAMLRequest's issuer against to find this enterprise application.
  entity_id = "api://customer-notes-saml"

  # The App Service name, used both as the resource name and to compose the
  # public hostname below.
  web_app_name = "${var.name_prefix}-app"

  # The port the container listens on inside App Service. App Service terminates
  # TLS and routes public traffic to the container on this port (WEBSITES_PORT).
  app_port = var.app_port

  # The public port Locally's App Service front door (furnace) listens on. Unlike
  # the Container Instance version of this example, the port a browser connects to
  # (5663, TLS-terminated by App Service) differs from the port the container
  # listens on (app_port). On Azure the public port is 443 and is implied, so this
  # is folded into app_public_url via the var override rather than exposed.
  furnace_port = 5663

  # The address a browser reaches the application on.
  #
  # App Service publishes a Linux web app at https://<name>.furnace.locally:<port>
  # (its default_hostname already carries the port). It is composed here rather
  # than read back from azurerm_linux_web_app.saml.default_hostname because
  # SAML_SP_ROOT_URL is an app setting on that same web app, so reading its
  # hostname would be a cycle. The reply URL below is composed from the same value
  # so the two always agree. The scheme is always https: App Service terminates
  # TLS for us, so unlike the Container Instance example there is no certificate to
  # inject and no plain-HTTP fallback.
  #
  # On Azure, set var.app_public_url to https://<name>.azurewebsites.net.
  app_public_url = coalesce(
    var.app_public_url,
    "https://${local.web_app_name}.furnace.locally:${local.furnace_port}",
  )

  # Where the identity provider POSTs the signed assertion back to. Registered as
  # the application's reply URL, which is where an identity-provider-initiated
  # sign-in reads the assertion consumer service URL from (there is no
  # AuthnRequest to carry it).
  acs_url = "${local.app_public_url}/saml/acs"

  # The identity-provider-initiated sign-in URL: Locally's SAML launch endpoint
  # for this application, named by its entity id. The application's sign-in page
  # links its button here (SIGN_IN_URL); the identity provider POSTs the assertion
  # back to acs_url once an identity is picked.
  sign_in_url = "${var.authority_host}/${data.azuread_client_config.current.tenant_id}/saml2/idp?sp=${urlencode(local.entity_id)}"
}
