module "eks" {
  source = "../"

  name               = "malik-eks"
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  # Recommended security defaults
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
    AIT         = "true"
  }
}

resource "aws_iam_role" "eks_breakglass_admin" {
  name = "${module.eks.cluster_name}-breakglass-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
      Action    = "sts:AssumeRole",
      Condition = { Bool = { "aws:MultiFactorAuthPresent" = "true" } }
    }]
  })
}

resource "aws_eks_access_entry" "breakglass" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.eks_breakglass_admin.arn
}

resource "aws_eks_access_policy_association" "breakglass_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.eks_breakglass_admin.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}