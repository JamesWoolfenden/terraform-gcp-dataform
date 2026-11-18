# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "dataform" {
  source          = "../../"
  name            = "example-dataform"
  region          = local.region
  kms_key_name    = google_kms_crypto_key.dataform.id
  service_account = google_service_account.dataform.email

  git_remote_settings = {
    url                                 = "https://github.com/example-org/dataform-pipelines.git"
    default_branch                      = "main"
    authentication_token_secret_version = google_secret_manager_secret_version.git_token.name
  }

  labels = {
    team = "data"
  }
}
