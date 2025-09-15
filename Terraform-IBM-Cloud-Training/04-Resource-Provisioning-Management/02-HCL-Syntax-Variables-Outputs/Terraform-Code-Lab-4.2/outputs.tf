# =============================================================================
# TERRAFORM OUTPUTS CONFIGURATION
# Advanced HCL Configuration Lab - Topic 4.2
# Demonstrates sophisticated output patterns and cross-module integration
# =============================================================================

# =============================================================================
# PROJECT AND DEPLOYMENT INFORMATION
# =============================================================================

output "deployment_summary" {
  description = "Comprehensive deployment summary with project metadata and configuration details"
  value = {
    # Project identification
    project = {
      name        = var.project_configuration.project_name
      code        = var.project_configuration.project_code
      description = var.project_configuration.project_description
      owner       = var.project_configuration.project_owner
    }
    
    # Environment information
    environment = {
      name        = var.project_configuration.environment.name
      tier        = var.project_configuration.environment.tier
      purpose     = var.project_configuration.environment.purpose
      criticality = var.project_configuration.environment.criticality
    }
    
    # Deployment metadata
    deployment = {
      timestamp     = time_static.deployment_time.rfc3339
      workspace     = terraform.workspace
      region        = var.primary_region
      resource_suffix = random_string.resource_suffix.result
    }
    
    # Organization context
    organization = {
      name        = var.project_configuration.organization.name
      division    = var.project_configuration.organization.division
      cost_center = var.project_configuration.organization.cost_center
    }
  }
}

# =============================================================================
# CONFIGURATION AND FEATURE STATUS
# =============================================================================

output "configuration_status" {
  description = "Current configuration status and feature enablement summary"
  value = {
    # Feature flags status
    features_enabled = {
      multi_region      = var.feature_flags.enable_multi_region
      disaster_recovery = var.feature_flags.enable_disaster_recovery
      auto_scaling      = var.feature_flags.enable_auto_scaling
      monitoring        = var.feature_flags.enable_monitoring
      backup           = var.feature_flags.enable_backup
      advanced_features = var.feature_flags.enable_advanced_features
      cost_optimization = var.feature_flags.enable_cost_optimization
      security_scanning = var.feature_flags.enable_security_scanning
      compliance_checks = var.feature_flags.enable_compliance_checks
      debug_mode       = var.feature_flags.enable_debug_mode
    }
    
    # Configuration validation
    validation_status = {
      provider_validation = var.feature_flags.enable_provider_validation
      resource_validation = var.feature_flags.enable_resource_validation
      output_validation   = var.feature_flags.enable_output_validation
      
      # Configuration hashes for change detection
      project_hash        = md5(jsonencode(var.project_configuration))
      infrastructure_hash = md5(jsonencode(var.infrastructure_configuration))
      feature_hash        = md5(jsonencode(var.feature_flags))
    }
    
    # Environment-specific settings
    environment_config = {
      is_production  = local.environment_config.is_production
      is_development = local.environment_config.is_development
      instance_count = local.environment_config.instance_count
      backup_enabled = local.environment_config.backup_enabled
      monitoring_level = local.environment_config.monitoring_level
    }
  }
}

# =============================================================================
# NETWORK CONFIGURATION OUTPUTS
# =============================================================================

output "network_configuration" {
  description = "Network configuration details for cross-module integration"
  value = {
    # VPC configuration
    vpc = {
      name = local.naming_convention.vpc
      cidr = local.network_design.vpc_cidr
    }
    
    # Subnet configuration
    subnets = {
      public = {
        cidrs = local.network_design.public_subnets
        count = length(local.network_design.public_subnets)
        names = [
          for i, cidr in local.network_design.public_subnets :
          "${local.naming_convention.subnet_prefix}-public-${i + 1}"
        ]
      }
      private = {
        cidrs = local.network_design.private_subnets
        count = length(local.network_design.private_subnets)
        names = [
          for i, cidr in local.network_design.private_subnets :
          "${local.naming_convention.subnet_prefix}-private-${i + 1}"
        ]
      }
    }
    
    # Availability zones
    availability_zones = {
      primary_region = var.primary_region
      zones         = local.network_design.availability_zones
      zone_count    = length(local.network_design.availability_zones)
    }
    
    # DNS configuration
    dns = var.infrastructure_configuration.network.dns_configuration
    
    # Network features
    features = {
      flow_logs_enabled   = var.infrastructure_configuration.network.enable_flow_logs
      nat_gateway_enabled = var.infrastructure_configuration.network.enable_nat_gateway
    }
  }
}

