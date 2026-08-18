module "application_insights" {
  source = "git@github.com:hmcts/terraform-module-application-insights?ref=4.x"

  env      = var.env
  product  = var.product
  name     = var.product
  location = var.location

  resource_group_name = azurerm_resource_group.juror_resource_group.name

  sampling_percentage = var.sampling_percentage

  common_tags = var.common_tags
}

moved {
  from = azurerm_application_insights.appinsights
  to   = module.application_insights.azurerm_application_insights.this
}


resource "azurerm_key_vault_secret" "app_insights_connection_string" {
  name         = "app-insights-connection-string"
  value        = module.application_insights.connection_string
  key_vault_id = module.juror-vault.key_vault_id
}

resource "azurerm_key_vault_secret" "azure_appinsights_key" {
  name         = "AppInsightsInstrumentationKey"
  value        = module.application_insights.instrumentation_key
  key_vault_id = module.juror-vault.key_vault_id
}

resource "azurerm_monitor_diagnostic_setting" "ai-ds" {
  name                           = "${var.product}-application_insights-${var.env}"
  target_resource_id             = module.application_insights.id
  eventhub_name                  = "azure-resource-events"
  eventhub_authorization_rule_id = "/subscriptions/8ae5b3b6-0b12-4888-b894-4cec33c92292/resourceGroups/soc-xsiam-eventhubs-prod-rg/providers/Microsoft.EventHub/namespaces/soc-prod-xsiam-eventhubns/authorizationRules/soc-xsiam-eventhub-namespace-sender"

  enabled_log {
    category = "AppRequests"
  }

  enabled_log {
    category = "AppExceptions"
  }

  enabled_log {
    category = "AppDependencies"
  }

  enabled_log {
    category = "AppTraces"
  }

  enabled_log {
    category = "AppAvailabilityResults"
  }

  enabled_log {
    category = "AppPerformanceCounters"
  }

  lifecycle {
    ignore_changes = [
      metric,
    ]
  }
}
