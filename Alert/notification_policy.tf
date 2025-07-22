resource "grafana_notification_policy" "default_policy" {
  # 전체 정책 트리의 기본 contact point
  contact_point = grafana_contact_point.discord_point.name

  policy {
    matcher {
      action = "default"
    }
    contact_point = grafana_contact_point.discord_point.name
  }
}
