<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.25.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.example_bucket](https://registry.terraform.io/providers/hashicorp/aws/5.25.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_versioning.versioning_example-bucket](https://registry.terraform.io/providers/hashicorp/aws/5.25.0/docs/resources/s3_bucket_versioning) | resource |
| [aws_secretsmanager_secret.another_secret](https://registry.terraform.io/providers/hashicorp/aws/5.25.0/docs/data-sources/secretsmanager_secret) | data source |
| [aws_ssm_parameter.example_secret](https://registry.terraform.io/providers/hashicorp/aws/5.25.0/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_another_non_secret_variable"></a> [another\_non\_secret\_variable](#input\_another\_non\_secret\_variable) | Dummy non-secret variable | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | name of the environment | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | name of the project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Location of resource group | `string` | `"eu-central-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | this outputs bucket id |
<!-- END_TF_DOCS -->