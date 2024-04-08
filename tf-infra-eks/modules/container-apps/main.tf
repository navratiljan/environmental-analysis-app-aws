resource "azurerm_container_app" "main" {
  name                         = var.container_app_name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name 
  revision_mode                = "Single"
    secret {
        name  = "password"
        value = var.acr_admin_password
    }

    registry {
        server               =  var.acr_login_server
        username             = var.acr_admin_username 
        password_secret_name = "password"
    }
    identity {
      type = "SystemAssigned"
    }
    ingress {
      target_port = var.container_target_port
      transport = var.ingress_http_version
      allow_insecure_connections = var.allow_insecure_connections
      traffic_weight {
        percentage = 100
        latest_revision = true
      }
      external_enabled = var.external_enabled
    }

    

  # Since we can have multiple containers in a container app, we need to loop through them
  # To understand below looping concepts applied refer to this 
  # https://stackoverflow.com/questions/58594506/how-to-for-each-through-a-listobjects-in-terraform-0-12

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    dynamic "volume" {
        #Creates the dynamic block only if condition is true
        for_each = {
            for volume in var.volumes :
            volume.volume_name => volume
        }
        content {
          name = volume.value.volume_name
          storage_type = volume.value.storage_type
        }
    }
    
    
    dynamic "container" {
        for_each = {
            for container in var.container_objects :
            container.name => container
        }
        content {
            name = container.value.name
            image  = container.value.image
            cpu    = container.value.cpu
            memory = container.value.memory
            command = container.value.command

            dynamic "volume_mounts" {
              for_each = {
                  for volume in var.volumes :
                  volume.volume_name => volume
              }
              content {
                path = volume_mounts.value.mount_path
                name = volume_mounts.value.volume_name
              }
            }
            
            dynamic "env" {
                for_each = {
                    for env in container.value.env_vars :
                    env.name => env
                }
                content {
                    name = env.value.name
                    value = env.value.value
                }
            }
        }
            }
        }
    }
