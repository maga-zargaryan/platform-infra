module "build_network" {
  source = "../modules/build-network"

  vpc_cidr                    = var.vpc_cidr
  availability_zones          = var.availability_zones
  private_subnet_cidrs        = var.private_subnet_cidrs
  interface_endpoints         = var.interface_endpoints
  endpoint_az_count           = var.endpoint_az_count
  flow_log_retention_in_days  = var.flow_log_retention_in_days
  kms_deletion_window_in_days = var.kms_deletion_window_in_days
}
