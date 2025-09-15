# =============================================================================
# OUTPUT CONFIGURATION
# Subtopic 6.2: State Locking and Drift Detection
# Comprehensive outputs for state management infrastructure
# =============================================================================

# =============================================================================
# STATE LOCKING CONFIGURATION OUTPUTS
# =============================================================================

output "state_locking_configuration" {
  description = "Complete state locking configuration details"
  value = var.enable_state_locking ? {
    enabled           = var.enable_state_locking
    cloudant_instance = ibm_resource_instance.cloudant[0].name
    cloudant_host     = ibm_resource_instance.cloudant[0].extensions.CLOUDANT_HOST
    lock_table_name   = var.lock_table_name
    lock_timeout      = "${var.lock_timeout_minutes} minutes"
    retry_attempts    = var.lock_retry_attempts
    retry_delay       = "${var.lock_retry_delay_seconds} seconds"
    service_plan      = var.cloudant_plan
    region           = var.primary_region
  } : null
}

output "cloudant_credentials_id" {
  description = "Cloudant service credentials ID for state locking"
  value       = var.enable_state_locking ? ibm_resource_key.cloudant_credentials[0].id : null
  sensitive   = true
}

output "lock_database_url" {
  description = "URL for the lock database in Cloudant"
  value       = var.enable_state_locking ? "${ibm_resource_instance.cloudant[0].extensions.CLOUDANT_HOST}/${var.lock_table_name}" : null
}

# =============================================================================
# INFRASTRUCTURE DETAILS OUTPUTS
# =============================================================================

output "vpc_infrastructure" {
  description = "VPC infrastructure details for state management demo"
  value = {
    vpc_id              = ibm_is_vpc.locking_demo_vpc.id
    vpc_name            = ibm_is_vpc.locking_demo_vpc.name
    vpc_crn             = ibm_is_vpc.locking_demo_vpc.crn
    address_prefix      = var.vpc_address_prefix
    subnet_id           = ibm_is_subnet.locking_demo_subnet.id
    subnet_name         = ibm_is_subnet.locking_demo_subnet.name
    subnet_cidr         = var.subnet_address_prefix
    availability_zone   = local.availability_zone
    public_gateway_id   = var.enable_public_gateway ? ibm_is_public_gateway.locking_demo_gateway[0].id : null
    security_group_id   = ibm_is_security_group.locking_demo_sg.id
  }
}

output "compute_resources" {
  description = "Compute resources for state management demonstration"
  value = {
    vsi_id              = ibm_is_instance.locking_demo_vsi.id
    vsi_name            = ibm_is_instance.locking_demo_vsi.name
    vsi_profile         = var.vsi_profile
    vsi_image           = var.vsi_image_name
    primary_ipv4        = ibm_is_instance.locking_demo_vsi.primary_network_interface[0].primary_ipv4_address
    floating_ip         = var.enable_floating_ip ? ibm_is_floating_ip.locking_demo_fip[0].address : null
    ssh_key_configured  = var.ssh_key_name != ""
    zone               = local.availability_zone
  }
}

# =============================================================================
# DRIFT DETECTION CONFIGURATION OUTPUTS
# =============================================================================

output "drift_detection_setup" {
  description = "Drift detection and automation configuration"
  value = var.enable_drift_detection ? {
    enabled                = var.enable_drift_detection
    schedule              = var.drift_check_schedule
    severity_threshold    = var.drift_severity_threshold
    auto_remediation      = var.enable_auto_remediation
    remediation_threshold = var.auto_remediation_threshold
    alert_channels        = var.drift_alert_channels
    functions_namespace   = var.enable_cloud_functions ? ibm_function_namespace.terraform_automation[0].name : null
    function_name         = var.enable_cloud_functions ? ibm_function_action.drift_detection[0].name : null
    trigger_name          = var.enable_cloud_functions ? ibm_function_trigger.drift_schedule[0].name : null
  } : null
}

