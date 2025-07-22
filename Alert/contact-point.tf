resource "grafana_contact_point" "discord_point" {
  name = "Discord-point"

  discord {
    url                     = var.discord_webhook_url
    disable_resolve_message = false
  }

  depends_on = [
  grafana_rule_group.app_alerts,
  grafana_notification_policy.default_policy,
  ]
}
