# ---------------------------------------------------------------------------
# Resource Group - which contains the deployed resources
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "saml" {
  name     = "${var.name_prefix}-resources"
  location = var.location
  tags     = var.tags
}
