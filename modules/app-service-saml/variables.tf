variable "name_prefix" {
  description = "The prefix used for all resources in this example."
  type        = string
}

variable "location" {
  description = "The region where these resources should be deployed."
  type        = string
}

variable "tags" {
  description = "A mapping of tags which should be applied to each of the resources."
  type        = map(string)
  default     = {}
}

# The identities assigned an application role. Users are given by user principal
# name and service principals by display name; each is looked up in the directory
# rather than created (see the for_each blocks in 6-entra-permissions.tf). Anyone
# not listed holds no role, and the identity provider refuses them, which is how
# the "access denied" case is reached without naming it explicitly.
variable "write_users" {
  description = "User principal names to assign the Customers.Write application role."
  type        = list(string)
  default     = []
}

variable "read_users" {
  description = "User principal names to assign the Customers.Read application role."
  type        = list(string)
  default     = []
}

variable "write_service_principals" {
  description = "Service principal display names to assign the Customers.Write application role."
  type        = list(string)
  default     = []
}

variable "read_service_principals" {
  description = "Service principal display names to assign the Customers.Read application role."
  type        = list(string)
  default     = []
}

variable "container_image" {
  description = <<-EOT
    The application image imported into the Locally Container Registry and run by
    App Service, pulled from Docker Hub.

    The default is a multi-arch build carrying both linux/amd64 (Azure App
    Service) and linux/arm64 (Apple Silicon), so it runs on either. To run
    unpublished local source instead, build and push it into a registry App
    Service can reach and point this at that tag.
  EOT
  type        = string
  default     = "docker.io/tombuildsstuff/customer-notes-crm-saml:latest"
}

variable "app_public_url" {
  description = <<-EOT
    The public base URL the application is reached on. The SAML reply URL and the
    application's own entity metadata hang off this.

    Leave it unset on Locally: the default is composed from the App Service name as
    https://<name>.furnace.locally:5663, the HTTPS address App Service publishes
    (its front door terminates TLS, so the scheme is always https).

    On Azure, set it to https://<name>.azurewebsites.net.

    It is a variable rather than being read from the web app because the
    application registration's reply URL is needed before the web app exists, and
    because the two platforms compose the address differently.
  EOT
  type        = string
  default     = null
}

variable "app_port" {
  description = "The port the application listens on inside the container (WEBSITES_PORT). App Service routes public traffic to the container on this port."
  type        = number
  default     = 8080
}

variable "authority_host" {
  description = <<-EOT
    The identity provider's base URL, used to build the SAML federation metadata
    URL the application fetches and the sign-in URL the browser is sent to.

    On Locally this must be the authority's *.locally name (auth.locally), not the
    127.0.0.1 loopback that ARM_ACTIVE_DIRECTORY_AUTHORITY_HOST carries: the
    container fetches the metadata itself, and 127.0.0.1 inside a container is the
    container. auth.locally resolves from both the container (via Locally's
    container DNS) and the host browser, and the Locally certificate covers it.

    Against Azure, set it to https://login.microsoftonline.com.
  EOT
  type        = string
  default     = "https://auth.locally:5677"
}
