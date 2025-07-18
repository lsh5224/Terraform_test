variable "grafana_api_key" {
  type      = string
  sensitive = true
}

provider "grafana" {
  url  = "http://k8s-monitori-grafanai-da2b011f10-124882021.ap-northeast-2.elb.amazonaws.com"
  auth = var.grafana_api_key
}

resource "grafana_data_source" "testdata" {
  name = "TestData"
  type = "testdata"
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
      datasource_uid = grafana_data_source.testdata.uid
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
