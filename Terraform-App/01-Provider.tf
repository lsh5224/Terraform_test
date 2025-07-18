terraform {
  required_version = ">= 1.0.0, <2.0.0"

  required_providers {
    grafana = {
      source  = "grafana/grafana"  # ✅ 반드시 이렇게!
      version = "~> 1.41.0"
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