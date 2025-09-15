# Provider Configuration and Authentication - Variables
# Comprehensive variable definitions for provider configuration,
# authentication methods, and enterprise security patterns

# ============================================================================
# IBM CLOUD AUTHENTICATION VARIABLES
# ============================================================================

variable "ibm_api_key" {
  description = "IBM Cloud API key for authentication (use IC_API_KEY environment variable)"
  type        = string
  default     = ""
  sensitive   = true
  
  validation {
    condition     = var.ibm_api_key == "" || length(var.ibm_api_key) > 20
    error_message = "IBM Cloud API key must be at least 20 characters long when provided."
  }
}

variable "ibm_region" {
  description = "IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao", "eu-es", "eu-fr"
    ], var.ibm_region)
    error_message = "IBM region must be a valid IBM Cloud region."
  }
}

variable "resource_group_id" {
  description = "IBM Cloud resource group ID for resource organization"
  type        = string
  default     = null
  
  validation {
    condition     = var.resource_group_id == null || can(regex("^[a-f0-9]{32}$", var.resource_group_id))
    error_message = "Resource group ID must be a valid 32-character hexadecimal string."
  }
}

# ============================================================================
# MULTI-ENVIRONMENT AUTHENTICATION VARIABLES
# ============================================================================

variable "dev_api_key" {
  description = "Development environment IBM Cloud API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "dev_region" {
  description = "Development environment region"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao", "eu-es", "eu-fr"
    ], var.dev_region)
    error_message = "Development region must be a valid IBM Cloud region."
  }
}

variable "dev_resource_group_id" {
  description = "Development environment resource group ID"
  type        = string
  default     = null
}

variable "staging_api_key" {
  description = "Staging environment IBM Cloud API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "staging_region" {
  description = "Staging environment region"
  type        = string
  default     = "us-east"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao", "eu-es", "eu-fr"
    ], var.staging_region)
    error_message = "Staging region must be a valid IBM Cloud region."
  }
}

variable "staging_resource_group_id" {
  description = "Staging environment resource group ID"
  type        = string
  default     = null
}

variable "prod_api_key" {
  description = "Production environment IBM Cloud API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "prod_region" {
  description = "Production environment region"
  type        = string
  default     = "eu-gb"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao", "eu-es", "eu-fr"
    ], var.prod_region)
    error_message = "Production region must be a valid IBM Cloud region."
  }
}

variable "prod_resource_group_id" {
  description = "Production environment resource group ID"
  type        = string
  default     = null
}

# ============================================================================
# PROVIDER PERFORMANCE CONFIGURATION
# ============================================================================

variable "provider_timeout" {
  description = "Provider timeout in seconds for API operations"
  type        = number
  default     = 300
  
  validation {
    condition     = var.provider_timeout >= 60 && var.provider_timeout <= 3600
    error_message = "Provider timeout must be between 60 and 3600 seconds."
  }
}

variable "max_retries" {
  description = "Maximum number of retries for failed API requests"
  type        = number
  default     = 3
  
  validation {
    condition     = var.max_retries >= 1 && var.max_retries <= 10
    error_message = "Max retries must be between 1 and 10."
  }
}

variable "retry_delay" {
  description = "Delay between retries in seconds"
  type        = number
  default     = 5
  
  validation {
    condition     = var.retry_delay >= 1 && var.retry_delay <= 60
    error_message = "Retry delay must be between 1 and 60 seconds."
  }
}

# ============================================================================
# ENTERPRISE SECURITY CONFIGURATION
# ============================================================================

variable "endpoint_type" {
  description = "IBM Cloud endpoint type (public or private)"
  type        = string
  default     = "public"
  
  validation {
    condition     = contains(["public", "private"], var.endpoint_type)
    error_message = "Endpoint type must be either 'public' or 'private'."
  }
}

variable "visibility" {
  description = "Resource visibility (public or private)"
  type        = string
  default     = "public"
  
  validation {
    condition     = contains(["public", "private"], var.visibility)
    error_message = "Visibility must be either 'public' or 'private'."
  }
}

variable "enable_trace_logging" {
  description = "Enable trace logging for provider debugging"
  type        = bool
  default     = false
}

