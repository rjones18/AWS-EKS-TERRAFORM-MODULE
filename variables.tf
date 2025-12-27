variable "name" {
  type        = string
  description = "Base name for the EKS cluster and resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS region (used only for validations/docs; provider sets actual region)"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for EKS control plane + node groups"
}

variable "cluster_version" {
  type        = string
  description = "EKS Kubernetes version"
  default     = "1.30"
}

variable "endpoint_public_access" {
  type        = bool
  description = "Whether the EKS API server endpoint is publicly accessible"
  default     = false
}

variable "endpoint_private_access" {
  type        = bool
  description = "Whether the EKS API server endpoint is privately accessible"
  default     = true
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "Allowed CIDRs for public EKS endpoint (only used when endpoint_public_access=true)"
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_types" {
  type        = list(string)
  description = "EKS control plane log types to enable"
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  type        = number
  description = "CloudWatch retention for EKS control plane logs"
  default     = 365
}

variable "cluster_log_kms_key_arn" {
  type        = string
  description = "KMS key ARN for encrypting CloudWatch log group (optional)"
  default     = null
}

variable "enable_cluster_encryption" {
  type        = bool
  description = "Enable envelope encryption for Kubernetes secrets"
  default     = true
}

variable "cluster_encryption_kms_key_arn" {
  type        = string
  description = "KMS key ARN for EKS secret encryption (required if enable_cluster_encryption=true)"
  default     = null
}

variable "node_group_name" {
  type        = string
  description = "Managed node group name suffix"
  default     = "default"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for the managed node group"
  default     = ["m6i.large"]
}

variable "node_capacity_type" {
  type        = string
  description = "ON_DEMAND or SPOT"
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "node_disk_size" {
  type        = number
  description = "Disk size in GiB for worker nodes"
  default     = 50
}

variable "enable_node_remote_access" {
  type        = bool
  description = "Enable SSH remote access to nodes (generally discouraged)"
  default     = false
}

variable "node_ssh_key_name" {
  type        = string
  description = "EC2 key pair name for node SSH (required if enable_node_remote_access=true)"
  default     = null
}

variable "node_remote_access_sg_ids" {
  type        = list(string)
  description = "Security group IDs allowed to SSH into nodes"
  default     = []
}

variable "additional_cluster_security_group_ids" {
  type        = list(string)
  description = "Additional security groups to attach to the EKS cluster ENIs"
  default     = []
}