provider "kubernetes" {
  host                   = data.aws_eks_cluster.MSA_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.MSA_eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.auth.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.MSA_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.MSA_eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.auth.token
  }
}