# IAM grants return before they propagate; creating the CMEK repository (or
# connecting the Git remote) straight after them can fail on the first apply.
resource "time_sleep" "iam_propagation" {
  create_duration = "60s"

  depends_on = [
    google_kms_crypto_key_iam_member.dataform,
    google_secret_manager_secret_iam_member.token,
    google_service_account_iam_member.token_creator,
  ]
}
