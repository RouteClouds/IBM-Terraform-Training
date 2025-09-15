# =============================================================================
# TERRAFORM VARIABLES CONFIGURATION
# =============================================================================
# Terraform Code Lab 5.1: Creating Reusable Modules
# This file demonstrates comprehensive variable design patterns for enterprise
# module development with IBM Cloud services.

# =============================================================================
# AUTHENTICATION AND PROVIDER CONFIGURATION
# =============================================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
  default     = null
  
  validation {
    condition = var.ibmcloud_api_key == null || can(regex("^[A-Za-z0-9_-]{44}$", var.ibmcloud_api_key))
    error_message = "IBM Cloud API key must be 44 characters long and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "account_id" {
  description = "IBM Cloud account ID for enterprise features"
  type        = string
  default     = null
  
  validation {
    condition = var.account_id == null || can(regex("^[a-f0-9]{32}$", var.account_id))
    error_message = "Account ID must be a 32-character hexadecimal string."
  }
}

# =============================================================================
# REGIONAL CONFIGURATION
# =============================================================================

variable "primary_region" {
  description = "Primary IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd",
      "jp-osa", "br-sao", "ca-tor", "eu-es", "eu-fr2"
    ], var.primary_region)
    error_message = "Primary region must be a valid IBM Cloud VPC region."
  }
}

variable "secondary_region" {
  description = "Secondary IBM Cloud region for multi-region deployments"
  type        = string
  default     = "us-east"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd",
      "jp-osa", "br-sao", "ca-tor", "eu-es", "eu-fr2"
    ], var.secondary_region)
    error_message = "Secondary region must be a valid IBM Cloud VPC region."
  }
  
  validation {
    condition = var.secondary_region != var.primary_region
    error_message = "Secondary region must be different from primary region."
  }
}

variable "enable_multi_region" {
  description = "Enable multi-region deployment for high availability"
  type        = bool
  default     = false
}

variable "enable_cross_region_networking" {
  description = "Enable cross-region networking between primary and secondary regions"
  type        = bool
  default     = false
}

# =============================================================================
# RESOURCE GROUP AND ORGANIZATION
# =============================================================================

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "default"
  
  validation {
    condition = can(regex("^[a-zA-Z0-9._-]{1,40}$", var.resource_group_name))
    error_message = "Resource group name must be 1-40 characters and contain only letters, numbers, periods, hyphens, and underscores."
  }
}

variable "organization_config" {
  description = "Organization configuration for enterprise governance"
  type = object({
    name        = string
    division    = string
    cost_center = string
    environment = string
    project     = string
    owner       = string
    contact     = string
  })
  
  default = {
    name        = "IBM Cloud Training"
    division    = "Education"
    cost_center = "CC-EDU-001"
    environment = "development"
    project     = "terraform-training"
    owner       = "platform-team"
    contact     = "platform-team@company.com"
  }
  
  validation {
    condition = contains(["development", "staging", "production"], var.organization_config.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
  
  validation {
    condition = can(regex("^CC-[A-Z]{2,4}-[0-9]{3}$", var.organization_config.cost_center))
    error_message = "Cost center must follow format: CC-ABC-123."
  }
  
  validation {
    condition = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.organization_config.contact))
    error_message = "Contact must be a valid email address."
  }
}

# =============================================================================
# MODULE CONFIGURATION
# =============================================================================

variable "module_config" {
  description = "Module-specific configuration for development and testing"
  type = object({
    name_prefix          = string
    version             = string
    enable_testing      = optional(bool, true)
    enable_validation   = optional(bool, true)
    enable_documentation = optional(bool, true)
    
    # Module development settings
    development = optional(object({
      enable_debug_mode    = optional(bool, false)
      enable_verbose_logs  = optional(bool, false)
      enable_dry_run      = optional(bool, false)
      enable_force_update = optional(bool, false)
    }), {})
    
    # Module testing settings
    testing = optional(object({
      enable_unit_tests        = optional(bool, true)
      enable_integration_tests = optional(bool, true)
      enable_e2e_tests        = optional(bool, false)
      test_timeout_minutes    = optional(number, 30)
      parallel_test_execution = optional(bool, true)
    }), {})
  })
  
  default = {
    name_prefix = "module-lab"
    version     = "1.0.0"
  }
  
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.module_config.name_prefix))
    error_message = "Name prefix must start with a letter, contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.module_config.version))
    error_message = "Version must follow semantic versioning format (e.g., 1.0.0)."
  }
}

