# holden:ignore:HLD_GCP_123 — the Git access token is rotated out-of-band by
# the Git provider; a Pub/Sub-notified rotation_period here would only track
# Terraform's own re-apply cadence, not the actual token rotation.
resource "google_secret_manager_secret" "git_token" {
  secret_id = "dataform-git-token"

  replication {
    auto {}
  }
}
