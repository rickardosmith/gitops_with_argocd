output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets_cidr_blocks" {
  description = "List of Private Subnets CIDR Blocks"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "private_subnets" {
  description = "List of Private Subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets_cidr_blocks" {
  description = "List of Public Subnets CIDR Blocks"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "public_subnets" {
  description = "List of Public Subnets"
  value       = module.vpc.public_subnets
}

output "eks_cluster_name" {
  description = "AWS EKS Cluster Name"
  value       = module.eks.cluster_id
}

output "eks_cluster_role_arn" {
  description = "AWS EKS Cluser IAM Role ARN"
  value       = module.eks.cluster_iam_role_arn
}