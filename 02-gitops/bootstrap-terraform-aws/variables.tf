variable "region" {
  type        = string
  description = "AWS Region"
}

variable "eks_cluster_name" {
  type        = string
  description = "AWS EKS Cluster name."
  default     = "the-eks-cluster"
}