output "cloud_functions_details" {
  description = "IBM Cloud Functions configuration for automation"
  value = var.enable_cloud_functions ? {
    namespace_id        = ibm_function_namespace.terraform_automation[0].id
    namespace_name      = ibm_function_namespace.terraform_automation[0].name
    function_memory     = var.function_memory_limit
    function_timeout    = var.function_timeout
    drift_function_id   = var.enable_drift_detection ? ibm_function_action.drift_detection[0].name : null
    schedule_trigger_id = var.enable_drift_detection ? ibm_function_trigger.drift_schedule[0].name : null
    rule_id            = var.enable_drift_detection ? ibm_function_rule.drift_detection_rule[0].name : null
  } : null
}

# =============================================================================
# BACKEND CONFIGURATION OUTPUTS
# =============================================================================

output "state_backend_configuration" {
  description = "State backend configuration details"
  value = {
    cos_instance_id     = ibm_resource_instance.state_cos.id
    cos_instance_name   = ibm_resource_instance.state_cos.name
    bucket_name         = ibm_cos_bucket.state_bucket.bucket_name
    bucket_region       = ibm_cos_bucket.state_bucket.region_location
    s3_endpoint_public  = ibm_cos_bucket.state_bucket.s3_endpoint_public
    s3_endpoint_private = ibm_cos_bucket.state_bucket.s3_endpoint_private
    versioning_enabled  = true
    lifecycle_configured = true
    activity_tracking   = true
  }
}

output "backend_credentials_id" {
  description = "Backend credentials ID for state storage access"
  value       = ibm_resource_key.state_cos_credentials.id
  sensitive   = true
}

# =============================================================================
# MONITORING AND COMPLIANCE OUTPUTS
# =============================================================================

output "monitoring_configuration" {
  description = "Monitoring and compliance setup details"
  value = {
    activity_tracker = var.enable_activity_tracker ? {
      instance_id   = ibm_resource_instance.activity_tracker[0].id
      instance_name = ibm_resource_instance.activity_tracker[0].name
      plan         = var.activity_tracker_plan
      region       = var.primary_region
    } : null
    monitoring = var.enable_monitoring ? {
      instance_id   = ibm_resource_instance.monitoring[0].id
      instance_name = ibm_resource_instance.monitoring[0].name
      plan         = var.monitoring_plan
      region       = var.primary_region
    } : null
    key_protect_enabled = var.enable_key_protect
  }
}

output "compliance_tracking" {
  description = "Compliance and audit tracking information"
  value = {
    activity_tracker_enabled = var.enable_activity_tracker
    monitoring_enabled       = var.enable_monitoring
    cost_tracking_enabled    = var.enable_cost_tracking
    audit_logging_active     = var.enable_activity_tracker
    encryption_enabled       = true
    versioning_enabled       = true
    lifecycle_management     = true
  }
}

# =============================================================================
# SECURITY CONFIGURATION OUTPUTS
# =============================================================================

output "security_configuration" {
  description = "Security groups and access control configuration"
  value = {
    primary_security_group = {
      id    = ibm_is_security_group.locking_demo_sg.id
      name  = ibm_is_security_group.locking_demo_sg.name
      rules = [
        "SSH (22/tcp) - Inbound from 0.0.0.0/0",
        "HTTP (80/tcp) - Inbound from 0.0.0.0/0", 
        "HTTPS (443/tcp) - Inbound from 0.0.0.0/0",
        "All traffic - Outbound to 0.0.0.0/0"
      ]
    }
    drift_test_security_group = var.simulate_drift ? {
      id   = ibm_is_security_group.drift_test_sg[0].id
      name = ibm_is_security_group.drift_test_sg[0].name
    } : null
    ssh_key_configured = var.ssh_key_name != ""
    floating_ip_enabled = var.enable_floating_ip
  }
}

# =============================================================================
# NOTIFICATION CONFIGURATION OUTPUTS
# =============================================================================

output "notification_setup" {
  description = "Notification and alerting configuration"
  value = {
    slack_webhook_configured = var.slack_webhook_url != ""
    email_recipients_count   = length(var.email_recipients)
    webhook_endpoints_count  = length(var.webhook_endpoints)
    alert_channels          = var.drift_alert_channels
    notification_channels   = [
      for channel in var.drift_alert_channels : {
        type = channel
        configured = (
          channel == "slack" ? var.slack_webhook_url != "" :
          channel == "email" ? length(var.email_recipients) > 0 :
          channel == "webhook" ? length(var.webhook_endpoints) > 0 :
          false
        )
      }
    ]
  }
}

