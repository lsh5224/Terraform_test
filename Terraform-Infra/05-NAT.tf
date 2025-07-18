# 탄력적(Elastic) IP
resource "aws_eip" "MSA_eip_2a" {
  domain = "vpc"
}

resource "aws_eip" "MSA_eip_2c" {
  domain = "vpc"
}


# NAT 게이트웨이
resource "aws_nat_gateway" "MSA_ngw_2a" {
  allocation_id = aws_eip.MSA_eip_2a.id
  subnet_id     = aws_subnet.MSA_pub_subnet_2a.id
  tags = {
    "Name" = "MSA_ngw_2a"
  }
}

resource "aws_nat_gateway" "MSA_ngw_2c" {
  allocation_id = aws_eip.MSA_eip_2c.id
  subnet_id     = aws_subnet.MSA_pub_subnet_2c.id
  tags = {
    "Name" = "MSA_ngw_2c"
  }
}
