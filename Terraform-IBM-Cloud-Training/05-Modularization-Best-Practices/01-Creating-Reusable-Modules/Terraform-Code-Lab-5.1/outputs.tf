# =============================================================================
# TERRAFORM OUTPUTS CONFIGURATION
# =============================================================================
# Terraform Code Lab 5.1: Creating Reusable Modules
# This file demonstrates comprehensive output design patterns for enterprise
# module development with IBM Cloud services.

# =============================================================================
# VPC INFRASTRUCTURE OUTPUTS
# =============================================================================

output "vpc_infrastructure" {
  description = "Complete VPC infrastructure information for integration and monitoring"
  value = {
    # Core VPC information
    vpc = {
      id                     = ibm_is_vpc.main.id
      name                   = ibm_is_vpc.main.name
      crn                    = ibm_is_vpc.main.crn
      status                 = ibm_is_vpc.main.status
      resource_group_id      = ibm_is_vpc.main.resource_group
      classic_access         = ibm_is_vpc.main.classic_access
      default_network_acl    = ibm_is_vpc.main.default_network_acl
      default_security_group = ibm_is_vpc.main.default_security_group
      default_routing_table  = ibm_is_vpc.main.default_routing_table
      
      # Address prefix information
      address_prefix_management = ibm_is_vpc.main.address_prefix_management
      address_prefixes          = ibm_is_vpc.main.address_prefixes
      
      # Creation metadata
      created_at = ibm_is_vpc.main.created_at
      href       = ibm_is_vpc.main.href
    }
    
    # Subnet information with detailed attributes
    subnets = {
      for subnet in ibm_is_subnet.main : subnet.name => {
        id                     = subnet.id
        name                   = subnet.name
        zone                   = subnet.zone
        cidr                   = subnet.ipv4_cidr_block
        available_ipv4_count   = subnet.available_ipv4_count
        total_ipv4_count       = subnet.total_ipv4_count
        public_gateway_enabled = subnet.public_gateway != null
        public_gateway_id      = subnet.public_gateway
        network_acl_id         = subnet.network_acl
        routing_table_id       = subnet.routing_table
        resource_group_id      = subnet.resource_group
        status                 = subnet.status
        created_at            = subnet.created_at
        href                  = subnet.href
      }
    }
    
    # Public gateway information
    public_gateways = {
      for gateway in ibm_is_public_gateway.main : gateway.name => {
        id                = gateway.id
        name              = gateway.name
        zone              = gateway.zone
        vpc_id            = gateway.vpc
        resource_group_id = gateway.resource_group
        status            = gateway.status
        created_at        = gateway.created_at
        href              = gateway.href
      }
    }
    
    # Security group information
    security_groups = {
      # Default security group
      default = {
        id    = ibm_is_vpc.main.default_security_group
        name  = "${ibm_is_vpc.main.name}-default-sg"
        type  = "default"
      }
      
      # Custom security groups
      custom = {
        for sg in ibm_is_security_group.custom : sg.name => {
          id                = sg.id
          name              = sg.name
          vpc_id            = sg.vpc
          resource_group_id = sg.resource_group
          rules             = sg.rules
          created_at        = sg.created_at
          href              = sg.href
        }
      }
      
      # Compute security group
      compute = var.compute_configuration.instance_count > 0 ? {
        id                = ibm_is_security_group.compute[0].id
        name              = ibm_is_security_group.compute[0].name
        vpc_id            = ibm_is_security_group.compute[0].vpc
        resource_group_id = ibm_is_security_group.compute[0].resource_group
        rules             = ibm_is_security_group.compute[0].rules
        created_at        = ibm_is_security_group.compute[0].created_at
        href              = ibm_is_security_group.compute[0].href
      } : null
    }
  }
  
  sensitive = false
}

# =============================================================================
# COMPUTE INFRASTRUCTURE OUTPUTS
# =============================================================================

