locals {
  # The application image, pulled from Docker Hub. A multi-arch build carrying
  # both linux/amd64 and linux/arm64, so it runs on Apple Silicon (Locally) and
  # on Azure App Service alike.
  source_image = var.container_image

  # The tag the image is stored under inside the Locally Container Registry once
  # imported. Derived from the source so the App Service pulls the same version.
  image_name = "customer-notes-crm-saml:${local.image_version}"

  # The version portion of the source image tag (everything after the last ":").
  image_version = element(split(":", local.source_image), length(split(":", local.source_image)) - 1)
}

# ---------------------------------------------------------------------------
# Container Registry - for storing the Container Image within Locally.
#
# App Service pulls the image from here rather than from Docker Hub directly.
# This isn't strictly necessary for a public image, but it mirrors how you'd
# host a private image on Azure and demonstrates importing one into Locally.
# ---------------------------------------------------------------------------
resource "azurerm_container_registry" "saml" {
  name                = "${replace(var.name_prefix, "-", "")}acr"
  resource_group_name = azurerm_resource_group.saml.name
  location            = azurerm_resource_group.saml.location
  sku                 = "Basic"
  admin_enabled       = true
}

# ---------------------------------------------------------------------------
# Import the CRM image from Docker Hub into the Locally ACR.
#
# Uses the Azure CLI to import the image, the same as you would against Azure.
# ---------------------------------------------------------------------------
resource "terraform_data" "import_image" {
  triggers_replace = [
    local.source_image,
    local.image_name,
    azurerm_container_registry.saml.login_server,
  ]

  provisioner "local-exec" {
    command = "az acr import --name ${azurerm_container_registry.saml.name} --source ${local.source_image} --image ${local.image_name} --force"
  }
}
