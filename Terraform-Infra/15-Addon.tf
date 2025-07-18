resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.MSA_eks_cluster.name
  addon_name        = "vpc-cni"
  depends_on        = [aws_eks_cluster.MSA_eks_cluster]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.MSA_eks_cluster.name
  addon_name        = "kube-proxy"
  depends_on        = [aws_eks_cluster.MSA_eks_cluster]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name      = aws_eks_cluster.MSA_eks_cluster.name
  addon_name        = "aws-ebs-csi-driver"
  depends_on        = [aws_eks_node_group.MSA_eks_node_group]
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.MSA_eks_cluster.name
  addon_name        = "coredns"
  depends_on        = [aws_eks_node_group.MSA_eks_node_group]
}