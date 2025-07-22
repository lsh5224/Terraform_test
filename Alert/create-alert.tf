resource "grafana_rule_group" "app_alerts" {
  name             = "Application Alerts"
  folder_uid       = grafana_folder.alerts.uid
  interval_seconds = 60   # 1분마다 평가

  # 1) Board Pods Down
  rule {
    name      = "Board Pods Down"
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
        expr   = "sum(kube_pod_status_phase{pod=~\"board-.*\",phase!=\"Running\"}) by (pod)"
        refId  = "A"
      })
    }

    reducer {
      type = "last"
    }

    operator {
      type  = "gt"
      value = "0"
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  # 2) Users Pods Down
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
        expr   = "sum(kube_pod_status_phase{pod=~\"users-.*\",phase!=\"Running\"}) by (pod)"
        refId  = "A"
      })
    }

    reducer {
      type = "last"
    }

    operator {
      type  = "gt"
      value = "0"
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  # 3) Frontend Pods Down
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
        expr   = "sum(kube_pod_status_phase{pod=~\"frontend-.*\",phase!=\"Running\"}) by (pod)"
        refId  = "A"
      })
    }

    reducer {
      type = "last"
    }

    operator {
      type  = "gt"
      value = "0"
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  # 4) Board Pods OK
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
        expr   = "sum(kube_pod_status_phase{pod=~\"board-.*\",phase=\"Running\"}) by (pod)"
        refId  = "A"
      })
    }

    reducer {
      type = "last"
    }

    operator {
      type  = "gt"
      value = "0"
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  # 5) Users Pods OK
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
        expr   = "sum(kube_pod_status_phase{pod=~\"users-.*\",phase=\"Running\"}) by (pod)"
        refId  = "A"
      })
    }

    reducer {
      type = "last"
    }

    operator {
      type  = "gt"
      value = "0"
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  # 6) Frontend Pods OK
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
        expr   = "sum(kube_pod_status_phase{pod=~\"frontend-.*\",phase=\"Running\"}) by (pod)"
        refId  = "A"
      })
    }

    reducer {
      type = "last"
    }

    operator {
      type  = "gt"
      value = "0"
    }

    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }
}
