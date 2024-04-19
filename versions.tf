terraform {
  required_version = ">= 1.1"
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      # version = "0.30.0"
    }
    aws = {
      source  = "hashicorp/aws"
      # version = "4.10.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
     # version = "~> 2.14.0"
    }

    helm = {
      source  = "hashicorp/helm"
     # version = "~> 2.7.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
     # version = "~> 1.14.0"
    }
  }
}

