resource "aws_kms_key" "eks_logs" {
  description             = "KMS key for EKS control plane CloudWatch logs"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = data.aws_iam_policy_document.eks_kms_policy.json

  tags = {
    Name        = "eks-logs-kms"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_kms_alias" "eks_logs" {
  name          = "alias/eks/logs"
  target_key_id = aws_kms_key.eks_logs.key_id
}

resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS Kubernetes secrets encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = data.aws_iam_policy_document.eks_kms_policy.json

  tags = {
    Name        = "eks-secrets-kms"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/eks/secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks_kms_policy" {
  statement {
    sid = "AllowRootAccountAccess"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "AllowEKSAndCloudWatchUsage"
    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com",
        "logs.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}