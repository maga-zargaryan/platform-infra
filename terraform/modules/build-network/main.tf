data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  name         = "java-platform-build"
  account_id   = data.aws_caller_identity.current.account_id
  partition    = data.aws_partition.current.partition
  region       = data.aws_region.current.region
  boundary_arn = "arn:${local.partition}:iam::${local.account_id}:policy/java-platform-permissions-boundary"
  az_suffixes  = [for az in var.availability_zones : substr(az, -2, 2)]

  # Builds run in the first subnet; interface endpoints live in the same AZ.
  build_subnet_ids = slice(module.vpc.private_subnets, 0, var.endpoint_az_count)

  # S3 buckets Image Builder and the build components read from. Everything else is denied.
  allowed_s3_buckets = [
    "ec2imagebuilder-toe-${local.region}-prod",
    "ec2imagebuilder-managed-resources-${local.region}-prod",
    "amazon-ssm-${local.region}",
    "aws-ssm-${local.region}",
    "aws-ssm-document-attachments-${local.region}",
    "patch-baseline-snapshot-${local.region}",
    "al2023-repos-${local.region}-de612dc2",
    "amazoncloudwatch-agent-${local.region}",
    "amazon-efs-utils-${local.region}",
  ]
}

module "kms" {
  source = "../kms-key"

  alias                   = local.name
  description             = "Image build network log encryption"
  deletion_window_in_days = var.kms_deletion_window_in_days
}

# Private, internet-isolated build network: Image Builder reaches AWS only through endpoints.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = local.name
  cidr = var.vpc_cidr
  azs  = var.availability_zones

  private_subnets      = var.private_subnet_cidrs
  private_subnet_names = [for s in local.az_suffixes : "${local.name}-private-${s}"]

  create_igw         = false
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
  flow_log_cloudwatch_log_group_name_suffix       = "build"
  flow_log_cloudwatch_log_group_retention_in_days = var.flow_log_retention_in_days
  flow_log_cloudwatch_log_group_kms_key_id        = module.kms.arn
  vpc_flow_log_iam_role_name                      = "java-platform-network-flow-logs-build"
  vpc_flow_log_iam_role_use_name_prefix           = false
  vpc_flow_log_iam_policy_name                    = "java-platform-network-flow-logs-build"
  vpc_flow_log_iam_policy_use_name_prefix         = false
  vpc_flow_log_permissions_boundary               = local.boundary_arn
}

resource "aws_security_group" "build_instance" {
  name        = "${local.name}-instance"
  description = "Image Builder build and test instances"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${local.name}-instance"
  }
}

resource "aws_vpc_security_group_egress_rule" "build_to_endpoints" {
  security_group_id            = aws_security_group.build_instance.id
  description                  = "HTTPS to interface endpoints"
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = module.vpc_endpoints.security_group_id
}

resource "aws_vpc_security_group_egress_rule" "build_to_s3" {
  security_group_id = aws_security_group.build_instance.id
  description       = "HTTPS to S3 through the gateway endpoint"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  prefix_list_id    = module.vpc_endpoints.endpoints["s3"].prefix_list_id
}

data "aws_iam_policy_document" "s3_endpoint" {
  statement {
    sid       = "AllowListBuildBuckets"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [for b in local.allowed_s3_buckets : "arn:${local.partition}:s3:::${b}"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    sid       = "AllowReadBuildBuckets"
    actions   = ["s3:GetObject"]
    resources = [for b in local.allowed_s3_buckets : "arn:${local.partition}:s3:::${b}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "6.7.3"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name        = "${local.name}-vpc-endpoints"
  security_group_description = "HTTPS from build instances to interface endpoints"
  security_group_rules = {
    https_from_build_instances = {
      description              = "HTTPS from build instances"
      source_security_group_id = aws_security_group.build_instance.id
    }
  }

  endpoints = merge(
    {
      s3 = {
        service         = "s3"
        service_type    = "Gateway"
        route_table_ids = module.vpc.private_route_table_ids
        policy          = data.aws_iam_policy_document.s3_endpoint.json
        tags            = { Name = "${local.name}-s3" }
      }
    },
    {
      for service in var.interface_endpoints : service => {
        service             = service
        private_dns_enabled = true
        subnet_ids          = local.build_subnet_ids
        tags                = { Name = "${local.name}-${service}" }
      }
    },
  )
}

# Contract consumed by java-ami.
locals {
  parameters = {
    vpc_id                  = module.vpc.vpc_id
    build_subnet_id         = local.build_subnet_ids[0]
    build_security_group_id = aws_security_group.build_instance.id
  }
}

resource "aws_ssm_parameter" "this" {
  for_each = local.parameters

  name  = "/java-platform/shared/${each.key}"
  type  = "String"
  value = each.value
}
