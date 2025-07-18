# OIDC Provider 정의
resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  url             = data.aws_eks_cluster.MSA_eks_cluster.identity[0].oidc[0].issuer
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0ecd01e10"] # 서울 리전 기본값
}


