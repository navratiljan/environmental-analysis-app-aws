# resource "aws_ecr_repository" "foo" {
#   name                 = "${local.infix}-ecr"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }
# resource "aws_ecr_repository" "fe" {
#   name                 = "${local.infix}-fe-ecr"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }