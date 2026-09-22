# ---------------------------------------------------------------------------
# Log Analytics - for storing the application's logs
# ---------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "saml" {
  name                = "${var.name_prefix}-logs"
  resource_group_name = azurerm_resource_group.saml.name
  location            = azurerm_resource_group.saml.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---------------------------------------------------------------------------
# Diagnostic settings - ship the Console Logs into the Log Analytics Workspace
# so they are KQL-queryable in the Monitoring -> Telemetry UI.
#
# Within the Locally Dashboard these can be queried using:
#   AppServiceConsoleLogs | order by TimeGenerated desc
# which is handy for watching the SAML sign-in flow as you exercise it.
# ---------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "saml" {
  name                       = "console-logs"
  target_resource_id         = azurerm_linux_web_app.saml.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.saml.id

  enabled_log {
    category = "AppServiceConsoleLogs"
  }
}