output "compute_infrastructure" {
  description = "Complete compute infrastructure information for integration and monitoring"
  value = var.compute_configuration.instance_count > 0 ? {
    # Instance information
    instances = {
      for instance in ibm_is_instance.compute : instance.name => {
        id                = instance.id
        name              = instance.name
        profile           = instance.profile
        image_id          = instance.image
        vpc_id            = instance.vpc
        zone              = instance.zone
        resource_group_id = instance.resource_group
        status            = instance.status
        
        # Network interface information
        primary_network_interface = {
          id                = instance.primary_network_interface[0].id
          name              = instance.primary_network_interface[0].name
          subnet_id         = instance.primary_network_interface[0].subnet
          security_groups   = instance.primary_network_interface[0].security_groups
          primary_ipv4_address = instance.primary_network_interface[0].primary_ipv4_address
        }
        
        # Boot volume information
        boot_volume = {
          id         = instance.boot_volume[0].id
          name       = instance.boot_volume[0].name
          size       = instance.boot_volume[0].size
          profile    = instance.boot_volume[0].profile
          encryption = instance.boot_volume[0].encryption
        }
        
        # SSH key information
        keys = instance.keys
        
        # Metadata
        created_at = instance.created_at
        href       = instance.href
        crn        = instance.crn
      }
    }
    
    # SSH key information
    ssh_key = var.compute_configuration.ssh_key_name != null ? {
      id   = data.ibm_is_ssh_key.lab_key[0].id
      name = data.ibm_is_ssh_key.lab_key[0].name
      type = "existing"
    } : {
      id   = ibm_is_ssh_key.lab_ssh_key[0].id
      name = ibm_is_ssh_key.lab_ssh_key[0].name
      type = "generated"
    }
    
    # Instance summary
    summary = {
      total_instances = length(ibm_is_instance.compute)
      instance_profile = var.compute_configuration.instance_profile
      base_image_name = var.compute_configuration.base_image_name
      zones_used = distinct([for instance in ibm_is_instance.compute : instance.zone])
    }
  } : null
  
  sensitive = false
}

# =============================================================================
# INTEGRATION ENDPOINTS AND CONNECTION INFORMATION
# =============================================================================

output "integration_endpoints" {
  description = "Integration endpoints and connection information for other modules"
  value = {
    # VPC integration points
    vpc = {
      id                     = ibm_is_vpc.main.id
      name                   = ibm_is_vpc.main.name
      default_security_group = ibm_is_vpc.main.default_security_group
      default_network_acl    = ibm_is_vpc.main.default_network_acl
      default_routing_table  = ibm_is_vpc.main.default_routing_table
    }
    
    # Subnet integration points
    subnets = {
      ids = [for subnet in ibm_is_subnet.main : subnet.id]
      names = [for subnet in ibm_is_subnet.main : subnet.name]
      zones = [for subnet in ibm_is_subnet.main : subnet.zone]
      cidrs = [for subnet in ibm_is_subnet.main : subnet.ipv4_cidr_block]
      
      # Zone-to-subnet mapping
      by_zone = {
        for subnet in ibm_is_subnet.main : subnet.zone => {
          id   = subnet.id
          name = subnet.name
          cidr = subnet.ipv4_cidr_block
        }
      }
    }
    
    # Security group integration points
    security_groups = {
      default_id = ibm_is_vpc.main.default_security_group
      custom_ids = [for sg in ibm_is_security_group.custom : sg.id]
      compute_id = var.compute_configuration.instance_count > 0 ? ibm_is_security_group.compute[0].id : null
    }
    
    # Public gateway integration points
    public_gateways = {
      ids = [for gateway in ibm_is_public_gateway.main : gateway.id]
      zones = [for gateway in ibm_is_public_gateway.main : gateway.zone]
      
      # Zone-to-gateway mapping
      by_zone = {
        for gateway in ibm_is_public_gateway.main : gateway.zone => gateway.id
      }
    }
    
    # API endpoints
    endpoints = {
      vpc_api = "https://vpc.${var.primary_region}.cloud.ibm.com/v1"
      is_api  = "https://vpc.${var.primary_region}.cloud.ibm.com/v1"
      iam_api = "https://iam.cloud.ibm.com/v1"
      
      # Resource-specific endpoints
      vpc_endpoint = "https://vpc.${var.primary_region}.cloud.ibm.com/v1/vpcs/${ibm_is_vpc.main.id}"
      monitoring_endpoint = var.enable_monitoring_services ? "https://monitoring.${var.primary_region}.cloud.ibm.com/api/v1/vpc/${ibm_is_vpc.main.id}" : null
    }
  }
  
  sensitive = false
}

# =============================================================================
# COST TRACKING AND RESOURCE UTILIZATION
# =============================================================================