# =============================================================================
# VPC MODULE CONFIGURATION
# =============================================================================

variable "vpc_configuration" {
  description = "Comprehensive VPC configuration for module development"
  type = object({
    # Basic VPC settings
    name                      = string
    address_prefix_management = optional(string, "auto")
    classic_access           = optional(bool, false)
    enable_public_gateway    = optional(bool, false)
    
    # Advanced VPC settings
    default_network_acl_name    = optional(string, null)
    default_routing_table_name  = optional(string, null)
    default_security_group_name = optional(string, null)
    
    # Subnet configuration
    subnets = optional(list(object({
      name                    = string
      zone                    = string
      cidr_block             = string
      public_gateway_enabled = optional(bool, false)
      
      # Advanced subnet settings
      resource_group_id = optional(string, null)
      network_acl_id   = optional(string, null)
      routing_table_id = optional(string, null)
    })), [])
    
    # Security group configuration
    security_groups = optional(list(object({
      name        = string
      description = string
      
      rules = optional(list(object({
        direction   = string
        protocol    = string
        port_min    = optional(number, null)
        port_max    = optional(number, null)
        source_type = string
        source      = string
        description = optional(string, "")
      })), [])
    })), [])
    
    # Network ACL configuration
    network_acls = optional(list(object({
      name = string
      
      rules = optional(list(object({
        name        = string
        action      = string
        direction   = string
        protocol    = string
        source      = string
        destination = string
        port_min    = optional(number, null)
        port_max    = optional(number, null)
      })), [])
    })), [])
  })
  
  default = {
    name = "lab-vpc"
    subnets = [
      {
        name       = "subnet-1"
        zone       = "us-south-1"
        cidr_block = "10.240.0.0/24"
      },
      {
        name       = "subnet-2"
        zone       = "us-south-2"
        cidr_block = "10.240.1.0/24"
      },
      {
        name       = "subnet-3"
        zone       = "us-south-3"
        cidr_block = "10.240.2.0/24"
      }
    ]
  }
  
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.vpc_configuration.name))
    error_message = "VPC name must start with a letter, contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition = length(var.vpc_configuration.name) >= 3 && length(var.vpc_configuration.name) <= 63
    error_message = "VPC name must be between 3 and 63 characters."
  }
  
  validation {
    condition = length(var.vpc_configuration.subnets) <= 15
    error_message = "Cannot create more than 15 subnets per VPC."
  }
  
  validation {
    condition = alltrue([
      for subnet in var.vpc_configuration.subnets :
      can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All subnet CIDR blocks must be valid IPv4 CIDR notation."
  }
  
  validation {
    condition = contains(["auto", "manual"], var.vpc_configuration.address_prefix_management)
    error_message = "Address prefix management must be 'auto' or 'manual'."
  }
}

# =============================================================================
# COMPUTE MODULE CONFIGURATION
# =============================================================================

variable "compute_configuration" {
  description = "Compute instance configuration for module testing"
  type = object({
    # Instance configuration
    instance_count   = optional(number, 2)
    instance_profile = optional(string, "cx2-2x4")
    base_image_name  = optional(string, "ibm-ubuntu-22-04-1-minimal-amd64-1")
    
    # SSH configuration
    ssh_key_name = optional(string, "lab-ssh-key")
    
    # Storage configuration
    boot_volume = optional(object({
      size       = optional(number, 100)
      profile    = optional(string, "general-purpose")
      encryption = optional(string, "provider_managed")
    }), {})
    
    # Network configuration
    security_group_rules = optional(list(object({
      direction   = string
      protocol    = string
      port_min    = optional(number, null)
      port_max    = optional(number, null)
      source_type = string
      source      = string
    })), [])
  })
  
  default = {
    instance_count = 2
  }
  
  validation {
    condition = var.compute_configuration.instance_count >= 1 && var.compute_configuration.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
  
  validation {
    condition = contains([
      "cx2-2x4", "cx2-4x8", "cx2-8x16", "mx2-2x16", "mx2-4x32"
    ], var.compute_configuration.instance_profile)
    error_message = "Instance profile must be a valid IBM Cloud VPC profile."
  }
}

# =============================================================================
# FEATURE FLAGS AND TOGGLES
# =============================================================================

variable "enable_enterprise_features" {
  description = "Enable enterprise features like governance and compliance"
  type        = bool
  default     = true
}

variable "enable_advanced_networking" {
  description = "Enable advanced networking features"
  type        = bool
  default     = false
}

variable "enable_security_services" {
  description = "Enable security services integration"
  type        = bool
  default     = true
}

variable "enable_monitoring_services" {
  description = "Enable monitoring and observability services"
  type        = bool
  default     = true
}

variable "enable_audit_logging" {
  description = "Enable audit logging for compliance"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable metrics collection"
  type        = bool
  default     = true
}

variable "enable_alerting" {
  description = "Enable alerting and notifications"
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for private connectivity"
  type        = bool
  default     = false
}

# =============================================================================
# SECURITY AND COMPLIANCE CONFIGURATION
# =============================================================================

variable "security_configuration" {
  description = "Security and compliance configuration"
  type = object({
    # Encryption settings
    encryption = optional(object({
      enable_encryption_at_rest    = optional(bool, true)
      enable_encryption_in_transit = optional(bool, true)
      kms_key_id                  = optional(string, null)
      kms_instance_id             = optional(string, null)
    }), {})
    
    # Access control
    access_control = optional(object({
      enable_iam_integration = optional(bool, true)
      allowed_ip_ranges     = optional(list(string), [])
      enable_mfa           = optional(bool, false)
    }), {})
    
    # Compliance frameworks
    compliance = optional(object({
      frameworks = optional(list(string), [])
      data_classification = optional(string, "internal")
      retention_period_days = optional(number, 90)
      audit_required = optional(bool, true)
    }), {})
  })
  
  default = {}
  
  validation {
    condition = var.security_configuration.compliance.data_classification == null || contains([
      "public", "internal", "confidential", "restricted"
    ], var.security_configuration.compliance.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for security configuration"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for ip_range in var.allowed_ip_ranges :
      can(cidrhost(ip_range, 0))
    ])
    error_message = "All IP ranges must be valid CIDR notation."
  }
}

# =============================================================================
# LOGGING AND MONITORING CONFIGURATION
# =============================================================================

variable "log_level" {
  description = "Logging level for provider and module operations"
  type        = string
  default     = "INFO"
  
  validation {
    condition = contains(["DEBUG", "INFO", "WARN", "ERROR"], var.log_level)
    error_message = "Log level must be one of: DEBUG, INFO, WARN, ERROR."
  }
}

variable "monitoring_configuration" {
  description = "Monitoring and observability configuration"
  type = object({
    # Metrics configuration
    metrics = optional(object({
      collection_interval_seconds = optional(number, 60)
      retention_days             = optional(number, 30)
      enable_custom_metrics      = optional(bool, false)
    }), {})
    
    # Logging configuration
    logging = optional(object({
      log_level           = optional(string, "INFO")
      retention_days      = optional(number, 30)
      enable_structured_logs = optional(bool, true)
    }), {})
    
    # Alerting configuration
    alerting = optional(object({
      enable_email_alerts = optional(bool, false)
      enable_slack_alerts = optional(bool, false)
      alert_channels     = optional(list(string), [])
    }), {})
  })
  
  default = {}
}

# =============================================================================
# TAGGING AND METADATA CONFIGURATION
# =============================================================================

variable "global_tags" {
  description = "Global tags to apply to all resources"
  type        = list(string)
  default = [
    "terraform:managed",
    "lab:module-creation",
    "topic:5.1"
  ]
  
  validation {
    condition = length(var.global_tags) <= 100
    error_message = "Cannot specify more than 100 global tags."
  }
  
  validation {
    condition = alltrue([
      for tag in var.global_tags :
      can(regex("^[a-zA-Z0-9:._-]{1,128}$", tag))
    ])
    error_message = "Tags must be 1-128 characters and contain only letters, numbers, colons, periods, hyphens, and underscores."
  }
}

variable "custom_tags" {
  description = "Custom tags for specific use cases"
  type        = map(string)
  default     = {}
  
  validation {
    condition = length(var.custom_tags) <= 50
    error_message = "Cannot specify more than 50 custom tags."
  }
}
