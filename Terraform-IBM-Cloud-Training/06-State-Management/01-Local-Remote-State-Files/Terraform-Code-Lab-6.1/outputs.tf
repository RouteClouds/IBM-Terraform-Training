# =============================================================================
# OUTPUT VALUES
# Subtopic 6.1: Local and Remote State Files
# Comprehensive outputs for state management demonstration and integration
# =============================================================================

# =============================================================================
# DEPLOYMENT INFORMATION
# =============================================================================

output "deployment_info" {
  description = "Deployment information and metadata"
  value = {
    project_name      = var.project_name
    environment       = var.environment
    deployment_time   = time_static.deployment_time.rfc3339
    terraform_version = "1.5.0+"
    region           = var.primary_region
    resource_group   = data.ibm_resource_group.main.name
    unique_suffix    = random_string.suffix.result
  }
}

# =============================================================================
# NETWORKING OUTPUTS
# =============================================================================

output "vpc_info" {
  description = "VPC configuration and connection details"
  value = {
    vpc_id               = ibm_is_vpc.state_demo_vpc.id
    vpc_name             = ibm_is_vpc.state_demo_vpc.name
    vpc_crn              = ibm_is_vpc.state_demo_vpc.crn
    vpc_status           = ibm_is_vpc.state_demo_vpc.status
    address_prefix       = var.vpc_address_prefix
    default_network_acl  = ibm_is_vpc.state_demo_vpc.default_network_acl
    default_routing_table = ibm_is_vpc.state_demo_vpc.default_routing_table
    default_security_group = ibm_is_vpc.state_demo_vpc.default_security_group
  }
}

output "subnet_info" {
  description = "Subnet configuration and network details"
  value = {
    subnet_id           = ibm_is_subnet.state_demo_subnet.id
    subnet_name         = ibm_is_subnet.state_demo_subnet.name
    subnet_crn          = ibm_is_subnet.state_demo_subnet.crn
    ipv4_cidr_block    = ibm_is_subnet.state_demo_subnet.ipv4_cidr_block
    available_ipv4_count = ibm_is_subnet.state_demo_subnet.available_ipv4_count
    total_ipv4_count   = ibm_is_subnet.state_demo_subnet.total_ipv4_count
    zone               = ibm_is_subnet.state_demo_subnet.zone
    public_gateway_id  = var.enable_public_gateway ? ibm_is_public_gateway.state_demo_gateway[0].id : null
  }
}

output "security_group_info" {
  description = "Security group configuration and rules"
  value = {
    security_group_id   = ibm_is_security_group.state_demo_sg.id
    security_group_name = ibm_is_security_group.state_demo_sg.name
    security_group_crn  = ibm_is_security_group.state_demo_sg.crn
    rules_count        = length(ibm_is_security_group.state_demo_sg.rules)
    vpc_id             = ibm_is_security_group.state_demo_sg.vpc
  }
}

# =============================================================================
# COMPUTE OUTPUTS
# =============================================================================

output "vsi_info" {
  description = "Virtual Server Instance configuration and connection details"
  value = {
    vsi_id                = ibm_is_instance.state_demo_vsi.id
    vsi_name              = ibm_is_instance.state_demo_vsi.name
    vsi_crn               = ibm_is_instance.state_demo_vsi.crn
    vsi_status            = ibm_is_instance.state_demo_vsi.status
    profile               = ibm_is_instance.state_demo_vsi.profile
    image_id              = ibm_is_instance.state_demo_vsi.image
    zone                  = ibm_is_instance.state_demo_vsi.zone
    vpc_id                = ibm_is_instance.state_demo_vsi.vpc
    primary_network_interface = {
      id                    = ibm_is_instance.state_demo_vsi.primary_network_interface[0].id
      name                  = ibm_is_instance.state_demo_vsi.primary_network_interface[0].name
      primary_ipv4_address  = ibm_is_instance.state_demo_vsi.primary_network_interface[0].primary_ipv4_address
      subnet_id             = ibm_is_instance.state_demo_vsi.primary_network_interface[0].subnet
    }
    boot_volume = {
      id   = ibm_is_instance.state_demo_vsi.boot_volume[0].id
      name = ibm_is_instance.state_demo_vsi.boot_volume[0].name
    }
  }
}

