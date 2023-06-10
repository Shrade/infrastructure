
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "data-shrade"
  }
}

data "aws_availability_zones" "this" {}

locals {
  subnets_public_private = chunklist(
    cidrsubnets(aws_vpc.this.cidr_block, 4, 4, 4, 2, 2 ,2),
    length(data.aws_availability_zones.this.names),
  )
}

resource "aws_subnet" "public" {
  count                   = length(local.subnets_public_private[0])
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnets_public_private[0][count.index]
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = length(local.subnets_public_private[1])
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.subnets_public_private[1][count.index]
  availability_zone = data.aws_availability_zones.this.names[count.index]
}