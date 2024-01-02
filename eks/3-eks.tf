module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.24"

  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true
  # External encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }
    vpc-cni    = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
  }
  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size = 5
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 2
      min_size     = 1
      max_size     = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }

    
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = module.eks_admins_iam_role.iam_role_arn
      username = module.eks_admins_iam_role.iam_role_name
      groups   = ["system:masters"]
    },
  ]

  # node_security_group_additional_rules = {
  #   ingress_allow_access_from_control_plane = {
  #     type                          = "ingress"
  #     protocol                      = "tcp"
  #     from_port                     = 9443
  #     to_port                       = 9443
  #     source_cluster_security_group = true
  #     description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
  #   }
  # }

  tags = {
    Environment = var.Environment
  }
}

# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009
data "aws_eks_cluster" "default" {
  #name = module.eks.cluster_id
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "default" {
  #name = module.eks.cluster_id
  name = data.aws_eks_cluster.default.id
}

