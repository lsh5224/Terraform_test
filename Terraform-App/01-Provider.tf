terraform {
  required_version = ">= 1.0.0, <2.0.0"

  required_providers {
    grafana = {
      source  = "grafana/grafana"  # ✅ 반드시 이렇게!
      version = ">= 2.9.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
     kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0, < 3.0.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2" # Asia Pacific (Seoul)
}

provider "grafana" {
  url  = "http://k8s-monitori-grafanai-da2b011f10-124882021.ap-northeast-2.elb.amazonaws.com"
  auth = var.grafana_api_key
}