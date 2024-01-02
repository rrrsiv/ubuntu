################################################################################
# Karpenter
################################################################################

module "karpenter" {
  source =  "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name           = data.aws_eks_cluster.default.name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  tags = {
    Environment = "${var.Environment}"
  }
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "https://charts.karpenter.sh"
  chart               = "karpenter"
  version             = "v0.16.3"

  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.default.name
  }

  set {
    name  = "clusterEndpoint"
    value = data.aws_eks_cluster.default.endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }
  depends_on = [module.eks]
}



# resource "helm_release" "karpenter" {
#   namespace        = "karpenter"
#   create_namespace = true

#   name       = "karpenter"
#   repository = "https://charts.karpenter.sh"
#   chart      = "karpenter"
#   version    = "v0.16.3"

# #   set {
# #     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
# #     value = aws_iam_role.karpenter_controller.arn
# #   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.karpenter.irsa_arn
#   }

#   set {
#     name  = "settings.aws.defaultInstanceProfile"
#     value = module.karpenter.instance_profile_name
#   }

#   set {
#     name  = "clusterName"
#     value = data.aws_eks_cluster.default.id
#   }

#   set {
#     name  = "clusterEndpoint"
#     value = data.aws_eks_cluster.default.endpoint
#   }

#   set {
#     name  = "aws.defaultInstanceProfile"
#     value = module.karpenter.instance_profile_name
#   }

#   depends_on = [module.eks]
# }



# data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:karpenter:karpenter"]
#     }

#     principals {
#       identifiers = [module.eks.oidc_provider_arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "karpenter_controller" {
#   assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy.json
#   name               = "karpenter-controller"
# }

# resource "aws_iam_policy" "karpenter_controller" {
#   policy = file("./controller-trust-policy.json")
#   name   = "KarpenterController"
# }

# resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
#   role       = aws_iam_role.karpenter_controller.name
#   policy_arn = aws_iam_policy.karpenter_controller.arn
# }

# resource "aws_iam_instance_profile" "karpenter" {
#   name = "KarpenterNodeInstanceProfile"
#   role = module.karpenter.instance_profile_name
# }

######################################### karpenter-provisioner #############################

resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: default
    spec:
      requirements:
      # Include general purpose instance families
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        # Exclude small instance sizes
        - key: karpenter.k8s.aws/instance-size
          operator: NotIn
          values: [nano, micro]
      limits:
        resources:
          cpu: 1000  # limit to 100 CPU cores
      providerRef:
        name: default
      ttlSecondsAfterEmpty: 60 # scale down nodes after 60 seconds without workloads (excluding daemons)
      ttlSecondsUntilExpired: 604800 # expire nodes after 7 days (in seconds) = 7 * 60 * 60 * 24
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      subnetSelector:
        "kubernetes.io/cluster/${var.eks_cluster_name}": owned
      securityGroupSelector:
        "kubernetes.io/cluster/${var.eks_cluster_name}": owned
      tags:
        "kubernetes.io/cluster/${var.eks_cluster_name}": owned
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}
