# Terraform Configuration Organization Lab - Variable Definitions
# Comprehensive variable structure demonstrating enterprise organization patterns

# ============================================================================
# ORGANIZATIONAL CONFIGURATION
# ============================================================================

variable "organization_config" {
  description = "Organization-wide configuration settings"
  type = object({
    name         = string
    division     = string
    cost_center  = string
    environment  = string
    project_name = string
    owner        = string
    contact      = string
  })
  
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9 -]*$", var.organization_config.name))
    error_message = "Organization name must start with a letter and contain only letters, numbers, spaces, and hyphens."
  }
  
  validation {
    condition = contains(["development", "staging", "production", "sandbox"], var.organization_config.environment)
    error_message = "Environment must be one of: development, staging, production, sandbox."
  }
  
  validation {
    condition = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.organization_config.contact))
    error_message = "Contact must be a valid email address."
  }
}

# ============================================================================
# REGIONAL CONFIGURATION
# ============================================================================

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
  description = "Secondary IBM Cloud region for multi-region deployments"
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

variable "dr_region" {
  description = "Disaster recovery region for business continuity"
  type        = string
  default     = "eu-gb"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao"
    ], var.dr_region)
    error_message = "DR region must be a valid IBM Cloud region."
  }
}

variable "enable_multi_region" {
  description = "Enable multi-region deployment for high availability"
  type        = bool
  default     = false
}

# ============================================================================
# RESOURCE GROUP CONFIGURATION
# ============================================================================

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "default"
  
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9-_]*$", var.resource_group_name))
    error_message = "Resource group name must start with a letter and contain only letters, numbers, hyphens, and underscores."
  }
}

variable "resource_group_id" {
  description = "ID of the IBM Cloud resource group (optional, will be looked up if not provided)"
  type        = string
  default     = null
}

# ============================================================================
# NAMING CONVENTION CONFIGURATION
# ============================================================================

variable "naming_convention" {
  description = "Naming convention configuration for consistent resource naming"
  type = object({
    separator    = string
    max_length   = number
    prefix       = string
    suffix       = string
    use_random   = bool
    random_length = number
  })
  
  default = {
    separator     = "-"
    max_length    = 63
    prefix        = ""
    suffix        = ""
    use_random    = true
    random_length = 4
  }
  
  validation {
    condition = var.naming_convention.max_length >= 10 && var.naming_convention.max_length <= 63
    error_message = "Maximum length must be between 10 and 63 characters."
  }
  
  validation {
    condition = var.naming_convention.random_length >= 2 && var.naming_convention.random_length <= 8
    error_message = "Random length must be between 2 and 8 characters."
  }
}

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

variable "network_configuration" {
  description = "Comprehensive network configuration for VPC and subnets"
  type = object({
    vpc_name = string
    address_prefix_management = string
    enable_public_gateway = bool
    
    subnets = list(object({
      name                    = string
      zone                    = string
      cidr_block             = string
      public_gateway_enabled = bool
      acl_rules = optional(list(object({
        name      = string
        action    = string
        direction = string
        source    = string
        destination = string
        protocol  = string
        port_min  = optional(number)
        port_max  = optional(number)
      })), [])
    }))
    
    security_groups = list(object({
      name        = string
      description = string
      rules = list(object({
        direction   = string
        protocol    = string
        port_min    = optional(number)
        port_max    = optional(number)
        source_type = string
        source      = string
      }))
    }))
  })
  
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.network_configuration.vpc_name))
    error_message = "VPC name must be lowercase, start with a letter, and contain only letters, numbers, and hyphens."
  }
  
  validation {
    condition = contains(["auto", "manual"], var.network_configuration.address_prefix_management)
    error_message = "Address prefix management must be 'auto' or 'manual'."
  }
  
  validation {
    condition = length(var.network_configuration.subnets) >= 1 && length(var.network_configuration.subnets) <= 15
    error_message = "Must have between 1 and 15 subnets (IBM Cloud VPC limit)."
  }
}

# ============================================================================
# COMPUTE CONFIGURATION
# ============================================================================

variable "compute_configuration" {
  description = "Compute instance configuration for scalable deployments"
  type = object({
    instance_profile = string
    instance_count   = number
    image_name       = string
    
    # Instance configuration
    user_data_template = optional(string, "")
    enable_monitoring  = bool
    enable_backup     = bool
    
    # Storage configuration
    boot_volume_size = number
    boot_volume_profile = string
    
    # Additional storage
    data_volumes = optional(list(object({
      name     = string
      size     = number
      profile  = string
      encrypted = bool
    })), [])
    
    # SSH configuration
    ssh_key_name = string
    create_ssh_key = bool
  })
  
  validation {
    condition = contains([
      "cx2-2x4", "cx2-4x8", "cx2-8x16", "cx2-16x32",
      "mx2-2x16", "mx2-4x32", "mx2-8x64", "mx2-16x128"
    ], var.compute_configuration.instance_profile)
    error_message = "Instance profile must be a valid IBM Cloud VPC profile."
  }
  
  validation {
    condition = var.compute_configuration.instance_count >= 1 && var.compute_configuration.instance_count <= 100
    error_message = "Instance count must be between 1 and 100."
  }
  
  validation {
    condition = var.compute_configuration.boot_volume_size >= 100 && var.compute_configuration.boot_volume_size <= 2000
    error_message = "Boot volume size must be between 100 and 2000 GB."
  }
}

