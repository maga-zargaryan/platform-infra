variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "vpc_cidr" {
  description = "Build VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per AZ."
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
