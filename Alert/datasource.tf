resource "grafana_data_source" "prometheus" {
  name   = "Prometheus"
  type   = "prometheus"
  access_mode = "proxy"
  url    = "http://prometheus-operated.monitoring.svc.cluster.local:9090"

  # json_data 대신 json_data_encoded 로 넘기세요
  json_data_encoded = jsonencode({
    # JSON 키 이름은 Grafana API 스펙에 맞춰 camelCase
    timeInterval = "30s"
  })
}
