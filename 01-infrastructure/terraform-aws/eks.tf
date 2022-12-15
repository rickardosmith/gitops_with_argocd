module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.29.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  cluster_addons = local.cluster_addons

  cluster_enabled_log_types = local.cluster_enabled_log_types

  ## If not specified then default is 90
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  # VPC
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Required for Karpenter role below
  enable_irsa = true

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults         = local.eks_managed_node_group_defaults
  eks_managed_node_groups                 = local.eks_managed_node_groups
  cluster_security_group_additional_rules = local.cluster_security_group_additional_rules
  node_security_group_additional_rules    = local.node_security_group_additional_rules
  node_security_group_tags                = local.node_security_group_tags

  tags = local.tags
}

#### IRSA
module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.4.0"

  role_name_prefix      = "vpc_cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}

module "karpenter_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.3.1"

  role_name                          = "karpenter-controller-${local.eks_cluster_name}"
  attach_karpenter_controller_policy = true

  karpenter_tag_key               = "karpenter.sh/discovery/${local.eks_cluster_name}"
  karpenter_controller_cluster_id = module.eks.cluster_id
  karpenter_controller_node_iam_role_arns = [
    module.eks.eks_managed_node_groups["bottlerocket"].iam_role_arn
  ]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}