output "cost_tracking" {
  description = "Cost tracking and resource utilization information"
  value = {
    # Resource count summary
    resource_count = {
      vpc_count               = 1
      subnet_count           = length(ibm_is_subnet.main)
      public_gateway_count   = length(ibm_is_public_gateway.main)
      security_group_count   = length(ibm_is_security_group.custom) + (var.compute_configuration.instance_count > 0 ? 1 : 0)
      instance_count         = length(ibm_is_instance.compute)
      ssh_key_count         = var.compute_configuration.ssh_key_name != null ? 0 : 1
    }
    
    # Cost allocation information
    cost_allocation = {
      organization  = var.organization_config.name
      division      = var.organization_config.division
      cost_center   = var.organization_config.cost_center
      environment   = var.organization_config.environment
      project       = var.organization_config.project
      owner         = var.organization_config.owner
      contact       = var.organization_config.contact
      region        = var.primary_region
    }
    
    # Estimated monthly costs (USD)
    estimated_monthly_cost = {
      # VPC and networking (mostly free)
      vpc_cost            = 0.00
      subnet_cost         = 0.00
      security_group_cost = 0.00
      
      # Public gateway costs
      public_gateway_cost = length(ibm_is_public_gateway.main) * 45.00
      
      # Compute costs (estimated based on profile)
      compute_cost = var.compute_configuration.instance_count * (
        var.compute_configuration.instance_profile == "cx2-2x4" ? 24.00 :
        var.compute_configuration.instance_profile == "cx2-4x8" ? 48.00 :
        var.compute_configuration.instance_profile == "cx2-8x16" ? 96.00 :
        var.compute_configuration.instance_profile == "mx2-2x16" ? 32.00 :
        var.compute_configuration.instance_profile == "mx2-4x32" ? 64.00 : 24.00
      )
      
      # Storage costs
      storage_cost = var.compute_configuration.instance_count * (var.compute_configuration.boot_volume.size * 0.10)
      
      # Total estimated cost
      total_estimated_cost = (
        length(ibm_is_public_gateway.main) * 45.00 +
        var.compute_configuration.instance_count * (
          var.compute_configuration.instance_profile == "cx2-2x4" ? 24.00 :
          var.compute_configuration.instance_profile == "cx2-4x8" ? 48.00 :
          var.compute_configuration.instance_profile == "cx2-8x16" ? 96.00 :
          var.compute_configuration.instance_profile == "mx2-2x16" ? 32.00 :
          var.compute_configuration.instance_profile == "mx2-4x32" ? 64.00 : 24.00
        ) +
        var.compute_configuration.instance_count * (var.compute_configuration.boot_volume.size * 0.10)
      )
    }
    
    # Resource optimization recommendations
    optimization_recommendations = {
      # Right-sizing recommendations
      right_sizing = var.compute_configuration.instance_count > 3 ? [
        "Consider using fewer, larger instances for better cost efficiency"
      ] : []
      
      # Network optimization
      network_optimization = length(ibm_is_public_gateway.main) > 1 ? [
        "Consider consolidating public gateways if cross-zone traffic is minimal"
      ] : []
      
      # Storage optimization
      storage_optimization = var.compute_configuration.boot_volume.size > 100 ? [
        "Consider using smaller boot volumes and separate data volumes for better cost control"
      ] : []
    }
  }
  
  sensitive = false
}

# =============================================================================
# MODULE METADATA AND CONFIGURATION
# =============================================================================

output "module_metadata" {
  description = "Module metadata and configuration information"
  value = {
    # Module information
    module = {
      name           = local.module_metadata.name
      version        = local.module_metadata.version
      lab_topic      = local.module_metadata.lab_topic
      lab_name       = local.module_metadata.lab_name
      created_at     = local.module_metadata.created_at
      terraform_version = local.module_metadata.terraform_version
      provider_version  = local.module_metadata.provider_version
    }
    
    # Configuration summary
    configuration = {
      primary_region    = var.primary_region
      secondary_region  = var.secondary_region
      multi_region      = var.enable_multi_region
      resource_group    = var.resource_group_name
      name_prefix       = local.name_prefix
      
      # Feature flags
      features = {
        enterprise_features   = var.enable_enterprise_features
        advanced_networking   = var.enable_advanced_networking
        security_services     = var.enable_security_services
        monitoring_services   = var.enable_monitoring_services
        audit_logging        = var.enable_audit_logging
        vpc_endpoints        = var.enable_vpc_endpoints
      }
    }
    
    # Tags applied
    tags = {
      base_tags   = local.base_tags
      global_tags = var.global_tags
      custom_tags = var.custom_tags
      all_tags    = local.all_tags
    }
    
    # Validation status
    validation = {
      provider_authenticated = data.ibm_iam_auth_token.primary_validation.iam_access_token != null
      region_available      = length(data.ibm_is_zones.primary_region_validation.zones) > 0
      resource_group_exists = data.ibm_resource_group.main.id != null
    }
  }
  
  sensitive = false
}

# =============================================================================
# SECURITY AND COMPLIANCE OUTPUTS
# =============================================================================

