# IBM Cloud Terraform Training - Topic 7.1: Managing Secrets and Credentials
# Terraform Code Lab 7.1 - Variable Definitions
#
# This file defines all input variables for the enterprise secrets management
# implementation with comprehensive validation and documentation.
#
# Author: IBM Cloud Terraform Training Team
# Version: 1.0.0
# Last Updated: 2024-09-15

# =============================================================================
# CORE PROJECT CONFIGURATION
# =============================================================================

variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "security-lab"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 20
    error_message = "Project name must be between 3 and 20 characters long."
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "team_email" {
  description = "Team email for notifications and resource ownership"
  type        = string
  default     = "security-team@company.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.team_email))
    error_message = "Team email must be a valid email address."
  }
}

# =============================================================================
# IBM CLOUD CONFIGURATION
# =============================================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition     = var.ibmcloud_api_key == null || length(var.ibmcloud_api_key) > 0
    error_message = "IBM Cloud API key cannot be empty if provided."
  }
}

variable "primary_region" {
  description = "Primary IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"

  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao"
    ], var.primary_region)
    error_message = "Primary region must be a valid IBM Cloud region."
  }
}

variable "secondary_region" {
  description = "Secondary IBM Cloud region for disaster recovery"
  type        = string
  default     = "us-east"

  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao"
    ], var.secondary_region)
    error_message = "Secondary region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "security-training"

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 40
    error_message = "Resource group name must be between 1 and 40 characters long."
  }
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

variable "key_rotation_interval_days" {
  description = "Interval in days for automatic key rotation"
  type        = number
  default     = 30

  validation {
    condition     = var.key_rotation_interval_days >= 7 && var.key_rotation_interval_days <= 365
    error_message = "Key rotation interval must be between 7 and 365 days."
  }
}

variable "secret_rotation_interval_days" {
  description = "Interval in days for automatic secret rotation"
  type        = number
  default     = 30

  validation {
    condition     = var.secret_rotation_interval_days >= 1 && var.secret_rotation_interval_days <= 90
    error_message = "Secret rotation interval must be between 1 and 90 days."
  }
}

variable "session_timeout_hours" {
  description = "Session timeout in hours for security policies"
  type        = number
  default     = 8

  validation {
    condition     = var.session_timeout_hours >= 1 && var.session_timeout_hours <= 24
    error_message = "Session timeout must be between 1 and 24 hours."
  }
}

variable "mfa_required" {
  description = "Whether multi-factor authentication is required"
  type        = bool
  default     = true
}

variable "dual_auth_required" {
  description = "Whether dual authorization is required for critical operations"
  type        = bool
  default     = false
}

# =============================================================================
# NETWORK SECURITY
# =============================================================================

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for access control"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Default allows all - restrict in production

  validation {
    condition = alltrue([
      for cidr in var.allowed_ip_ranges : can(cidrhost(cidr, 0))
    ])
    error_message = "All IP ranges must be valid CIDR blocks."
  }
}

variable "development_ip_ranges" {
  description = "Allowed IP ranges for development environment"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "production_ip_ranges" {
  description = "Allowed IP ranges for production environment (restricted)"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

# =============================================================================
# COMPLIANCE CONFIGURATION
# =============================================================================

variable "soc2_compliance_required" {
  description = "Whether SOC2 compliance is required"
  type        = bool
  default     = true
}

variable "iso27001_compliance_required" {
  description = "Whether ISO27001 compliance is required"
  type        = bool
  default     = true
}

variable "gdpr_compliance_required" {
  description = "Whether GDPR compliance is required"
  type        = bool
  default     = false
}

variable "hipaa_compliance_required" {
  description = "Whether HIPAA compliance is required"
  type        = bool
  default     = false
}

variable "audit_retention_days" {
  description = "Number of days to retain audit logs"
  type        = number
  default     = 90

  validation {
    condition     = var.audit_retention_days >= 30 && var.audit_retention_days <= 2555
    error_message = "Audit retention must be between 30 days and 7 years (2555 days)."
  }
}

# =============================================================================
# APPLICATION CONFIGURATION
# =============================================================================

variable "application_name" {
  description = "Name of the application using the secrets"
  type        = string
  default     = "demo-app"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.application_name))
    error_message = "Application name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "database_username" {
  description = "Database username for application credentials"
  type        = string
  default     = "app_user"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_username))
    error_message = "Database username must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "database_password" {
  description = "Database password for application credentials (will be auto-generated if not provided)"
  type        = string
  default     = null
  sensitive   = true
}

# =============================================================================
# MONITORING AND ALERTING
# =============================================================================

variable "enable_monitoring" {
  description = "Whether to enable security monitoring and alerting"
  type        = bool
  default     = true
}

variable "security_team_email" {
  description = "Email address for security team notifications"
  type        = string
  default     = "security-alerts@company.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.security_team_email))
    error_message = "Security team email must be a valid email address."
  }
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for security notifications"
  type        = string
  default     = ""
  sensitive   = true
}

variable "alert_threshold_failed_logins" {
  description = "Number of failed login attempts before triggering alert"
  type        = number
  default     = 5

  validation {
    condition     = var.alert_threshold_failed_logins >= 1 && var.alert_threshold_failed_logins <= 20
    error_message = "Failed login alert threshold must be between 1 and 20."
  }
}

# =============================================================================
# COST OPTIMIZATION
# =============================================================================

variable "enable_cost_optimization" {
  description = "Whether to enable cost optimization features"
  type        = bool
  default     = true
}

variable "auto_delete_unused_secrets" {
  description = "Whether to automatically delete unused secrets after retention period"
  type        = bool
  default     = false
}

variable "secret_retention_days" {
  description = "Number of days to retain unused secrets before deletion"
  type        = number
  default     = 90

  validation {
    condition     = var.secret_retention_days >= 30 && var.secret_retention_days <= 365
    error_message = "Secret retention must be between 30 and 365 days."
  }
}

# =============================================================================
# ADVANCED CONFIGURATION
# =============================================================================

variable "enable_cross_region_replication" {
  description = "Whether to enable cross-region replication for disaster recovery"
  type        = bool
  default     = false
}

variable "enable_automated_testing" {
  description = "Whether to enable automated security testing"
  type        = bool
  default     = true
}

variable "custom_policies" {
  description = "Custom security policies in JSON format"
  type        = map(string)
  default     = {}
}

variable "webhook_endpoints" {
  description = "Webhook endpoints for secret rotation notifications"
  type = object({
    pre_rotation_webhook  = optional(string, "")
    post_rotation_webhook = optional(string, "")
  })
  default = {
    pre_rotation_webhook  = ""
    post_rotation_webhook = ""
  }
}

# =============================================================================
# FEATURE FLAGS
# =============================================================================

variable "enable_key_protect" {
  description = "Whether to enable IBM Cloud Key Protect"
  type        = bool
  default     = true
}

variable "enable_secrets_manager" {
  description = "Whether to enable IBM Cloud Secrets Manager"
  type        = bool
  default     = true
}

variable "enable_activity_tracker" {
  description = "Whether to enable IBM Cloud Activity Tracker"
  type        = bool
  default     = true
}

variable "enable_iam_policies" {
  description = "Whether to create IAM access policies"
  type        = bool
  default     = true
}

variable "enable_incident_response" {
  description = "Whether to enable automated incident response"
  type        = bool
  default     = false
}
