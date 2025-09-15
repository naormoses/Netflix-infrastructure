terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.1"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}
