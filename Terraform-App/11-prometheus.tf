resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = "monitoring"

  set {
    name  = "server.persistentVolume.storageClass"
    value = "ebs-sc"
  }

  depends_on = [kubernetes_namespace.monitoring]
}