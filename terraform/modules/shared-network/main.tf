resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "shared-image-builder-vpc"
  }
}

locals {
  az_index = {
    for i, az in var.availability_zones : az => i
  }

  interface_services = toset([
    "imagebuilder",
    "ssm",
    "ssmmessages",
    "secretsmanager",
    "kms",
    "logs"
  ])
}

resource "aws_subnet" "private" {
  for_each = local.az_index

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = var.private_subnet_cidrs[each.value]

  tags = {
    Name = "shared-image-builder-private-${each.key}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "shared-image-builder-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "endpoints" {
  name        = "shared-image-builder-vpce-sg"
  description = "HTTPS access to private AWS service endpoints for Image Builder"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from Image Builder private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shared-image-builder-vpce-sg"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "AllowImageBuilderBucketListing"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:ListBucket"

        Resource = [
          "arn:aws:s3:::ec2imagebuilder-toe-${var.aws_region}-prod",
          "arn:aws:s3:::ec2imagebuilder-toe-${var.aws_region}-preprod",
          "arn:aws:s3:::ec2imagebuilder-toe-${var.aws_region}-beta",
          "arn:aws:s3:::ec2imagebuilder-managed-resources-${var.aws_region}-prod",
          "arn:aws:s3:::ec2imagebuilder-managed-resources-${var.aws_region}-preprod",
          "arn:aws:s3:::ec2imagebuilder-managed-resources-${var.aws_region}-beta",
          "arn:aws:s3:::amazon-ssm-${var.aws_region}"
        ]
      },
      {
        Sid       = "AllowImageBuilderObjectAccess"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"

        Resource = [
          "arn:aws:s3:::ec2imagebuilder-toe-${var.aws_region}-prod/*",
          "arn:aws:s3:::ec2imagebuilder-toe-${var.aws_region}-preprod/*",
          "arn:aws:s3:::ec2imagebuilder-toe-${var.aws_region}-beta/*",
          "arn:aws:s3:::ec2imagebuilder-managed-resources-${var.aws_region}-prod/*",
          "arn:aws:s3:::ec2imagebuilder-managed-resources-${var.aws_region}-preprod/*",
          "arn:aws:s3:::ec2imagebuilder-managed-resources-${var.aws_region}-beta/*",
          "arn:aws:s3:::amazon-ssm-${var.aws_region}/*"
        ]
      }
    ]
  })

  tags = {
    Name = "shared-image-builder-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "interfaces" {
  for_each = local.interface_services

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "shared-image-builder-${each.key}-endpoint"
  }
}