resource "grafana_contact_point" "discord_point" {
  name = "Discord-point"

  # Discord 통합 블록 사용
  discord {
    url                      = var.discord_webhook_url
    # 기본값이 false 이므로 생략해도 됩니다만,
    # 해제 메시지를 보내고 싶다면 false 로 명시할 수 있습니다.
    disable_resolve_message  = false
  }
}
