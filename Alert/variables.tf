variable "grafana_url" {
  type        = string
  description = "Grafana URL"
}

variable "grafana_api_key" {
  type        = string
  description = "Grafana API Key (sensitive)"
  sensitive   = true
}

variable "discord_webhook_url" {
  type        = string
  description = "Grafana URL"
}