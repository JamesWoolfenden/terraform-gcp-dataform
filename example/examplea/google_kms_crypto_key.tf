resource "google_kms_crypto_key" "dataform" {
  name                       = "dataform-key"
  key_ring                   = google_kms_key_ring.dataform.id
  rotation_period            = "7776000s"
  destroy_scheduled_duration = "2592000s"

  lifecycle {
    prevent_destroy = true
  }
}
