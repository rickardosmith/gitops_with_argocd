locals {
  tags                = var.tags
  public_subnet_tags  = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags

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
  ## "audit",             // enabled by default
  ## "api",               // enabled by default
  ## "authenticator",     // enabled by default
  ## "controllerManager", // disabled by default
  ## "scheduler",         // disabled by default
  cluster_enabled_log_types = var.cluster_enabled_log_types

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
    # iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {

    # Adds to the AWS provided user data
    bottlerocket = {
      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"

      min_size       = 0
      desired_size   = 3
      max_size       = 4
      instance_types = var.whitelist_ec2_instance_types
      capacity_type  = "SPOT"
      disk_size      = 30

      labels = merge({
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
        },
      local.tags)

      tags        = local.tags
      name        = "eks-nodes"
      description = "EKS managed node group."
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
    },
    ingress_allow_access_from_control_plane_to_non_priviledged_ports = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      source_cluster_security_group = true
      description                   = "Allow access from control plane to all non-priviledged ports"
    },
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
}
