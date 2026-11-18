resource "google_dataform_repository" "main" {
  provider        = google-beta
  name            = var.name
  region          = var.region
  display_name    = var.display_name
  kms_key_name    = var.kms_key_name
  service_account = var.service_account
  labels          = var.labels

  dynamic "git_remote_settings" {
    for_each = var.git_remote_settings == null ? [] : [var.git_remote_settings]
    content {
      url                                 = git_remote_settings.value.url
      default_branch                      = git_remote_settings.value.default_branch
      authentication_token_secret_version = git_remote_settings.value.authentication_token_secret_version
    }
  }

  workspace_compilation_overrides {
    default_database = data.google_project.current.project_id
    schema_suffix    = var.workspace_schema_suffix
  }

  depends_on = [
    google_kms_crypto_key_iam_member.dataform,
    google_secret_manager_secret_iam_member.token,
    google_service_account_iam_member.token_creator,
  ]
}
