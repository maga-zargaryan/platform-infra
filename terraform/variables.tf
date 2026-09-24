variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
}

variable "environment" {
  description = "Environment name used for resource naming and tags."
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
    error_message = "At least two Availability Zones are required for high availability."
  }
}

variable "public_subnet_cidrs" {
  description = "One public subnet CIDR per Availability Zone."
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

variable "domain_name" {
  description = "Domain name used for the ACM certificate."
  type        = string
}

variable "route53_zone_id" {
  description = "Existing public Route53 hosted zone ID used for ACM DNS validation."
  type        = string
}
