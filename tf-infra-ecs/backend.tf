terraform {
  backend "s3" {
    bucket         = "fastapi-template-812222239604-s3-tfstate-dev-01"
    key            = "fastapi-template-dev-ecs.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "fastapi-template-812222239604-s3-tflocks-dev-01"
  }
}
