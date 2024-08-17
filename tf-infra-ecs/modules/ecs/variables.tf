variable "infix" {
  description = "Infix to be used in the resource names"
  type        = string
} 
variable "application_name" {
  description = "Name of the application"
  type        = string
}
variable "region" {
  description = "AWS region"
  type        = string
}

variable "container_cpu" {
  description = "CPU units for the container"
  type        = number
}

variable "container_memory" {
  description = "Memory size for the container"
  type        = number
}

variable "container_port" {
  description = "Container port number"
  type        = number
}

variable "host_port" {
  description = "Host port number"
  type        = number
}


variable "volumes" {
  description = "Map of volumes to attach to the container"
  type        = map(string)
  default = {}
}

variable "placement_constraints" {
  description = "Placement constraints for the ECS service"
  type        = list(object({
    type       = string
    expression = string
  }))
  default = []
}

variable "container_desired_count" {
  description = "Desired count of tasks"
  type        = number
}

variable "enable_circuit_breaker" {
  description = "Enable circuit breaker for deployments"
  type        = bool
}

variable "rollback_circuit_breaker" {
  description = "Rollback strategy for circuit breaker"
  type        = bool
}

variable "sg_inbound_cidr_block" {
  description = "CIDR blocks for inbound security group rules"
  type        = string
}
variable "environment_variables" {
  description = "Environment variables for the container"
  type        = list(map(string))
  default = []
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}


variable "ecr_image_tag" {
  description = "ECR image tag"
  type        = string
  
}
variable "vpc_subnets" {
  description = "Subnets to deploy the ECS service"
  type        = list(string)
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
  default = ""
}

variable "aws_route53_zone" {
  description = "Route53 zone to create DNS records"
}

variable "is_public_service" {
  description = "Flag to determine if the service is public"
  type        = bool
  default     = false
}

variable "public_alb_dnsname" {
  description = "DNS name of the public ALB"
  type        = string
}