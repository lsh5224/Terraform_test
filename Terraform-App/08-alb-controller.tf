resource "helm_release" "alb_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "kube-system"
  version          = "1.6.2" 
  
  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.MSA_eks_cluster.name
  }

  set {
    name  = "vpcId"
    value = data.aws_eks_cluster.MSA_eks_cluster.vpc_config[0].vpc_id
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }
  
  depends_on = [helm_release.cert_manager]
}