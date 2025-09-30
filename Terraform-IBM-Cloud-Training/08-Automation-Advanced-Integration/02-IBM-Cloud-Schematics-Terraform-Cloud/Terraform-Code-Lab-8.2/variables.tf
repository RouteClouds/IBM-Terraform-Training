# IBM Cloud Schematics & Terraform Cloud Integration - Variables Configuration
# Topic 8.2: Advanced Integration Lab Environment
# Version: 1.0.0

# =============================================================================
# AUTHENTICATION AND PROVIDER VARIABLES
# =============================================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.ibmcloud_api_key) > 0
    error_message = "IBM Cloud API key must be provided."
  }
}

variable "terraform_cloud_token" {
  description = "Terraform Cloud API token for workspace integration"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.terraform_cloud_token) > 0
    error_message = "Terraform Cloud API token must be provided."
  }
}

variable "terraform_cloud_hostname" {
  description = "Terraform Cloud hostname"
  type        = string
  default     = "app.terraform.io"
  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.terraform_cloud_hostname))
    error_message = "Terraform Cloud hostname must be a valid domain name."
  }
}

variable "terraform_cloud_organization" {
  description = "Terraform Cloud organization name"
  type        = string
  validation {
    condition     = length(var.terraform_cloud_organization) > 0
    error_message = "Terraform Cloud organization name must be provided."
  }
}

# =============================================================================
# IBM CLOUD CONFIGURATION VARIABLES
# =============================================================================

variable "ibm_region" {
  description = "IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd", "ca-tor"
    ], var.ibm_region)
    error_message = "IBM Cloud region must be a valid region."
  }
}

variable "resource_group_name" {
  description = "IBM Cloud resource group name"
  type        = string
  default     = "default"
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name must be provided."
  }
}

# =============================================================================
# PROJECT AND ENVIRONMENT VARIABLES
# =============================================================================

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "schematics-tf-cloud-lab"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition = contains([
      "dev", "development", "staging", "stage", "prod", "production", "test"
    ], var.environment)
    error_message = "Environment must be one of: dev, development, staging, stage, prod, production, test."
  }
}

variable "owner_email" {
  description = "Email address of the resource owner"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address."
  }
}

variable "cost_center" {
  description = "Cost center for billing and resource tracking"
  type        = string
  default     = "IT-Infrastructure"
  validation {
    condition     = length(var.cost_center) > 0
    error_message = "Cost center must be provided."
  }
}

variable "compliance_level" {
  description = "Compliance level for the resources (standard, high, critical)"
  type        = string
  default     = "standard"
  validation {
    condition = contains([
      "standard", "high", "critical"
    ], var.compliance_level)
    error_message = "Compliance level must be one of: standard, high, critical."
  }
}

# =============================================================================
# SCHEMATICS WORKSPACE CONFIGURATION
# =============================================================================

variable "workspace_description" {
  description = "Description for the Schematics workspace"
  type        = string
  default     = "IBM Cloud Schematics workspace with Terraform Cloud integration for enterprise automation"
}

variable "workspace_template_repo" {
  description = "Git repository URL for Terraform templates"
  type        = string
  default     = "https://github.com/IBM-Cloud/terraform-ibm-examples"
  validation {
    condition     = can(regex("^https://github\\.com/[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$", var.workspace_template_repo))
    error_message = "Template repository must be a valid GitHub repository URL."
  }
}

variable "workspace_template_branch" {
  description = "Git branch for Terraform templates"
  type        = string
  default     = "main"
  validation {
    condition     = length(var.workspace_template_branch) > 0
    error_message = "Template branch must be provided."
  }
}

variable "workspace_template_folder" {
  description = "Folder path within the repository containing Terraform templates"
  type        = string
  default     = "examples/vpc"
}

# =============================================================================
# ACCESS CONTROL AND SECURITY VARIABLES
# =============================================================================

variable "access_group_name" {
  description = "Name for the IAM access group"
  type        = string
  default     = "schematics-users"
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.access_group_name))
    error_message = "Access group name must contain only letters, numbers, dots, underscores, and hyphens."
  }
}

variable "team_members" {
  description = "List of team member email addresses for access group"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for email in var.team_members : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All team member entries must be valid email addresses."
  }
}

variable "workspace_access_level" {
  description = "Access level for workspace users (viewer, operator, manager)"
  type        = string
  default     = "operator"
  validation {
    condition = contains([
      "viewer", "operator", "manager"
    ], var.workspace_access_level)
    error_message = "Workspace access level must be one of: viewer, operator, manager."
  }
}

# =============================================================================
# COST AND PERFORMANCE VARIABLES
# =============================================================================

variable "budget_limit" {
  description = "Monthly budget limit in USD for cost tracking"
  type        = number
  default     = 500
  validation {
    condition     = var.budget_limit > 0 && var.budget_limit <= 10000
    error_message = "Budget limit must be between 1 and 10000 USD."
  }
}

variable "budget_alert_threshold" {
  description = "Budget alert threshold percentage (0-100)"
  type        = number
  default     = 80
  validation {
    condition     = var.budget_alert_threshold >= 0 && var.budget_alert_threshold <= 100
    error_message = "Budget alert threshold must be between 0 and 100."
  }
}

variable "auto_destroy_schedule" {
  description = "Cron schedule for automatic resource cleanup (empty to disable)"
  type        = string
  default     = ""
  validation {
    condition = var.auto_destroy_schedule == "" || can(regex("^[0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+$", var.auto_destroy_schedule))
    error_message = "Auto destroy schedule must be a valid cron expression or empty string."
  }
}

# =============================================================================
# INTEGRATION AND WORKFLOW VARIABLES
# =============================================================================

variable "enable_terraform_cloud_integration" {
  description = "Enable Terraform Cloud workspace integration"
  type        = bool
  default     = true
}

variable "enable_cost_tracking" {
  description = "Enable cost tracking and budget alerts"
  type        = bool
  default     = true
}

variable "enable_audit_logging" {
  description = "Enable comprehensive audit logging"
  type        = bool
  default     = true
}

variable "deployment_delay_hours" {
  description = "Delay in hours before deployment (for scheduling)"
  type        = number
  default     = 0
  validation {
    condition     = var.deployment_delay_hours >= 0 && var.deployment_delay_hours <= 168
    error_message = "Deployment delay must be between 0 and 168 hours (1 week)."
  }
}

# =============================================================================
# NOTIFICATION AND MONITORING VARIABLES
# =============================================================================

variable "notification_email" {
  description = "Email address for notifications and alerts"
  type        = string
  default     = ""
  validation {
    condition = var.notification_email == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Notification email must be a valid email address or empty string."
  }
}

variable "monitoring_enabled" {
  description = "Enable monitoring and alerting for workspace resources"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain audit logs"
  type        = number
  default     = 90
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 365
    error_message = "Log retention days must be between 30 and 365."
  }
}
