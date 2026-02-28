# AWS Three-Tier VPC (Production-Style, Cost-Aware) — Terraform

Production-style **three-tier VPC architecture** in AWS, built entirely with **Terraform**.  
Designed to demonstrate private compute, secure management access, and cost-aware networking patterns suitable for a cloud engineering portfolio.

> **Cost note:** This project creates an **Application Load Balancer (ALB)** and EC2 instances which are **not fully Free Tier**. Destroy resources when not actively testing.

---

## Architecture Overview

This environment provisions:

- Custom **VPC** with DNS support
- **2 Availability Zones** (configurable)
- **Public subnets** (ALB + NAT instance)
- **Private App subnets** (Auto Scaling Group instances, no public IPs)
- **Private Data subnets** (network-ready for RDS/DB tier; DB not created by default)
- **Internet Gateway**
- Route tables per tier
- Security groups for ALB, app, NAT, and VPC endpoints
- **NAT Instance** (low-cost alternative to NAT Gateway)
- **SSM Session Manager access** (no SSH required)
- **VPC Interface Endpoints** for SSM (optional)
- **S3 Gateway Endpoint** (enables private subnets to reach Amazon Linux repos in S3 without NAT)

---

## High-Level Diagram (Text)
