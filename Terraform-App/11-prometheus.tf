resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = "monitoring"

  set {
    name  = "server.persistentVolume.storageClass"
    value = "ebs-sc"
  }
  force_update  = true       # 변경 여부와 관계없이 삭제→재생성
  depends_on = [kubernetes_namespace.monitoring]
}