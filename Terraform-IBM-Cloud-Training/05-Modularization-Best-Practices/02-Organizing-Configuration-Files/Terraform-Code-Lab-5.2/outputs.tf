# Terraform Configuration Organization Lab - Output Definitions
# Comprehensive outputs demonstrating enterprise organization patterns

# ============================================================================
# INFRASTRUCTURE OUTPUTS
# ============================================================================

output "infrastructure_summary" {
  description = "Complete infrastructure deployment summary"
  value = {
    deployment_id = time_static.deployment_time.id
    deployment_time = time_static.deployment_time.rfc3339
    
    # Core infrastructure
    vpc = {
      id   = ibm_is_vpc.main.id
      name = ibm_is_vpc.main.name
      crn  = ibm_is_vpc.main.crn
      status = ibm_is_vpc.main.status
      address_prefix_management = ibm_is_vpc.main.address_prefix_management
    }
    
    # Network components
    networking = {
      subnets = {
        for idx, subnet in ibm_is_subnet.subnets : subnet.name => {
          id = subnet.id
          zone = subnet.zone
          cidr = subnet.ipv4_cidr_block
          available_ipv4_address_count = subnet.available_ipv4_address_count
          public_gateway_attached = subnet.public_gateway != null
        }
      }
      
      public_gateways = {
        for zone, gateway in ibm_is_public_gateway.gateway : zone => {
          id = gateway.id
          name = gateway.name
          zone = gateway.zone
        }
      }
      
      security_groups = {
        for idx, sg in ibm_is_security_group.security_groups : sg.name => {
          id = sg.id
          name = sg.name
          rule_count = length(sg.rules)
        }
      }
    }
    
    # Configuration metadata
    configuration = {
      environment = local.current_environment
      region = var.primary_region
      resource_name_base = local.resource_name
      naming_convention = var.naming_convention
      organization = var.organization_config.name
      project = var.organization_config.project_name
    }
  }
}

# ============================================================================
# INTEGRATION ENDPOINTS
# ============================================================================

output "integration_endpoints" {
  description = "Integration points for other modules and configurations"
  value = {
    # VPC integration
    vpc_id = ibm_is_vpc.main.id
    vpc_crn = ibm_is_vpc.main.crn
    
    # Subnet integration
    subnet_ids = [for subnet in ibm_is_subnet.subnets : subnet.id]
    subnet_map = {
      for subnet in ibm_is_subnet.subnets : subnet.zone => {
        id = subnet.id
        cidr = subnet.ipv4_cidr_block
        name = subnet.name
      }
    }
    
    # Security group integration
    security_group_ids = [for sg in ibm_is_security_group.security_groups : sg.id]
    security_group_map = {
      for sg in ibm_is_security_group.security_groups : sg.name => sg.id
    }
    
    # SSH key integration
    ssh_key_id = var.compute_configuration.create_ssh_key ? ibm_is_ssh_key.ssh_key[0].id : null
    ssh_key_name = var.compute_configuration.create_ssh_key ? ibm_is_ssh_key.ssh_key[0].name : null
    
    # Resource group
    resource_group_id = var.resource_group_id
    
    # Regional information
    primary_region = var.primary_region
    availability_zones = [for subnet in local.processed_subnets : subnet.zone]
  }
}

# ============================================================================
# COST TRACKING AND OPTIMIZATION
# ============================================================================

