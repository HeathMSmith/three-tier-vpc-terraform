# ALB SG: allow inbound HTTP from internet; outbound to app instances
resource "aws_security_group" "alb" {
  name        = "${local.name}-sg-alb"
  description = "ALB security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description      = "HTTP from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "To app on HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(local.common_tags, { Name = "${local.name}-sg-alb" })
}

# App SG: allow HTTP only from ALB SG; allow all egress (goes via NAT instance)
resource "aws_security_group" "app" {
  name        = "${local.name}-sg-app"
  description = "App tier security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name}-sg-app" })
}

# NAT instance SG: allow inbound from VPC; allow outbound to internet
resource "aws_security_group" "nat" {
  name        = "${local.name}-sg-nat"
  description = "NAT instance security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name}-sg-nat" })
}

# Optional: endpoint SG (for interface endpoints)
resource "aws_security_group" "vpce" {
  count       = var.enable_ssm_endpoints ? 1 : 0
  name        = "${local.name}-sg-vpce"
  description = "VPC endpoint security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name}-sg-vpce" })
}