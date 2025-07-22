terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 2.9.0"
    }
  }
}

provider "grafana" {
  url  = var.grafana_url       # Grafana endpoint (ex. "https://grafana.example.com")
  auth = var.grafana_api_key   # 워크스페이스에 등록한 API Key 변수
}