variable "security_level" {
  description = "Security level for provider configuration"
  type        = string
  default     = "standard"
  
  validation {
    condition     = contains(["basic", "standard", "high", "maximum"], var.security_level)
    error_message = "Security level must be one of: basic, standard, high, maximum."
  }
}

# ============================================================================
# PROJECT AND ENVIRONMENT CONFIGURATION
# ============================================================================

variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "lab3-provider-config"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name for resource tagging and configuration"
  type        = string
  default     = "lab"
  
  validation {
    condition = contains([
      "dev", "development", "test", "testing", "stage", "staging",
      "prod", "production", "lab", "demo", "sandbox"
    ], var.environment)
    error_message = "Environment must be a valid environment name."
  }
}

variable "owner" {
  description = "Owner email for resource tagging and accountability"
  type        = string
  default     = "lab-user@example.com"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner))
    error_message = "Owner must be a valid email address."
  }
}

# ============================================================================
# EXTERNAL INTEGRATION CONFIGURATION
# ============================================================================

variable "vault_address" {
  description = "HashiCorp Vault address for secret management"
  type        = string
  default     = ""
  
  validation {
    condition     = var.vault_address == "" || can(regex("^https?://", var.vault_address))
    error_message = "Vault address must be a valid HTTP/HTTPS URL when provided."
  }
}

variable "vault_token" {
  description = "HashiCorp Vault token for authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_vault_integration" {
  description = "Enable HashiCorp Vault integration for secret management"
  type        = bool
  default     = false
}

# ============================================================================
# ADVANCED PROVIDER FEATURES
# ============================================================================

variable "performance_mode" {
  description = "Provider performance mode configuration"
  type        = string
  default     = "balanced"
  
  validation {
    condition     = contains(["fast", "balanced", "conservative"], var.performance_mode)
    error_message = "Performance mode must be one of: fast, balanced, conservative."
  }
}

variable "feature_flags" {
  description = "Feature flags for experimental provider features"
  type = object({
    vpc_next_generation   = optional(bool, false)
    enhanced_security     = optional(bool, false)
    cost_optimization     = optional(bool, false)
    advanced_networking   = optional(bool, false)
    beta_features         = optional(bool, false)
  })
  default = {
    vpc_next_generation = false
    enhanced_security   = false
    cost_optimization   = false
    advanced_networking = false
    beta_features       = false
  }
}

variable "enable_vpc_next_gen" {
  description = "Enable VPC next generation features"
  type        = bool
  default     = false
}

variable "enable_enhanced_security" {
  description = "Enable enhanced security features"
  type        = bool
  default     = false
}

variable "enable_cost_optimization" {
  description = "Enable cost optimization features"
  type        = bool
  default     = false
}

# ============================================================================
# TESTING AND VALIDATION CONFIGURATION
# ============================================================================

variable "test_mode" {
  description = "Enable test mode for provider configuration validation"
  type        = bool
  default     = false
}

variable "validation_enabled" {
  description = "Enable comprehensive validation of provider configurations"
  type        = bool
  default     = true
}

variable "monitoring_enabled" {
  description = "Enable monitoring and metrics collection"
  type        = bool
  default     = true
}

variable "debug_mode" {
  description = "Enable debug mode for detailed logging and troubleshooting"
  type        = bool
  default     = false
}

# ============================================================================
# RESOURCE NAMING AND TAGGING
# ============================================================================

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "lab3"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_prefix))
    error_message = "Resource prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    "Lab"         = "3.3"
    "Topic"       = "Provider-Configuration"
    "Course"      = "IBM-Cloud-Terraform"
    "Environment" = "lab"
  }

  validation {
    condition     = length(var.common_tags) <= 50
    error_message = "Common tags map cannot exceed 50 entries."
  }
}

variable "cost_center" {
  description = "Cost center for billing and resource tracking"
  type        = string
  default     = "training"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.cost_center))
    error_message = "Cost center must contain only alphanumeric characters, hyphens, and underscores."
  }
}

# ============================================================================
# PROVIDER CONFIGURATION TESTING
# ============================================================================

variable "provider_test_resources" {
  description = "Number of test resources to create for provider validation"
  type        = number
  default     = 5

  validation {
    condition     = var.provider_test_resources >= 1 && var.provider_test_resources <= 20
    error_message = "Provider test resources must be between 1 and 20."
  }
}
