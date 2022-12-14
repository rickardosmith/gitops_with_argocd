locals {
  tags = var.tags

  eks_cluster_name = var.eks_cluster_name

  # Determine Availability Zones List
  azs          = slice(data.aws_availability_zones.available.names, 0, local.az_net_match)
  subnet_max   = max(length(var.private_subnets), length(var.public_subnets))
  az_net_match = local.subnet_max > length(data.aws_availability_zones.available.names[*]) ? length(data.aws_availability_zones.available.names[*]) : local.subnet_max

  # Used to determine correct partition (i.e. - `aws`, `aws-gov`, `aws-cn`, etc.)
  partition = data.aws_partition.current.partition

  # Add the appropriate tags on your subnets to allow the AWS Load Balancer Ingress Controller
  # to create a load balancer using auto-discovery.
  # https://aws.amazon.com/premiumsupport/knowledge-center/eks-load-balancer-controller-subnets/
  public_subnet_tags = {
    "kubernetes.io/role/elb"                          = 1
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                 = 1
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = var.eks_addon_version["coredns"]
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = var.eks_addon_version["kube-proxy"]
    }
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      addon_version            = var.eks_addon_version["vpc-cni"]
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = var.eks_addon_version["aws-ebs-csi-driver"]
    }
  }

  # Control Plane Logging
  ## "audit"             // enabled by default
  ## "api"               // enabled by default
  ## "authenticator"     // enabled by default
  ## "controllerManager" // disabled by default
  ## "scheduler"         // disabled by default
  cluster_enabled_log_types = var.cluster_enabled_log_types //["audit","api","authenticator"]

  eks_managed_node_group_defaults = {
    disk_size      = 30
    instance_types = var.whitelist_ec2_instance_types
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
    # We are using the IRSA created below for permissions
    # However, we have to provision a new cluster with the policy attached FIRST
    # before we can disable. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the new cluster
    #iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {

    # Adds to the AWS provided user data
    bottlerocket = {
      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"

      instance_types = var.whitelist_ec2_instance_types
      # Not required nor used - avoid tagging two security groups with same tag as well
      create_security_group = false

      min_size     = var.eks_managed_node_groups_min_size
      desired_size = var.eks_managed_node_groups_desired_size
      max_size     = var.eks_managed_node_groups_max_size

      capacity_type = "ON_DEMAND"
      disk_size     = var.eks_managed_node_groups_disk_size

      iam_role_additional_policies = [
        # Required by Karpenter
        "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]

      labels = merge({
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
        },
      local.tags)

      tags = merge(local.tags, {
        "karpenter.sh/discovery/${local.eks_cluster_name}" = local.eks_cluster_name
      })
      name        = var.eks_managed_node_group_instances_name
      description = "EKS managed node group EC2 instance."
    }
  }

  # Extend cluster security group rules
  # Note: This module comes packaged with the following ports configured:
  #       Ingress - 443/TCP
  #       Egress  - 443/TCP, 10250/TCP
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  # Note: This module comes packaged with the following ports configured:
  #       Ingress - 443/TCP, 10250/TCP, 53/TCP, 53/UDP
  #       Egress  - 443/TCP, 53/TCP, 53/UDP, 123/TCP, 123/UDP
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_allow_access_from_control_plane_to_non_priviledged_ports = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      source_cluster_security_group = true
      description                   = "Allow access from control plane to all non-priviledged ports"
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery/${local.eks_cluster_name}" = local.eks_cluster_name
  }
}
