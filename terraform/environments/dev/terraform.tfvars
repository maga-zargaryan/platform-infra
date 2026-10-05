aws_region  = "eu-west-1"
environment = "dev"

vpc_cidr                 = "10.10.0.0/16"
availability_zones       = ["eu-west-1a", "eu-west-1b"]
public_subnet_cidrs      = ["10.10.1.0/24", "10.10.2.0/24"]
private_app_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
private_db_subnet_cidrs  = ["10.10.21.0/24", "10.10.22.0/24"]

interface_endpoints = ["ssm", "ssmmessages", "secretsmanager", "logs", "monitoring"]
# Non-production: endpoints in one AZ (reduced redundancy, reduced cost).
endpoint_az_count = 1

flow_log_retention_in_days  = 30
kms_deletion_window_in_days = 7

domain_name       = "dev.margarita.c-loud.am"
route53_zone_name = "margarita.c-loud.am"
