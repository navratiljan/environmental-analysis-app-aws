#TODO dedicated provider in one account
### SSM Secure strings ###
# These are usually static secret values that don't need to be rotated and don't have a lifecycle
# data "aws_ssm_parameter" "example_secret" {
#   name = "/${var.project_name}/${var.environment}/example-secret"
# }


# ### AWS Secrets manager ###
# # These secrets are either rotated or have tied lifecycle with AWS services, f.e RDS password
# data "aws_secretsmanager_secret" "another_secret" {
#   name = "${var.environment}/postgres_pass"
# }