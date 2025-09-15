# Variables for IBM Cloud Provider Configuration Lab 2.2
# This file defines all input variables for comprehensive provider configuration examples

# =============================================================================
# AUTHENTICATION VARIABLES
# =============================================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.ibmcloud_api_key) > 20
    error_message = "IBM Cloud API key must be valid (length > 20 characters)."
  }
}

variable "enterprise_api_key" {
  description = "Enterprise IBM Cloud API key for production environments"
  type        = string
  sensitive   = true
  default     = null
  
  validation {
    condition = var.enterprise_api_key == null || length(var.enterprise_api_key) > 20
    error_message = "Enterprise API key must be valid if provided."
  }
}

variable "dev_api_key" {
  description = "Development environment API key"
  type        = string
  sensitive   = true
  default     = null
}

variable "staging_api_key" {
  description = "Staging environment API key"
  type        = string
  sensitive   = true
  default     = null
}

variable "testing_api_key" {
  description = "Testing environment API key"
  type        = string
  sensitive   = true
  default     = null
}

variable "dr_api_key" {
  description = "Disaster recovery environment API key"
  type        = string
  sensitive   = true
  default     = null
}

# =============================================================================
# REGIONAL CONFIGURATION VARIABLES
# =============================================================================

variable "ibm_region" {
  description = "Primary IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-de", "eu-gb", 
      "jp-tok", "jp-osa", "au-syd", "ca-tor",
      "br-sao", "eu-es"
    ], var.ibm_region)
    error_message = "Region must be a valid IBM Cloud region."
  }
}

variable "ibm_zone" {
  description = "Primary IBM Cloud zone for resource deployment"
  type        = string
  default     = "us-south-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+(-[a-z]+)?-[0-9]$", var.ibm_zone))
    error_message = "Zone must follow IBM Cloud zone naming convention (e.g., us-south-1)."
  }
}

variable "enterprise_region" {
  description = "Enterprise production region"
  type        = string
  default     = "us-south"
}

variable "enterprise_zone" {
  description = "Enterprise production zone"
  type        = string
  default     = "us-south-1"
}

variable "dev_region" {
  description = "Development environment region"
  type        = string
  default     = "us-south"
}

variable "dev_zone" {
  description = "Development environment zone"
  type        = string
  default     = "us-south-2"
}

variable "staging_region" {
  description = "Staging environment region"
  type        = string
  default     = "us-east"
}

variable "staging_zone" {
  description = "Staging environment zone"
  type        = string
  default     = "us-east-1"
}

variable "testing_region" {
  description = "Testing environment region"
  type        = string
  default     = "us-south"
}

variable "testing_zone" {
  description = "Testing environment zone"
  type        = string
  default     = "us-south-3"
}

variable "dr_region" {
  description = "Disaster recovery region"
  type        = string
  default     = "eu-de"
}

variable "dr_zone" {
  description = "Disaster recovery zone"
  type        = string
  default     = "eu-de-1"
}

variable "kubernetes_region" {
  description = "Kubernetes cluster region"
  type        = string
  default     = "us-south"
}

variable "database_region" {
  description = "Database services region"
  type        = string
  default     = "us-south"
}

# =============================================================================
# RESOURCE GROUP VARIABLES
# =============================================================================

variable "resource_group_id" {
  description = "Primary resource group ID for resource organization"
  type        = string
  default     = null
}

variable "enterprise_resource_group_id" {
  description = "Enterprise resource group ID"
  type        = string
  default     = null
}

variable "dev_resource_group_id" {
  description = "Development resource group ID"
  type        = string
  default     = null
}

variable "staging_resource_group_id" {
  description = "Staging resource group ID"
  type        = string
  default     = null
}

variable "testing_resource_group_id" {
  description = "Testing resource group ID"
  type        = string
  default     = null
}

variable "dr_resource_group_id" {
  description = "Disaster recovery resource group ID"
  type        = string
  default     = null
}

variable "kubernetes_resource_group_id" {
  description = "Kubernetes resource group ID"
  type        = string
  default     = null
}

variable "database_resource_group_id" {
  description = "Database resource group ID"
  type        = string
  default     = null
}

# =============================================================================
# PROVIDER PERFORMANCE VARIABLES
# =============================================================================

variable "provider_timeout" {
  description = "Default provider timeout in seconds"
  type        = number
  default     = 600
  
  validation {
    condition     = var.provider_timeout >= 60 && var.provider_timeout <= 3600
    error_message = "Provider timeout must be between 60 and 3600 seconds."
  }
}

variable "max_retries" {
  description = "Maximum number of retries for provider operations"
  type        = number
  default     = 5
  
  validation {
    condition     = var.max_retries >= 1 && var.max_retries <= 50
    error_message = "Max retries must be between 1 and 50."
  }
}

