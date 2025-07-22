locals {
  alert_rule_files = fileset("${path.module}/Alert/rules", "*.yaml")

  alert_rule_data = {
    for filename in local.alert_rule_files :
    filename => file("${path.module}/Alert/rules/${filename}")
  }
}

resource "kubernetes_config_map" "grafana_alert_rules" {
  metadata {
    name      = "grafana-alert-rules"
    namespace = "monitoring"
    labels = {
      grafana_alert = "1"
    }
  }

  data = local.alert_rule_data
}