# =============================================================================
# VARIABLES CONFIGURATION
# Resource Dependencies and Attributes Lab - Topic 4.3
# =============================================================================

# =============================================================================
# BASIC CONFIGURATION VARIABLES
# =============================================================================

variable "resource_group_id" {
  description = "IBM Cloud resource group ID for all resources"
  type        = string
  
  validation {
    condition     = length(var.resource_group_id) > 0
    error_message = "Resource group ID cannot be empty."
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

variable "secondary_region" {
  description = "Secondary IBM Cloud region for multi-region deployment"
  type        = string
  default     = "us-east"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd"
    ], var.secondary_region)
    error_message = "Secondary region must be a valid IBM Cloud region."
  }
}

variable "dr_region" {
  description = "Disaster recovery region for cross-region replication"
  type        = string
  default     = "eu-gb"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd"
    ], var.dr_region)
    error_message = "DR region must be a valid IBM Cloud region."
  }
}

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

variable "project_configuration" {
  description = "Comprehensive project configuration with dependency management settings"
  type = object({
    project_name        = string
    project_code        = string
    project_description = string
    project_owner       = string
    
    organization = object({
      name        = string
      division    = string
      department  = string
      cost_center = string
      budget_code = string
    })
    
    environment = object({
      name        = string
      tier        = string
      purpose     = string
      criticality = string
    })
    
    compliance = object({
      frameworks          = list(string)
      data_classification = string
      retention_period    = number
      audit_required      = bool
    })
    
    dependency_management = object({
      enable_implicit_dependencies = bool
      enable_explicit_dependencies = bool
      enable_data_source_caching   = bool
      enable_dependency_validation = bool
      optimization_level           = string
    })
  })
  
  default = {
    project_name        = "dependency-lab"
    project_code        = "DEP-001"
    project_description = "Resource Dependencies and Attributes Laboratory"
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
      frameworks          = ["iso27001", "soc2"]
      data_classification = "internal"
      retention_period    = 90
      audit_required      = true
    }
    
    dependency_management = {
      enable_implicit_dependencies = true
      enable_explicit_dependencies = true
      enable_data_source_caching   = true
      enable_dependency_validation = true
      optimization_level           = "balanced"
    }
  }
  
  validation {
    condition     = length(var.project_configuration.project_name) > 3
    error_message = "Project name must be at least 4 characters long."
  }
  
  validation {
    condition = contains(["development", "staging", "production"], var.project_configuration.environment.name)
    error_message = "Environment name must be development, staging, or production."
  }
  
  validation {
    condition = contains(["low", "medium", "high", "critical"], var.project_configuration.environment.criticality)
    error_message = "Environment criticality must be low, medium, high, or critical."
  }
  
  validation {
    condition = contains(["performance", "balanced", "cost"], var.project_configuration.dependency_management.optimization_level)
    error_message = "Optimization level must be performance, balanced, or cost."
  }
}

# =============================================================================
# INFRASTRUCTURE CONFIGURATION
# =============================================================================

variable "infrastructure_configuration" {
  description = "Infrastructure configuration with dependency patterns"
  type = object({
    network = object({
      vpc_cidr_blocks = list(string)
      subnet_configuration = object({
        public_subnets   = list(string)
        private_subnets  = list(string)
        database_subnets = list(string)
      })
      enable_flow_logs   = bool
      enable_nat_gateway = bool
      dns_configuration = object({
        enable_dns_hostnames = bool
        enable_dns_support   = bool
        custom_dns_servers   = list(string)
      })
    })
    
    compute = object({
      instance_types = map(object({
        instance_profile  = string
        min_instances    = number
        max_instances    = number
        desired_instances = number
      }))
      auto_scaling = object({
        enabled               = bool
        scale_up_threshold    = number
        scale_down_threshold  = number
        scale_up_adjustment   = number
        scale_down_adjustment = number
      })
    })
    
    storage = object({
      volume_types = map(object({
        size_gb     = number
        volume_type = string
        encrypted   = bool
      }))
      backup_configuration = object({
        enabled           = bool
        retention_days    = number
        backup_schedule   = string
        cross_region_copy = bool
      })
    })
    
    security = object({
      encryption = object({
        at_rest_enabled       = bool
        in_transit_enabled    = bool
        key_management        = string
        customer_managed_keys = bool
      })
      access_control = object({
        enable_iam_roles = bool
        enable_mfa      = bool
        session_timeout = number
        password_policy = object({
          min_length        = number
          require_symbols   = bool
          require_numbers   = bool
          require_uppercase = bool
          require_lowercase = bool
        })
      })
    })
    
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
  
  default = {
    network = {
      vpc_cidr_blocks = ["10.0.0.0/16"]
      subnet_configuration = {
        public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
        private_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
        database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
      }
      enable_flow_logs   = true
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
          max_instances    = 5
          desired_instances = 2
        }
        app_tier = {
          instance_profile  = "bx2-4x16"
          min_instances    = 2
          max_instances    = 10
          desired_instances = 3
        }
        data_tier = {
          instance_profile  = "bx2-8x32"
          min_instances    = 1
          max_instances    = 3
          desired_instances = 2
        }
      }
      auto_scaling = {
        enabled               = true
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
        detailed_monitoring = true
        custom_metrics     = true
        retention_days     = 30
      }
      logging = {
        application_logs = true
        system_logs     = true
        audit_logs      = true
        log_retention   = 30
      }
      alerting = {
        enabled = true
        notification_channels = ["email", "slack"]
        alert_thresholds = {
          cpu_utilization    = 80
          memory_utilization = 85
          disk_utilization   = 90
          network_throughput = 1000
        }
      }
    }
  }
  
  validation {
    condition = alltrue([
      for cidr in var.infrastructure_configuration.network.vpc_cidr_blocks :
      can(cidrhost(cidr, 0))
    ])
    error_message = "All VPC CIDR blocks must be valid IPv4 CIDR notation."
  }
  
  validation {
    condition = var.infrastructure_configuration.storage.backup_configuration.retention_days >= 1 && var.infrastructure_configuration.storage.backup_configuration.retention_days <= 365
    error_message = "Backup retention days must be between 1 and 365."
  }
}