# =============================================================================
# COMPUTE CONFIGURATION OUTPUTS
# =============================================================================

output "compute_configuration" {
  description = "Compute configuration and optimization details"
  value = {
    # Instance type configuration
    instance_types = {
      web_tier = {
        profile         = local.optimization_config.optimized_instance_types.web
        min_instances   = var.infrastructure_configuration.compute.instance_types.web_tier.min_instances
        max_instances   = var.infrastructure_configuration.compute.instance_types.web_tier.max_instances
        desired_instances = var.infrastructure_configuration.compute.instance_types.web_tier.desired_instances
      }
      app_tier = {
        profile         = local.optimization_config.optimized_instance_types.app
        min_instances   = var.infrastructure_configuration.compute.instance_types.app_tier.min_instances
        max_instances   = var.infrastructure_configuration.compute.instance_types.app_tier.max_instances
        desired_instances = var.infrastructure_configuration.compute.instance_types.app_tier.desired_instances
      }
      data_tier = {
        profile         = local.optimization_config.optimized_instance_types.data
        min_instances   = var.infrastructure_configuration.compute.instance_types.data_tier.min_instances
        max_instances   = var.infrastructure_configuration.compute.instance_types.data_tier.max_instances
        desired_instances = var.infrastructure_configuration.compute.instance_types.data_tier.desired_instances
      }
    }
    
    # Auto-scaling configuration
    auto_scaling = var.infrastructure_configuration.compute.auto_scaling
    
    # Performance optimization
    performance_optimization = var.advanced_configuration.performance
    
    # Naming conventions
    naming = {
      instance_prefix = local.naming_convention.instance_prefix
      volume_prefix   = local.naming_convention.volume_prefix
    }
  }
}

# =============================================================================
# STORAGE CONFIGURATION OUTPUTS
# =============================================================================

output "storage_configuration" {
  description = "Storage configuration and optimization settings"
  value = {
    # Volume configuration
    volumes = {
      root_volume = {
        size_gb     = var.infrastructure_configuration.storage.volume_types.root_volume.size_gb
        volume_type = local.optimization_config.storage_optimization.root_volume_type
        encrypted   = var.infrastructure_configuration.storage.volume_types.root_volume.encrypted
      }
      data_volume = {
        size_gb     = var.infrastructure_configuration.storage.volume_types.data_volume.size_gb
        volume_type = local.optimization_config.storage_optimization.data_volume_type
        encrypted   = var.infrastructure_configuration.storage.volume_types.data_volume.encrypted
      }
    }
    
    # Backup configuration
    backup = local.feature_configurations.backup
    
    # Storage optimization
    optimization = {
      cost_optimized = var.feature_flags.enable_cost_optimization
      performance_mode = var.advanced_configuration.performance.enable_performance_mode
      storage_optimization = var.advanced_configuration.performance.storage_optimization
    }
  }
}

# =============================================================================
# SECURITY CONFIGURATION OUTPUTS
# =============================================================================

output "security_configuration" {
  description = "Security configuration and compliance settings"
  value = {
    # Encryption settings
    encryption = local.security_config.encryption
    
    # Access control
    access_control = local.security_config.access_control
    
    # Compliance requirements
    compliance = {
      frameworks = var.project_configuration.compliance.frameworks
      data_classification = var.project_configuration.compliance.data_classification
      retention_period = var.project_configuration.compliance.retention_period
      audit_required = var.project_configuration.compliance.audit_required
      
      # Compliance validation results
      requirements = local.security_config.compliance_requirements
    }
    
    # Security features
    security_features = {
      security_scanning_enabled = var.feature_flags.enable_security_scanning
      compliance_checks_enabled = var.feature_flags.enable_compliance_checks
      advanced_security = var.feature_flags.enable_advanced_features
    }
  }
}

