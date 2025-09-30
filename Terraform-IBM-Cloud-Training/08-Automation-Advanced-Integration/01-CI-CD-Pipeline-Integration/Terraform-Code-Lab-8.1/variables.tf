# Variable Definitions for IBM Cloud CI/CD Pipeline Integration Lab 8.1
# This file defines all input variables for implementing enterprise CI/CD automation

# IBM Cloud Authentication and Configuration
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication and resource management"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.ibmcloud_api_key) > 0
    error_message = "IBM Cloud API key must not be empty."
  }
}

variable "ibm_region" {
  description = "IBM Cloud region where CI/CD infrastructure will be deployed"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd", "jp-osa", "br-sao", "ca-tor"
    ], var.ibm_region)
    error_message = "IBM region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group for organizing CI/CD resources"
  type        = string
  default     = "default"
  
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name must not be empty."
  }
}

# Project and Environment Configuration
variable "project_name" {
  description = "Name of the project for resource naming and organization"
  type        = string
  default     = "cicd-automation"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name for resource organization and deployment targeting"
  type        = string
  default     = "dev"
  
  validation {
    condition = contains([
      "dev", "staging", "prod", "test", "lab", "demo"
    ], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test, lab, demo."
  }
}

variable "owner" {
  description = "Owner of the CI/CD resources for tracking and billing purposes"
  type        = string
  default     = "cicd-team"
  
  validation {
    condition     = length(var.owner) > 0
    error_message = "Owner must not be empty."
  }
}

# GitLab CI/CD Configuration
variable "gitlab_token" {
  description = "GitLab personal access token for CI/CD pipeline configuration"
  type        = string
  default     = ""
  sensitive   = true
}

variable "gitlab_base_url" {
  description = "GitLab base URL (use default for GitLab.com or specify for self-hosted)"
  type        = string
  default     = "https://gitlab.com/api/v4/"
  
  validation {
    condition     = can(regex("^https://", var.gitlab_base_url))
    error_message = "GitLab base URL must start with https://."
  }
}

variable "gitlab_project_id" {
  description = "GitLab project ID for CI/CD pipeline configuration (optional)"
  type        = string
  default     = ""
}

variable "gitlab_project_name" {
  description = "Name for new GitLab project if creating one"
  type        = string
  default     = "terraform-cicd-automation"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.gitlab_project_name))
    error_message = "GitLab project name must contain only lowercase letters, numbers, and hyphens."
  }
}

# GitHub Actions Configuration
variable "github_token" {
  description = "GitHub personal access token for GitHub Actions configuration"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_organization" {
  description = "GitHub organization or username for repository management"
  type        = string
  default     = ""
}

variable "github_repository_name" {
  description = "GitHub repository name for CI/CD pipeline (optional if exists)"
  type        = string
  default     = ""
}

variable "github_base_url" {
  description = "GitHub base URL (use default for GitHub.com or specify for GitHub Enterprise)"
  type        = string
  default     = "https://api.github.com/"
  
  validation {
    condition     = can(regex("^https://", var.github_base_url))
    error_message = "GitHub base URL must start with https://."
  }
}

# Terraform Cloud/Enterprise Configuration
variable "tfe_hostname" {
  description = "Terraform Cloud/Enterprise hostname"
  type        = string
  default     = "app.terraform.io"
}

