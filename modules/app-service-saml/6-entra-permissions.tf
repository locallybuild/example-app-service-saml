# The identities are looked up rather than created: Locally seeds every tenant
# with a directory of people, groups and service principals, and an example that
# added its own would leave a second Ada Lovelace behind in a directory that
# already has one. Users are matched by user principal name and service
# principals by display name, one lookup per entry via for_each.
data "azuread_user" "write" {
  for_each            = toset(var.write_users)
  user_principal_name = each.value
}

data "azuread_user" "read" {
  for_each            = toset(var.read_users)
  user_principal_name = each.value
}

data "azuread_service_principal" "write" {
  for_each     = toset(var.write_service_principals)
  display_name = each.value
}

data "azuread_service_principal" "read" {
  for_each     = toset(var.read_service_principals)
  display_name = each.value
}

# One application role assignment per identity, binding it to the role its list
# names. The map key is the principal's own name, so the assignment's address in
# state stays stable as the lists change.
resource "azuread_app_role_assignment" "user_write" {
  for_each            = data.azuread_user.write
  app_role_id         = local.role_write_id
  principal_object_id = each.value.object_id
  resource_object_id  = azuread_service_principal.customer_notes.object_id
}

resource "azuread_app_role_assignment" "user_read" {
  for_each            = data.azuread_user.read
  app_role_id         = local.role_read_id
  principal_object_id = each.value.object_id
  resource_object_id  = azuread_service_principal.customer_notes.object_id
}

resource "azuread_app_role_assignment" "sp_write" {
  for_each            = toset(var.write_service_principals)
  app_role_id         = local.role_write_id
  principal_object_id = data.azuread_service_principal.write[each.key].object_id
  resource_object_id  = azuread_service_principal.customer_notes.object_id
}

resource "azuread_app_role_assignment" "sp_read" {
  for_each            = toset(var.read_service_principals)
  app_role_id         = local.role_read_id
  principal_object_id = data.azuread_service_principal.read[each.key].object_id
  resource_object_id  = azuread_service_principal.customer_notes.object_id
}
