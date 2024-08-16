region="eu-central-1"
environment="prod"
project_name="exampleproject"
postgres_user= "postgresuserprod"
another_non_secret_variable="prod-somevalue"

ecs_app_config = {
  ens-api = {
    container_cpu = 2
    container_memory = 512
    container_port = 80
    host_port = 80
    container_desired_count = 1
    environment_variables = []
    sg_inbound_cidr_block = ""
  }
  ens-fe = {
    container_cpu = 1
    container_memory = 256
    container_port = 80
    host_port = 80
    container_desired_count = 1
    environment_variables = []
    sg_inbound_cidr_block = ""
  }
}