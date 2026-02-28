resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.app.id,
    aws_route_table.data.id
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name}-vpce-s3"
  })
}