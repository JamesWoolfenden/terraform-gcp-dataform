locals {
  # The Dataform Service Agent — the identity Dataform uses internally to
  # encrypt repository data with the CMEK key, read the Git token from
  # Secret Manager, and mint tokens for the custom service account.
  # Every grant to it depends on google_project_service_identity.dataform so the
  # agent exists first (it is otherwise created lazily).
  dataform_service_agent = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-dataform.iam.gserviceaccount.com"

  # authentication_token_secret_version is a secret *version* name
  # ("projects/P/secrets/S/versions/V"); IAM is granted on the secret itself.
  token_secret_id = var.git_remote_settings == null ? null : split("/versions/", var.git_remote_settings.authentication_token_secret_version)[0]

  # The service account may live in another project: take the project from the
  # email (name@PROJECT.iam.gserviceaccount.com) rather than assuming the
  # provider's project.
  service_account_project = regex("@([^@]+)\\.iam\\.gserviceaccount\\.com$", var.service_account)[0]
  service_account_id      = "projects/${local.service_account_project}/serviceAccounts/${var.service_account}"
}
