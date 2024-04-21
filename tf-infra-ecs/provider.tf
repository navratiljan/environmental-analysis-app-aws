terraform {
  required_version = "~> 1.5" # Always try to use the most up to date version of Terraform

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0" # Always try to use the most up to date version of the AWS provider
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0" # Always try to use the most up to date version of the Kubernetes provider
    }
  }
}
provider "aws" {
  region = var.region

  # Set default tags for all resources
  default_tags {
    tags = local.tags
  }
}