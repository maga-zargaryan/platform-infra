variable "vpc_cidr" {
  description = "CIDR block for the image build VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones for the build subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "One private subnet CIDR per Availability Zone."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "One private subnet CIDR is required per Availability Zone."
  }
}

variable "interface_endpoints" {
  description = "AWS services reached through interface VPC endpoints during image builds."
  type        = list(string)
}

variable "endpoint_az_count" {
  description = "Number of Availability Zones hosting interface endpoints (and used for builds)."
  type        = number
}

variable "flow_log_retention_in_days" {
  description = "VPC flow log retention."
  type        = number
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period before the build network KMS key is deleted."
  type        = number
}
