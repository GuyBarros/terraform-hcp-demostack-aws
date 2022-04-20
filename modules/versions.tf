terraform {
  required_version = ">= 1.1"
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.26.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.10.0"
    }
  }
}