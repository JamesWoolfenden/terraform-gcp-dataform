variable "name" {
  type        = string
  description = "Name of the Dataform repository"

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "var.name must be a non-empty string"
  }
}

variable "region" {
  type        = string
  description = "Region for the Dataform repository"
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "var.region must be a non-empty string"
  }
}

variable "display_name" {
  type        = string
  description = "Human-readable display name of the repository. Null to use the name"
  default     = null

  validation {
    condition     = var.display_name == null || length(trimspace(var.display_name)) > 0
    error_message = "var.display_name must be null or a non-empty string"
  }
}

variable "kms_key_name" {
  type        = string
  description = "CMEK key used to encrypt the repository and its derived data; must be in the same region as the repository"

  validation {
    condition     = length(trimspace(var.kms_key_name)) > 0
    error_message = "var.kms_key_name must be a non-empty string"
  }

  validation {
    condition     = can(regex("/locations/${var.region}/", var.kms_key_name))
    error_message = "var.kms_key_name must be a KMS key in the same location as var.region — Dataform CMEK requires the key and the repository to be co-located"
  }
}

variable "service_account" {
  type        = string
  description = "Email of the custom service account Dataform runs workflow invocations as; must not be a default GCP service account"

  validation {
    condition     = length(trimspace(var.service_account)) > 0 && !can(regex("(-compute@developer|@appspot)\\.gserviceaccount\\.com$", var.service_account))
    error_message = "var.service_account must be a non-empty service account email and must not be a default GCP service account (Compute Engine or App Engine)"
  }

  validation {
    condition     = can(regex("^[^/]+@[^/]+\\.iam\\.gserviceaccount\\.com$", var.service_account))
    error_message = "var.service_account must be a service account email (name@project.iam.gserviceaccount.com), not a resource id"
  }
}

variable "git_remote_settings" {
  type = object({
    url                                 = string
    default_branch                      = string
    authentication_token_secret_version = string
  })
  description = "Optional third-party Git remote. The access token is held in Secret Manager and referenced by its secret version name. Null for a Dataform-hosted repository (and no release/workflow configs)"
  default     = null

  validation {
    condition     = var.git_remote_settings == null || can(regex("^https://", var.git_remote_settings.url))
    error_message = "var.git_remote_settings.url must be an https:// URL"
  }

  validation {
    condition     = var.git_remote_settings == null || length(trimspace(try(var.git_remote_settings.default_branch, ""))) > 0
    error_message = "var.git_remote_settings.default_branch must be a non-empty string"
  }

  validation {
    condition     = var.git_remote_settings == null || can(regex("^projects/[^/]+/secrets/[^/]+/versions/[^/]+$", var.git_remote_settings.authentication_token_secret_version))
    error_message = "var.git_remote_settings.authentication_token_secret_version must be a Secret Manager secret version name (projects/P/secrets/S/versions/V)"
  }
}

variable "workspace_schema_suffix" {
  type        = string
  description = "Schema suffix applied to development workspace compilations, keeping workspace output apart from production datasets"
  default     = "_dev"

  validation {
    condition     = length(trimspace(var.workspace_schema_suffix)) > 0
    error_message = "var.workspace_schema_suffix must be a non-empty string"
  }
}

variable "time_zone" {
  type        = string
  description = "IANA time zone used for the release and workflow cron schedules"
  default     = "Etc/UTC"

  validation {
    condition     = length(trimspace(var.time_zone)) > 0
    error_message = "var.time_zone must be a non-empty string"
  }
}

variable "release_config" {
  type = object({
    name             = optional(string, "production")
    git_commitish    = optional(string, "main")
    cron_schedule    = optional(string, "0 6 * * *")
    default_schema   = optional(string, "dataform")
    default_location = optional(string)
    assertion_schema = optional(string, "dataform_assertions")
  })
  description = "Release configuration, created only when git_remote_settings is set"
  default     = {}

  validation {
    condition     = length(trimspace(var.release_config.name)) > 0 && length(trimspace(var.release_config.git_commitish)) > 0
    error_message = "var.release_config.name and var.release_config.git_commitish must be non-empty strings"
  }

  validation {
    condition     = var.release_config.cron_schedule == null || length(split(" ", trimspace(var.release_config.cron_schedule))) == 5
    error_message = "var.release_config.cron_schedule must be null or a five-field cron expression"
  }
}

variable "workflow_config" {
  type = object({
    name          = optional(string, "production")
    cron_schedule = optional(string, "0 7 * * *")
    included_tags = optional(list(string), [])
  })
  description = "Workflow (scheduled invocation) configuration, created only when git_remote_settings is set. Runs as var.service_account"
  default     = {}

  validation {
    condition     = length(trimspace(var.workflow_config.name)) > 0
    error_message = "var.workflow_config.name must be a non-empty string"
  }

  validation {
    condition     = var.workflow_config.cron_schedule == null || length(split(" ", trimspace(var.workflow_config.cron_schedule))) == 5
    error_message = "var.workflow_config.cron_schedule must be null or a five-field cron expression"
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels applied to the repository for cost allocation and ownership tracking"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.labels : can(regex("^[a-z0-9_-]{1,63}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v))])
    error_message = "var.labels keys and values must be lowercase letters, numbers, underscores, or dashes (GCP label constraints)"
  }
}
