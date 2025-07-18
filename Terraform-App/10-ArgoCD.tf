resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  depends_on = [kubernetes_namespace.argocd]

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "server.insecure"
    value = "true"
  }

}