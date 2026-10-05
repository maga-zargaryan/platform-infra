aws_region = "eu-west-1"

vpc_cidr             = "10.30.0.0/16"
availability_zones   = ["eu-west-1a", "eu-west-1b"]
private_subnet_cidrs = ["10.30.1.0/24", "10.30.2.0/24"]

interface_endpoints = ["imagebuilder", "ssm", "ssmmessages", "logs"]
# Build tooling is not customer facing: one AZ.
endpoint_az_count = 1

flow_log_retention_in_days  = 30
kms_deletion_window_in_days = 7
