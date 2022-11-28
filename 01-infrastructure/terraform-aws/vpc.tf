module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                 = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  private_subnet_tags = local.private_subnet_tags
  public_subnet_tags  = local.public_subnet_tags

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = local.tags
}