output "floating_ip_info" {
  description = "Floating IP configuration (if enabled)"
  value = var.enable_floating_ip ? {
    floating_ip_id      = ibm_is_floating_ip.state_demo_fip[0].id
    floating_ip_address = ibm_is_floating_ip.state_demo_fip[0].address
    floating_ip_name    = ibm_is_floating_ip.state_demo_fip[0].name
    floating_ip_crn     = ibm_is_floating_ip.state_demo_fip[0].crn
    target_interface_id = ibm_is_floating_ip.state_demo_fip[0].target
  } : null
}

# =============================================================================
# STATE MANAGEMENT OUTPUTS
# =============================================================================

output "state_backend_info" {
  description = "State backend configuration and access details"
  value = var.enable_remote_state ? {
    cos_instance_id   = ibm_resource_instance.state_cos[0].id
    cos_instance_name = ibm_resource_instance.state_cos[0].name
    cos_instance_crn  = ibm_resource_instance.state_cos[0].crn
    cos_instance_guid = ibm_resource_instance.state_cos[0].guid
    bucket_name       = ibm_cos_bucket.state_bucket[0].bucket_name
    bucket_crn        = ibm_cos_bucket.state_bucket[0].crn
    s3_endpoint_public = ibm_cos_bucket.state_bucket[0].s3_endpoint_public
    s3_endpoint_private = ibm_cos_bucket.state_bucket[0].s3_endpoint_private
    region_location   = ibm_cos_bucket.state_bucket[0].region_location
    storage_class     = ibm_cos_bucket.state_bucket[0].storage_class
    versioning_enabled = local.state_config.versioning
  } : null
}

output "state_credentials" {
  description = "State backend access credentials (sensitive)"
  value = var.enable_remote_state ? {
    access_key_id     = ibm_resource_key.state_cos_credentials[0].credentials["cos_hmac_keys.access_key_id"]
    secret_access_key = ibm_resource_key.state_cos_credentials[0].credentials["cos_hmac_keys.secret_access_key"]
    endpoint          = ibm_cos_bucket.state_bucket[0].s3_endpoint_public
    bucket_name       = ibm_cos_bucket.state_bucket[0].bucket_name
    region           = var.primary_region
  } : null
  sensitive = true
}

output "backend_configuration" {
  description = "Terraform backend configuration block"
  value = var.enable_remote_state ? {
    backend_type = "s3"
    configuration = {
      bucket                      = ibm_cos_bucket.state_bucket[0].bucket_name
      key                        = "infrastructure/terraform.tfstate"
      region                     = var.primary_region
      endpoint                   = ibm_cos_bucket.state_bucket[0].s3_endpoint_public
      skip_credentials_validation = true
      skip_region_validation     = true
      skip_metadata_api_check    = true
      force_path_style           = true
      encrypt                    = true
    }
  } : null
}

# =============================================================================
# TEAM ACCESS OUTPUTS
# =============================================================================

output "team_access_info" {
  description = "Team access configuration and credentials"
  value = var.enable_remote_state && local.team_config.enabled ? {
    developer_access = {
      role        = local.team_config.developer_perms[0]
      permissions = "Read-only access for planning and analysis"
    }
    operator_access = {
      role        = local.team_config.operator_perms[0]
      permissions = "Read-write access for infrastructure deployment"
    }
    team_members_count = length(local.team_config.members)
  } : null
}

output "developer_credentials" {
  description = "Developer team access credentials (read-only)"
  value = var.enable_remote_state && local.team_config.enabled ? {
    access_key_id     = ibm_resource_key.developer_credentials[0].credentials["cos_hmac_keys.access_key_id"]
    secret_access_key = ibm_resource_key.developer_credentials[0].credentials["cos_hmac_keys.secret_access_key"]
    role             = local.team_config.developer_perms[0]
    permissions      = "Read-only"
  } : null
  sensitive = true
}

