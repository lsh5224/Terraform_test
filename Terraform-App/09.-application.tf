resource "helm_release" "msa_front" {
  name       = "msa-front"
  chart      = "${path.module}/../mychart/frontend"
  values     = [file("${path.module}/../mychart/frontend/values.yaml")]
  namespace  = "default"
}

resource "helm_release" "msa_boards" {
  name       = "msa-boards"
  chart      = "${path.module}/../mychart/boards"
  values     = [file("${path.module}/../mychart/boards/values.yaml")]
  namespace  = "default"
}

resource "helm_release" "msa_users" {
  name       = "msa-users"
  chart      = "${path.module}/../mychart/users"
  values     = [file("${path.module}/../mychart/users/values.yaml")]
  namespace  = "default"
}