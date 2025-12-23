output "cluster_name" {
  value       = aws_eks_cluster.this.name
  description = "EKS cluster name"
}

output "cluster_arn" {
  value       = aws_eks_cluster.this.arn
  description = "EKS cluster ARN"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "EKS API server endpoint"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  description = "Base64 encoded certificate data required for kubeconfig"
  sensitive   = true
}

output "cluster_security_group_id" {
  value       = aws_security_group.cluster.id
  description = "Security group attached to EKS cluster ENIs"
}

# IRSA / OIDC
output "oidc_issuer_url" {
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
  description = "OIDC issuer URL (for IRSA)"
}

# Node Group
output "node_group_name" {
  value       = aws_eks_node_group.this.node_group_name
  description = "Managed node group name"
}

output "node_role_arn" {
  value       = aws_iam_role.nodes.arn
  description = "IAM role ARN used by worker nodes"
}