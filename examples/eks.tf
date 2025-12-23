module "eks" {
  source = "../"

  name               = "malik-eks"
  vpc_id             = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids

  # Recommended security defaults
  endpoint_public_access  = false
  endpoint_private_access = true

  # Control plane logs
  cluster_log_retention_days = 365
  cluster_log_kms_key_arn    = var.logs_kms_key_arn

  # Secrets encryption
  enable_cluster_encryption     = true
  cluster_encryption_kms_key_arn = var.eks_kms_key_arn

  node_instance_types = ["m6i.large"]
  node_desired_size   = 2
  node_min_size       = 2
  node_max_size       = 4

  tags = {
    Environment = "dev"
    Owner       = "platform"
    AIT         = "true"
  }
}