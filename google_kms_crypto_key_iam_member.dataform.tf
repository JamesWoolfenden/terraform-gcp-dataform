resource "google_kms_crypto_key_iam_member" "dataform" {
  crypto_key_id = var.kms_key_name
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = local.dataform_service_agent

  depends_on = [google_project_service_identity.dataform]
}
