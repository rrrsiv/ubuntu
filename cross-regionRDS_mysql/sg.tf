module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Complete MySQL example security group"
  vpc_id      = data.aws_vpc.dr.id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = var.port 
      to_port     = var.port
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = data.aws_vpc.dr.cidr_block
    },
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  depends_on = [
    data.aws_vpc.dr
  ]

  tags = local.tags


}



module "security_group_dr" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Complete MySQL example security group"
  vpc_id      = data.aws_vpc.replica.id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = var.port 
      to_port     = var.port
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = data.aws_vpc.replica.cidr_block
    },
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]

  depends_on = [
    data.aws_vpc.replica
  ]

  tags = local.tags
  providers = {
    aws = aws.region1
  }

}

# provider "aws" {
#   region = "us-east-2"
#  }

# provider "aws" {
#   alias = "region1"
#   region = "ap-south-1"
#  }
