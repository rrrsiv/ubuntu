module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.3"

  name = "main"
  cidr = "10.16.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.16.0.0/25", "10.16.32.0/25"]
  public_subnets  = ["10.16.64.0/24", "10.16.96.0/24"]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "staging"
  }
}

data "aws_availability_zones" "available" {}
