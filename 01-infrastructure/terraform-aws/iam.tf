resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${local.eks_cluster_name}"
  role = module.eks.eks_managed_node_groups["bottlerocket"].iam_role_name
}
