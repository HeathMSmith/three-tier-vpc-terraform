# Interface endpoints for SSM in private subnets (helps reduce dependency on NAT for management traffic)
resource "aws_vpc_endpoint" "ssm" {
  count               = var.enable_ssm_endpoints ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.app : s.id]
  security_group_ids  = [aws_security_group.vpce[0].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, { Name = "${local.name}-vpce-ssm" })
}

resource "aws_vpc_endpoint" "ec2messages" {
  count               = var.enable_ssm_endpoints ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.app : s.id]
  security_group_ids  = [aws_security_group.vpce[0].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, { Name = "${local.name}-vpce-ec2messages" })
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count               = var.enable_ssm_endpoints ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.app : s.id]
  security_group_ids  = [aws_security_group.vpce[0].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, { Name = "${local.name}-vpce-ssmmessages" })
}