variable "grafana_api_key" {
  type      = string
  sensitive = true
}

provider "grafana" {
  url  = "http://k8s-monitori-grafanai-da2b011f10-124882021.ap-northeast-2.elb.amazonaws.com"
  auth = var.grafana_api_key
}

resource "grafana_data_source" "prometheus" {
  name = "Prometheus"
  type = "prometheus"
  url  = "http://prometheus-server.monitoring.svc.cluster.local:80" # ← 클러스터 내 주소

  json_data = jsonencode({
    timeInterval = "30s"
  })
}

resource "grafana_contact_point" "discord" {
  name = "discord-contact"
  type = "discord"

  settings = jsonencode({
    url = "https://discord.com/api/webhooks/1392319208339144847/H2XrOcmDERVVOSX45sHuPSmkg_ZZ1AEym8E62WhufAjPIQZ6u45G5kGmmkkasqoz6W20"
  })
}

resource "grafana_folder" "my_folder" {
  title = "My Rule Folder"
}

resource "grafana_rule_group" "my_alert_rule_group" {
  name              = "My Alert Rules"
  folder_uid        = grafana_folder.my_folder.uid
  interval_seconds  = 60
  org_id            = 1

  rule {
    name      = "My Random Walk Alert"
    condition = "C"
    for       = "0s"

    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = grafana_data_source.prometheus.uid
      model = jsonencode({
        intervalMs     = 1000
        maxDataPoints  = 43200
        refId          = "A"
      })
    }

    data {
      datasource_uid = "__expr__"
      ref_id         = "B"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = <<EOT
{
  "conditions": [{
    "evaluator": { "params": [70], "type": "gt" },
    "operator": { "type": "and" },
    "query": { "params": ["A"] },
    "reducer": { "type": "last" },
    "type": "query"
  }],
  "datasource": {
    "name": "Expression",
    "type": "__expr__",
    "uid": "__expr__"
  },
  "expression": "A",
  "hide": false,
  "intervalMs": 1000,
  "maxDataPoints": 43200,
  "refId": "B",
  "type": "reduce"
}
EOT
    }

    data {
      datasource_uid = "__expr__"
      ref_id         = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        expression = "$B > 70"
        type       = "math"
        refId      = "C"
      })
    }
  }
}

resource "grafana_rule_group" "pod_alert_rules" {
  name              = "Pod Alert Rules"
  folder_uid        = grafana_folder.my_folder.uid
  interval_seconds  = 60
  org_id            = 1

  rule {
    name = "Pod frontend 죽음"
    condition = "A"
    for       = "0s"

    data {
      ref_id = "A"
      datasource_uid = grafana_data_source.prometheus.uid
      relative_time_range {
        from = 60
        to   = 0
      }
      model = jsonencode({
        expr = "absent(kube_pod_status_phase{namespace=\"default\", pod=~\"frontend-.*\", phase=\"Running\"})"
        interval = ""
        legendFormat = "frontend pod down"
        refId = "A"
      })
    }
  }

  rule {
    name = "Pod frontend 살아있음"
    condition = "A"
    for       = "0s"

    data {
      ref_id = "A"
      datasource_uid = grafana_data_source.prometheus.uid
      relative_time_range {
        from = 60
        to   = 0
      }
      model = jsonencode({
        expr = "kube_pod_status_phase{namespace=\"default\", pod=~\"frontend-.*\", phase=\"Running\"} > 0"
        interval = ""
        legendFormat = "frontend pod alive"
        refId = "A"
      })
    }
  }

  # 아래는 boards, users 알림 4개 추가 필요 (복사 붙여넣기해서 pod 이름만 바꾸면 됨)
}
