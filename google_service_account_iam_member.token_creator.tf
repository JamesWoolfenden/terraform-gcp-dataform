resource "google_service_account_iam_member" "token_creator" {
  service_account_id = local.service_account_id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = local.dataform_service_agent

  depends_on = [google_project_service_identity.dataform]
}
