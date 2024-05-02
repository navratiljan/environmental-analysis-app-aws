resource "aws_ecs_cluster" "cluster" {
  name = "${local.infix}-ecs-cluster"

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
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "${local.infix}-fastapi-service"
      image     = "812222239604.dkr.ecr.eu-central-1.amazonaws.com/exampleproject-prod-ecr:latest"
      cpu       = 256
      memory    = 512
      essential = true
      environment = [
        {
        name  = "S3_DATASETS_BUCKET_NAME"
        value = "environmental-app-dataset-bucket"
        },
        {
        name  = "DYNAMODB_TABLE"
        value = "table-environmental-dataset-fastapi"
      }
    ]
      logConfiguration = {
        logDriver = "awslogs"
        options    = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.ecs_fastapi.name}"
          "awslogs-region"        = "eu-central-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  #   volume {
  #     name      = "service-storage"
  #     host_path = "/ecs/service-storage"
  #   }

  #   placement_constraints {
  #     type       = "memberOf"
  #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #   }

}

resource "aws_ecs_service" "service" {
  name            = "${local.infix}-fastapi-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  enable_execute_command = true
  #depends_on      = [aws_iam_role_policy.foo]

  # deployment_circuit_breaker {
  #   enable   = true
  #   rollback = false
  # }


  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = "${local.infix}-fastapi-service"
    container_port   = 80
  }

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups  = [module.aws_ecs_sg.security_group_id]
    assign_public_ip = false
  }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }
}