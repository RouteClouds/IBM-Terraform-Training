# =============================================================================
# TERRAFORM VARIABLES CONFIGURATION
# Advanced HCL Configuration Lab - Topic 4.2
# Demonstrates sophisticated variable patterns, validation, and enterprise use
# =============================================================================

# =============================================================================
# AUTHENTICATION AND PROVIDER VARIABLES
# =============================================================================

variable "ibmcloud_api_key" {
  description = <<-EOT
    IBM Cloud API key for authentication.
    
    This key provides access to IBM Cloud services and should be kept secure.
    Can be set via environment variable IBMCLOUD_API_KEY or IC_API_KEY.
    
    To obtain an API key:
    1. Log in to IBM Cloud console
    2. Go to Manage > Access (IAM) > API keys
    3. Create a new API key with appropriate permissions
  EOT
  
  type      = string
  sensitive = true
  default   = null
  
  validation {
    condition = var.ibmcloud_api_key == null || can(regex("^[a-zA-Z0-9_-]{40,}$", var.ibmcloud_api_key))
    error_message = "IBM Cloud API key must be at least 40 characters and contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "resource_group_id" {
  description = <<-EOT
    IBM Cloud Resource Group ID for organizing resources.
    
    All resources created in this lab will be placed in this resource group.
    Use 'ibmcloud resource groups' to list available resource groups.
  EOT
  
  type = string
  
  validation {
    condition     = can(regex("^[a-f0-9]{32}$", var.resource_group_id))
    error_message = "Resource Group ID must be a 32-character hexadecimal string."
  }
}

# =============================================================================
# REGION AND GEOGRAPHY VARIABLES
# =============================================================================

variable "primary_region" {
  description = "Primary IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd",
      "jp-osa", "br-sao", "ca-tor", "eu-fr2"
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
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd",
      "jp-osa", "br-sao", "ca-tor", "eu-fr2"
    ], var.secondary_region)
    error_message = "Secondary region must be a valid IBM Cloud region."
  }
  
  validation {
    condition     = var.secondary_region != var.primary_region
    error_message = "Secondary region must be different from primary region."
  }
}

variable "disaster_recovery_region" {
  description = "Disaster recovery region for backup deployments"
  type        = string
  default     = "eu-gb"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd",
      "jp-osa", "br-sao", "ca-tor", "eu-fr2"
    ], var.disaster_recovery_region)
    error_message = "Disaster recovery region must be a valid IBM Cloud region."
  }
  
  validation {
    condition = var.disaster_recovery_region != var.primary_region && var.disaster_recovery_region != var.secondary_region
    error_message = "Disaster recovery region must be different from primary and secondary regions."
  }
}

# =============================================================================
# PROJECT AND ORGANIZATION VARIABLES
# =============================================================================

variable "project_configuration" {
  description = <<-EOT
    Comprehensive project configuration object containing all project metadata,
    organizational information, and deployment specifications.
    
    This variable demonstrates complex object types with nested validation
    and enterprise-grade configuration management patterns.
  EOT
  
  type = object({
    # Project identification
    project_name        = string
    project_code        = string
    project_description = string
    project_owner       = string
    
    # Organizational metadata
    organization = object({
      name        = string
      division    = string
      department  = string
      cost_center = string
      budget_code = string
    })
    
    # Environment configuration
    environment = object({
      name        = string
      tier        = string
      purpose     = string
      criticality = string
    })
    
    # Compliance and governance
    compliance = object({
      frameworks          = list(string)
      data_classification = string
      retention_period    = number
      audit_required      = bool
    })
    
    # Technical specifications
    technical = object({
      architecture_pattern = string
      deployment_model     = string
      scaling_strategy     = string
      backup_strategy      = string
    })
  })
  
  # Comprehensive validation rules
  validation {
    condition = can(regex("^[a-z][a-z0-9-]{2,29}$", var.project_configuration.project_name))
    error_message = "Project name must be 3-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition = can(regex("^[A-Z]{2,5}-[0-9]{3,6}$", var.project_configuration.project_code))
    error_message = "Project code must follow format: 2-5 uppercase letters, hyphen, 3-6 digits (e.g., PROJ-001)."
  }
  
  validation {
    condition = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.project_configuration.project_owner))
    error_message = "Project owner must be a valid email address."
  }
  
  validation {
    condition = contains(["development", "testing", "staging", "production"], var.project_configuration.environment.name)
    error_message = "Environment name must be: development, testing, staging, or production."
  }
  
  validation {
    condition = contains(["low", "medium", "high", "critical"], var.project_configuration.environment.criticality)
    error_message = "Environment criticality must be: low, medium, high, or critical."
  }
  
  validation {
    condition = alltrue([
      for framework in var.project_configuration.compliance.frameworks :
      contains(["sox", "hipaa", "pci-dss", "iso27001", "gdpr", "fedramp"], framework)
    ])
    error_message = "Compliance frameworks must be from: sox, hipaa, pci-dss, iso27001, gdpr, fedramp."
  }
  
  validation {
    condition = var.project_configuration.compliance.retention_period >= 30 && var.project_configuration.compliance.retention_period <= 2555
    error_message = "Retention period must be between 30 days and 7 years (2555 days)."
  }
  
  default = {
    project_name        = "hcl-advanced-lab"
    project_code        = "HCL-001"
    project_description = "Advanced HCL Configuration Laboratory"
    project_owner       = "terraform-admin@company.com"
    
    organization = {
      name        = "acme-corp"
      division    = "engineering"
      department  = "platform-engineering"
      cost_center = "eng-001"
      budget_code = "budget-eng-2024"
    }
    
    environment = {
      name        = "development"
      tier        = "dev"
      purpose     = "training-lab"
      criticality = "low"
    }
    
    compliance = {
      frameworks          = ["iso27001"]
      data_classification = "internal"
      retention_period    = 90
      audit_required      = false
    }
    
    technical = {
      architecture_pattern = "multi-tier"
      deployment_model     = "cloud-native"
      scaling_strategy     = "horizontal"
      backup_strategy      = "automated"
    }
  }
}

