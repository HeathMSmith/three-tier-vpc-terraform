output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_app_subnet_ids" {
  value = [for s in aws_subnet.app : s.id]
}

output "private_data_subnet_ids" {
  value = [for s in aws_subnet.data : s.id]
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "nat_instance_id" {
  value = aws_instance.nat.id
}