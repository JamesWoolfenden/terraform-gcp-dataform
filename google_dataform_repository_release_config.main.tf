resource "google_dataform_repository_release_config" "main" {
  count    = var.git_remote_settings == null ? 0 : 1
  provider = google-beta

  project       = data.google_project.current.project_id
  region        = var.region
  repository    = google_dataform_repository.main.name
  name          = var.release_config.name
  git_commitish = var.release_config.git_commitish
  cron_schedule = var.release_config.cron_schedule
  time_zone     = var.time_zone

  code_compilation_config {
    default_database = data.google_project.current.project_id
    default_schema   = var.release_config.default_schema
    default_location = var.release_config.default_location
    assertion_schema = var.release_config.assertion_schema
  }
}
