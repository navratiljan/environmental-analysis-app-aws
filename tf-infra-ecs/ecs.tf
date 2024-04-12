# resource "aws_ecs_cluster" "cluster" {
#   name = "${local.infix}-ecs-cluster"

#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
# }

# resource "aws_ecs_task_definition" "app" {
#   family = "service"
#   network_mode = "awsvpc"
#   container_definitions = jsonencode([
#     {
#       name      = "${local.infix}-fastapi-service"
#       image     = "service-first"
#       cpu       = 1
#       memory    = 4
#       essential = true
#       portMappings = [
#         {
#           containerPort = 8080
#           hostPort      = 80
#         }
#       ]
#     }
#   ])

# #   volume {
# #     name      = "service-storage"
# #     host_path = "/ecs/service-storage"
# #   }

# #   placement_constraints {
# #     type       = "memberOf"
# #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
# #   }
# }

# resource "aws_ecs_service" "service" {
#   name            = "${local.infix}-fastapi-service"
#   cluster         = aws_ecs_cluster.cluster.id
#   task_definition = aws_ecs_task_definition.app.arn
#   desired_count   = 3
#   depends_on      = [aws_iam_role_policy.foo]

#   ordered_placement_strategy {
#     type  = "binpack"
#     field = "cpu"
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.foo.arn
#     container_name   = "mongo"
#     container_port   = 8080
#   }

# #   placement_constraints {
# #     type       = "memberOf"
# #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
# #   }
# }