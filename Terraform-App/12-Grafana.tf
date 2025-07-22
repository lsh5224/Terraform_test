resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  depends_on = [helm_release.prometheus]

  # 기존 admin 계정 설정
  set {
    name  = "adminUser"
    value = "admin"
  }
  set {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }
  set {
    name  = "sidecar.alerts.enabled"
    value = "true"
  }

  set {
    name  = "sidecar.alerts.defaultFolderName"
    value = "Alert Rules"
  }

  set {
    name  = "sidecar.alerts.folder"
    value = "/etc/grafana/provisioning/rules"
  }

  set {
    name  = "extraVolumeMounts[0].name"
    value = "alert-rules"
  }

  set {
    name  = "extraVolumeMounts[0].mountPath"
    value = "/etc/grafana/provisioning/rules"
  }

  set {
    name  = "extraVolumes[0].name"
    value = "alert-rules"
  }

  set {
    name  = "extraVolumes[0].configMap.name"
    value = kubernetes_config_map.grafana_alert_rules.metadata[0].name
  }
  # ① sidecar 활성화 (프로비저닝 파일을 읽어들이는 사이드카)
  set {
    name  = "sidecar.datasources.enabled"
    value = "true"
  }

  # ② 데이터소스 정의: datasources.datasources.yaml 파일로 전달
  values = [
    <<-EOF
    datasources:
      datasources.yaml:
        apiVersion: 1
        datasources:
          - name: Prometheus
            type: prometheus
            access: proxy
            url: http://prometheus-server.monitoring.svc.cluster.local:80
            isDefault: true
    EOF
  ]
}


variable "grafana_admin_password" {
  description = "Initial admin password for Grafana"
  type        = string
  sensitive   = true
}

