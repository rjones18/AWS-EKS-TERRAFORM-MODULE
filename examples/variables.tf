variable "region" {
  type        = string
  description = "AWS region to deploy EKS into"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for EKS control plane and node groups"
}

variable "logs_kms_key_arn" {
  type        = string
  description = "KMS key ARN used to encrypt EKS control plane CloudWatch logs"
}

variable "eks_kms_key_arn" {
  type        = string
  description = "KMS key ARN used for EKS secrets encryption"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, stg, prod)"
  default     = "dev"
}

variable "owner" {
  type        = string
  description = "Team or owner responsible for this EKS cluster"
  default     = "platform"
}