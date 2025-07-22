resource "grafana_contact_point" "discord_point" {
  name = "Discord-point"

  discord {
    url                     = var.discord_webhook_url
    disable_resolve_message = false
  }
}
