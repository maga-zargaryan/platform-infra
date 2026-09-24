resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.environment}-vpce-sg"
  description = "HTTPS access from private application subnets to VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from private application subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_app_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_app.id, aws_route_table.private_db.id]
  tags              = { Name = "${var.environment}-s3-endpoint" }
}

locals {
  interface_services = toset([
    "ssm",
    "ssmmessages",
    "secretsmanager",
    "kms",
    "logs"
  ])
}

resource "aws_vpc_endpoint" "interfaces" {
  for_each            = local.interface_services
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private_app)[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
  tags                = { Name = "${var.environment}-${each.key}-endpoint" }
}