# =============================================================================
# MONITORING AND OPERATIONS OUTPUTS
# =============================================================================

output "monitoring_configuration" {
  description = "Monitoring, alerting, and operational configuration"
  value = {
    enabled = var.feature_flags.enable_monitoring
    monitoring_settings = var.feature_flags.enable_monitoring ? local.feature_configurations.monitoring : {}
    infrastructure_monitoring = var.infrastructure_configuration.monitoring
    operations = var.advanced_configuration.operations
    alerting = {
      enabled = var.infrastructure_configuration.monitoring.alerting.enabled
      thresholds = var.infrastructure_configuration.monitoring.alerting.alert_thresholds
      notification_channels = var.infrastructure_configuration.monitoring.alerting.notification_channels
    }
  }
}

# =============================================================================
# COST ANALYSIS AND OPTIMIZATION OUTPUTS
# =============================================================================

output "cost_analysis" {
  description = "Cost analysis, optimization recommendations, and budget information"
  value = {
    # Estimated costs
    estimated_monthly_costs = local.optimization_config.estimated_monthly_cost
    
    # Total estimated cost
    total_estimated_monthly_cost = (
      local.optimization_config.estimated_monthly_cost.compute +
      local.optimization_config.estimated_monthly_cost.storage +
      local.optimization_config.estimated_monthly_cost.network +
      local.optimization_config.estimated_monthly_cost.monitoring +
      local.optimization_config.estimated_monthly_cost.backup
    )
    
    # Cost optimization settings
    cost_optimization = var.advanced_configuration.cost_optimization
    
    # Optimization recommendations
    recommendations = {
      cost_optimization_enabled = var.feature_flags.enable_cost_optimization
      environment_optimized = !local.environment_config.is_production
      
      # Specific recommendations
      suggestions = [
        var.feature_flags.enable_cost_optimization ? 
          "Cost optimization is enabled - instance types optimized for non-production" : 
          "Enable cost optimization for potential savings",
        
        var.advanced_configuration.cost_optimization.resource_scheduling.enable_scheduling ? 
          "Resource scheduling is enabled - instances will start/stop automatically" : 
          "Consider enabling resource scheduling for development environments",
        
        var.advanced_configuration.cost_optimization.rightsizing.enable_rightsizing ? 
          "Rightsizing analysis is enabled - monitor recommendations" : 
          "Enable rightsizing analysis to optimize instance sizes",
        
        local.environment_config.is_production ? 
          "Production environment - consider reserved instances for long-term savings" : 
          "Development environment - on-demand pricing is appropriate"
      ]
    }
  }
}

# =============================================================================
# RESOURCE NAMING AND TAGGING OUTPUTS
# =============================================================================

output "resource_metadata" {
  description = "Resource naming conventions, tagging strategy, and metadata"
  value = {
    # Naming conventions
    naming_convention = local.naming_convention
    
    # Tagging strategy
    tagging = {
      common_tags = local.common_tags
      tag_count = length(local.common_tags)
      
      # Tag categories
      tag_categories = {
        project_tags = [
          for key, value in local.common_tags :
          key if startswith(key, "project:")
        ]
        environment_tags = [
          for key, value in local.common_tags :
          key if startswith(key, "environment:")
        ]
        organization_tags = [
          for key, value in local.common_tags :
          key if startswith(key, "org:")
        ]
        compliance_tags = [
          for key, value in local.common_tags :
          key if startswith(key, "compliance:")
        ]
      }
    }
    
    # Resource identification
    resource_identification = {
      project_prefix = local.project_prefix
      resource_suffix = random_string.resource_suffix.result
      unique_identifier = "${local.project_prefix}-${random_string.resource_suffix.result}"
    }
  }
}

# =============================================================================
# VALIDATION AND DEBUG OUTPUTS
# =============================================================================