# =============================================================================
# INFRASTRUCTURE CONFIGURATION VARIABLES
# =============================================================================

variable "infrastructure_configuration" {
  description = <<-EOT
    Advanced infrastructure configuration demonstrating complex variable types,
    conditional logic, and enterprise-scale resource planning.
    
    This variable showcases sophisticated HCL patterns including:
    - Nested object types with validation
    - Conditional resource allocation
    - Multi-environment configurations
    - Performance and cost optimization settings
  EOT
  
  type = object({
    # Network configuration
    network = object({
      vpc_cidr_blocks     = list(string)
      subnet_configuration = object({
        public_subnets  = list(string)
        private_subnets = list(string)
        database_subnets = list(string)
      })
      enable_flow_logs    = bool
      enable_nat_gateway  = bool
      dns_configuration   = object({
        enable_dns_hostnames = bool
        enable_dns_support   = bool
        custom_dns_servers   = list(string)
      })
    })
    
    # Compute configuration
    compute = object({
      instance_types = object({
        web_tier = object({
          instance_profile = string
          min_instances   = number
          max_instances   = number
          desired_instances = number
        })
        app_tier = object({
          instance_profile = string
          min_instances   = number
          max_instances   = number
          desired_instances = number
        })
        data_tier = object({
          instance_profile = string
          min_instances   = number
          max_instances   = number
          desired_instances = number
        })
      })
      auto_scaling = object({
        enabled                = bool
        scale_up_threshold     = number
        scale_down_threshold   = number
        scale_up_adjustment    = number
        scale_down_adjustment  = number
      })
    })
    
    # Storage configuration
    storage = object({
      volume_types = object({
        root_volume = object({
          size_gb     = number
          volume_type = string
          encrypted   = bool
        })
        data_volume = object({
          size_gb     = number
          volume_type = string
          encrypted   = bool
        })
      })
      backup_configuration = object({
        enabled           = bool
        retention_days    = number
        backup_schedule   = string
        cross_region_copy = bool
      })
    })
    
    # Security configuration
    security = object({
      encryption = object({
        at_rest_enabled     = bool
        in_transit_enabled  = bool
        key_management      = string
        customer_managed_keys = bool
      })
      access_control = object({
        enable_iam_roles    = bool
        enable_mfa          = bool
        session_timeout     = number
        password_policy     = object({
          min_length      = number
          require_symbols = bool
          require_numbers = bool
          require_uppercase = bool
          require_lowercase = bool
        })
      })
    })
    
    # Monitoring and logging
    monitoring = object({
      enabled = bool
      metrics = object({
        detailed_monitoring = bool
        custom_metrics     = bool
        retention_days     = number
      })
      logging = object({
        application_logs = bool
        system_logs     = bool
        audit_logs      = bool
        log_retention   = number
      })
      alerting = object({
        enabled = bool
        notification_channels = list(string)
        alert_thresholds = object({
          cpu_utilization    = number
          memory_utilization = number
          disk_utilization   = number
          network_throughput = number
        })
      })
    })
  })
  
  # Complex validation rules
  validation {
    condition = alltrue([
      for cidr in var.infrastructure_configuration.network.vpc_cidr_blocks :
      can(cidrhost(cidr, 0))
    ])
    error_message = "All VPC CIDR blocks must be valid IPv4 CIDR notation."
  }
  
  validation {
    condition = alltrue([
      for subnet in var.infrastructure_configuration.network.subnet_configuration.public_subnets :
      can(cidrhost(subnet, 0))
    ])
    error_message = "All public subnet CIDRs must be valid IPv4 CIDR notation."
  }
  
  validation {
    condition = var.infrastructure_configuration.compute.instance_types.web_tier.min_instances <= var.infrastructure_configuration.compute.instance_types.web_tier.max_instances
    error_message = "Web tier minimum instances must be less than or equal to maximum instances."
  }
  
  validation {
    condition = var.infrastructure_configuration.storage.volume_types.root_volume.size_gb >= 20 && var.infrastructure_configuration.storage.volume_types.root_volume.size_gb <= 1000
    error_message = "Root volume size must be between 20 GB and 1000 GB."
  }
  
  validation {
    condition = contains(["ibm", "customer"], var.infrastructure_configuration.security.encryption.key_management)
    error_message = "Key management must be either 'ibm' or 'customer'."
  }
  
  validation {
    condition = var.infrastructure_configuration.security.access_control.session_timeout >= 300 && var.infrastructure_configuration.security.access_control.session_timeout <= 28800
    error_message = "Session timeout must be between 5 minutes (300 seconds) and 8 hours (28800 seconds)."
  }
  
  default = {
    network = {
      vpc_cidr_blocks = ["10.0.0.0/16"]
      subnet_configuration = {
        public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
        private_subnets  = ["10.0.10.0/24", "10.0.20.0/24"]
        database_subnets = ["10.0.100.0/24", "10.0.200.0/24"]
      }
      enable_flow_logs   = false
      enable_nat_gateway = true
      dns_configuration = {
        enable_dns_hostnames = true
        enable_dns_support   = true
        custom_dns_servers   = ["8.8.8.8", "8.8.4.4"]
      }
    }
    
    compute = {
      instance_types = {
        web_tier = {
          instance_profile  = "bx2-2x8"
          min_instances    = 1
          max_instances    = 3
          desired_instances = 2
        }
        app_tier = {
          instance_profile  = "bx2-4x16"
          min_instances    = 1
          max_instances    = 5
          desired_instances = 2
        }
        data_tier = {
          instance_profile  = "bx2-8x32"
          min_instances    = 1
          max_instances    = 2
          desired_instances = 1
        }
      }
      auto_scaling = {
        enabled               = false
        scale_up_threshold    = 70
        scale_down_threshold  = 30
        scale_up_adjustment   = 1
        scale_down_adjustment = 1
      }
    }
    
    storage = {
      volume_types = {
        root_volume = {
          size_gb     = 100
          volume_type = "general-purpose"
          encrypted   = true
        }
        data_volume = {
          size_gb     = 500
          volume_type = "10iops-tier"
          encrypted   = true
        }
      }
      backup_configuration = {
        enabled           = true
        retention_days    = 30
        backup_schedule   = "daily"
        cross_region_copy = false
      }
    }
    
    security = {
      encryption = {
        at_rest_enabled       = true
        in_transit_enabled    = true
        key_management        = "ibm"
        customer_managed_keys = false
      }
      access_control = {
        enable_iam_roles = true
        enable_mfa      = false
        session_timeout = 3600
        password_policy = {
          min_length        = 12
          require_symbols   = true
          require_numbers   = true
          require_uppercase = true
          require_lowercase = true
        }
      }
    }
    
    monitoring = {
      enabled = true
      metrics = {
        detailed_monitoring = false
        custom_metrics     = false
        retention_days     = 30
      }
      logging = {
        application_logs = true
        system_logs     = true
        audit_logs      = false
        log_retention   = 30
      }
      alerting = {
        enabled = false
        notification_channels = []
        alert_thresholds = {
          cpu_utilization    = 80
          memory_utilization = 85
          disk_utilization   = 90
          network_throughput = 1000
        }
      }
    }
  }
}