output "cost_analysis" {
  description = "Comprehensive cost analysis and optimization recommendations"
  value = {
    # Cost breakdown
    estimated_monthly_cost = local.estimated_monthly_cost
    total_monthly_cost = local.total_estimated_cost
    
    # Budget analysis
    budget_status = {
      monthly_budget = var.cost_configuration.monthly_budget_limit
      current_estimate = local.total_estimated_cost
      budget_utilization_percent = (local.total_estimated_cost / var.cost_configuration.monthly_budget_limit) * 100
      within_budget = local.cost_within_budget
      remaining_budget = var.cost_configuration.monthly_budget_limit - local.total_estimated_cost
    }
    
    # Cost allocation
    cost_allocation = {
      cost_center = var.cost_configuration.cost_center
      billing_account = var.cost_configuration.billing_account_id
      allocation_tags = var.cost_configuration.cost_allocation_tags
    }
    
    # Optimization recommendations
    optimization_recommendations = [
      local.total_estimated_cost > (var.cost_configuration.monthly_budget_limit * 0.8) ? 
        "Consider optimizing instance profiles or reducing instance count" : null,
      
      !var.cost_configuration.enable_auto_scaling ? 
        "Enable auto-scaling to optimize costs based on demand" : null,
      
      !var.cost_configuration.enable_scheduled_shutdown ? 
        "Consider scheduled shutdown for non-production environments" : null,
      
      length([for vol in var.compute_configuration.data_volumes : vol if !vol.encrypted]) > 0 ? 
        "Enable encryption for all data volumes (may have cost implications)" : null
    ]
    
    # Cost tracking metadata
    cost_tracking = {
      last_calculated = timestamp()
      calculation_method = "estimated"
      currency = "USD"
      region_pricing = var.primary_region
    }
  }
}

# ============================================================================
# SECURITY AND COMPLIANCE
# ============================================================================

output "security_compliance" {
  description = "Security configuration and compliance status"
  value = {
    # Security configuration
    security_settings = {
      compliance_framework = var.security_configuration.compliance_framework
      data_classification = var.security_configuration.data_classification
      encryption_at_rest = var.security_configuration.encryption_at_rest
      encryption_in_transit = var.security_configuration.encryption_in_transit
    }
    
    # Network security
    network_security = {
      vpc_id = ibm_is_vpc.main.id
      security_group_count = length(ibm_is_security_group.security_groups)
      public_gateway_enabled = var.network_configuration.enable_public_gateway
      
      # Security group summary
      security_groups = {
        for sg in ibm_is_security_group.security_groups : sg.name => {
          id = sg.id
          rule_count = length(sg.rules)
        }
      }
    }
    
    # Compliance status
    compliance_status = {
      framework = var.security_configuration.compliance_framework
      data_class = var.security_configuration.data_classification
      
      # Compliance checks
      checks = {
        encryption_enabled = var.security_configuration.encryption_at_rest
        monitoring_enabled = var.security_configuration.enable_security_monitoring
        activity_tracker_enabled = var.security_configuration.enable_activity_tracker
        iam_policies_enabled = var.security_configuration.enable_iam_policies
      }
      
      compliance_score = (
        (var.security_configuration.encryption_at_rest ? 25 : 0) +
        (var.security_configuration.enable_security_monitoring ? 25 : 0) +
        (var.security_configuration.enable_activity_tracker ? 25 : 0) +
        (var.security_configuration.enable_iam_policies ? 25 : 0)
      )
    }
    
    # Security recommendations
    security_recommendations = [
      !var.security_configuration.encryption_at_rest ? 
        "Enable encryption at rest for enhanced security" : null,
      
      !var.security_configuration.enable_security_monitoring ? 
        "Enable security monitoring for threat detection" : null,
      
      !var.security_configuration.enable_activity_tracker ? 
        "Enable Activity Tracker for audit compliance" : null,
      
      var.security_configuration.compliance_framework == "none" ? 
        "Consider implementing a compliance framework" : null
    ]
  }
}

# ============================================================================
# OPERATIONAL INFORMATION
# ============================================================================

