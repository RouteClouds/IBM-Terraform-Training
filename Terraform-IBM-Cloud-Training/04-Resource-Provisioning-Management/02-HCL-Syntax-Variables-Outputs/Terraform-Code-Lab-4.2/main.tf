# =============================================================================
# MAIN TERRAFORM CONFIGURATION
# Advanced HCL Configuration Lab - Topic 4.2
# Demonstrates sophisticated HCL patterns, variable usage, and output strategies
# =============================================================================

# =============================================================================
# LOCAL VALUES AND COMPUTED EXPRESSIONS
# =============================================================================

locals {
  # Project naming and identification
  project_prefix = "${var.project_configuration.project_name}-${var.project_configuration.environment.name}"
  
  # Resource naming conventions
  naming_convention = {
    vpc              = "${local.project_prefix}-vpc"
    subnet_prefix    = "${local.project_prefix}-subnet"
    security_group   = "${local.project_prefix}-sg"
    instance_prefix  = "${local.project_prefix}-instance"
    volume_prefix    = "${local.project_prefix}-volume"
    load_balancer    = "${local.project_prefix}-lb"
  }
  
  # Environment-specific configurations
  environment_config = {
    is_production = var.project_configuration.environment.name == "production"
    is_development = var.project_configuration.environment.name == "development"
    
    # Conditional resource sizing based on environment
    instance_count = var.project_configuration.environment.name == "production" ? 3 : 1
    backup_enabled = var.project_configuration.environment.name == "production" ? true : var.feature_flags.enable_backup
    monitoring_level = var.project_configuration.environment.name == "production" ? "comprehensive" : "basic"
  }
  
  # Advanced CIDR calculations
  network_design = {
    vpc_cidr = var.infrastructure_configuration.network.vpc_cidr_blocks[0]
    
    # Calculate subnet CIDRs dynamically
    public_subnets = [
      for i, cidr in var.infrastructure_configuration.network.subnet_configuration.public_subnets :
      cidr
    ]
    
    private_subnets = [
      for i, cidr in var.infrastructure_configuration.network.subnet_configuration.private_subnets :
      cidr
    ]
    
    # Calculate available zones
    availability_zones = [
      "${var.primary_region}-1",
      "${var.primary_region}-2",
      "${var.primary_region}-3"
    ]
  }
  
  # Comprehensive tagging strategy
  common_tags = merge(
    var.global_tags,
    {
      # Project tags
      "project:name"        = var.project_configuration.project_name
      "project:code"        = var.project_configuration.project_code
      "project:owner"       = var.project_configuration.project_owner
      
      # Environment tags
      "environment:name"    = var.project_configuration.environment.name
      "environment:tier"    = var.project_configuration.environment.tier
      "environment:purpose" = var.project_configuration.environment.purpose
      
      # Organization tags
      "org:name"           = var.project_configuration.organization.name
      "org:division"       = var.project_configuration.organization.division
      "org:cost-center"    = var.project_configuration.organization.cost_center
      
      # Compliance tags
      "compliance:frameworks" = join(",", var.project_configuration.compliance.frameworks)
      "compliance:classification" = var.project_configuration.compliance.data_classification
      
      # Operational tags
      "terraform:workspace" = terraform.workspace
      "terraform:lab"      = "4.2-hcl-advanced"
      "deployment:timestamp" = timestamp()
    }
  )
  
  # Feature-based configurations
  feature_configurations = {
    # Multi-region setup
    multi_region = var.feature_flags.enable_multi_region ? {
      primary_region   = var.primary_region
      secondary_region = var.secondary_region
      dr_region       = var.disaster_recovery_region
    } : {
      primary_region = var.primary_region
    }
    
    # Monitoring configuration
    monitoring = var.feature_flags.enable_monitoring ? {
      enabled = true
      level   = local.environment_config.monitoring_level
      
      # Dynamic alert configuration
      alerts = {
        for metric, threshold in var.infrastructure_configuration.monitoring.alerting.alert_thresholds :
        metric => {
          threshold = threshold
          enabled   = var.infrastructure_configuration.monitoring.alerting.enabled
        }
      }
    } : {
      enabled = false
    }
    
    # Backup configuration
    backup = var.feature_flags.enable_backup ? {
      enabled = true
      retention = var.infrastructure_configuration.storage.backup_configuration.retention_days
      schedule = var.infrastructure_configuration.storage.backup_configuration.backup_schedule
      cross_region = var.infrastructure_configuration.storage.backup_configuration.cross_region_copy
    } : {
      enabled = false
    }
  }
  
  # Performance and cost optimization
  optimization_config = {
    # Instance type optimization based on environment and features
    optimized_instance_types = {
      web = var.feature_flags.enable_cost_optimization && !local.environment_config.is_production ? "bx2-2x8" : var.infrastructure_configuration.compute.instance_types.web_tier.instance_profile

      app = var.feature_flags.enable_cost_optimization && !local.environment_config.is_production ? "bx2-2x8" : var.infrastructure_configuration.compute.instance_types.app_tier.instance_profile

      data = var.infrastructure_configuration.compute.instance_types.data_tier.instance_profile
    }
    
    # Storage optimization
    storage_optimization = {
      root_volume_type = var.feature_flags.enable_cost_optimization && !local.environment_config.is_production ? "general-purpose" : var.infrastructure_configuration.storage.volume_types.root_volume.volume_type

      data_volume_type = var.infrastructure_configuration.storage.volume_types.data_volume.volume_type
    }
    
    # Cost estimation (simplified)
    estimated_monthly_cost = {
      compute = local.environment_config.instance_count * 150  # Estimated per instance
      storage = var.infrastructure_configuration.storage.volume_types.root_volume.size_gb * 0.10 + var.infrastructure_configuration.storage.volume_types.data_volume.size_gb * 0.15
      network = var.feature_flags.enable_multi_region ? 50 : 25
      monitoring = var.feature_flags.enable_monitoring ? 30 : 0
      backup = var.feature_flags.enable_backup ? 20 : 0
    }
  }
  
  # Security configuration
  security_config = {
    # Encryption settings
    encryption = {
      at_rest = var.infrastructure_configuration.security.encryption.at_rest_enabled
      in_transit = var.infrastructure_configuration.security.encryption.in_transit_enabled
      key_management = var.infrastructure_configuration.security.encryption.key_management
    }
    
    # Access control
    access_control = {
      iam_enabled = var.infrastructure_configuration.security.access_control.enable_iam_roles
      mfa_enabled = var.infrastructure_configuration.security.access_control.enable_mfa
      session_timeout = var.infrastructure_configuration.security.access_control.session_timeout
    }
    
    # Compliance requirements
    compliance_requirements = {
      for framework in var.project_configuration.compliance.frameworks :
      framework => {
        required = true
        audit_logging = contains(["sox", "hipaa", "pci-dss"], framework)
        encryption_required = contains(["hipaa", "pci-dss"], framework)
        access_logging = true
      }
    }
  }
}