output "validation_results" {
  description = "Configuration validation results and debug information"
  value = {
    debug_mode_enabled = var.feature_flags.enable_debug_mode

    # Validation status
    validation_enabled = {
      provider_validation = var.feature_flags.enable_provider_validation
      resource_validation = var.feature_flags.enable_resource_validation
      output_validation = var.feature_flags.enable_output_validation
    }

    # Configuration analysis (only when debug mode is enabled)
    configuration_analysis = var.feature_flags.enable_debug_mode ? {
      total_variables = 6  # Approximate count
      complex_variables = 3  # project_configuration, infrastructure_configuration, advanced_configuration
      feature_flags_count = length(var.feature_flags)

      # Complexity metrics
      complexity_score = {
        variable_complexity = "high"
        validation_rules = "comprehensive"
        conditional_logic = "advanced"
        output_structure = "sophisticated"
      }
    } : {
      total_variables = 0
      complex_variables = 0
      feature_flags_count = 0
      complexity_score = {
        variable_complexity = "unknown"
        validation_rules = "unknown"
        conditional_logic = "unknown"
        output_structure = "unknown"
      }
    }

    # Debug information (only when debug mode is enabled)
    debug_info = var.feature_flags.enable_debug_mode ? {
      terraform_workspace = terraform.workspace
      deployment_timestamp = time_static.deployment_time.rfc3339
      random_suffix = random_string.resource_suffix.result

      # Generated files (if debug mode enabled)
      generated_files = [
        "generated_config.json",
        "generated_terraform.tfvars.template"
      ]
    } : {
      terraform_workspace = "unknown"
      deployment_timestamp = "unknown"
      random_suffix = "unknown"
      generated_files = []
    }
  }
}

# =============================================================================
# INTEGRATION AND NEXT STEPS OUTPUTS
# =============================================================================

output "integration_guidance" {
  description = "Integration guidance and next steps for using this configuration"
  value = {
    # Module integration
    module_integration = {
      network_outputs = "Use network_configuration output for VPC module integration"
      compute_outputs = "Use compute_configuration output for instance module integration"
      storage_outputs = "Use storage_configuration output for volume module integration"
      security_outputs = "Use security_configuration output for security module integration"
    }
    
    # Next steps
    next_steps = [
      "Review the deployment_summary output for project overview",
      "Use network_configuration output to create VPC and subnets",
      "Apply compute_configuration for instance provisioning",
      "Implement security_configuration for compliance requirements",
      "Monitor cost_analysis output for budget management",
      var.feature_flags.enable_monitoring ? 
        "Configure monitoring using monitoring_configuration output" : 
        "Consider enabling monitoring for production deployments",
      var.feature_flags.enable_backup ? 
        "Backup is configured - review storage_configuration output" : 
        "Consider enabling backup for data protection"
    ]
    
    # Best practices
    best_practices = [
      "Regularly review cost_analysis output for optimization opportunities",
      "Monitor security_configuration for compliance adherence",
      "Use validation_results output for configuration debugging",
      "Implement proper tagging using resource_metadata output",
      "Follow naming conventions from resource_metadata output"
    ]
  }
}

# =============================================================================
# SENSITIVE OUTPUTS
# =============================================================================

output "sensitive_information" {
  description = "Sensitive configuration data (marked as sensitive)"
  sensitive = true
  value = {
    # Configuration hashes for change detection
    configuration_hashes = {
      project_hash = md5(jsonencode(var.project_configuration))
      infrastructure_hash = md5(jsonencode(var.infrastructure_configuration))
      feature_hash = md5(jsonencode(var.feature_flags))
      advanced_hash = md5(jsonencode(var.advanced_configuration))
    }
    
    # Debug password (if generated)
    debug_password = var.feature_flags.enable_debug_mode && length(random_password.demo_password) > 0 ? random_password.demo_password[0].result : null
    
    # Secret rotation information
    secret_rotation = var.feature_flags.enable_security_scanning && length(time_rotating.secret_rotation) > 0 ? {
      next_rotation = time_rotating.secret_rotation[0].rotation_rfc3339
      rotation_days = 90
    } : null
  }
}
