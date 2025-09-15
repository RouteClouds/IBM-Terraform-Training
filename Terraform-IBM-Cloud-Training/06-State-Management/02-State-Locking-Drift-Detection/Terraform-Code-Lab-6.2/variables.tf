# =============================================================================
# CORE CONFIGURATION VARIABLES
# Subtopic 6.2: State Locking and Drift Detection
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
  default     = "state-locking-lab"
  
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
# STATE LOCKING CONFIGURATION
# =============================================================================

variable "enable_state_locking" {
  description = "Enable state locking with Cloudant backend"
  type        = bool
  default     = false
}

variable "lock_table_name" {
  description = "Name of the lock table/database"
  type        = string
  default     = "terraform-locks"
}

variable "lock_timeout_minutes" {
  description = "Lock timeout in minutes"
  type        = number
  default     = 10
  
  validation {
    condition     = var.lock_timeout_minutes >= 1 && var.lock_timeout_minutes <= 60
    error_message = "Lock timeout must be between 1 and 60 minutes."
  }
}

variable "lock_retry_attempts" {
  description = "Number of lock retry attempts"
  type        = number
  default     = 3
  
  validation {
    condition     = var.lock_retry_attempts >= 1 && var.lock_retry_attempts <= 10
    error_message = "Lock retry attempts must be between 1 and 10."
  }
}

variable "lock_retry_delay_seconds" {
  description = "Delay between lock retry attempts in seconds"
  type        = number
  default     = 5
  
  validation {
    condition     = var.lock_retry_delay_seconds >= 1 && var.lock_retry_delay_seconds <= 30
    error_message = "Lock retry delay must be between 1 and 30 seconds."
  }
}

# =============================================================================
# DRIFT DETECTION CONFIGURATION
# =============================================================================

variable "enable_drift_detection" {
  description = "Enable automated drift detection"
  type        = bool
  default     = false
}

variable "drift_check_schedule" {
  description = "Cron schedule for drift detection (default: every 6 hours)"
  type        = string
  default     = "0 */6 * * *"
  
  validation {
    condition     = can(regex("^[0-9*,/-]+ [0-9*,/-]+ [0-9*,/-]+ [0-9*,/-]+ [0-9*,/-]+$", var.drift_check_schedule))
    error_message = "Drift check schedule must be a valid cron expression."
  }
}

variable "drift_alert_channels" {
  description = "List of alert channels for drift notifications"
  type        = list(string)
  default     = ["email"]
  
  validation {
    condition = alltrue([
      for channel in var.drift_alert_channels : contains(["email", "slack", "webhook", "sms"], channel)
    ])
    error_message = "Alert channels must be one of: email, slack, webhook, sms."
  }
}

variable "drift_severity_threshold" {
  description = "Severity threshold for drift alerts (1-10)"
  type        = number
  default     = 3
  
  validation {
    condition     = var.drift_severity_threshold >= 1 && var.drift_severity_threshold <= 10
    error_message = "Drift severity threshold must be between 1 and 10."
  }
}

variable "enable_auto_remediation" {
  description = "Enable automatic drift remediation for low-risk changes"
  type        = bool
  default     = false
}

variable "auto_remediation_threshold" {
  description = "Maximum severity score for automatic remediation"
  type        = number
  default     = 3
  
  validation {
    condition     = var.auto_remediation_threshold >= 1 && var.auto_remediation_threshold <= 5
    error_message = "Auto remediation threshold must be between 1 and 5."
  }
}

# =============================================================================
# NOTIFICATION CONFIGURATION
# =============================================================================

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
}

variable "email_recipients" {
  description = "List of email addresses for notifications"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for email in var.email_recipients : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All email recipients must be valid email addresses."
  }
}

variable "webhook_endpoints" {
  description = "List of webhook endpoints for notifications"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for url in var.webhook_endpoints : can(regex("^https?://", url))
    ])
    error_message = "All webhook endpoints must be valid HTTP/HTTPS URLs."
  }
}

