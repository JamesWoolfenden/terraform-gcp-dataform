output "id" {
  value       = google_dataform_repository.main.id
  description = "ID of the Dataform repository"
}

output "name" {
  value       = google_dataform_repository.main.name
  description = "Name of the Dataform repository"
}

output "release_config_id" {
  value       = try(google_dataform_repository_release_config.main[0].id, null)
  description = "ID of the release config, or null when no Git remote is configured"
}

output "workflow_config_id" {
  value       = try(google_dataform_repository_workflow_config.main[0].id, null)
  description = "ID of the workflow config, or null when no Git remote is configured"
}
