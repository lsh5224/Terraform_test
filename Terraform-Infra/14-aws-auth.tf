# EKS 클러스터 정보 가져오기
data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.MSA_eks_cluster.name
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.MSA_eks_cluster.name
}

# Kubernetes provider (클러스터와 통신 가능해야 함, kubeconfig가 있어야 함!)
provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.MSA_eks_node_group_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes"
        ]
      },
      {
        rolearn  = aws_iam_role.bastion_eks_role.arn
        username = "bastion"
        groups   = [
          "system:masters"
        ]
      }
    ])
  }
}