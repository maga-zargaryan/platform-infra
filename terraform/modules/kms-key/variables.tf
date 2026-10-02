variable "alias" {
  description = "Alias name without the alias/ prefix."
  type        = string
}

variable "description" {
  description = "Key description."
  type        = string
}

variable "deletion_window_in_days" {
  description = "Waiting period before the key is deleted."
  type        = number

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

variable "via_services" {
  description = "AWS service prefixes (e.g. ec2, rds) through which account principals may use the key."
  type        = list(string)
  default     = []
}

variable "allow_autoscaling" {
  description = "Allow the Auto Scaling service-linked role to use the key for EBS volumes."
  type        = bool
  default     = false
}

variable "allow_cloudwatch_alarms" {
  description = "Allow CloudWatch alarms to publish to topics encrypted with the key."
  type        = bool
  default     = false
}
