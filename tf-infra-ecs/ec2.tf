
resource "aws_lb" "public-lb" {
  name               = "${local.infix}-ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.aws_lb_sg.security_group_id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "logselb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

module "aws_lb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.infix}-ecs-sg"
  description = "Security group to be used with ECS LB"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 0 
      to_port     = 80
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 0 
      to_port     = 443
      protocol    = "tcp"
      description =  "ports"
      cidr_blocks = local.vpc_cidr 
    }
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = "${local.infix}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_ipv6            = false
  create_egress_only_igw = true


  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}