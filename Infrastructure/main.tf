data "aws_region" "current" {}


module "aws_vpc" {
  source = "../modules/vpc"

  cidr_block       = var.cidr_block
  name             = var.name
  aws_subnet_count = var.aws_subnet_count
}


module "aws_eks_cluster" {
  source     = "../modules/eks"
  env        = var.env
  subnet_ids = module.aws_vpc.subnet_ids
}

module "lb_controller" {
  source            = "../modules/loadbalancer"
  cluster_name      = module.aws_eks_cluster.cluster_name
  aws_region        = data.aws_region.current.region
  vpc_ID            = module.aws_vpc.vpc_ID
  oidc_provider     = module.aws_eks_cluster.oidc_provider
  oidc_provider_arn = module.aws_eks_cluster.oidc_provider_arn
}


