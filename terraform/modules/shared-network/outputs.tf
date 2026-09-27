output "vpc_id" { value = aws_vpc.this.id }
output "private_subnet_ids" { value = values(aws_subnet.private)[*].id }
output "endpoint_security_group_id" { value = aws_security_group.endpoints.id }
