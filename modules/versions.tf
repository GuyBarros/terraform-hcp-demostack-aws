terraform {
  required_version = ">= 1.0"
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.9.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "3.49.0"
    }
  }
}