# =============================================================================
# DATA SOURCES
# =============================================================================

# Get available zones in the primary region
data "ibm_is_zones" "primary_zones" {
  region = var.primary_region
}

# Get resource group information
data "ibm_resource_group" "project_rg" {
  name = "default"  # This would typically be dynamic based on var.resource_group_id
}

# Get latest Ubuntu image
data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-20-04-3-minimal-amd64-2"
}

# Get SSH key (if exists)
data "ibm_is_ssh_keys" "available_keys" {}

# =============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# =============================================================================

# Generate random suffix for unique resource naming
resource "random_string" "resource_suffix" {
  length  = 8
  special = false
  upper   = false
  
  keepers = {
    project_name = var.project_configuration.project_name
    environment  = var.project_configuration.environment.name
  }
}

# Generate random password for demonstration
resource "random_password" "demo_password" {
  count = var.feature_flags.enable_debug_mode ? 1 : 0
  
  length  = var.infrastructure_configuration.security.access_control.password_policy.min_length
  special = var.infrastructure_configuration.security.access_control.password_policy.require_symbols
  numeric = var.infrastructure_configuration.security.access_control.password_policy.require_numbers
  upper   = var.infrastructure_configuration.security.access_control.password_policy.require_uppercase
  lower   = var.infrastructure_configuration.security.access_control.password_policy.require_lowercase
}

