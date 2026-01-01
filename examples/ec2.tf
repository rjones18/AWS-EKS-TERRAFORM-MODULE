############################################
# Amazon Linux 2023 (x86_64) latest
############################################
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

############################################
# Security Group for kubectl host
# - No inbound needed if you use SSM
# - Egress open so it can reach EKS endpoint + pull packages
############################################
resource "aws_security_group" "kubectl_host" {
  name        = "${var.cluster_name}-kubectl-host-sg"
  description = "Security group for kubectl host"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.cluster_name}-kubectl-host-sg" })

  # Optional SSH (not recommended if you have SSM)
  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidrs) > 0 ? [1] : []
    content {
      description = "SSH (optional)"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidrs
    }
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow kubectl host SG to reach EKS API (control plane) on 443
resource "aws_security_group_rule" "kubectl_to_eks_api" {
  type                     = "ingress"
  security_group_id        = module.eks.cluster_security_group_id # <-- output from EKS module
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kubectl_host.id
  description              = "Allow kubectl host to reach EKS API"
}

############################################
# IAM role + instance profile
# - SSM access (recommended)
# - EKS Describe for update-kubeconfig
############################################
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kubectl_host" {
  name               = "${var.cluster_name}-kubectl-host-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = var.tags
}

# SSM so you can connect without SSH
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.kubectl_host.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Minimal EKS read needed for kubeconfig generation
data "aws_iam_policy_document" "eks_describe" {
  statement {
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks_describe" {
  name   = "${var.cluster_name}-kubectl-host-eks-describe"
  policy = data.aws_iam_policy_document.eks_describe.json
}

resource "aws_iam_role_policy_attachment" "eks_describe" {
  role       = aws_iam_role.kubectl_host.name
  policy_arn = aws_iam_policy.eks_describe.arn
}

resource "aws_iam_instance_profile" "kubectl_host" {
  name = "${var.cluster_name}-kubectl-host-profile"
  role = aws_iam_role.kubectl_host.name
}

resource "aws_eks_access_entry" "kubectl_host" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.kubectl_host.arn
}

resource "aws_eks_access_policy_association" "kubectl_host_view" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.kubectl_host.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }
}

############################################
# EC2 instance
############################################
resource "aws_instance" "kubectl_host" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.small"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.kubectl_host.id]
  iam_instance_profile        = aws_iam_instance_profile.kubectl_host.name
  associate_public_ip_address = false # recommended (use SSM)

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf -y update

    # Install kubectl (Amazon EKS docs use this pattern; pin version later if you want)
    dnf -y install curl tar gzip
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    # Install AWS CLI v2 (AL2023 often already has awscli, but ensure v2-ish)
    dnf -y install awscli

    # Configure kubeconfig for the instance role identity
    mkdir -p /home/ec2-user/.kube
    chown -R ec2-user:ec2-user /home/ec2-user/.kube

    sudo -u ec2-user aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}

    # Smoke test (won't succeed until you grant Kubernetes RBAC via access entry/aws-auth)
    sudo -u ec2-user kubectl version --client=true
  EOF

  tags = merge(var.tags, { Name = "${var.cluster_name}-kubectl-host" })
}

output "kubectl_host_instance_id" {
  value = aws_instance.kubectl_host.id
}

output "kubectl_host_role_arn" {
  value = aws_iam_role.kubectl_host.arn
}