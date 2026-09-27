output "vpc_id" { value = module.network.vpc_id }
output "private_subnet_ids" { value = module.network.private_subnet_ids }
output "endpoint_security_group_id" { value = module.network.endpoint_security_group_id }
