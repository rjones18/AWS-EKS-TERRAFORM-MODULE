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

#### Variables for EKS EC2 Bastion ####

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "malik-eks"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the kubectl host (private subnet recommended)"
  default     = "subnet-0fe92f91659185f4d"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to SSH (only used if you open 22; SSM recommended)"
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
