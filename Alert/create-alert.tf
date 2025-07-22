# ./alert/create-alert.tf

resource "grafana_rule_group" "app_alerts" {
  name             = "Application Alerts"
  folder_uid       = grafana_folder.alerts.uid
  interval_seconds = 60   # 1분마다 평가

  ##################################################################
  # 1) Board Pods Down
  ##################################################################
  rule {
    name = "Board Pods Down"
    for  = "1m"

    # A: 비정상(Non-Running) 시계열 쿼리
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

    # B: A > 0 인지 수식으로 판단 (스칼라 값 생성)
    data {
      ref_id         = "B"
      datasource_uid = "__expr__"

      # 단순 수식이므로 시간범위는 0~0
      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        expression = "$A > 0"
        type       = "math"
        refId      = "B"
      })
    }

    condition = "B"
    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  ##################################################################
  # 2) Users Pods Down
  ##################################################################
  rule {
    name = "Users Pods Down"
    for  = "1m"

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

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        expression = "$A > 0"
        type       = "math"
        refId      = "B"
      })
    }

    condition = "B"
    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  ##################################################################
  # 3) Frontend Pods Down
  ##################################################################
  rule {
    name = "Frontend Pods Down"
    for  = "1m"

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

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        expression = "$A > 0"
        type       = "math"
        refId      = "B"
      })
    }

    condition = "B"
    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  ##################################################################
  # 4) Board Pods OK
  ##################################################################
  rule {
    name = "Board Pods OK"
    for  = "1m"

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

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        expression = "$A > 0"
        type       = "math"
        refId      = "B"
      })
    }

    condition = "B"
    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  ##################################################################
  # 5) Users Pods OK
  ##################################################################
  rule {
    name = "Users Pods OK"
    for  = "1m"

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

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        expression = "$A > 0"
        type       = "math"
        refId      = "B"
      })
    }

    condition = "B"
    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }

  ##################################################################
  # 6) Frontend Pods OK
  ##################################################################
  rule {
    name = "Frontend Pods OK"
    for  = "1m"

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

    data {
      ref_id         = "B"
      datasource_uid = "__expr__"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        expression = "$A > 0"
        type       = "math"
        refId      = "B"
      })
    }

    condition = "B"
    notification_settings {
      contact_point = grafana_contact_point.discord_point.name
    }
  }
}
