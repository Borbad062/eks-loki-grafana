terraform {
  required_version = ">= 1.13.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.1"
    }
  }
}
