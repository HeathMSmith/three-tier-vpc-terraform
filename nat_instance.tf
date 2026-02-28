data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# NAT Instance user data: enable IP forwarding + configure iptables MASQUERADE
locals {
  nat_user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail
    dnf -y update
    echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-nat.conf
    sysctl -p /etc/sysctl.d/99-nat.conf

    # Basic NAT
    dnf -y install iptables-services
    systemctl enable iptables
    systemctl start iptables

    # Masquerade traffic out of the primary interface
    IFACE=$(ip route | awk '/default/ {print $5; exit}')
    iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE
    iptables -A FORWARD -i $IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -o $IFACE -j ACCEPT

    service iptables save
  EOF
}

# Place NAT instance in the first public subnet
resource "aws_instance" "nat" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type_nat
  subnet_id                   = values(aws_subnet.public)[0].id
  vpc_security_group_ids      = [aws_security_group.nat.id]
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = local.nat_user_data

  tags = merge(local.common_tags, {
    Name = "${local.name}-nat-instance"
    Role = "nat"
  })
}

# Routes for private subnets -> NAT instance
resource "aws_route" "app_default_via_nat" {
  route_table_id         = aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id

  depends_on = [aws_instance.nat]
}

resource "aws_route" "data_default_via_nat" {
  route_table_id         = aws_route_table.data.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id

  depends_on = [aws_instance.nat]
}