output "security_compliance" {
  description = "Security and compliance information"
  value = {
    # Encryption status
    encryption = {
      vpc_encryption_enabled     = true  # VPC data is encrypted by default
      storage_encryption_enabled = var.compute_configuration.boot_volume.encryption != "none"
      transit_encryption_enabled = true  # IBM Cloud encrypts data in transit by default
    }
    
    # Access control
    access_control = {
      iam_integration_enabled = var.security_configuration.access_control.enable_iam_integration
      security_groups_configured = length(ibm_is_security_group.custom) + (var.compute_configuration.instance_count > 0 ? 1 : 0)
      network_acls_configured = 1  # Default network ACL
    }
    
    # Compliance frameworks
    compliance = {
      frameworks_supported = var.security_configuration.compliance.frameworks
      data_classification = var.security_configuration.compliance.data_classification
      audit_logging_enabled = var.enable_audit_logging
      retention_period_days = var.security_configuration.compliance.retention_period_days
    }
    
    # Security recommendations
    security_recommendations = concat(
      var.compute_configuration.instance_count > 0 && length([
        for rule in ibm_is_security_group.compute[0].rules : rule
        if rule.direction == "inbound" && rule.remote[0].cidr_block == "0.0.0.0/0"
      ]) > 0 ? ["Consider restricting inbound security group rules to specific IP ranges"] : [],
      
      !var.enable_audit_logging ? ["Enable audit logging for compliance requirements"] : [],
      
      var.security_configuration.compliance.data_classification == "public" ? ["Review data classification for sensitive workloads"] : []
    )
  }
  
  sensitive = false
}

# =============================================================================
# MONITORING AND OBSERVABILITY OUTPUTS
# =============================================================================

output "monitoring_observability" {
  description = "Monitoring and observability configuration"
  value = var.enable_monitoring_services ? {
    # Activity Tracker
    activity_tracker = var.organization_config.environment == "production" ? {
      instance_id   = ibm_resource_instance.activity_tracker[0].id
      instance_name = ibm_resource_instance.activity_tracker[0].name
      service_plan  = ibm_resource_instance.activity_tracker[0].plan
      location      = ibm_resource_instance.activity_tracker[0].location
    } : null
    
    # Flow Logs
    flow_logs = var.monitoring_configuration.logging.enable_structured_logs ? {
      flow_log_id   = ibm_is_flow_log.vpc_flow_logs[0].id
      flow_log_name = ibm_is_flow_log.vpc_flow_logs[0].name
      target_vpc    = ibm_is_flow_log.vpc_flow_logs[0].target
      active        = ibm_is_flow_log.vpc_flow_logs[0].active
    } : null
    
    # Monitoring configuration
    configuration = {
      metrics_enabled = var.enable_metrics
      alerting_enabled = var.enable_alerting
      log_level = var.log_level
      retention_days = var.monitoring_configuration.logging.retention_days
    }
    
    # Monitoring endpoints
    endpoints = {
      metrics_endpoint = "https://monitoring.${var.primary_region}.cloud.ibm.com/api/v1"
      logging_endpoint = "https://logging.${var.primary_region}.cloud.ibm.com/api/v1"
      activity_tracker_endpoint = "https://activity-tracker.${var.primary_region}.cloud.ibm.com/api/v1"
    }
  } : null
  
  sensitive = false
}

# =============================================================================
# DEVELOPMENT AND DEBUGGING OUTPUTS
# =============================================================================

output "development_info" {
  description = "Development and debugging information (only shown in debug mode)"
  value = var.module_config.development.enable_debug_mode ? {
    # Random values generated
    random_suffix = random_string.suffix.result
    
    # SSH key information (for generated keys only)
    ssh_key_info = var.compute_configuration.ssh_key_name == null ? {
      public_key_openssh = tls_private_key.lab_ssh_key[0].public_key_openssh
      public_key_fingerprint = tls_private_key.lab_ssh_key[0].public_key_fingerprint_md5
      private_key_file = var.module_config.development.enable_debug_mode ? "${path.module}/generated/ssh-private-key.pem" : null
    } : null
    
    # Timestamps
    timestamps = {
      creation_time = time_static.creation_time.rfc3339
      rotation_schedule = time_rotating.rotation_schedule.rfc3339
    }
    
    # Local values for debugging
    local_values = {
      name_prefix = local.name_prefix
      vpc_config = local.vpc_config
      subnet_configs = local.subnet_configs
      security_group_configs = local.security_group_configs
    }
  } : null
  
  sensitive = true
}
