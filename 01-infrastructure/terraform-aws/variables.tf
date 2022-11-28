variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name."
  default     = "my-vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block."
  default     = "10.0.0.0/16"
}

variable "number_of_azs" {
  type        = number
  description = "Number of Availability Zones."
  default     = 3
}

variable "private_subnets" {
  type        = list(string)
  description = "VPC Private Subnets."
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "VPC Public Subnets."
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags - Key-Value pairs."
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

variable "eks_cluster_name" {
  type        = string
  description = "AWS EKS Cluster name."
  default     = "the-eks-cluster"
}

variable "eks_cluster_version" {
  type        = string
  description = "AWS EKS Cluster version."
  default     = "1.22"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  description = "Enable Cluster Endpoint Private Access"
  default     = true
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Enable Cluster Endpoint Public Access"
  default     = true
}

variable "cluster_addons" {
  type        = map(string)
  description = "EKS Cluster Addons"
  default     = {}
}

variable "eks_addon_version" {
  type        = map(string)
  description = "AWS EKS Addons plugin versions"
  default = {
    vpc-cni            = "v1.11.3-eksbuild.1"
    kube-proxy         = "v1.22.11-eksbuild.2"
    coredns            = "v1.8.7-eksbuild.1"
    aws-ebs-csi-driver = "v1.10.0-eksbuild.1"
  }
}

variable "whitelist_ec2_instance_types" {
  type        = list(string)
  description = "List of Allow EC2 Instance Types."
  default     = ["t3a.medium", "t3a.large"]
}


variable "cluster_enabled_log_types" {
  type        = list(string)
  description = "value"
  default     = []
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "CloudWatch Log Retention period in days"
  default     = 90
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS Hostnames"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS Support"
  default     = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway"
  default     = true
}

variable "enable_vpn_gateway" {
  type        = bool
  description = "Enable VPN Gateway"
  default     = false
}