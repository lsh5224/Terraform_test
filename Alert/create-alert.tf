# ./alert/rule_group.tf

resource "grafana_rule_group" "app_alerts" {
  name             = "Application Alerts"
  folder_uid       = grafana_folder.alerts.uid
  interval_seconds = 60   # 1분마다 평가

  # 1) board-xxx Pod 비정상(Non-Running) 감지
  rule {
    name      = "Board Pods Down"
    condition = "A"
    for       = "1m"

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.prometheus.uid

      # ← 꼭 추가!
      relative_time_range {
        from = 60
        to   = 0
      }

      model = jsonencode({
        expr  = "sum(kube_pod_status_phase{pod=~\"board-.*\",phase!=\"Running\"}) by (pod) > 0"
        refId = "A"
      })
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  # 2) users-xxx Pod 비정상 감지
  rule {
    name      = "Users Pods Down"
    condition = "A"
    for       = "1m"

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.prometheus.uid

      relative_time_range {
        from = 60
        to   = 0
      }

      model = jsonencode({
        expr  = "sum(kube_pod_status_phase{pod=~\"users-.*\",phase!=\"Running\"}) by (pod) > 0"
        refId = "A"
      })
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  # 3) frontend-xxx Pod 비정상 감지
  rule {
    name      = "Frontend Pods Down"
    condition = "A"
    for       = "1m"

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.prometheus.uid

      relative_time_range {
        from = 60
        to   = 0
      }

      model = jsonencode({
        expr  = "sum(kube_pod_status_phase{pod=~\"frontend-.*\",phase!=\"Running\"}) by (pod) > 0"
        refId = "A"
      })
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  # 4) board-xxx Pod 정상(Running) 감지
  rule {
    name      = "Board Pods OK"
    condition = "A"
    for       = "1m"

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.prometheus.uid

      relative_time_range {
        from = 60
        to   = 0
      }

      model = jsonencode({
        expr  = "sum(kube_pod_status_phase{pod=~\"board-.*\",phase=\"Running\"}) by (pod) > 0"
        refId = "A"
      })
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  # 5) users-xxx Pod 정상 감지
  rule {
    name      = "Users Pods OK"
    condition = "A"
    for       = "1m"

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.prometheus.uid

      relative_time_range {
        from = 60
        to   = 0
      }

      model = jsonencode({
        expr  = "sum(kube_pod_status_phase{pod=~\"users-.*\",phase=\"Running\"}) by (pod) > 0"
        refId = "A"
      })
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  # 6) frontend-xxx Pod 정상 감지
  rule {
    name      = "Frontend Pods OK"
    condition = "A"
    for       = "1m"

    data {
      ref_id         = "A"
      datasource_uid = data.grafana_data_source.prometheus.uid

      relative_time_range {
        from = 60
        to   = 0
      }

      model = jsonencode({
        expr  = "sum(kube_pod_status_phase{pod=~\"frontend-.*\",phase=\"Running\"}) by (pod) > 0"
        refId = "A"
      })
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }
}
