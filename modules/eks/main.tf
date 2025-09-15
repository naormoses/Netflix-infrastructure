resource "aws_eks_cluster" "main" {
  name = "${var.env}-eks"
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.32"

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_CloudWatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.eks_cluster_role.name
}


resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_eks_access_entry" "cluster_admin_user" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::864981744677:user/naor"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_admin_access" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_eks_access_entry.cluster_admin_user.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}


resource "aws_eks_node_group" "prod" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "prod"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEC2ContainerRegistryReadOnly
  ]
}

data "aws_caller_identity" "current" {}

locals {
  oidc_issuer_url   = aws_eks_cluster.main.identity[0].oidc[0].issuer
  oidc_provider     = replace(local.oidc_issuer_url, "https://", "")
  oidc_provider_id  = regex("id/(.*)", local.oidc_provider)[0]
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"
}
