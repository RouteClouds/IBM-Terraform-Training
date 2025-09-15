# =============================================================================
# CORE CONFIGURATION VARIABLES
# Subtopic 6.1: Local and Remote State Files
# =============================================================================

variable "ibm_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.ibm_api_key) > 0
    error_message = "IBM Cloud API key must be provided."
  }
}

variable "primary_region" {
  description = "Primary IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd"
    ], var.primary_region)
    error_message = "Primary region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "IBM Cloud resource group name"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "state-management-lab"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
  
  validation {
    condition = contains([
      "development", "staging", "production"
    ], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

# =============================================================================
# STATE MANAGEMENT CONFIGURATION
# =============================================================================

variable "enable_remote_state" {
  description = "Enable remote state backend configuration"
  type        = bool
  default     = false
}

variable "state_bucket_name" {
  description = "Name of the COS bucket for state storage"
  type        = string
  default     = ""
}

variable "enable_state_versioning" {
  description = "Enable versioning for state bucket"
  type        = bool
  default     = true
}

variable "enable_state_encryption" {
  description = "Enable encryption for state files"
  type        = bool
  default     = true
}

variable "state_backup_retention_days" {
  description = "Number of days to retain state backups"
  type        = number
  default     = 30
  
  validation {
    condition     = var.state_backup_retention_days >= 1 && var.state_backup_retention_days <= 365
    error_message = "Backup retention must be between 1 and 365 days."
  }
}

# =============================================================================
# INFRASTRUCTURE CONFIGURATION
# =============================================================================

variable "vpc_address_prefix" {
  description = "Address prefix for VPC CIDR block"
  type        = string
  default     = "10.240.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_address_prefix, 0))
    error_message = "VPC address prefix must be a valid CIDR block."
  }
}

variable "subnet_address_prefix" {
  description = "Address prefix for subnet CIDR block"
  type        = string
  default     = "10.240.1.0/24"
  
  validation {
    condition     = can(cidrhost(var.subnet_address_prefix, 0))
    error_message = "Subnet address prefix must be a valid CIDR block."
  }
}

variable "enable_public_gateway" {
  description = "Enable public gateway for internet access"
  type        = bool
  default     = true
}

variable "enable_floating_ip" {
  description = "Enable floating IP for VSI"
  type        = bool
  default     = false
}

# =============================================================================
# COMPUTE CONFIGURATION
# =============================================================================

variable "vsi_profile" {
  description = "VSI profile for compute instances"
  type        = string
  default     = "bx2-2x8"
  
  validation {
    condition = contains([
      "bx2-2x8", "bx2-4x16", "bx2-8x32", "cx2-2x4", "cx2-4x8"
    ], var.vsi_profile)
    error_message = "VSI profile must be a valid IBM Cloud profile."
  }
}

variable "vsi_image_name" {
  description = "VSI image name for compute instances"
  type        = string
  default     = "ibm-ubuntu-22-04-1-minimal-amd64-1"
}

variable "ssh_key_name" {
  description = "Name of existing SSH key for VSI access"
  type        = string
  default     = ""
}

variable "auto_delete_volume" {
  description = "Automatically delete boot volume when VSI is deleted"
  type        = bool
  default     = true
}

# =============================================================================
# MONITORING AND COMPLIANCE
# =============================================================================

variable "enable_activity_tracker" {
  description = "Enable Activity Tracker for audit logging"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable monitoring for infrastructure"
  type        = bool
  default     = true
}

variable "enable_key_protect" {
  description = "Enable Key Protect for encryption"
  type        = bool
  default     = false  # Set to false to avoid additional costs in lab
}

variable "activity_tracker_plan" {
  description = "Activity Tracker service plan"
  type        = string
  default     = "lite"
  
  validation {
    condition = contains([
      "lite", "7-day", "14-day", "30-day"
    ], var.activity_tracker_plan)
    error_message = "Activity Tracker plan must be lite, 7-day, 14-day, or 30-day."
  }
}

# =============================================================================
# PROVIDER CONFIGURATION
# =============================================================================

variable "provider_timeout" {
  description = "Timeout for IBM Cloud provider operations (seconds)"
  type        = number
  default     = 300
  
  validation {
    condition     = var.provider_timeout >= 60 && var.provider_timeout <= 1800
    error_message = "Provider timeout must be between 60 and 1800 seconds."
  }
}

variable "max_retries" {
  description = "Maximum number of retries for IBM Cloud provider"
  type        = number
  default     = 3
  
  validation {
    condition     = var.max_retries >= 1 && var.max_retries <= 10
    error_message = "Max retries must be between 1 and 10."
  }
}

# =============================================================================
# COST OPTIMIZATION
# =============================================================================

variable "enable_cost_tracking" {
  description = "Enable cost tracking and tagging"
  type        = bool
  default     = true
}

variable "cost_center" {
  description = "Cost center for billing allocation"
  type        = string
  default     = "training"
}

variable "budget_alert_threshold" {
  description = "Budget alert threshold in USD"
  type        = number
  default     = 50
  
  validation {
    condition     = var.budget_alert_threshold > 0
    error_message = "Budget alert threshold must be greater than 0."
  }
}

# =============================================================================
# TEAM COLLABORATION
# =============================================================================

variable "team_members" {
  description = "List of team member email addresses for access"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for email in var.team_members : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All team member entries must be valid email addresses."
  }
}

variable "enable_team_access" {
  description = "Enable team access controls for state management"
  type        = bool
  default     = false
}

variable "developer_role_permissions" {
  description = "Permissions for developer role (read-only by default)"
  type        = list(string)
  default     = ["Reader"]
  
  validation {
    condition = alltrue([
      for perm in var.developer_role_permissions : contains(["Reader", "Writer", "Manager"], perm)
    ])
    error_message = "Developer permissions must be Reader, Writer, or Manager."
  }
}

variable "operator_role_permissions" {
  description = "Permissions for operator role (read-write by default)"
  type        = list(string)
  default     = ["Writer"]
  
  validation {
    condition = alltrue([
      for perm in var.operator_role_permissions : contains(["Reader", "Writer", "Manager"], perm)
    ])
    error_message = "Operator permissions must be Reader, Writer, or Manager."
  }
}
