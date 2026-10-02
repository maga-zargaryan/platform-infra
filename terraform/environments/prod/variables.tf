variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per AZ."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "Private application subnet CIDRs, one per AZ."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "Private database subnet CIDRs, one per AZ."
  type        = list(string)
}

variable "interface_endpoints" {
  description = "Interface VPC endpoint services."
  type        = list(string)
}

variable "endpoint_az_count" {
  description = "Number of AZs hosting interface endpoints."
  type        = number
}

variable "flow_log_retention_in_days" {
  description = "VPC flow log retention."
  type        = number
}

variable "kms_deletion_window_in_days" {
  description = "KMS key deletion window."
  type        = number
}

variable "domain_name" {
  description = "Application domain name."
  type        = string
}

variable "route53_zone_name" {
  description = "Existing public hosted zone."
  type        = string
}
