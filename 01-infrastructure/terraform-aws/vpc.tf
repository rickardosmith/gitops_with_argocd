module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                 = local.azs
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  private_subnet_tags = local.private_subnet_tags
  public_subnet_tags  = local.public_subnet_tags

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  enable_vpn_gateway = var.enable_vpn_gateway

  tags = local.tags
}