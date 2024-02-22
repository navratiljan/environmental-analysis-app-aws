terraform {
  required_version = "~> 1.6" # Always try to use the most up to date version of Terraform

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25.0" # Always try to use the most up to date version of the AWS provider
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0" # Always try to use the most up to date version of the Kubernetes provider
    }
  }
}
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
provider "aws" {
  region = var.region
  alias  = "primary"


  # Set default tags for all resources
  default_tags {
    tags = local.tags
  }
}