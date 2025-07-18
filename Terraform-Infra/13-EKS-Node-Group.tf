# Node Group IAM Role 생성
resource "aws_iam_role" "MSA_eks_node_group_role" {
  name = "MSA_eks_node_group_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "custom_ebs_csi" {
  name        = "AmazonEBSCSIDriverPolicy"
  description = "Custom EBS CSI Driver Policy (관리형 정책이 없는 경우 사용)"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ec2:CreateSnapshot",
              "ec2:DeleteSnapshot",
              "ec2:CreateVolume",
              "ec2:DeleteVolume",
              "ec2:AttachVolume",
              "ec2:DetachVolume",
              "ec2:ModifyVolume",
              "ec2:DescribeAvailabilityZones",
              "ec2:DescribeInstances",
              "ec2:DescribeSnapshots",
              "ec2:DescribeTags",
              "ec2:DescribeVolumes",
              "ec2:DescribeVolumesModifications",
              "ec2:CreateTags",
              "ec2:DeleteTags"
              ],
            "Resource": "*"
        }
    ]
}
EOF
}

# IAM Role에 정책 추가
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.MSA_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.MSA_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.MSA_eks_node_group_role.name
}

# Node Group 생성
resource "aws_eks_node_group" "MSA_eks_node_group" {
  cluster_name    = aws_eks_cluster.MSA_eks_cluster.name
  node_group_name = "MSA_eks_node_group"
  node_role_arn   = aws_iam_role.MSA_eks_node_group_role.arn
  subnet_ids      = [aws_subnet.MSA_pri_subnet_2a.id, aws_subnet.MSA_pri_subnet_2c.id]


  tags = {
    "k8s.io/cluster_autoscaler/enabled"               = "true"
    "k8s.io/cluster_autoscaler/MSA_eks_cluster" = "owned"
  }

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.large"]
  disk_size      = 20

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
  ]
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  policy_arn = aws_iam_policy.custom_ebs_csi.arn
  role       = aws_iam_role.MSA_eks_node_group_role.name

  depends_on = [aws_iam_policy.custom_ebs_csi]
}