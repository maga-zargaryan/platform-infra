data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  name         = "java-platform-${var.environment}"
  account_id   = data.aws_caller_identity.current.account_id
  boundary_arn = "arn:${data.aws_partition.current.partition}:iam::${local.account_id}:policy/java-platform-permissions-boundary"
  az_suffixes  = [for az in var.availability_zones : substr(az, -2, 2)]
}

module "kms" {
  source = "../kms-key"

  alias                   = local.name
  description             = "${var.environment} Java platform encryption (EBS, RDS, EFS, Secrets Manager, logs)"
  deletion_window_in_days = var.kms_deletion_window_in_days
  via_services            = ["ec2", "rds", "elasticfilesystem", "secretsmanager", "sns"]
  allow_autoscaling       = true
  allow_cloudwatch_alarms = true
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = local.name
  cidr = var.vpc_cidr
  azs  = var.availability_zones

  # Public: load balancers only. Private app: compute. Database: RDS and nothing else.
  public_subnets        = var.public_subnet_cidrs
  private_subnets       = var.private_app_subnet_cidrs
  database_subnets      = var.private_db_subnet_cidrs
  public_subnet_names   = [for s in local.az_suffixes : "${local.name}-public-${s}"]
  private_subnet_names  = [for s in local.az_suffixes : "${local.name}-app-${s}"]
  database_subnet_names = [for s in local.az_suffixes : "${local.name}-db-${s}"]

  map_public_ip_on_launch            = false
  create_database_subnet_group       = true
  database_subnet_group_name         = local.name
  create_database_subnet_route_table = true

  # No internet egress from private subnets: AWS services are reached through VPC endpoints.
  enable_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  enable_flow_log                                 = true
  flow_log_traffic_type                           = "ALL"
  flow_log_max_aggregation_interval               = 60
  create_flow_log_cloudwatch_log_group            = true
  create_flow_log_cloudwatch_iam_role             = true
  flow_log_cloudwatch_log_group_name_prefix       = "/java-platform/flow-logs/"
  flow_log_cloudwatch_log_group_name_suffix       = var.environment
  flow_log_cloudwatch_log_group_retention_in_days = var.flow_log_retention_in_days
  flow_log_cloudwatch_log_group_kms_key_id        = module.kms.arn
  vpc_flow_log_iam_role_name                      = "java-platform-network-flow-logs-${var.environment}"
  vpc_flow_log_iam_role_use_name_prefix           = false
  vpc_flow_log_iam_policy_name                    = "java-platform-network-flow-logs-${var.environment}"
  vpc_flow_log_iam_policy_use_name_prefix         = false
  vpc_flow_log_permissions_boundary               = local.boundary_arn
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "6.7.3"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name        = "${local.name}-vpc-endpoints"
  security_group_description = "HTTPS from the VPC to interface endpoints"
  security_group_rules = {
    https_from_vpc = {
      description = "HTTPS from within the VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  endpoints = merge(
    {
      s3 = {
        service         = "s3"
        service_type    = "Gateway"
        route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.database_route_table_ids)
        tags            = { Name = "${local.name}-s3" }
      }
    },
    {
      for service in var.interface_endpoints : service => {
        service             = service
        private_dns_enabled = true
        subnet_ids          = slice(module.vpc.private_subnets, 0, var.endpoint_az_count)
        tags                = { Name = "${local.name}-${service}" }
      }
    },
  )
}

data "aws_route53_zone" "this" {
  name         = var.route53_zone_name
  private_zone = false
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = local.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.this.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for r in aws_route53_record.certificate_validation : r.fqdn]
}

# Contract consumed by java-infra.
locals {
  parameters = {
    vpc_id               = { type = "String", value = module.vpc.vpc_id }
    vpc_cidr             = { type = "String", value = module.vpc.vpc_cidr_block }
    public_subnet_ids    = { type = "StringList", value = join(",", module.vpc.public_subnets) }
    app_subnet_ids       = { type = "StringList", value = join(",", module.vpc.private_subnets) }
    db_subnet_group_name = { type = "String", value = module.vpc.database_subnet_group_name }
    endpoint_sg_id       = { type = "String", value = module.vpc_endpoints.security_group_id }
    s3_prefix_list_id    = { type = "String", value = module.vpc_endpoints.endpoints["s3"].prefix_list_id }
    kms_key_arn          = { type = "String", value = module.kms.arn }
    acm_certificate_arn  = { type = "String", value = aws_acm_certificate_validation.this.certificate_arn }
    domain_name          = { type = "String", value = var.domain_name }
    route53_zone_id      = { type = "String", value = data.aws_route53_zone.this.zone_id }
  }
}

resource "aws_ssm_parameter" "this" {
  for_each = local.parameters

  name  = "/java-platform/${var.environment}/${each.key}"
  type  = each.value.type
  value = each.value.value
}
