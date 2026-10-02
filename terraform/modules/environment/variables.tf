variable "environment" {
  description = "Environment name."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the environment VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones used by the environment."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones are required."
  }
}

variable "public_subnet_cidrs" {
  description = "One public (load balancer) subnet CIDR per Availability Zone."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "public_subnet_cidrs must contain exactly one CIDR per Availability Zone."
  }
}

variable "private_app_subnet_cidrs" {
  description = "One private application subnet CIDR per Availability Zone."
  type        = list(string)

  validation {
    condition     = length(var.private_app_subnet_cidrs) == length(var.availability_zones)
    error_message = "private_app_subnet_cidrs must contain exactly one CIDR per Availability Zone."
  }
}

variable "private_db_subnet_cidrs" {
  description = "One private database subnet CIDR per Availability Zone."
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_cidrs) == length(var.availability_zones)
    error_message = "private_db_subnet_cidrs must contain exactly one CIDR per Availability Zone."
  }
}

variable "interface_endpoints" {
  description = "AWS services reached through interface VPC endpoints."
  type        = list(string)
}

variable "endpoint_az_count" {
  description = "Number of Availability Zones hosting interface endpoints. Production uses all AZs; non-production may use one."
  type        = number

  validation {
    condition     = var.endpoint_az_count >= 1
    error_message = "endpoint_az_count must be at least 1."
  }
}

variable "flow_log_retention_in_days" {
  description = "VPC flow log retention."
  type        = number
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period before the environment KMS key is deleted."
  type        = number
}

variable "domain_name" {
  description = "Application domain name for the ACM certificate."
  type        = string
}

variable "route53_zone_name" {
  description = "Existing public hosted zone that holds the application records."
  type        = string
}
