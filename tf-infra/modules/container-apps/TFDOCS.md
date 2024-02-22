<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_admin_password"></a> [acr\_admin\_password](#input\_acr\_admin\_password) | password of admin for ACR | `string` | n/a | yes |
| <a name="input_acr_admin_username"></a> [acr\_admin\_username](#input\_acr\_admin\_username) | username of admin for ACR | `string` | n/a | yes |
| <a name="input_acr_login_server"></a> [acr\_login\_server](#input\_acr\_login\_server) | url of acr login server | `string` | n/a | yes |
| <a name="input_allow_insecure_connections"></a> [allow\_insecure\_connections](#input\_allow\_insecure\_connections) | Whether or not allow insecure connections via Ingress | `bool` | `false` | no |
| <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id) | Id of parent container apps environment | `string` | n/a | yes |
| <a name="input_container_app_name"></a> [container\_app\_name](#input\_container\_app\_name) | Name of contaier app | `string` | n/a | yes |
| <a name="input_container_objects"></a> [container\_objects](#input\_container\_objects) | List of container objects, refer to default value or values in containerapps.tf | <pre>list(object({<br>      name = string<br>      image = string<br>      cpu = number<br>      memory = string<br>      volume_name = optional(string)<br>      mount_path = optional(string)<br>      create_volume = optional(bool, false)<br>      command = list(string)<br>      env_vars = list(object({<br>        name = string,<br>        value = string<br>      }))<br>      env_vars_resource_dependant = optional(<br>        list(<br>          object({<br>            name = string,<br>            value = string<br>          })<br>        )<br>      )<br>    }))</pre> | n/a | yes |
| <a name="input_container_target_port"></a> [container\_target\_port](#input\_container\_target\_port) | Target port for ACR ingress | `number` | n/a | yes |
| <a name="input_create_volume"></a> [create\_volume](#input\_create\_volume) | Describes whether or not create a volume for containers | `bool` | `false` | no |
| <a name="input_external_enabled"></a> [external\_enabled](#input\_external\_enabled) | whether or not allow external connections from the internet | `bool` | `false` | no |
| <a name="input_infix"></a> [infix](#input\_infix) | infix passed from locals in root | `string` | n/a | yes |
| <a name="input_ingress_http_version"></a> [ingress\_http\_version](#input\_ingress\_http\_version) | HTTPv1,2 or auto | `string` | `"auto"` | no |
| <a name="input_location"></a> [location](#input\_location) | location | `string` | n/a | yes |
| <a name="input_max_replicas"></a> [max\_replicas](#input\_max\_replicas) | Maximum number of running containers at one time | `number` | `10` | no |
| <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas) | Minimum number of running containers at one tim | `number` | `1` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | name of parent resource group | `string` | n/a | yes |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Volumes for container app (includes all container volume mounts) its empty by default | <pre>list(<br>    object({<br>      volume_name = string,<br>      mount_path = string<br>      storage_type = string<br>    })<br>  )</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ingress_url"></a> [ingress\_url](#output\_ingress\_url) | n/a |
<!-- END_TF_DOCS -->