# =============================================================================
# FEATURE FLAGS AND CONDITIONAL VARIABLES
# =============================================================================

variable "feature_flags" {
  description = <<-EOT
    Feature flags for enabling/disabling various functionality.
    
    This demonstrates conditional logic patterns and feature toggle
    implementation in Terraform configurations.
  EOT
  
  type = object({
    # Core features
    enable_multi_region      = bool
    enable_disaster_recovery = bool
    enable_auto_scaling      = bool
    enable_monitoring        = bool
    enable_backup           = bool
    
    # Advanced features
    enable_advanced_features = bool
    enable_cost_optimization = bool
    enable_security_scanning = bool
    enable_compliance_checks = bool
    enable_performance_tuning = bool
    
    # Development features
    enable_debug_mode        = bool
    enable_provider_validation = bool
    enable_resource_validation = bool
    enable_output_validation   = bool
  })
  
  default = {
    # Core features
    enable_multi_region      = false
    enable_disaster_recovery = false
    enable_auto_scaling      = false
    enable_monitoring        = true
    enable_backup           = true
    
    # Advanced features
    enable_advanced_features = false
    enable_cost_optimization = true
    enable_security_scanning = false
    enable_compliance_checks = true
    enable_performance_tuning = false
    
    # Development features
    enable_debug_mode          = false
    enable_provider_validation = true
    enable_resource_validation = true
    enable_output_validation   = true
  }
}

