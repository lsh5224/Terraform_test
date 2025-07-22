resource "grafana_notification_policy" "default_policy" {
  # 알림을 묶을 레이블 키 (일반적으로 alertname 사용)
  group_by      = ["alertname"]
  # Default route의 Contact Point로 Discord-point 지정
  contact_point = grafana_contact_point.discord_point.name

  # (선택) 그룹화 및 반복 타이밍을 조정하려면 아래 옵션 추가
  # group_wait     = "30s"
  # group_interval = "5m"
  # repeat_interval = "1h"
}
