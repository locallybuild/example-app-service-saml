data "azuread_client_config" "current" {}

resource "azuread_application" "customer_notes" {
  display_name    = "Customer Notes"
  identifier_uris = [local.entity_id]
  owners          = [data.azuread_client_config.current.object_id]

  web {
    # The assertion consumer service URL, composed rather than read from the App
    # Service's hostname: an IdP-initiated sign-in reads the ACS from here (there
    # is no AuthnRequest to carry it), and it must match the SAML_SP_ROOT_URL the
    # container is given.
    redirect_uris = [local.acs_url]
  }

  app_role {
    id = local.role_read_id
    # User and Application both, so a service principal can hold this role as
    # well as a person, which is what lets read_service_principals be assigned it
    # below.
    allowed_member_types = ["User", "Application"]
    display_name         = "Customers.Read"
    description          = "See customers and the notes on their records."
    value                = local.role_read
    enabled              = true
  }

  app_role {
    id = local.role_write_id
    # Application as well as User, so a service principal can hold this role,
    # which is what lets Locally's Default Identity be assigned it below.
    allowed_member_types = ["User", "Application"]
    display_name         = "Customers.Write"
    description          = "Add customers, and add notes to their records."
    value                = local.role_write
    enabled              = true
  }
}

resource "azuread_service_principal" "customer_notes" {
  client_id = azuread_application.customer_notes.client_id
  owners    = [data.azuread_client_config.current.object_id]

  # SAML, rather than the OpenID Connect default.
  preferred_single_sign_on_mode = "saml"

  # Without this, anyone in the directory could sign in. With it, the identity
  # provider refuses a user who holds no application role assignment, so an
  # identity left out of the lists below reaches "not assigned to this
  # application" (AADSTS50105) and never reaches the application at all.
  app_role_assignment_required = true
}
