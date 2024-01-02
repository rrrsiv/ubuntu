# provider "aws" {
#   region = local.region
#   access_key = "AKIATK7B2XVIEEYAHDVB"
#   secret_key = "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"
# }

# # provider "aws" {
# #   region = "us-east-2"
# #   alias  = "virginia"
# # }

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.this.token
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#     token                  = data.aws_eks_cluster_auth.this.token
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       # This requires the awscli to be installed locally where Terraform is executed
#       args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#     }
#   }
# }

# provider "kubectl" {
#   apply_retry_count      = 5
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   load_config_file       = false
#   token                  = data.aws_eks_cluster_auth.this.token
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

# data "aws_availability_zones" "available" {}
# data "aws_caller_identity" "current" {}

# data "aws_eks_cluster_auth" "this" {
#   name = module.eks.cluster_name
# }


# locals {
#   name            = "test"
#   cluster_version = "1.24"
#   region          = "us-east-1"

#   vpc_cidr = "10.10.0.0/16"
#   azs      = slice(data.aws_availability_zones.available.names, 0, 3)

#   tags = {
#     Example    = local.name

#   }
# }

# ################################################################################
# # EKS Module
# ################################################################################

# module "eks" {
#   source = "terraform-aws-modules/eks/aws"
#   version = "~> 19.0"

#   cluster_name                   = local.name
#   cluster_version                = local.cluster_version
#   cluster_endpoint_public_access = true

#   cluster_addons = {
#     kube-proxy = {
#       most_recent = true
#     }
#     vpc-cni    = {
#       most_recent = true
#     }
#     coredns = {
#       most_recent = true
#     }
#   }
#   # External encryption key
#   create_kms_key = false
#   cluster_encryption_config = {
#     resources        = ["secrets"]
#     provider_key_arn = module.kms.key_arn
#   }
#   vpc_id                   = module.vpc.vpc_id
#   subnet_ids               = module.vpc.private_subnets
#   control_plane_subnet_ids = module.vpc.intra_subnets

 
#   create_cluster_security_group = true
#   create_node_security_group    = true

#   manage_aws_auth_configmap = true
#   aws_auth_roles = [
#     # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
#     {
#       rolearn  = module.karpenter.role_arn
#       username = "system:node:{{EC2PrivateDNSName}}"
#       groups = [
#         "system:bootstrappers",
#         "system:nodes",
#       ]
#     },
#   ]

#   tags = merge(local.tags, {
#     # NOTE - if creating multiple security groups with this module, only tag the
#     # security group that Karpenter should utilize with the following tag
#     # (i.e. - at most, only one security group should have this tag in your account)
#     "karpenter.sh/discovery" = local.name
#   })
# }

# ################################################################################
# # Karpenter
# ################################################################################

# module "karpenter" {
#   source =  "terraform-aws-modules/eks/aws//modules/karpenter"

#   cluster_name           = module.eks.cluster_name
#   irsa_oidc_provider_arn = module.eks.oidc_provider_arn
#   irsa_namespace_service_accounts = ["karpenter:karpenter"]

#   tags = local.tags
# }

# resource "helm_release" "karpenter" {
#   namespace        = "karpenter"
#   create_namespace = true

#   name                = "karpenter"
#   repository          = "https://charts.karpenter.sh"
#   chart               = "karpenter"
#   version             = "v0.16.3"

#   set {
#     name  = "settings.aws.clusterName"
#     value = module.eks.cluster_name
#   }

#   set {
#     name  = "settings.aws.clusterEndpoint"
#     value = module.eks.cluster_endpoint
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.karpenter.irsa_arn
#   }

#   set {
#     name  = "settings.aws.defaultInstanceProfile"
#     value = module.karpenter.instance_profile_name
#   }

#   set {
#     name  = "settings.aws.interruptionQueueName"
#     value = module.karpenter.queue_name
#   }
# }

# resource "kubectl_manifest" "karpenter_provisioner" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.sh/v1alpha5
#     kind: Provisioner
#     metadata:
#       name: default
#     spec:
#       requirements:
#         - key: karpenter.sh/capacity-type
#           operator: In
#           values: [c5, m5, r5, t3, t2]
#         - key: karpenter.k8s.aws/instance-size
#           operator: NotIn
#           values: [nano, micro, small]
#       limits:
#         resources:
#           cpu: 1000
#       providerRef:
#         name: default
#       ttlSecondsAfterEmpty: 60
#       ttlSecondsUntilExpired: 604800
#   YAML

#   depends_on = [
#     helm_release.karpenter
#   ]
# }

# resource "kubectl_manifest" "karpenter_node_template" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.k8s.aws/v1alpha1
#     kind: AWSNodeTemplate
#     metadata:
#       name: default
#     spec:
#       subnetSelector:
#         karpenter.sh/discovery: ${module.eks.cluster_name}
#       securityGroupSelector:
#         karpenter.sh/discovery: ${module.eks.cluster_name}
#       tags:
#         karpenter.sh/discovery: ${module.eks.cluster_name}
#   YAML

#   depends_on = [
#     helm_release.karpenter
#   ]
# }

# # # Example deployment using the [pause image](https://www.ianlewis.org/en/almighty-pause-container)
# # # and starts with zero replicas
# # resource "kubectl_manifest" "karpenter_example_deployment" {
# #   yaml_body = <<-YAML
# #     apiVersion: apps/v1
# #     kind: Deployment
# #     metadata:
# #       name: inflate
# #     spec:
# #       replicas: 0
# #       selector:
# #         matchLabels:
# #           app: inflate
# #       template:
# #         metadata:
# #           labels:
# #             app: inflate
# #         spec:
# #           terminationGracePeriodSeconds: 0
# #           containers:
# #             - name: inflate
# #               image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
# #               resources:
# #                 requests:
# #                   cpu: 1
# #   YAML

# #   depends_on = [
# #     helm_release.karpenter
# #   ]
# # }

# ################################################################################
# # Supporting Resources
# ################################################################################

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 3.0"

#   name = local.name
#   cidr = local.vpc_cidr

#   azs             = local.azs
#   private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
#   public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
#   intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

#   enable_nat_gateway   = true
#   single_nat_gateway   = true
#   enable_dns_hostnames = true

#   enable_flow_log                      = true
#   create_flow_log_cloudwatch_iam_role  = true
#   create_flow_log_cloudwatch_log_group = true

#   public_subnet_tags = {
#     "kubernetes.io/role/elb" = 1
#   }

#   private_subnet_tags = {
#     "kubernetes.io/role/internal-elb" = 1
#     # Tags subnets for Karpenter auto-discovery
#     "karpenter.sh/discovery" = local.name
#   }

#   tags = local.tags
# }

# module "kms" {
#   source  = "terraform-aws-modules/kms/aws"
#   version = "1.1.0"

#   aliases               = ["eks/${local.name}"]
#   description           = "${local.name} cluster encryption key"
#   enable_default_policy = true
#   key_owners            = [data.aws_caller_identity.current.arn]

#   tags = local.tags
# }
