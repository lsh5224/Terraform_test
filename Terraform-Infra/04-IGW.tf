resource "aws_internet_gateway" "MSA_igw" {
  vpc_id = aws_vpc.MSA_vpc.id

  tags = {
    Name = "MSA_igw"  # AWS 태그 값은 하이픈 OK
  }
}