variable "tfe_token" {
  description = "Terraform Cloud/Enterprise API token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tfe_organization" {
  description = "Terraform Cloud/Enterprise organization name"
  type        = string
  default     = ""
}

variable "tfe_workspace_name" {
  description = "Terraform Cloud workspace name for CI/CD integration"
  type        = string
  default     = ""
}

variable "tfe_ssl_skip_verify" {
  description = "Skip SSL verification for self-hosted Terraform Enterprise"
  type        = bool
  default     = false
}

# IBM Cloud Schematics Configuration
variable "schematics_workspace_name" {
  description = "Name for IBM Cloud Schematics workspace"
  type        = string
  default     = ""
}

variable "schematics_workspace_description" {
  description = "Description for IBM Cloud Schematics workspace"
  type        = string
  default     = "CI/CD Pipeline Automation Workspace"
}

variable "schematics_template_source_type" {
  description = "Source type for Schematics template (git_hub, git_lab, etc.)"
  type        = string
  default     = "git_hub"
  
  validation {
    condition = contains([
      "git_hub", "git_lab", "git_hub_enterprise", "git_lab_enterprise", "ibm_git_lab", "ibm_github"
    ], var.schematics_template_source_type)
    error_message = "Schematics template source type must be a valid option."
  }
}

variable "schematics_template_repo_url" {
  description = "Repository URL for Schematics template source"
  type        = string
  default     = ""
}

variable "schematics_template_repo_branch" {
  description = "Repository branch for Schematics template source"
  type        = string
  default     = "main"
}

# CI/CD Pipeline Configuration
variable "pipeline_trigger_events" {
  description = "List of events that should trigger the CI/CD pipeline"
  type        = list(string)
  default     = ["push", "merge_request", "tag"]
  
  validation {
    condition = alltrue([
      for event in var.pipeline_trigger_events : contains([
        "push", "merge_request", "tag", "schedule", "manual"
      ], event)
    ])
    error_message = "Pipeline trigger events must be valid GitLab CI events."
  }
}

variable "pipeline_environments" {
  description = "List of environments for multi-stage deployment pipeline"
  type        = list(string)
  default     = ["dev", "staging", "prod"]
  
  validation {
    condition     = length(var.pipeline_environments) > 0
    error_message = "At least one pipeline environment must be specified."
  }
}

variable "enable_security_scanning" {
  description = "Enable security scanning in CI/CD pipeline (TFSec, Checkov, etc.)"
  type        = bool
  default     = true
}

variable "enable_compliance_checks" {
  description = "Enable compliance policy checks in CI/CD pipeline"
  type        = bool
  default     = true
}

variable "enable_cost_estimation" {
  description = "Enable cost estimation in CI/CD pipeline"
  type        = bool
  default     = true
}

variable "enable_drift_detection" {
  description = "Enable infrastructure drift detection and remediation"
  type        = bool
  default     = true
}

# Notification Configuration
variable "notification_channels" {
  description = "Configuration for pipeline notification channels"
  type = object({
    slack_webhook_url    = optional(string, "")
    teams_webhook_url    = optional(string, "")
    email_recipients     = optional(list(string), [])
    enable_success_notifications = optional(bool, false)
    enable_failure_notifications = optional(bool, true)
  })
  default = {
    slack_webhook_url    = ""
    teams_webhook_url    = ""
    email_recipients     = []
    enable_success_notifications = false
    enable_failure_notifications = true
  }
}

# Security and Compliance Configuration
variable "security_scanning_tools" {
  description = "List of security scanning tools to integrate in pipeline"
  type        = list(string)
  default     = ["tfsec", "checkov", "terrascan"]
  
  validation {
    condition = alltrue([
      for tool in var.security_scanning_tools : contains([
        "tfsec", "checkov", "terrascan", "snyk", "bridgecrew"
      ], tool)
    ])
    error_message = "Security scanning tools must be from the supported list."
  }
}

variable "compliance_frameworks" {
  description = "List of compliance frameworks to validate against"
  type        = list(string)
  default     = ["cis", "nist", "pci"]
  
  validation {
    condition = alltrue([
      for framework in var.compliance_frameworks : contains([
        "cis", "nist", "pci", "sox", "hipaa", "gdpr"
      ], framework)
    ])
    error_message = "Compliance frameworks must be from the supported list."
  }
}

# Performance and Optimization Configuration
variable "pipeline_timeout_minutes" {
  description = "Maximum timeout for pipeline execution in minutes"
  type        = number
  default     = 60
  
  validation {
    condition     = var.pipeline_timeout_minutes > 0 && var.pipeline_timeout_minutes <= 480
    error_message = "Pipeline timeout must be between 1 and 480 minutes (8 hours)."
  }
}

variable "parallel_execution_limit" {
  description = "Maximum number of parallel pipeline executions"
  type        = number
  default     = 3
  
  validation {
    condition     = var.parallel_execution_limit > 0 && var.parallel_execution_limit <= 10
    error_message = "Parallel execution limit must be between 1 and 10."
  }
}

variable "cache_configuration" {
  description = "Configuration for pipeline caching to improve performance"
  type = object({
    enable_terraform_cache = optional(bool, true)
    enable_docker_cache    = optional(bool, true)
    enable_dependency_cache = optional(bool, true)
    cache_ttl_hours        = optional(number, 24)
  })
  default = {
    enable_terraform_cache = true
    enable_docker_cache    = true
    enable_dependency_cache = true
    cache_ttl_hours        = 24
  }
}

# Resource Tagging and Organization
variable "additional_tags" {
  description = "Additional tags to apply to all CI/CD resources"
  type        = map(string)
  default     = {}
}

variable "cost_center" {
  description = "Cost center for billing and resource allocation tracking"
  type        = string
  default     = "engineering"
}

variable "business_unit" {
  description = "Business unit responsible for the CI/CD infrastructure"
  type        = string
  default     = "platform-engineering"
}

# Monitoring and Observability Configuration
variable "enable_monitoring" {
  description = "Enable comprehensive monitoring for CI/CD pipeline and infrastructure"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable centralized logging for CI/CD pipeline activities"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CI/CD pipeline logs"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_retention_days >= 7 && var.log_retention_days <= 365
    error_message = "Log retention must be between 7 and 365 days."
  }
}

variable "monitoring_alert_thresholds" {
  description = "Thresholds for monitoring alerts"
  type = object({
    pipeline_failure_rate_percent = optional(number, 10)
    pipeline_duration_minutes     = optional(number, 45)
    resource_utilization_percent  = optional(number, 80)
    cost_variance_percent         = optional(number, 20)
  })
  default = {
    pipeline_failure_rate_percent = 10
    pipeline_duration_minutes     = 45
    resource_utilization_percent  = 80
    cost_variance_percent         = 20
  }
}