# =============================================================================
# TAGGING AND METADATA VARIABLES
# =============================================================================

variable "global_tags" {
  description = <<-EOT
    Global tags applied to all resources.
    
    These tags provide consistent metadata across all infrastructure
    components for cost tracking, compliance, and operational management.
  EOT
  
  type = map(string)
  
  validation {
    condition = alltrue([
      for key, value in var.global_tags :
      can(regex("^[a-zA-Z0-9:._-]+$", key)) && can(regex("^[a-zA-Z0-9:._\\s-]+$", value))
    ])
    error_message = "Tag keys and values must contain only alphanumeric characters, colons, periods, underscores, spaces, and hyphens."
  }
  
  validation {
    condition = alltrue([
      for key, value in var.global_tags :
      length(key) <= 128 && length(value) <= 256
    ])
    error_message = "Tag keys must be 128 characters or less, and values must be 256 characters or less."
  }
  
  default = {
    "managed-by"    = "terraform"
    "lab-name"      = "hcl-advanced-4.2"
    "created-by"    = "terraform-training"
    "purpose"       = "education"
    "cost-tracking" = "training-budget"
  }
}

# =============================================================================
# ADVANCED CONFIGURATION VARIABLES
# =============================================================================

variable "advanced_configuration" {
  description = <<-EOT
    Advanced configuration options for sophisticated use cases.
    
    This variable demonstrates enterprise-grade configuration patterns
    including performance tuning, cost optimization, and operational settings.
  EOT
  
  type = object({
    # Performance configuration
    performance = object({
      enable_performance_mode = bool
      cpu_optimization       = string
      memory_optimization    = string
      network_optimization   = string
      storage_optimization   = string
    })
    
    # Cost optimization
    cost_optimization = object({
      enable_cost_controls = bool
      budget_alerts       = bool
      resource_scheduling = object({
        enable_scheduling = bool
        start_schedule   = string
        stop_schedule    = string
        timezone        = string
      })
      rightsizing = object({
        enable_rightsizing = bool
        analysis_period   = number
        threshold_cpu     = number
        threshold_memory  = number
      })
    })
    
    # Operational configuration
    operations = object({
      maintenance_window = object({
        enabled    = bool
        day_of_week = string
        start_time = string
        duration   = number
      })
      change_management = object({
        require_approval = bool
        approval_timeout = number
        rollback_enabled = bool
      })
      incident_response = object({
        enable_auto_response = bool
        escalation_timeout  = number
        notification_channels = list(string)
      })
    })
  })
  
  validation {
    condition = contains(["balanced", "performance", "cost"], var.advanced_configuration.performance.cpu_optimization)
    error_message = "CPU optimization must be: balanced, performance, or cost."
  }
  
  validation {
    condition = contains(["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"], 
                        var.advanced_configuration.operations.maintenance_window.day_of_week)
    error_message = "Maintenance window day must be a valid day of the week."
  }
  
  validation {
    condition = can(regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.advanced_configuration.operations.maintenance_window.start_time))
    error_message = "Maintenance window start time must be in HH:MM format (24-hour)."
  }
  
  default = {
    performance = {
      enable_performance_mode = false
      cpu_optimization       = "balanced"
      memory_optimization    = "balanced"
      network_optimization   = "balanced"
      storage_optimization   = "balanced"
    }
    
    cost_optimization = {
      enable_cost_controls = true
      budget_alerts       = true
      resource_scheduling = {
        enable_scheduling = false
        start_schedule   = "08:00"
        stop_schedule    = "18:00"
        timezone        = "UTC"
      }
      rightsizing = {
        enable_rightsizing = false
        analysis_period   = 30
        threshold_cpu     = 20
        threshold_memory  = 30
      }
    }
    
    operations = {
      maintenance_window = {
        enabled     = true
        day_of_week = "sunday"
        start_time  = "02:00"
        duration    = 4
      }
      change_management = {
        require_approval = false
        approval_timeout = 24
        rollback_enabled = true
      }
      incident_response = {
        enable_auto_response  = false
        escalation_timeout   = 30
        notification_channels = []
      }
    }
  }
}
