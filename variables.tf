variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Name prefix for resources"
  default     = "three-tier-vpc"
}

variable "environment" {
  type        = string
  description = "Environment tag"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.20.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Number of AZs to use (2 recommended)"
  default     = 2
}

variable "instance_type_app" {
  type        = string
  description = "App tier instance type"
  default     = "t3.micro"
}

variable "instance_type_nat" {
  type        = string
  description = "NAT instance type (keep small for cost)"
  default     = "t3.micro"
}

variable "desired_capacity" {
  type        = number
  description = "ASG desired capacity"
  default     = 1
}

variable "min_size" {
  type        = number
  description = "ASG min size"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "ASG max size"
  default     = 2
}

variable "enable_ssm_endpoints" {
  type        = bool
  description = "Create VPC interface endpoints for SSM to reduce NAT dependence for management"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Extra tags to apply"
  default     = {}
}