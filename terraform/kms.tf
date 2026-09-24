locals {
  kms_keys = {
    rds     = "RDS database encryption"
    efs     = "EFS file-system encryption"
    ebs     = "EBS volume encryption"
    secrets = "Secrets Manager encryption"
  }
}

resource "aws_kms_key" "workload" {
  for_each                = local.kms_keys
  description             = "${var.environment} ${each.value}"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = { Name = "${var.environment}-wordpress-${each.key}" }
}

resource "aws_kms_alias" "workload" {
  for_each      = aws_kms_key.workload
  name          = "alias/${var.environment}-wordpress-${each.key}"
  target_key_id = each.value.key_id
}
