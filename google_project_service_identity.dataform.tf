# The Dataform service agent is created lazily, typically by the first
# repository. A CMEK repository needs the agent granted on the key *before* it
# is created, so on a fresh project the grants below would fail with
# "service account does not exist". Generating the identity up front fixes the
# ordering.
resource "google_project_service_identity" "dataform" {
  provider = google-beta
  project  = data.google_project.current.project_id
  service  = "dataform.googleapis.com"
}
