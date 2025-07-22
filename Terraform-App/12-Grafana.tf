resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  depends_on = [helm_release.prometheus]

  set {
    name  = "adminUser"
    value = "admin"
  }

  set {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }
}

variable "grafana_admin_password" {
  description = "Initial admin password for Grafana"
  type        = string
  sensitive   = true
}

