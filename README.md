# terraform-gcp-dataform

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-dataform/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-dataform/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-dataform.svg)](https://github.com/JamesWoolfenden/terraform-gcp-dataform/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-dataform.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-dataform/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Dataform. Creates a CMEK-encrypted Dataform repository that runs as a dedicated (non-default) service account, optionally connected to a third-party Git remote whose access token is held in Secret Manager. When a Git remote is supplied it also creates a release config and a scheduled workflow config. The Dataform service agent (`service-PROJECT_NUMBER@gcp-sa-dataform.iam.gserviceaccount.com`) is granted exactly what it needs: `roles/cloudkms.cryptoKeyEncrypterDecrypter` on the key, `roles/secretmanager.secretAccessor` on the token secret, and `roles/iam.serviceAccountTokenCreator` on the custom service account.

## Usage

Add **module.dataform.tf** to your code:-

```terraform
module "dataform" {
  source          = "jameswoolfenden/dataform/gcp"
  name            = "example-dataform"
  region          = "europe-west2"
  kms_key_name    = google_kms_crypto_key.dataform.id
  service_account = google_service_account.dataform.email

  git_remote_settings = {
    url                                 = "https://github.com/example-org/dataform-pipelines.git"
    default_branch                      = "main"
    authentication_token_secret_version = google_secret_manager_secret_version.git_token.name
  }
}
```

See [example/examplea](example/examplea) for a complete working example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google-beta_google_dataform_repository.main](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository) | resource |
| [google-beta_google_dataform_repository_release_config.main](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository_release_config) | resource |
| [google-beta_google_dataform_repository_workflow_config.main](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_dataform_repository_workflow_config) | resource |
| [google_kms_crypto_key_iam_member.dataform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_secret_manager_secret_iam_member.token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account_iam_member.token_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_project.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Human-readable display name of the repository. Null to use the name | `string` | `null` | no |
| <a name="input_git_remote_settings"></a> [git\_remote\_settings](#input\_git\_remote\_settings) | Optional third-party Git remote. The access token is held in Secret Manager and referenced by its secret version name. Null for a Dataform-hosted repository (and no release/workflow configs) | <pre>object({<br/>    url                                 = string<br/>    default\_branch                      = string<br/>    authentication\_token\_secret\_version = string<br/>  })</pre> | `null` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | CMEK key used to encrypt the repository and its derived data; must be in the same region as the repository | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the repository for cost allocation and ownership tracking | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Dataform repository | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for the Dataform repository | `string` | `"europe-west2"` | no |
| <a name="input_release_config"></a> [release\_config](#input\_release\_config) | Release configuration, created only when git\_remote\_settings is set | <pre>object({<br/>    name             = optional(string, "production")<br/>    git\_commitish    = optional(string, "main")<br/>    cron\_schedule    = optional(string, "0 6 * * *")<br/>    default\_schema   = optional(string, "dataform")<br/>    default\_location = optional(string)<br/>    assertion\_schema = optional(string, "dataform\_assertions")<br/>  })</pre> | `{}` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Email of the custom service account Dataform runs workflow invocations as; must not be a default GCP service account | `string` | n/a | yes |
| <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone) | IANA time zone used for the release and workflow cron schedules | `string` | `"Etc/UTC"` | no |
| <a name="input_workflow_config"></a> [workflow\_config](#input\_workflow\_config) | Workflow (scheduled invocation) configuration, created only when git\_remote\_settings is set. Runs as var.service\_account | <pre>object({<br/>    name          = optional(string, "production")<br/>    cron\_schedule = optional(string, "0 7 * * *")<br/>    included\_tags = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_workspace_schema_suffix"></a> [workspace\_schema\_suffix](#input\_workspace\_schema\_suffix) | Schema suffix applied to development workspace compilations, keeping workspace output apart from production datasets | `string` | `"_dev"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | ID of the Dataform repository |
| <a name="output_name"></a> [name](#output\_name) | Name of the Dataform repository |
| <a name="output_release_config_id"></a> [release\_config\_id](#output\_release\_config\_id) | ID of the release config, or null when no Git remote is configured |
| <a name="output_workflow_config_id"></a> [workflow\_config\_id](#output\_workflow\_config\_id) | ID of the workflow config, or null when no Git remote is configured |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.setIamPolicy",
    "dataform.releaseConfigs.create",
    "dataform.releaseConfigs.delete",
    "dataform.releaseConfigs.get",
    "dataform.releaseConfigs.update",
    "dataform.repositories.create",
    "dataform.repositories.delete",
    "dataform.repositories.get",
    "dataform.workflowConfigs.create",
    "dataform.workflowConfigs.delete",
    "dataform.workflowConfigs.get",
    "dataform.workflowConfigs.update",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "resourcemanager.projects.get",
    "secretmanager.secrets.getIamPolicy",
    "secretmanager.secrets.setIamPolicy"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeys.getIamPolicy",
    "dataform.releaseConfigs.get",
    "dataform.repositories.get",
    "dataform.workflowConfigs.get",
    "iam.serviceAccounts.getIamPolicy",
    "resourcemanager.projects.get",
    "secretmanager.secrets.getIamPolicy"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-dataform/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-dataform/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
