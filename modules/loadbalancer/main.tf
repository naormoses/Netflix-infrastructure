resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = var.vpc_ID
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]

  depends_on = [
    aws_iam_role.lb_controller_role
  ]
}

data "aws_iam_policy_document" "lb_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "lb_controller_role" {
  name               = "AmazonEKSLoadBalancerControllerRole-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.lb_assume_role.json
}

resource "aws_iam_policy" "lb_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy-${var.cluster_name}"
  policy = file("${path.module}/Resources/lb_controller_policy.json")
}

resource "aws_iam_role_policy_attachment" "lb_policy_attach" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller_role.arn
    }
  }

  depends_on = [
    aws_iam_role.lb_controller_role
  ]
}