# =============================================================================
# TIME-BASED RESOURCES
# =============================================================================

# Deployment timestamp
resource "time_static" "deployment_time" {
  triggers = {
    project_config = md5(jsonencode(var.project_configuration))
    infrastructure_config = md5(jsonencode(var.infrastructure_configuration))
  }
}

# Rotation schedule for secrets (if enabled)
resource "time_rotating" "secret_rotation" {
  count = var.feature_flags.enable_security_scanning ? 1 : 0
  
  rotation_days = 90
  
  triggers = {
    environment = var.project_configuration.environment.name
  }
}

# =============================================================================
# LOCAL FILE RESOURCES FOR CONFIGURATION
# =============================================================================

# Generate configuration file for the deployment
resource "local_file" "deployment_config" {
  count = var.feature_flags.enable_debug_mode ? 1 : 0
  
  filename = "${path.module}/generated_config.json"
  
  content = jsonencode({
    deployment = {
      timestamp = time_static.deployment_time.rfc3339
      project   = var.project_configuration.project_name
      environment = var.project_configuration.environment.name
      region    = var.primary_region
    }
    
    configuration = {
      naming_convention = local.naming_convention
      network_design   = local.network_design
      optimization     = local.optimization_config
      security        = local.security_config
    }
    
    features = var.feature_flags
    
    estimated_costs = local.optimization_config.estimated_monthly_cost
  })
  
  file_permission = "0644"
}

# Generate terraform.tfvars template
resource "local_file" "tfvars_template" {
  count = var.feature_flags.enable_debug_mode ? 1 : 0
  
  filename = "${path.module}/generated_terraform.tfvars.template"
  
  content = templatefile("${path.module}/templates/terraform.tfvars.simple.tpl", {
    project_name = var.project_configuration.project_name
    environment  = var.project_configuration.environment.name
    region      = var.primary_region
    
    # Dynamic values
    vpc_cidr = local.network_design.vpc_cidr
    public_subnets = local.network_design.public_subnets
    private_subnets = local.network_design.private_subnets
    
    # Feature flags
    enable_monitoring = var.feature_flags.enable_monitoring
    enable_backup    = var.feature_flags.enable_backup
  })
  
  file_permission = "0644"
}

# =============================================================================
# NULL RESOURCES FOR VALIDATION AND PROVISIONING
# =============================================================================