output "operational_info" {
  description = "Operational information for management and monitoring"
  value = {
    # Deployment information
    deployment = {
      terraform_version = local.configuration_metadata.terraform_version
      configuration_version = local.configuration_metadata.configuration_version
      deployment_time = time_static.deployment_time.rfc3339
      deployment_id = time_static.deployment_time.id
      last_updated = local.configuration_metadata.last_updated
    }
    
    # Environment information
    environment = {
      name = local.current_environment
      region = var.primary_region
      multi_region_enabled = var.enable_multi_region
      secondary_region = var.enable_multi_region ? var.secondary_region : null
      dr_region = var.enable_multi_region ? var.dr_region : null
    }
    
    # Resource inventory
    resource_inventory = {
      vpc_count = 1
      subnet_count = length(ibm_is_subnet.subnets)
      security_group_count = length(ibm_is_security_group.security_groups)
      public_gateway_count = length(ibm_is_public_gateway.gateway)
      ssh_key_count = var.compute_configuration.create_ssh_key ? 1 : 0
    }
    
    # Naming convention applied
    naming_convention = {
      pattern_used = local.resource_name
      base_name = local.base_name
      unique_suffix = local.unique_suffix
      separator = var.naming_convention.separator
      max_length = var.naming_convention.max_length
    }
    
    # Tags applied
    tagging = {
      standard_tags = local.standard_tags
      tag_count = length(local.standard_tags)
      cost_allocation_tags = var.cost_configuration.cost_allocation_tags
    }
  }
}

# ============================================================================
# DEVELOPMENT AND DEBUGGING
# ============================================================================

output "development_info" {
  description = "Development and debugging information"
  value = {
    # Configuration processing
    processed_configuration = {
      subnets = local.processed_subnets
      security_groups = local.processed_security_groups
      environment_config = local.env_config
      instance_count = local.instance_count
    }
    
    # Validation results
    validation_results = {
      cost_within_budget = local.cost_within_budget
      naming_convention_valid = length(local.resource_name) <= var.naming_convention.max_length
      subnet_count_valid = length(local.processed_subnets) <= 15
    }
    
    # Feature flags status
    feature_flags = var.feature_flags
    
    # SSH key information (for development)
    ssh_key_info = var.compute_configuration.create_ssh_key ? {
      private_key_file = "${path.module}/generated/${local.resource_name}-private-key.pem"
      public_key_fingerprint = ibm_is_ssh_key.ssh_key[0].fingerprint
      key_length = ibm_is_ssh_key.ssh_key[0].length
    } : null
    
    # Debug information
    debug_info = {
      terraform_workspace = terraform.workspace
      module_path = path.module
      configuration_hash = sha256(jsonencode({
        organization = var.organization_config
        network = var.network_configuration
        compute = var.compute_configuration
      }))
    }
  }
  
  # Mark as sensitive to prevent accidental exposure in logs
  sensitive = true
}

# ============================================================================
# QUICK REFERENCE
# ============================================================================

output "quick_reference" {
  description = "Quick reference information for common operations"
  value = {
    # Connection information
    connection = {
      vpc_id = ibm_is_vpc.main.id
      primary_subnet_id = length(ibm_is_subnet.subnets) > 0 ? ibm_is_subnet.subnets[0].id : null
      default_security_group_id = length(ibm_is_security_group.security_groups) > 0 ? ibm_is_security_group.security_groups[0].id : null
      ssh_key_id = var.compute_configuration.create_ssh_key ? ibm_is_ssh_key.ssh_key[0].id : null
    }
    
    # Common commands
    commands = {
      ssh_connect = var.compute_configuration.create_ssh_key ? "ssh -i ${path.module}/generated/${local.resource_name}-private-key.pem root@<instance-ip>" : "SSH key not created - use existing key"
      
      terraform_plan = "terraform plan -var-file=terraform.tfvars"
      terraform_apply = "terraform apply -var-file=terraform.tfvars"
      terraform_destroy = "terraform destroy -var-file=terraform.tfvars"
    }
    
    # Important URLs and references
    references = {
      ibm_cloud_console = "https://cloud.ibm.com/vpc-ext/network/vpcs"
      vpc_console_url = "https://cloud.ibm.com/vpc-ext/network/vpcs/${ibm_is_vpc.main.id}"
      documentation = "https://cloud.ibm.com/docs/vpc"
      terraform_provider = "https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs"
    }
    
    # Next steps
    next_steps = [
      "Deploy compute instances using the created VPC and subnets",
      "Configure load balancers for high availability",
      "Set up monitoring and logging for operational visibility",
      "Implement backup and disaster recovery procedures",
      "Review and optimize cost allocation and budgets"
    ]
  }
}
