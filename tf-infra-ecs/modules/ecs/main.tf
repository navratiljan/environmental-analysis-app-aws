resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${local.base_name}"
}

## ECR ##
resource "aws_ecr_repository" "app" {
  name                 = "${var.application_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

## EC2 ##
module "aws_ecs_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.base_name}-ecs-sg"
  description = "Security group to be used with ECS LB"
  vpc_id      = var.vpc_id

  ## INGRESS ##
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP inbound traffic"
      cidr_blocks = var.sg_inbound_cidr_block
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS inbound traffic"
      cidr_blocks = var.sg_inbound_cidr_block
    }
  ]

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

resource "aws_lb_target_group" "ecs" {
  name        = "${var.application_name}-ecs-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

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
  load_balancer_arn = var.alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

## ECS ##
resource "aws_ecs_cluster" "cluster" {
  name = "${local.base_name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "fastapi"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions = jsonencode([
    {
      name      = "${local.base_name}-fastapi-service"
      image     = "${aws_ecr_repository.app.repository_url}:${var.ecr_image_tag}"
      cpu       = "${var.container_cpu}"
      memory    = "${var.container_memory}"
      essential = true
      environment = var.environment_variables
      logConfiguration = {
        logDriver = "awslogs"
        options    = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.ecs.name}"
          "awslogs-region"        = "${var.region}"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-multiline-pattern": "^(INFO|DEBUG|WARN|ERROR|CRITICAL)"
        }
      }
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
        }
      ]
    }
  ])

  dynamic "volume" {
    for_each = var.volumes
    content {
      name      = volume.value.name
      host_path = volume.value.host_path
    }
    
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

}

resource "aws_ecs_service" "service" {
  name            = "${local.base_name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.container_desired_count
  launch_type     = "FARGATE"
  enable_execute_command = true
  #depends_on      = [aws_iam_role_policy.foo]

  deployment_circuit_breaker {
    enable   = var.enable_circuit_breaker
    rollback = var.rollback_circuit_breaker
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = "${local.base_name}-fastapi-service"
    container_port   = var.container_port
  }

  network_configuration {
    subnets = var.vpc_subnets
    security_groups  = [module.aws_ecs_sg.security_group_id]
    assign_public_ip = false
  }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }
}