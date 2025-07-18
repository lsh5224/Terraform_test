data "aws_eks_cluster" "MSA_eks_cluster" {
  name = "MSA_eks_cluster"   # 실제 Infra에서 만든 클러스터 이름과 맞춰야 함
}

data "aws_eks_cluster_auth" "auth" {
  name = data.aws_eks_cluster.MSA_eks_cluster.name
}

data "aws_eks_node_group" "MSA_eks_node_group" {
  cluster_name    = data.aws_eks_cluster.MSA_eks_cluster.name
  node_group_name = "MSA_eks_node_group"   # 실제 NodeGroup 이름
}
