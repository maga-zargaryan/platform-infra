output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "app_subnet_ids" {
  value = module.vpc.private_subnets
}

output "db_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}

output "kms_key_arn" {
  value = module.kms.arn
}

output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.this.certificate_arn
}

output "ssm_parameter_names" {
  value = [for p in aws_ssm_parameter.this : p.name]
}
