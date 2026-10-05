module "environment" {
  source = "../../modules/environment"

  environment                 = var.environment
  vpc_cidr                    = var.vpc_cidr
  availability_zones          = var.availability_zones
  public_subnet_cidrs         = var.public_subnet_cidrs
  private_app_subnet_cidrs    = var.private_app_subnet_cidrs
  private_db_subnet_cidrs     = var.private_db_subnet_cidrs
  interface_endpoints         = var.interface_endpoints
  endpoint_az_count           = var.endpoint_az_count
  flow_log_retention_in_days  = var.flow_log_retention_in_days
  kms_deletion_window_in_days = var.kms_deletion_window_in_days
  domain_name                 = var.domain_name
  route53_zone_name           = var.route53_zone_name
}
