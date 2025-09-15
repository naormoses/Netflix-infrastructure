output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "certificate_authority" {
  value = aws_eks_cluster.main.certificate_authority
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_oidc_issuer_url" {
  value = local.oidc_issuer_url
}

output "oidc_provider" {
  value = local.oidc_provider
}

output "oidc_provider_id" {
  value = local.oidc_provider_id
}

output "oidc_provider_arn" {
  value = local.oidc_provider_arn
}
