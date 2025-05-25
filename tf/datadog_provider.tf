terraform {
  required_providers {
    datadog = {
      source = "datadog/datadog"
      version = "~> 3.0"
      configuration_aliases = [datadog.mirror]
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.eu"
}

provider "datadog" {
  alias = "mirror"
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.eu"
}

resource "datadog_integration_aws" "main" {
  account_id                       = data.aws_caller_identity.current.account_id
  role_name                        = aws_iam_role.datadog_integration.name
  filter_tags                      = ["env:${var.environment}"]
  host_tags                        = ["env:${var.environment}"]
  account_specific_namespace_rules = {
    auto_scaling = true
    opsworks     = true
  }
  excluded_regions = []
}

# Obtener el ID de la cuenta AWS actual
data "aws_caller_identity" "current" {} 