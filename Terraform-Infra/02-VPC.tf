resource "aws_vpc" "MSA_vpc" {
  cidr_block           = "10.22.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "MSA_vpc"
  }
}