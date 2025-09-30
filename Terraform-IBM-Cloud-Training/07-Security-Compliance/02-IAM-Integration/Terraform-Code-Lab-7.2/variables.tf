# IBM Cloud IAM Integration - Terraform Variables
# Topic 7.2: Identity and Access Management (IAM) Integration
# Lab 7.2: Enterprise Identity and Access Management Implementation

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

variable "project_name" {
  description = "Name prefix for all resources in this project"
  type        = string
  default     = "iam-integration-lab72"

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
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"

  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao"
    ], var.region)
    error_message = "Region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "default"
}

# =============================================================================
# IDENTITY PROVIDER CONFIGURATION
# =============================================================================

variable "enable_saml_federation" {
  description = "Enable SAML federation with enterprise directory"
  type        = bool
  default     = true
}

variable "saml_entity_id" {
  description = "SAML entity ID for enterprise directory"
  type        = string
  default     = "https://enterprise.company.com/saml"
}

variable "saml_sign_in_url" {
  description = "SAML sign-in URL for enterprise directory"
  type        = string
  default     = "https://enterprise.company.com/saml/sso"
}

variable "saml_certificate" {
  description = "SAML certificate for enterprise directory (base64 encoded)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_oidc_federation" {
  description = "Enable OIDC federation with cloud-native providers"
  type        = bool
  default     = true
}

variable "oidc_issuer" {
  description = "OIDC issuer URL"
  type        = string
  default     = "https://auth.company.com"
}

variable "oidc_client_id" {
  description = "OIDC client ID"
  type        = string
  default     = "enterprise-app-client"
}

variable "oidc_client_secret" {
  description = "OIDC client secret"
  type        = string
  default     = ""
  sensitive   = true
}

# =============================================================================
# MULTI-FACTOR AUTHENTICATION CONFIGURATION
# =============================================================================

variable "enforce_mfa" {
  description = "Enforce multi-factor authentication for all users"
  type        = bool
  default     = true
}

variable "mfa_type" {
  description = "Type of MFA to enforce (TOTP, SMS, EMAIL)"
  type        = string
  default     = "TOTP"

  validation {
    condition     = contains(["TOTP", "SMS", "EMAIL"], var.mfa_type)
    error_message = "MFA type must be one of: TOTP, SMS, EMAIL."
  }
}

variable "session_timeout_hours" {
  description = "Session timeout in hours"
  type        = number
  default     = 8

  validation {
    condition     = var.session_timeout_hours >= 1 && var.session_timeout_hours <= 24
    error_message = "Session timeout must be between 1 and 24 hours."
  }
}

variable "session_inactivity_timeout_minutes" {
  description = "Session inactivity timeout in minutes"
  type        = number
  default     = 30

  validation {
    condition     = var.session_inactivity_timeout_minutes >= 5 && var.session_inactivity_timeout_minutes <= 120
    error_message = "Session inactivity timeout must be between 5 and 120 minutes."
  }
}

# =============================================================================
# ACCESS CONTROL CONFIGURATION
# =============================================================================

variable "corporate_ip_ranges" {
  description = "List of corporate IP ranges for access control"
  type        = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

variable "max_login_attempts" {
  description = "Maximum login attempts before account lockout"
  type        = number
  default     = 3

  validation {
    condition     = var.max_login_attempts >= 3 && var.max_login_attempts <= 10
    error_message = "Max login attempts must be between 3 and 10."
  }
}

variable "enable_conditional_access" {
  description = "Enable conditional access policies"
  type        = bool
  default     = true
}

variable "risk_score_threshold" {
  description = "Risk score threshold for conditional access (0-100)"
  type        = number
  default     = 75

  validation {
    condition     = var.risk_score_threshold >= 0 && var.risk_score_threshold <= 100
    error_message = "Risk score threshold must be between 0 and 100."
  }
}

# =============================================================================
# ENTERPRISE USER CONFIGURATION
# =============================================================================

variable "enterprise_users" {
  description = "Map of enterprise users for testing and demonstration"
  type = map(object({
    email         = string
    first_name    = string
    last_name     = string
    employee_id   = string
    department    = string
    cost_center   = string
    manager_email = string
    role          = string
    access_level  = string
  }))
  default = {
    john_doe = {
      email         = "john.doe@company.com"
      first_name    = "John"
      last_name     = "Doe"
      employee_id   = "EMP001"
      department    = "Engineering"
      cost_center   = "CC-ENG-001"
      manager_email = "jane.smith@company.com"
      role          = "Senior Engineer"
      access_level  = "standard"
    }
    jane_smith = {
      email         = "jane.smith@company.com"
      first_name    = "Jane"
      last_name     = "Smith"
      employee_id   = "EMP002"
      department    = "Engineering"
      cost_center   = "CC-ENG-001"
      manager_email = "bob.johnson@company.com"
      role          = "Engineering Manager"
      access_level  = "elevated"
    }
    alice_johnson = {
      email         = "alice.johnson@company.com"
      first_name    = "Alice"
      last_name     = "Johnson"
      employee_id   = "EMP003"
      department    = "Finance"
      cost_center   = "CC-FIN-001"
      manager_email = "bob.wilson@company.com"
      role          = "Financial Analyst"
      access_level  = "standard"
    }
    bob_wilson = {
      email         = "bob.wilson@company.com"
      first_name    = "Bob"
      last_name     = "Wilson"
      employee_id   = "EMP004"
      department    = "Finance"
      cost_center   = "CC-FIN-001"
      manager_email = "charlie.brown@company.com"
      role          = "Finance Manager"
      access_level  = "elevated"
    }
    charlie_brown = {
      email         = "charlie.brown@company.com"
      first_name    = "Charlie"
      last_name     = "Brown"
      employee_id   = "EMP005"
      department    = "Operations"
      cost_center   = "CC-OPS-001"
      manager_email = "diana.prince@company.com"
      role          = "Operations Engineer"
      access_level  = "standard"
    }
  }
}

# =============================================================================
# DEPARTMENT ACCESS MAPPINGS
# =============================================================================

variable "department_access_mappings" {
  description = "Access group mappings for different departments"
  type = map(object({
    access_groups        = list(string)
    default_permissions  = list(string)
    elevated_permissions = list(string)
    approval_required    = bool
  }))
  default = {
    Engineering = {
      access_groups = [
        "developers",
        "code-repository-access",
        "development-environment",
        "ci-cd-pipeline"
      ]
      default_permissions  = ["read", "write", "deploy"]
      elevated_permissions = ["admin", "debug", "production-deploy"]
      approval_required    = false
    }
    Finance = {
      access_groups = [
        "financial-systems",
        "reporting-tools",
        "audit-access",
        "compliance-tools"
      ]
      default_permissions  = ["read", "report"]
      elevated_permissions = ["write", "approve", "audit"]
      approval_required    = true
    }
    Operations = {
      access_groups = [
        "infrastructure-monitoring",
        "incident-response",
        "production-access",
        "backup-systems"
      ]
      default_permissions  = ["read", "monitor", "alert"]
      elevated_permissions = ["admin", "emergency", "maintenance"]
      approval_required    = true
    }
    Security = {
      access_groups = [
        "security-tools",
        "audit-logs",
        "compliance-systems",
        "incident-investigation"
      ]
      default_permissions  = ["read", "investigate", "monitor"]
      elevated_permissions = ["admin", "forensics", "emergency-response"]
      approval_required    = false
    }
  }
}

# =============================================================================
# PRIVILEGED ACCESS MANAGEMENT
# =============================================================================

variable "enable_jit_access" {
  description = "Enable just-in-time privileged access"
  type        = bool
  default     = true
}

variable "jit_max_duration_hours" {
  description = "Maximum duration for JIT access in hours"
  type        = number
  default     = 4

  validation {
    condition     = var.jit_max_duration_hours >= 1 && var.jit_max_duration_hours <= 8
    error_message = "JIT max duration must be between 1 and 8 hours."
  }
}

variable "privileged_access_approval_required" {
  description = "Require approval for privileged access requests"
  type        = bool
  default     = true
}

# =============================================================================
# COMPLIANCE AND GOVERNANCE
# =============================================================================

variable "compliance_frameworks" {
  description = "List of compliance frameworks to implement"
  type        = list(string)
  default     = ["SOC2", "ISO27001", "GDPR"]
}

variable "audit_log_retention_days" {
  description = "Audit log retention period in days"
  type        = number
  default     = 2555 # 7 years

  validation {
    condition     = var.audit_log_retention_days >= 365
    error_message = "Audit log retention must be at least 365 days."
  }
}

variable "enable_automated_compliance_reporting" {
  description = "Enable automated compliance reporting"
  type        = bool
  default     = true
}

# =============================================================================
# INTEGRATION CONFIGURATION
# =============================================================================

variable "siem_integration_enabled" {
  description = "Enable SIEM integration for security events"
  type        = bool
  default     = true
}

variable "siem_endpoint" {
  description = "SIEM endpoint URL for event forwarding"
  type        = string
  default     = "https://siem.company.com/api/events"
}

variable "hr_system_integration_enabled" {
  description = "Enable HR system integration for user lifecycle"
  type        = bool
  default     = true
}

variable "hr_webhook_token" {
  description = "Webhook token for HR system integration"
  type        = string
  default     = ""
  sensitive   = true
}

# =============================================================================
# NOTIFICATION CONFIGURATION
# =============================================================================

variable "notification_channels" {
  description = "List of notification channels for alerts"
  type        = list(string)
  default = [
    "email:security-team@company.com",
    "slack:security-alerts",
    "pagerduty:security-incidents"
  ]
}

variable "enable_real_time_alerts" {
  description = "Enable real-time security alerts"
  type        = bool
  default     = true
}

# =============================================================================
# TAGGING AND METADATA
# =============================================================================

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = list(string)
  default = [
    "project:iam-integration",
    "topic:7.2",
    "lab:enterprise-identity",
    "terraform:managed"
  ]
}

variable "additional_tags" {
  description = "Additional tags for specific resource customization"
  type        = map(string)
  default = {
    "cost-center" = "security"
    "owner"       = "security-team"
    "backup"      = "required"
    "monitoring"  = "enabled"
    "compliance"  = "required"
  }
}
