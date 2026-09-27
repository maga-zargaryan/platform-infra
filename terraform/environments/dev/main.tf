module "environment" {
  source                   = "../../modules/environment"
  aws_region               = var.aws_region
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  domain_name              = var.domain_name
  route53_zone_id          = var.route53_zone_id
}
