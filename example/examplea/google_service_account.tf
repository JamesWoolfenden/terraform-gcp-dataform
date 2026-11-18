resource "google_service_account" "dataform" {
  account_id   = "dataform-runner"
  display_name = "Dedicated SA for Dataform workflow invocations"
}
