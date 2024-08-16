data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
locals {
  tags = {
    env      = var.environment
    project  = var.project_name
    location = var.region
  }

  infix = "${var.project_name}-${var.environment}"
}
locals {
  account_id      = data.aws_caller_identity.current.account_id
  cluster_version = "1.27"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  test = { for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    record = dvo.resource_record_value
    type   = dvo.resource_record_type
  } }
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

