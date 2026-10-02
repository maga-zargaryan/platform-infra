aws_region  = "eu-west-1"
environment = "prod"

vpc_cidr                 = "10.20.0.0/16"
availability_zones       = ["eu-west-1a", "eu-west-1b"]
public_subnet_cidrs      = ["10.20.1.0/24", "10.20.2.0/24"]
private_app_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]
private_db_subnet_cidrs  = ["10.20.21.0/24", "10.20.22.0/24"]

interface_endpoints = ["ssm", "ssmmessages", "secretsmanager", "logs", "monitoring"]
# Production: endpoints in every AZ so an AZ failure does not cut access to AWS services.
endpoint_az_count = 2

flow_log_retention_in_days  = 365
kms_deletion_window_in_days = 30

domain_name       = "margarita.c-loud.am"
route53_zone_name = "margarita.c-loud.am"
