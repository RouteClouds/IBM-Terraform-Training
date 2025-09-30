# Variables for Topic 8.3: Troubleshooting & Lifecycle Management
# Comprehensive variable definitions for advanced troubleshooting lab environment

# ============================================================================
# AUTHENTICATION AND ACCESS
# ============================================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.ibmcloud_api_key) > 20
    error_message = "IBM Cloud API key must be provided and valid."
  }
}

# ============================================================================
# IBM CLOUD CONFIGURATION
# ============================================================================

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
    error_message = "Resource group name cannot be empty."
  }
}

variable "private_endpoints_enabled" {
  description = "Enable private endpoints for IBM Cloud services"
  type        = bool
  default     = true
}

variable "vpc_endpoints_enabled" {
  description = "Enable VPC endpoints for enhanced security"
  type        = bool
  default     = true
}

# ============================================================================
# PROJECT AND ENVIRONMENT CONFIGURATION
# ============================================================================

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "troubleshooting-lab"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "lab"
  
  validation {
    condition = contains([
      "dev", "development", "staging", "stage", "prod", "production", "lab", "test"
    ], var.environment)
    error_message = "Environment must be one of: dev, development, staging, stage, prod, production, lab, test."
  }
}

variable "owner_email" {
  description = "Email address of the resource owner"
  type        = string
  default     = "admin@example.com"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address."
  }
}

variable "cost_center" {
  description = "Cost center for billing and chargeback"
  type        = string
  default     = "training"
}

# ============================================================================
# TROUBLESHOOTING AND DEBUGGING CONFIGURATION
# ============================================================================

variable "debug_enabled" {
  description = "Enable comprehensive debugging and logging"
  type        = bool
  default     = true
}

variable "monitoring_enabled" {
  description = "Enable performance monitoring and alerting"
  type        = bool
  default     = true
}

variable "self_healing_enabled" {
  description = "Enable self-healing infrastructure capabilities"
  type        = bool
  default     = true
}

variable "performance_optimization_enabled" {
  description = "Enable performance optimization features"
  type        = bool
  default     = true
}

variable "operational_excellence_enabled" {
  description = "Enable operational excellence and SRE practices"
  type        = bool
  default     = true
}

# ============================================================================
# PERFORMANCE OPTIMIZATION SETTINGS
# ============================================================================

variable "parallel_operations" {
  description = "Number of parallel operations for performance optimization"
  type        = number
  default     = 10
  
  validation {
    condition     = var.parallel_operations >= 1 && var.parallel_operations <= 50
    error_message = "Parallel operations must be between 1 and 50."
  }
}

variable "cache_enabled" {
  description = "Enable caching for improved performance"
  type        = bool
  default     = true
}

variable "batch_size" {
  description = "Batch size for bulk operations"
  type        = number
  default     = 5
  
  validation {
    condition     = var.batch_size >= 1 && var.batch_size <= 20
    error_message = "Batch size must be between 1 and 20."
  }
}

variable "timeout_multiplier" {
  description = "Timeout multiplier for extended operations"
  type        = number
  default     = 1.5
  
  validation {
    condition     = var.timeout_multiplier >= 1.0 && var.timeout_multiplier <= 5.0
    error_message = "Timeout multiplier must be between 1.0 and 5.0."
  }
}

# ============================================================================
# MONITORING AND ALERTING CONFIGURATION
# ============================================================================

variable "metrics_retention_days" {
  description = "Number of days to retain metrics data"
  type        = number
  default     = 30
  
  validation {
    condition     = var.metrics_retention_days >= 7 && var.metrics_retention_days <= 365
    error_message = "Metrics retention must be between 7 and 365 days."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain log data"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_retention_days >= 7 && var.log_retention_days <= 365
    error_message = "Log retention must be between 7 and 365 days."
  }
}

variable "alert_threshold_cpu" {
  description = "CPU utilization threshold for alerts (percentage)"
  type        = number
  default     = 80
  
  validation {
    condition     = var.alert_threshold_cpu >= 50 && var.alert_threshold_cpu <= 95
    error_message = "CPU alert threshold must be between 50 and 95 percent."
  }
}

variable "alert_threshold_memory" {
  description = "Memory utilization threshold for alerts (percentage)"
  type        = number
  default     = 85
  
  validation {
    condition     = var.alert_threshold_memory >= 50 && var.alert_threshold_memory <= 95
    error_message = "Memory alert threshold must be between 50 and 95 percent."
  }
}

