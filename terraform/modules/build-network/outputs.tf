output "vpc_id" {
  value = module.vpc.vpc_id
}

output "build_subnet_id" {
  value = local.build_subnet_ids[0]
}

output "build_security_group_id" {
  value = aws_security_group.build_instance.id
}