# =============================================================================
# FEATURE FLAGS
# =============================================================================

variable "feature_flags" {
  description = "Feature flags for enabling/disabling specific functionality"
  type = object({
    enable_multi_region      = bool
    enable_disaster_recovery = bool
    enable_auto_scaling      = bool
    enable_monitoring        = bool
    enable_backup           = bool
    enable_advanced_features = bool
    enable_cost_optimization = bool
    enable_security_scanning = bool
    enable_compliance_checks = bool
    enable_performance_tuning = bool
    enable_debug_mode          = bool
    enable_provider_validation = bool
    enable_resource_validation = bool
    enable_output_validation   = bool
  })
  
  default = {
    enable_multi_region      = false
    enable_disaster_recovery = false
    enable_auto_scaling      = true
    enable_monitoring        = true
    enable_backup           = true
    enable_advanced_features = false
    enable_cost_optimization = true
    enable_security_scanning = true
    enable_compliance_checks = true
    enable_performance_tuning = false
    enable_debug_mode          = true
    enable_provider_validation = true
    enable_resource_validation = true
    enable_output_validation   = true
  }
}

# =============================================================================
# DEPENDENCY CONFIGURATION
# =============================================================================

variable "dependency_configuration" {
  description = "Advanced dependency management configuration"
  type = object({
    implicit_dependencies = object({
      enable_vpc_to_subnet     = bool
      enable_subnet_to_instance = bool
      enable_sg_cross_reference = bool
      enable_lb_to_instance    = bool
    })
    
    explicit_dependencies = object({
      enable_database_first    = bool
      enable_monitoring_first  = bool
      enable_security_first    = bool
      enable_network_first     = bool
    })
    
    data_source_strategy = object({
      cache_results           = bool
      enable_conditional_logic = bool
      enable_dynamic_discovery = bool
      refresh_interval        = number
    })
    
    optimization_settings = object({
      enable_parallel_creation = bool
      max_parallelism         = number
      enable_dependency_graph  = bool
      enable_performance_monitoring = bool
    })
  })
  
  default = {
    implicit_dependencies = {
      enable_vpc_to_subnet     = true
      enable_subnet_to_instance = true
      enable_sg_cross_reference = true
      enable_lb_to_instance    = true
    }
    
    explicit_dependencies = {
      enable_database_first    = true
      enable_monitoring_first  = true
      enable_security_first    = true
      enable_network_first     = true
    }
    
    data_source_strategy = {
      cache_results           = true
      enable_conditional_logic = true
      enable_dynamic_discovery = true
      refresh_interval        = 300
    }
    
    optimization_settings = {
      enable_parallel_creation = true
      max_parallelism         = 10
      enable_dependency_graph  = true
      enable_performance_monitoring = true
    }
  }
  
  validation {
    condition = var.dependency_configuration.optimization_settings.max_parallelism >= 1 && var.dependency_configuration.optimization_settings.max_parallelism <= 50
    error_message = "Max parallelism must be between 1 and 50."
  }
  
  validation {
    condition = var.dependency_configuration.data_source_strategy.refresh_interval >= 60
    error_message = "Data source refresh interval must be at least 60 seconds."
  }
}

# =============================================================================
# GLOBAL TAGS
# =============================================================================

variable "global_tags" {
  description = "Global tags applied to all resources"
  type        = map(string)
  default = {
    "managed-by"      = "terraform"
    "lab-name"        = "dependencies-4.3"
    "created-by"      = "terraform-training"
    "purpose"         = "education"
    "cost-tracking"   = "training-budget"
    "environment"     = "development"
    "auto-shutdown"   = "enabled"
    "backup-required" = "standard"
  }
  
  validation {
    condition = alltrue([
      for tag_key, tag_value in var.global_tags :
      length(tag_key) <= 128 && length(tag_value) <= 256
    ])
    error_message = "Tag keys must be <= 128 characters and values <= 256 characters."
  }
}
