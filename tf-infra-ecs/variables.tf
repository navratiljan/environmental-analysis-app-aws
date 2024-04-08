variable "region" {
  description = "Location of resource group"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "name of the environment"
  type        = string
}

variable "project_name" {
  description = "name of the project"
  type        = string
}

variable "another_non_secret_variable" {
  description = "Dummy non-secret variable"
  type        = string
}

variable "eks_disk_size" {
  description = "Disk size for EKS nodes"
  type        = number
  default     = 100
}

variable "eks_node_group_instance_role_name" {
  description = "IAM role name for EKS node group"
  type        = string
  default     = "eks_node_group_instance_role"
}