# ============================================================================
# SECURITY CONFIGURATION
# ============================================================================

variable "security_configuration" {
  description = "Security settings and compliance configuration"
  type = object({
    enable_flow_logs = bool
    enable_activity_tracker = bool
    enable_key_management = bool
    
    # Encryption settings
    encryption_at_rest = bool
    encryption_in_transit = bool
    
    # Compliance framework
    compliance_framework = string
    data_classification = string
    
    # Access control
    enable_iam_policies = bool
    enable_context_based_restrictions = bool
    
    # Monitoring and alerting
    enable_security_monitoring = bool
    alert_notification_channels = list(string)
  })
  
  validation {
    condition = contains(["SOC2", "ISO27001", "HIPAA", "PCI-DSS", "GDPR", "none"], var.security_configuration.compliance_framework)
    error_message = "Compliance framework must be one of: SOC2, ISO27001, HIPAA, PCI-DSS, GDPR, none."
  }
  
  validation {
    condition = contains(["public", "internal", "confidential", "restricted"], var.security_configuration.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

# ============================================================================
# COST MANAGEMENT CONFIGURATION
# ============================================================================

variable "cost_configuration" {
  description = "Cost management and optimization settings"
  type = object({
    monthly_budget_limit = number
    cost_center         = string
    billing_account_id  = string
    
    # Cost optimization
    enable_auto_scaling = bool
    enable_scheduled_shutdown = bool
    shutdown_schedule = optional(object({
      weekdays = object({
        start_time = string
        end_time   = string
      })
      weekends = object({
        enabled = bool
      })
    }))
    
    # Cost tracking
    cost_allocation_tags = map(string)
    enable_cost_alerts = bool
    cost_alert_thresholds = list(number)
  })
  
  validation {
    condition = var.cost_configuration.monthly_budget_limit > 0 && var.cost_configuration.monthly_budget_limit <= 100000
    error_message = "Monthly budget limit must be between $1 and $100,000."
  }
  
  validation {
    condition = can(regex("^CC-[A-Z]{3}-[0-9]{3}$", var.cost_configuration.cost_center))
    error_message = "Cost center must follow format: CC-XXX-000 (e.g., CC-ENG-001)."
  }
}

# ============================================================================
# ENVIRONMENT-SPECIFIC CONFIGURATION
# ============================================================================

variable "environment_specific_config" {
  description = "Environment-specific configuration overrides"
  type = object({
    # Development environment settings
    development = optional(object({
      instance_count = number
      enable_monitoring = bool
      backup_retention_days = number
    }))
    
    # Staging environment settings
    staging = optional(object({
      instance_count = number
      enable_monitoring = bool
      backup_retention_days = number
      enable_load_testing = bool
    }))
    
    # Production environment settings
    production = optional(object({
      instance_count = number
      enable_monitoring = bool
      backup_retention_days = number
      enable_high_availability = bool
      enable_disaster_recovery = bool
    }))
  })
  
  default = {
    development = {
      instance_count = 1
      enable_monitoring = false
      backup_retention_days = 7
    }
    staging = {
      instance_count = 2
      enable_monitoring = true
      backup_retention_days = 14
      enable_load_testing = true
    }
    production = {
      instance_count = 3
      enable_monitoring = true
      backup_retention_days = 30
      enable_high_availability = true
      enable_disaster_recovery = true
    }
  }
}

# ============================================================================
# TAGGING CONFIGURATION
# ============================================================================

variable "standard_tags" {
  description = "Standard tags applied to all resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition = alltrue([
      for key, value in var.standard_tags :
      can(regex("^[a-zA-Z][a-zA-Z0-9-_]*$", key)) && 
      can(regex("^[a-zA-Z0-9-_. ]*$", value))
    ])
    error_message = "Tag keys must start with a letter and contain only letters, numbers, hyphens, and underscores. Values can contain letters, numbers, hyphens, underscores, periods, and spaces."
  }
}

variable "custom_tags" {
  description = "Custom tags for specific use cases"
  type        = map(string)
  default     = {}
}

# ============================================================================
# FEATURE FLAGS
# ============================================================================

variable "feature_flags" {
  description = "Feature flags for enabling/disabling specific functionality"
  type = object({
    enable_advanced_networking = bool
    enable_container_registry  = bool
    enable_database_services   = bool
    enable_ai_services        = bool
    enable_edge_computing     = bool
    enable_quantum_services   = bool
  })
  
  default = {
    enable_advanced_networking = true
    enable_container_registry  = false
    enable_database_services   = false
    enable_ai_services        = false
    enable_edge_computing     = false
    enable_quantum_services   = false
  }
}
