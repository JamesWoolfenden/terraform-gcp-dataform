resource "google_secret_manager_secret_version" "git_token" {
  secret      = google_secret_manager_secret.git_token.id
  secret_data = "placeholder-rotated-out-of-band"
}
