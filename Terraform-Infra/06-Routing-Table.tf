# 라우팅 테이블
resource "aws_route_table" "MSA_pub_rt" {
  vpc_id = aws_vpc.MSA_vpc.id

  tags = {
    "Name" = "MSA_pub_rt"
  }
}

resource "aws_route_table" "MSA_pri_rt_2a" {
  vpc_id = aws_vpc.MSA_vpc.id

  tags = {
    "Name" = "MSA_pri_rt_2a"
  }
}

resource "aws_route_table" "MSA_pri_rt_2c" {
  vpc_id = aws_vpc.MSA_vpc.id

  tags = {
    "Name" = "MSA_pri_rt_2c"
  }
}

# 라우팅
resource "aws_route" "MSA_pub_rt" {
  route_table_id         = aws_route_table.MSA_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.MSA_igw.id
}

resource "aws_route" "MSA_pri_rt_2a" {
  route_table_id         = aws_route_table.MSA_pri_rt_2a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.MSA_ngw_2a.id
}

resource "aws_route" "MSA_pri_rt_2c" {
  route_table_id         = aws_route_table.MSA_pri_rt_2c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.MSA_ngw_2c.id
}

# 명시적 서브넷 연결
resource "aws_route_table_association" "MSA_pub_rt_associate_2a" {
  subnet_id      = aws_subnet.MSA_pub_subnet_2a.id
  route_table_id = aws_route_table.MSA_pub_rt.id
}

resource "aws_route_table_association" "MSA_pub_rt_associate_2c" {
  subnet_id      = aws_subnet.MSA_pub_subnet_2c.id
  route_table_id = aws_route_table.MSA_pub_rt.id
}

resource "aws_route_table_association" "MSA_pri_rt_associate_2a" {
  subnet_id      = aws_subnet.MSA_pri_subnet_2a.id
  route_table_id = aws_route_table.MSA_pri_rt_2a.id
}

resource "aws_route_table_association" "MSA_pri_rt_associate_2c" {
  subnet_id      = aws_subnet.MSA_pri_subnet_2c.id
  route_table_id = aws_route_table.MSA_pri_rt_2c.id
}