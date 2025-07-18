resource "helm_release" "ingress" {
  name       = "ingress"
  chart      = "${path.module}/../ingress"
  namespace  = "default"

  depends_on = [helm_release.alb_controller]
}