# =============================================================================
# TESTING AND VALIDATION OUTPUTS
# =============================================================================

output "testing_configuration" {
  description = "Testing and validation setup details"
  value = {
    testing_mode_enabled     = var.enable_testing_mode
    drift_simulation_enabled = var.simulate_drift
    conflict_testing_enabled = var.test_conflict_scenarios
    drift_test_resources = var.simulate_drift ? {
      security_group_id = ibm_is_security_group.drift_test_sg[0].id
      test_rule_id     = ibm_is_security_group_rule.drift_test_rule[0].rule_id
    } : null
    lock_test_id = random_uuid.lock_test_id.result
  }
}

# =============================================================================
# COST OPTIMIZATION OUTPUTS
# =============================================================================

output "cost_optimization" {
  description = "Cost tracking and optimization configuration"
  value = {
    cost_tracking_enabled   = var.enable_cost_tracking
    cost_center            = var.cost_center
    budget_alert_threshold = var.budget_alert_threshold
    resource_tagging = {
      common_tags_count = length(local.common_tags)
      project_name     = var.project_name
      environment      = var.environment
    }
    service_plans = {
      cloudant_plan         = var.cloudant_plan
      activity_tracker_plan = var.activity_tracker_plan
      monitoring_plan       = var.monitoring_plan
      cos_plan             = "lite"
    }
  }
}

# =============================================================================
# DEPLOYMENT METADATA OUTPUTS
# =============================================================================

output "deployment_metadata" {
  description = "Deployment metadata and configuration summary"
  value = {
    deployment_time     = time_static.deployment_time.rfc3339
    terraform_version   = ">=1.5.0"
    provider_version    = "~>1.58.0"
    project_name        = var.project_name
    environment         = var.environment
    region             = var.primary_region
    resource_group     = var.resource_group_name
    unique_suffix      = random_string.suffix.result
    configuration_hash = md5(jsonencode({
      state_locking    = local.locking_config
      drift_detection  = local.drift_config
      notifications   = local.notification_config
    }))
  }
}

# =============================================================================
# QUICK ACCESS OUTPUTS
# =============================================================================

output "quick_access_info" {
  description = "Quick access information for common operations"
  value = {
    ssh_command = var.ssh_key_name != "" && var.enable_floating_ip ? 
      "ssh -i ~/.ssh/${var.ssh_key_name} ubuntu@${ibm_is_floating_ip.locking_demo_fip[0].address}" : 
      "SSH access requires SSH key and floating IP configuration"
    
    cloudant_dashboard = var.enable_state_locking ? 
      "https://cloud.ibm.com/services/cloudant/${ibm_resource_instance.cloudant[0].id}" : 
      "State locking not enabled"
    
    cos_dashboard = "https://cloud.ibm.com/objectstorage/${ibm_resource_instance.state_cos.id}"
    
    monitoring_dashboard = var.enable_monitoring ? 
      "https://cloud.ibm.com/observe/monitoring/${ibm_resource_instance.monitoring[0].id}" : 
      "Monitoring not enabled"
    
    activity_tracker_dashboard = var.enable_activity_tracker ? 
      "https://cloud.ibm.com/observe/activitytracker/${ibm_resource_instance.activity_tracker[0].id}" : 
      "Activity Tracker not enabled"
  }
}

# =============================================================================
# NEXT STEPS GUIDANCE
# =============================================================================

output "next_steps" {
  description = "Guidance for next steps and configuration"
  value = {
    backend_migration = var.enable_state_locking ? 
      "Use generated_backend_with_locking.tf to migrate to locked backend" : 
      "Enable state locking to generate backend configuration"
    
    drift_detection_setup = var.enable_drift_detection ? 
      "Drift detection is configured and active" : 
      "Enable drift detection to activate automated monitoring"
    
    testing_procedures = [
      "1. Test state locking with concurrent terraform operations",
      "2. Simulate drift by manually modifying resources",
      "3. Verify drift detection and alerting functionality",
      "4. Test conflict resolution procedures",
      "5. Validate automated remediation workflows"
    ]
    
    documentation_links = [
      "Lab 13: State Locking and Drift Detection",
      "Concept.md: Advanced State Management Theory",
      "README.md: Complete implementation guide"
    ]
  }
}
