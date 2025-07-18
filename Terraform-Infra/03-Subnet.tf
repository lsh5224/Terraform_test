# Public Subnet - ap-northeast-2a
resource "aws_subnet" "MSA_pub_subnet_2a" {
  vpc_id                  = aws_vpc.MSA_vpc.id
  cidr_block              = "10.22.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name                                      = "MSA_pub_subnet-2a"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/MSA_eks_cluster" = "shared"
  }
}

# Public Subnet - ap-northeast-2c
resource "aws_subnet" "MSA_pub_subnet_2c" {
  vpc_id                  = aws_vpc.MSA_vpc.id
  cidr_block              = "10.22.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name                                      = "MSA_pub_subnet-2c"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/MSA_eks_cluster" = "shared"
  }
}

# Private Subnet - ap-northeast-2a
resource "aws_subnet" "MSA_pri_subnet_2a" {
  vpc_id            = aws_vpc.MSA_vpc.id
  cidr_block        = "10.22.11.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name                                      = "MSA_pri_subnet-2a"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/MSA_eks_cluster" = "shared"
  }
}

# Private Subnet - ap-northeast-2c
resource "aws_subnet" "MSA_pri_subnet_2c" {
  vpc_id            = aws_vpc.MSA_vpc.id
  cidr_block        = "10.22.12.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name                                      = "MSA_pri_subnet-2c"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/MSA_eks_cluster" = "shared"
  }
}

