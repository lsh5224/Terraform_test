resource "grafana_contact_point" "discord_point" {
  name = "Discord-point"

  # arbitrary webhook integration
  webhook {
    url           = var.discord_webhook_url
    send_resolved = true
  }
}
