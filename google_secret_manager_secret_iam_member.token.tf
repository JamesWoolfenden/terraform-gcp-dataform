resource "google_secret_manager_secret_iam_member" "token" {
  count = var.git_remote_settings == null ? 0 : 1

  secret_id = local.token_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = local.dataform_service_agent

  depends_on = [google_project_service_identity.dataform]
}
