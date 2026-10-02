output "arn" {
  value = aws_kms_key.this.arn
}

output "alias_arn" {
  value = aws_kms_alias.this.arn
}