# Validate configuration consistency
resource "null_resource" "configuration_validation" {
  count = var.feature_flags.enable_resource_validation ? 1 : 0
  
  triggers = {
    project_hash = md5(jsonencode(var.project_configuration))
    infrastructure_hash = md5(jsonencode(var.infrastructure_configuration))
    feature_hash = md5(jsonencode(var.feature_flags))
    validation_timestamp = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Configuration Validation"
      echo "======================="
      echo "Project: ${var.project_configuration.project_name}"
      echo "Environment: ${var.project_configuration.environment.name}"
      echo "Region: ${var.primary_region}"
      echo "Instance Count: ${local.environment_config.instance_count}"
      echo "Monitoring: ${var.feature_flags.enable_monitoring}"
      echo "Backup: ${var.feature_flags.enable_backup}"
      echo "Multi-region: ${var.feature_flags.enable_multi_region}"
      echo ""
      echo "Estimated Monthly Cost: $${local.optimization_config.estimated_monthly_cost.compute + local.optimization_config.estimated_monthly_cost.storage + local.optimization_config.estimated_monthly_cost.network + local.optimization_config.estimated_monthly_cost.monitoring + local.optimization_config.estimated_monthly_cost.backup}"
      echo ""
      echo "Validation completed successfully at $(date)"
    EOT
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Performance benchmarking
resource "null_resource" "performance_benchmark" {
  count = var.feature_flags.enable_performance_tuning ? 1 : 0
  
  triggers = {
    performance_config = jsonencode(var.advanced_configuration.performance)
    benchmark_timestamp = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Performance Benchmark"
      echo "===================="
      echo "CPU Optimization: ${var.advanced_configuration.performance.cpu_optimization}"
      echo "Memory Optimization: ${var.advanced_configuration.performance.memory_optimization}"
      echo "Network Optimization: ${var.advanced_configuration.performance.network_optimization}"
      echo "Storage Optimization: ${var.advanced_configuration.performance.storage_optimization}"
      echo ""
      echo "Performance mode: ${var.advanced_configuration.performance.enable_performance_mode ? "enabled" : "disabled"}"
      echo "Benchmark completed at $(date)"
    EOT
  }
}

# Cost optimization analysis
resource "null_resource" "cost_analysis" {
  count = var.feature_flags.enable_cost_optimization ? 1 : 0
  
  triggers = {
    cost_config = jsonencode(var.advanced_configuration.cost_optimization)
    optimization_config = jsonencode(local.optimization_config)
    analysis_timestamp = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Cost Optimization Analysis"
      echo "========================="
      echo "Cost controls enabled: ${var.advanced_configuration.cost_optimization.enable_cost_controls}"
      echo "Budget alerts: ${var.advanced_configuration.cost_optimization.budget_alerts}"
      echo "Resource scheduling: ${var.advanced_configuration.cost_optimization.resource_scheduling.enable_scheduling}"
      echo "Rightsizing enabled: ${var.advanced_configuration.cost_optimization.rightsizing.enable_rightsizing}"
      echo ""
      echo "Estimated monthly costs:"
      echo "  Compute: $${local.optimization_config.estimated_monthly_cost.compute}"
      echo "  Storage: $${local.optimization_config.estimated_monthly_cost.storage}"
      echo "  Network: $${local.optimization_config.estimated_monthly_cost.network}"
      echo "  Monitoring: $${local.optimization_config.estimated_monthly_cost.monitoring}"
      echo "  Backup: $${local.optimization_config.estimated_monthly_cost.backup}"
      echo "  Total: $${local.optimization_config.estimated_monthly_cost.compute + local.optimization_config.estimated_monthly_cost.storage + local.optimization_config.estimated_monthly_cost.network + local.optimization_config.estimated_monthly_cost.monitoring + local.optimization_config.estimated_monthly_cost.backup}"
      echo ""
      echo "Analysis completed at $(date)"
    EOT
  }
}

# Compliance validation
resource "null_resource" "compliance_validation" {
  count = var.feature_flags.enable_compliance_checks ? 1 : 0
  
  triggers = {
    compliance_config = jsonencode(var.project_configuration.compliance)
    security_config = jsonencode(local.security_config)
    validation_timestamp = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Compliance Validation"
      echo "===================="
      echo "Frameworks: ${join(", ", var.project_configuration.compliance.frameworks)}"
      echo "Data classification: ${var.project_configuration.compliance.data_classification}"
      echo "Audit required: ${var.project_configuration.compliance.audit_required}"
      echo "Retention period: ${var.project_configuration.compliance.retention_period} days"
      echo ""
      echo "Security configuration:"
      echo "  Encryption at rest: ${local.security_config.encryption.at_rest}"
      echo "  Encryption in transit: ${local.security_config.encryption.in_transit}"
      echo "  Key management: ${local.security_config.encryption.key_management}"
      echo "  IAM enabled: ${local.security_config.access_control.iam_enabled}"
      echo "  MFA enabled: ${local.security_config.access_control.mfa_enabled}"
      echo ""
      echo "Compliance validation completed at $(date)"
    EOT
  }
}