variable "notification_channels" {
  description = "List of notification channels for alerts"
  type        = list(string)
  default     = ["email", "slack"]
  
  validation {
    condition = alltrue([
      for channel in var.notification_channels : contains(["email", "slack", "pagerduty", "webhook"], channel)
    ])
    error_message = "Notification channels must be one of: email, slack, pagerduty, webhook."
  }
}

# ============================================================================
# SELF-HEALING CONFIGURATION
# ============================================================================

variable "health_check_interval" {
  description = "Health check interval in minutes"
  type        = number
  default     = 5
  
  validation {
    condition     = var.health_check_interval >= 1 && var.health_check_interval <= 60
    error_message = "Health check interval must be between 1 and 60 minutes."
  }
}

variable "remediation_timeout" {
  description = "Remediation timeout in minutes"
  type        = number
  default     = 15
  
  validation {
    condition     = var.remediation_timeout >= 5 && var.remediation_timeout <= 120
    error_message = "Remediation timeout must be between 5 and 120 minutes."
  }
}

variable "escalation_threshold" {
  description = "Number of failed remediation attempts before escalation"
  type        = number
  default     = 3
  
  validation {
    condition     = var.escalation_threshold >= 1 && var.escalation_threshold <= 10
    error_message = "Escalation threshold must be between 1 and 10 attempts."
  }
}

variable "auto_recovery_enabled" {
  description = "Enable automatic recovery for common issues"
  type        = bool
  default     = true
}

# ============================================================================
# OPERATIONAL EXCELLENCE AND SRE SETTINGS
# ============================================================================

variable "slo_availability_target" {
  description = "Service Level Objective for availability (percentage)"
  type        = number
  default     = 99.9
  
  validation {
    condition     = var.slo_availability_target >= 95.0 && var.slo_availability_target <= 99.99
    error_message = "SLO availability target must be between 95.0 and 99.99 percent."
  }
}

variable "slo_performance_target" {
  description = "Service Level Objective for performance (response time in ms)"
  type        = number
  default     = 500
  
  validation {
    condition     = var.slo_performance_target >= 100 && var.slo_performance_target <= 5000
    error_message = "SLO performance target must be between 100 and 5000 milliseconds."
  }
}

variable "error_budget_percentage" {
  description = "Error budget percentage for SLO management"
  type        = number
  default     = 0.1
  
  validation {
    condition     = var.error_budget_percentage >= 0.01 && var.error_budget_percentage <= 5.0
    error_message = "Error budget percentage must be between 0.01 and 5.0 percent."
  }
}

variable "incident_response_time" {
  description = "Target incident response time in minutes"
  type        = number
  default     = 15
  
  validation {
    condition     = var.incident_response_time >= 5 && var.incident_response_time <= 120
    error_message = "Incident response time must be between 5 and 120 minutes."
  }
}

# ============================================================================
# COST OPTIMIZATION AND BUDGETING
# ============================================================================

variable "budget_limit" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 500
  
  validation {
    condition     = var.budget_limit >= 50 && var.budget_limit <= 10000
    error_message = "Budget limit must be between $50 and $10,000."
  }
}

variable "cost_optimization_enabled" {
  description = "Enable automated cost optimization"
  type        = bool
  default     = true
}

variable "resource_cleanup_enabled" {
  description = "Enable automatic resource cleanup for cost optimization"
  type        = bool
  default     = false
}

# ============================================================================
# ADVANCED CONFIGURATION
# ============================================================================

variable "custom_metrics" {
  description = "Custom metrics configuration for specialized monitoring"
  type = map(object({
    name        = string
    description = string
    unit        = string
    threshold   = number
  }))
  default = {
    terraform_apply_duration = {
      name        = "terraform_apply_duration"
      description = "Terraform apply operation duration"
      unit        = "seconds"
      threshold   = 1800
    }
    infrastructure_drift = {
      name        = "infrastructure_drift"
      description = "Number of resources with configuration drift"
      unit        = "count"
      threshold   = 5
    }
  }
}

variable "integration_endpoints" {
  description = "External integration endpoints for notifications and webhooks"
  type = map(object({
    url     = string
    method  = string
    headers = map(string)
  }))
  default = {}
  sensitive = true
}

variable "feature_flags" {
  description = "Feature flags for experimental and beta features"
  type = map(bool)
  default = {
    experimental_monitoring = false
    beta_self_healing      = false
    advanced_analytics     = false
    ml_predictions         = false
  }
}
