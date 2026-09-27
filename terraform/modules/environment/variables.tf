variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
}

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
  description = "CIDRs for public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "public_subnet_cidrs must contain exactly one CIDR per Availability Zone."
  }
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs for private application subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_app_subnet_cidrs) == length(var.availability_zones)
    error_message = "private_app_subnet_cidrs must contain exactly one CIDR per Availability Zone."
  }
}

variable "private_db_subnet_cidrs" {
  description = "CIDRs for private database subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_cidrs) == length(var.availability_zones)
    error_message = "private_db_subnet_cidrs must contain exactly one CIDR per Availability Zone."
  }
}

variable "domain_name" {
  description = "Domain name for the ACM certificate."
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID."
  type        = string
}