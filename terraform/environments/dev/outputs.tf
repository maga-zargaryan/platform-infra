output "vpc_id" {
  value = module.environment.vpc_id
}

output "public_subnet_ids" {
  value = module.environment.public_subnet_ids
}

output "app_subnet_ids" {
  value = module.environment.app_subnet_ids
}

output "db_subnet_group_name" {
  value = module.environment.db_subnet_group_name
}

output "kms_key_arn" {
  value = module.environment.kms_key_arn
}

output "acm_certificate_arn" {
  value = module.environment.acm_certificate_arn
}

output "ssm_parameter_names" {
  value = module.environment.ssm_parameter_names
}
