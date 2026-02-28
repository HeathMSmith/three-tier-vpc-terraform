data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # /20 subnets carved from /16 = plenty for a demo, neat boundaries
  public_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i)]     # 0,1
  app_cidrs    = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 4)] # 4,5
  data_cidrs   = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 8)] # 8,9
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = local.public_cidrs[each.key]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name}-subnet-public-${each.value}"
    Tier = "public"
  })
}

resource "aws_subnet" "app" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = local.app_cidrs[each.key]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.name}-subnet-app-${each.value}"
    Tier = "app"
  })
}

resource "aws_subnet" "data" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = local.data_cidrs[each.key]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.name}-subnet-data-${each.value}"
    Tier = "data"
  })
}

# Public route table -> IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name}-rt-public"
  })
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# App route table -> NAT instance (added in nat_instance.tf once nat exists)
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name}-rt-app"
  })
}

resource "aws_route_table_association" "app" {
  for_each = aws_subnet.app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.app.id
}

# Data route table -> NAT instance (optional; often you’d keep data isolated, but for patching you may want egress)
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name}-rt-data"
  })
}

resource "aws_route_table_association" "data" {
  for_each = aws_subnet.data

  subnet_id      = each.value.id
  route_table_id = aws_route_table.data.id
}