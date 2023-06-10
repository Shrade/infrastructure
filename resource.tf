locals {
  environment = var.environment
}

/* 
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  assume_role {
    role_arn = var.aws_role_arn
  }
} */
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "data-shrade"
  }
}

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.this.id
  name   = "shrade"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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
  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  count             = length(local.subnets_public_private[1])
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.subnets_public_private[1][count.index]
  availability_zone = data.aws_availability_zones.this.names[count.index]
  tags = {
    Name = "private-${count.index + 1}"
  }
}

module "s3_artifact" {
  source = "./s3"
  bucket_name = "${local.environment}-shrade"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "shrade_ecr" {
  name = "shrade_ecr"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "VisualEditor0",
        Action = [
                "ecr:CreateRepository",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:ListImages",
                "ecr:DescribeRepositories",
                "ecr:DescribeImages",
                "ecr:GetRepositoryPolicy",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy",
                "ecr:TagResource",
                "ecr:UntagResource",
                "ecr:BatchGetImage"
            ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ecr:ap-southeast-1:${data.aws_caller_identity.current.account_id}:repository/shrade*"
        ]
      },
      {
        Sid = "VisualEditor1"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user" "shrade_ecr" {
  name = "shrade_ecr"
}

resource "aws_iam_user_policy_attachment" "data_titan_ecr_attach" {
  user       = aws_iam_user.shrade_ecr.name
  policy_arn = aws_iam_policy.shrade_ecr.arn
}

resource "aws_instance" "shrade_ec2" {
  ami           = "ami-067d12e172891a3e4"
  instance_type = "t2.micro" 

  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id = "subnet-0b6155ee14a343d8f"
  tags = {
    Name = "shrade_ec2"
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "shrade=eks"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}