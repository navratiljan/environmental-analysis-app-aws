variable "resource_group_name" {
  description = "name of parent resource group"
  type = string
}
variable "location" {
  description = "location"
  type = string
}

variable "infix" {
  description = "infix passed from locals in root"
  type = string
}
variable "container_app_name" {
  description = "Name of contaier app"
  type = string
}   
variable "container_app_environment_id" {
  description = "Id of parent container apps environment"
  type = string
}
variable "acr_login_server" {
  description = "url of acr login server"
  type = string
}
variable "acr_admin_password" {
  description = "password of admin for ACR"
  type = string
}
variable "acr_admin_username" {
  description = "username of admin for ACR"
  type = string
}
variable "container_target_port" {
  description = "Target port for ACR ingress"
  type = number
}
variable "min_replicas" {
  description = "Minimum number of running containers at one tim"
  type = number
  default = 1
}
variable "max_replicas" {
  description = "Maximum number of running containers at one time"
  type = number
  default = 10
}

variable "allow_insecure_connections" {
  description = "Whether or not allow insecure connections via Ingress"
  type = bool
  default = false
}
variable "volumes" {
  description = "Volumes for container app (includes all container volume mounts) its empty by default"
  type = list(
    object({
      volume_name = string,
      mount_path = string
      storage_type = string
    })
  )
  default = []
}
variable "create_volume" {
  description = "Describes whether or not create a volume for containers"
  type = bool
  default = false
}

variable "container_objects" {
    description = "List of container objects, refer to default value or values in containerapps.tf"
    type = list(object({
      name = string
      image = string
      cpu = number
      memory = string
      volume_name = optional(string)
      mount_path = optional(string)
      create_volume = optional(bool, false)
      command = list(string)
      env_vars = list(object({
        name = string,
        value = string
      }))
      env_vars_resource_dependant = optional(
        list(
          object({
            name = string,
            value = string
          })
        )
      )
    }))
}
variable "external_enabled" {
  type = bool
  description = "whether or not allow external connections from the internet"
  default = false
}
variable "ingress_http_version" {
  type = string
  description = "HTTPv1,2 or auto"
  default = "auto"
}


