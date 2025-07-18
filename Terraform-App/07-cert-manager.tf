resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  depends_on = [kubernetes_namespace.cert-manager]

  set {
    name  = "installCRDs"
    value = "true"
  }
}