output "vpc_id" {
  value = module.build_network.vpc_id
}

output "build_subnet_id" {
  value = module.build_network.build_subnet_id
}

output "build_security_group_id" {
  value = module.build_network.build_security_group_id
}
