resource "google_dataform_repository_workflow_config" "main" {
  count    = var.git_remote_settings == null ? 0 : 1
  provider = google-beta

  project        = data.google_project.current.project_id
  region         = var.region
  repository     = google_dataform_repository.main.name
  name           = var.workflow_config.name
  release_config = google_dataform_repository_release_config.main[0].id
  cron_schedule  = var.workflow_config.cron_schedule
  time_zone      = var.time_zone

  invocation_config {
    included_tags                            = var.workflow_config.included_tags
    transitive_dependencies_included         = true
    transitive_dependents_included           = false
    fully_refresh_incremental_tables_enabled = false
    service_account                          = var.service_account
  }
}
