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

resource "aws_lb_target_group" "ecs" {
  name        = "${local.infix}-ecs-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 4
    interval            = 10
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.public-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

module "aws_ecs_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.infix}-ecs-sg"
  description = "Security group to be used with ECS LB"
  vpc_id      = module.vpc.vpc_id

  ## INGRESS ##
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP inbound traffic"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS inbound traffic"
      cidr_blocks = local.vpc_cidr
    }
  ]


  ## EGRESS ##
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all traffic out"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}

module "aws_lb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.infix}-ecs-sg"
  description = "Security group to be used with ECS LB"
  vpc_id      = module.vpc.vpc_id

  ## INGRESS ##
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP inbound traffic"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS inbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]


  ## EGRESS ##
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all traffic out"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}