
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