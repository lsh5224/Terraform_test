resource "grafana_data_source" "prometheus" {
  name   = "Prometheus"
  type   = "prometheus"
  access = "proxy"
  url    = "http://prometheus-operated.monitoring.svc.cluster.local:9090"

  json_data = {
    time_interval = "30s"
  }
}
