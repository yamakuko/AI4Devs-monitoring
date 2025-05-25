variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog Application Key"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "team" {
  description = "Nombre del equipo responsable, requerido por la política de tags de Datadog."
  type        = string
  default     = "devops"
}
