resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.environment}-wp-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-wp-igw" }
}

locals {
  az_index = { for i, az in var.availability_zones : az => i }
}

resource "aws_subnet" "public" {
  for_each                = local.az_index
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = var.public_subnet_cidrs[each.value]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.environment}-public-${each.key}" }
}

resource "aws_subnet" "private_app" {
  for_each          = local.az_index
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = var.private_app_subnet_cidrs[each.value]
  tags              = { Name = "${var.environment}-private-app-${each.key}" }
}

resource "aws_subnet" "private_db" {
  for_each          = local.az_index
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = var.private_db_subnet_cidrs[each.value]
  tags              = { Name = "${var.environment}-private-db-${each.key}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.environment}-public-rt" }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-private-app-rt" }
}

resource "aws_route_table_association" "private_app" {
  for_each       = aws_subnet.private_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-private-db-rt" }
}

resource "aws_route_table_association" "private_db" {
  for_each       = aws_subnet.private_db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_db.id
}