output "operator_credentials" {
  description = "Operator team access credentials (read-write)"
  value = var.enable_remote_state && local.team_config.enabled ? {
    access_key_id     = ibm_resource_key.operator_credentials[0].credentials["cos_hmac_keys.access_key_id"]
    secret_access_key = ibm_resource_key.operator_credentials[0].credentials["cos_hmac_keys.secret_access_key"]
    role             = local.team_config.operator_perms[0]
    permissions      = "Read-write"
  } : null
  sensitive = true
}

# =============================================================================
# MONITORING AND COMPLIANCE OUTPUTS
# =============================================================================

output "monitoring_info" {
  description = "Monitoring and compliance service information"
  value = {
    activity_tracker = var.enable_activity_tracker ? {
      instance_id   = ibm_resource_instance.activity_tracker[0].id
      instance_name = ibm_resource_instance.activity_tracker[0].name
      instance_crn  = ibm_resource_instance.activity_tracker[0].crn
      plan         = var.activity_tracker_plan
      location     = var.primary_region
    } : null
    
    monitoring = var.enable_monitoring ? {
      instance_id   = ibm_resource_instance.monitoring[0].id
      instance_name = ibm_resource_instance.monitoring[0].name
      instance_crn  = ibm_resource_instance.monitoring[0].crn
      plan         = "graduated-tier"
      location     = var.primary_region
    } : null
  }
}

# =============================================================================
# COST TRACKING OUTPUTS
# =============================================================================

output "cost_tracking_info" {
  description = "Cost tracking and optimization information"
  value = {
    cost_center           = var.cost_center
    budget_alert_threshold = var.budget_alert_threshold
    resource_tags        = local.common_tags
    estimated_monthly_cost = {
      vpc_subnet          = "Free"
      vsi_bx2_2x8        = "$30-50/month"
      cos_lite           = "Free (5GB)"
      activity_tracker   = var.activity_tracker_plan == "lite" ? "Free" : "$20-100/month"
      monitoring         = "$20-50/month"
      total_estimate     = "$70-200/month"
    }
    cost_optimization_features = [
      "COS lifecycle management",
      "Lite plan usage where available",
      "Auto-delete volumes",
      "Resource tagging for cost allocation"
    ]
  }
}

# =============================================================================
# INTEGRATION OUTPUTS
# =============================================================================

output "integration_endpoints" {
  description = "Service endpoints for integration and automation"
  value = {
    vpc_api_endpoint     = "https://${var.primary_region}.iaas.cloud.ibm.com"
    cos_api_endpoint     = var.enable_remote_state ? ibm_cos_bucket.state_bucket[0].s3_endpoint_public : null
    activity_tracker_endpoint = var.enable_activity_tracker ? "https://${var.primary_region}.logging.cloud.ibm.com" : null
    monitoring_endpoint  = var.enable_monitoring ? "https://${var.primary_region}.monitoring.cloud.ibm.com" : null
  }
}

output "state_management_summary" {
  description = "Complete state management implementation summary"
  value = {
    local_state_demo = {
      vpc_resources     = 1
      subnet_resources  = 1
      vsi_resources     = 1
      security_groups   = 1
      total_resources   = 4 + (var.enable_floating_ip ? 1 : 0) + (var.enable_public_gateway ? 1 : 0)
    }
    
    remote_state_backend = var.enable_remote_state ? {
      cos_instance      = 1
      cos_bucket        = 1
      service_credentials = 1 + (local.team_config.enabled ? 2 : 0)
      backend_configured = true
      versioning_enabled = local.state_config.versioning
      encryption_enabled = local.state_config.encryption
    } : null
    
    team_collaboration = local.team_config.enabled ? {
      team_members_configured = length(local.team_config.members)
      developer_access_configured = true
      operator_access_configured = true
      workflow_documentation_generated = true
    } : null
    
    monitoring_compliance = {
      activity_tracker_enabled = var.enable_activity_tracker
      monitoring_enabled = var.enable_monitoring
      cost_tracking_enabled = var.enable_cost_tracking
      audit_logging_configured = var.enable_activity_tracker
    }
  }
}
