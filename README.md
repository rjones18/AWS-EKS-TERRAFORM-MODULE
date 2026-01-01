# AWS-EKS-TERRAFORM-MODULE

A Terraform module for deploying **Amazon EKS clusters** with secure defaults, private networking, IAM-based access control, and operational best practices.

This module is designed for **platform engineering teams** managing Kubernetes clusters in both **commercial and regulated environments**.

---

## Features

- Private or public EKS cluster endpoints
- IAM-based access control using **EKS Access Entries**
- Managed node groups with autoscaling
- Control plane logging with configurable retention
- KMS encryption for:
  - Kubernetes secrets
  - Control plane logs
- Secure-by-default networking
- Designed to work with **SSM-based admin hosts**
- Compatible with CI/CD-driven infrastructure workflows

---

## Architecture Overview

- EKS control plane with configurable endpoint access
- Managed node groups deployed into private subnets
- Optional admin access via:
  - IAM roles (Access Entries)
  - Bastion / SSM-connected EC2 hosts
- KMS-backed encryption for secrets and logs

---

## Usage

### Basic Example

```hcl
module "eks" {
  source = "git::https://github.com/your-org/terraform-aws-eks.git?ref=v1.0.0"

  name               = "example-eks"
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  endpoint_public_access  = false
  endpoint_private_access = true

  # Control plane logging
  cluster_log_retention_days = 365
  cluster_log_kms_key_arn    = aws_kms_key.eks_logs.arn

  # Secrets encryption
  enable_cluster_encryption      = true
  cluster_encryption_kms_key_arn = aws_kms_key.eks_secrets.arn

  node_instance_types = ["t3.medium"]
  node_desired_size   = 2
  node_min_size       = 2
  node_max_size       = 4

  tags = {
    Environment = "dev"
    Owner       = "platform"
  }
}