variable "retry_delay" {
  description = "Delay between retries in seconds"
  type        = number
  default     = 30
  
  validation {
    condition     = var.retry_delay >= 5 && var.retry_delay <= 300
    error_message = "Retry delay must be between 5 and 300 seconds."
  }
}

# =============================================================================
# SECURITY AND COMPLIANCE VARIABLES
# =============================================================================

variable "use_private_endpoints" {
  description = "Enable private endpoints for enhanced security"
  type        = bool
  default     = true
}

variable "enable_debug_tracing" {
  description = "Enable debug tracing for provider operations"
  type        = bool
  default     = false
}

variable "enterprise_enable_tracing" {
  description = "Enable tracing for enterprise environments"
  type        = bool
  default     = false
}

variable "staging_use_private_endpoints" {
  description = "Use private endpoints in staging environment"
  type        = bool
  default     = true
}

variable "staging_enable_tracing" {
  description = "Enable tracing in staging environment"
  type        = bool
  default     = false
}

variable "kubernetes_enable_tracing" {
  description = "Enable tracing for Kubernetes operations"
  type        = bool
  default     = false
}

variable "force_private_endpoints" {
  description = "Force private endpoints for all provider configurations"
  type        = bool
  default     = false
}

variable "enable_audit_logging" {
  description = "Enable comprehensive audit logging"
  type        = bool
  default     = true
}

# =============================================================================
# CLASSIC INFRASTRUCTURE VARIABLES
# =============================================================================

variable "classic_username" {
  description = "IBM Cloud Classic Infrastructure username"
  type        = string
  sensitive   = true
  default     = null
}

variable "classic_api_key" {
  description = "IBM Cloud Classic Infrastructure API key"
  type        = string
  sensitive   = true
  default     = null
}

variable "enable_classic_infrastructure" {
  description = "Enable IBM Cloud Classic Infrastructure support"
  type        = bool
  default     = false
}

# =============================================================================
# PROJECT AND ENVIRONMENT VARIABLES
# =============================================================================

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "provider-config-lab"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment designation (dev, staging, prod, lab)"
  type        = string
  default     = "lab"
  
  validation {
    condition     = contains(["dev", "staging", "prod", "lab", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, lab, test."
  }
}

variable "owner" {
  description = "Resource owner for tagging and accountability"
  type        = string
  default     = "terraform-lab-student"
  
  validation {
    condition     = length(var.owner) > 0
    error_message = "Owner must be specified."
  }
}

# =============================================================================
# TESTING AND VALIDATION VARIABLES
# =============================================================================

variable "enable_provider_testing" {
  description = "Enable provider configuration testing"
  type        = bool
  default     = true
}

variable "test_connectivity" {
  description = "Test provider connectivity during deployment"
  type        = bool
  default     = true
}

variable "validate_authentication" {
  description = "Validate authentication for all configured providers"
  type        = bool
  default     = true
}

variable "test_multi_region" {
  description = "Test multi-region provider configurations"
  type        = bool
  default     = false
}

variable "performance_testing_enabled" {
  description = "Enable performance testing for provider operations"
  type        = bool
  default     = false
}

# =============================================================================
# ADVANCED CONFIGURATION VARIABLES
# =============================================================================

variable "vpc_generation" {
  description = "VPC generation to use (1 or 2)"
  type        = number
  default     = 2
  
  validation {
    condition     = contains([1, 2], var.vpc_generation)
    error_message = "VPC generation must be 1 or 2."
  }
}

variable "custom_endpoints" {
  description = "Custom endpoint configuration for specific environments"
  type = object({
    iam_url       = optional(string)
    iam_token_url = optional(string)
    api_endpoint  = optional(string)
  })
  default = {}
}

variable "provider_aliases" {
  description = "List of provider aliases to configure"
  type        = list(string)
  default = [
    "us_south",
    "us_east", 
    "eu_de",
    "jp_tok"
  ]
  
  validation {
    condition     = length(var.provider_aliases) > 0
    error_message = "At least one provider alias must be specified."
  }
}

# =============================================================================
# TAGGING STRATEGY VARIABLES
# =============================================================================

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    "terraform"   = "managed"
    "lab"         = "2.2"
    "purpose"     = "provider-configuration"
    "training"    = "ibm-cloud-terraform"
  }
}

variable "additional_tags" {
  description = "Additional tags for specific use cases"
  type        = list(string)
  default     = []
}

variable "environment_tags" {
  description = "Environment-specific tags"
  type        = map(string)
  default     = {}
}

# =============================================================================
# COST MANAGEMENT VARIABLES
# =============================================================================

variable "enable_cost_tracking" {
  description = "Enable cost tracking tags and monitoring"
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
