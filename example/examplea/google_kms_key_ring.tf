resource "google_kms_key_ring" "dataform" {
  name     = "dataform-keyring"
  location = local.region
}
