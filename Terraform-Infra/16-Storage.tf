resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner     = "ebs.csi.aws.com"
  reclaim_policy          = "Delete"
  volume_binding_mode     = "WaitForFirstConsumer"
  allow_volume_expansion  = true

  depends_on = [aws_eks_cluster.MSA_eks_cluster, aws_eks_addon.ebs_csi]
}