# =============================================================================
# INFRASTRUCTURE CONFIGURATION
# =============================================================================

variable "vpc_address_prefix" {
  description = "Address prefix for VPC CIDR block"
  type        = string
  default     = "10.241.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_address_prefix, 0))
    error_message = "VPC address prefix must be a valid CIDR block."
  }
}

variable "subnet_address_prefix" {
  description = "Address prefix for subnet CIDR block"
  type        = string
  default     = "10.241.1.0/24"
  
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

# =============================================================================
# MONITORING AND COMPLIANCE
# =============================================================================

variable "enable_activity_tracker" {
  description = "Enable Activity Tracker for audit logging"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable monitoring for infrastructure and state management"
  type        = bool
  default     = true
}

variable "enable_key_protect" {
  description = "Enable Key Protect for encryption"
  type        = bool
  default     = false
}

variable "activity_tracker_plan" {
  description = "Activity Tracker service plan"
  type        = string
  default     = "7-day"
  
  validation {
    condition = contains([
      "lite", "7-day", "14-day", "30-day"
    ], var.activity_tracker_plan)
    error_message = "Activity Tracker plan must be lite, 7-day, 14-day, or 30-day."
  }
}

variable "monitoring_plan" {
  description = "Monitoring service plan"
  type        = string
  default     = "graduated-tier"
  
  validation {
    condition = contains([
      "lite", "graduated-tier"
    ], var.monitoring_plan)
    error_message = "Monitoring plan must be lite or graduated-tier."
  }
}

# =============================================================================
# CLOUDANT CONFIGURATION
# =============================================================================

variable "cloudant_plan" {
  description = "Cloudant service plan for state locking"
  type        = string
  default     = "lite"
  
  validation {
    condition = contains([
      "lite", "standard"
    ], var.cloudant_plan)
    error_message = "Cloudant plan must be lite or standard."
  }
}

variable "cloudant_capacity_throughput" {
  description = "Cloudant capacity throughput units (for standard plan)"
  type        = number
  default     = 1
  
  validation {
    condition     = var.cloudant_capacity_throughput >= 1 && var.cloudant_capacity_throughput <= 100
    error_message = "Cloudant capacity throughput must be between 1 and 100."
  }
}

# =============================================================================
# CLOUD FUNCTIONS CONFIGURATION
# =============================================================================

variable "enable_cloud_functions" {
  description = "Enable IBM Cloud Functions for automation"
  type        = bool
  default     = false
}

variable "functions_namespace" {
  description = "Cloud Functions namespace for drift detection"
  type        = string
  default     = "terraform-automation"
}

variable "function_memory_limit" {
  description = "Memory limit for Cloud Functions (MB)"
  type        = number
  default     = 256
  
  validation {
    condition     = contains([128, 256, 512, 1024, 2048], var.function_memory_limit)
    error_message = "Function memory limit must be 128, 256, 512, 1024, or 2048 MB."
  }
}

variable "function_timeout" {
  description = "Timeout for Cloud Functions (seconds)"
  type        = number
  default     = 300
  
  validation {
    condition     = var.function_timeout >= 1 && var.function_timeout <= 600
    error_message = "Function timeout must be between 1 and 600 seconds."
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
  default     = 100
  
  validation {
    condition     = var.budget_alert_threshold > 0
    error_message = "Budget alert threshold must be greater than 0."
  }
}

# =============================================================================
# TESTING AND VALIDATION
# =============================================================================

variable "enable_testing_mode" {
  description = "Enable testing mode with additional validation"
  type        = bool
  default     = false
}

variable "simulate_drift" {
  description = "Simulate drift for testing purposes"
  type        = bool
  default     = false
}

variable "test_conflict_scenarios" {
  description = "Enable conflict testing scenarios"
  type        = bool
  default     = false
}
