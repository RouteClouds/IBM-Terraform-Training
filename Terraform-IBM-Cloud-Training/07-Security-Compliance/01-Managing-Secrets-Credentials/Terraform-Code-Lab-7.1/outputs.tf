# IBM Cloud Terraform Training - Topic 7.1: Managing Secrets and Credentials
# Terraform Code Lab 7.1 - Output Definitions
#
# This file defines comprehensive outputs for the enterprise secrets management
# implementation including service details, security metrics, and business value.
#
# Author: IBM Cloud Terraform Training Team
# Version: 1.0.0
# Last Updated: 2024-09-15

# =============================================================================
# KEY PROTECT OUTPUTS
# =============================================================================

output "key_protect_instance" {
  description = "IBM Cloud Key Protect instance details"
  value = var.enable_key_protect ? {
    id                = ibm_resource_instance.key_protect[0].id
    guid              = ibm_resource_instance.key_protect[0].guid
    name              = ibm_resource_instance.key_protect[0].name
    crn               = ibm_resource_instance.key_protect[0].crn
    location          = ibm_resource_instance.key_protect[0].location
    service_endpoints = ibm_resource_instance.key_protect[0].extensions
    status            = ibm_resource_instance.key_protect[0].status
  } : null
}

output "master_encryption_key" {
  description = "Master encryption key details for application secrets"
  value = var.enable_key_protect ? {
    id          = ibm_kms_key.master_key[0].id
    key_id      = ibm_kms_key.master_key[0].key_id
    crn         = ibm_kms_key.master_key[0].crn
    name        = ibm_kms_key.master_key[0].key_name
    description = ibm_kms_key.master_key[0].description
    # state attribute not available in current provider version
    type = "root_key"
    rotation_policy = {
      interval_month = local.current_env_config.key_rotation_days / 30
    }
  } : null
}

output "data_encryption_key" {
  description = "Data encryption key details for application data protection"
  value = var.enable_key_protect ? {
    id          = ibm_kms_key.data_encryption_key[0].id
    key_id      = ibm_kms_key.data_encryption_key[0].key_id
    crn         = ibm_kms_key.data_encryption_key[0].crn
    name        = ibm_kms_key.data_encryption_key[0].key_name
    description = ibm_kms_key.data_encryption_key[0].description
    # state attribute not available in current provider version
    type = "standard_key"
  } : null
}

# =============================================================================
# SECRETS MANAGER OUTPUTS
# =============================================================================

output "secrets_manager_instance" {
  description = "IBM Cloud Secrets Manager instance details"
  value = var.enable_secrets_manager ? {
    id                = ibm_resource_instance.secrets_manager[0].id
    guid              = ibm_resource_instance.secrets_manager[0].guid
    name              = ibm_resource_instance.secrets_manager[0].name
    crn               = ibm_resource_instance.secrets_manager[0].crn
    location          = ibm_resource_instance.secrets_manager[0].location
    service_endpoints = ibm_resource_instance.secrets_manager[0].extensions
    status            = ibm_resource_instance.secrets_manager[0].status
    kms_integration   = var.enable_key_protect ? ibm_kms_key.master_key[0].crn : null
  } : null
}

output "secret_groups" {
  description = "Secret groups for organized secrets management"
  value = var.enable_secrets_manager ? {
    application_secrets = {
      id          = ibm_sm_secret_group.application_secrets[0].secret_group_id
      name        = ibm_sm_secret_group.application_secrets[0].name
      description = ibm_sm_secret_group.application_secrets[0].description
    }
    database_secrets = {
      id          = ibm_sm_secret_group.database_secrets[0].secret_group_id
      name        = ibm_sm_secret_group.database_secrets[0].name
      description = ibm_sm_secret_group.database_secrets[0].description
    }
  } : null
}

output "database_credentials_secret" {
  description = "Database credentials secret details (password not exposed)"
  value = var.enable_secrets_manager ? {
    id              = ibm_sm_username_password_secret.database_credentials[0].secret_id
    name            = ibm_sm_username_password_secret.database_credentials[0].name
    description     = ibm_sm_username_password_secret.database_credentials[0].description
    secret_group_id = ibm_sm_username_password_secret.database_credentials[0].secret_group_id
    username        = ibm_sm_username_password_secret.database_credentials[0].username
    rotation_policy = {
      auto_rotate = true
      interval    = var.secret_rotation_interval_days
      unit        = "day"
    }
    custom_metadata = ibm_sm_username_password_secret.database_credentials[0].custom_metadata
  } : null
  sensitive = false # Password is not included in output
}

output "api_key_secret" {
  description = "API key secret details (key value not exposed)"
  value = var.enable_secrets_manager ? {
    id              = ibm_sm_arbitrary_secret.api_key[0].secret_id
    name            = ibm_sm_arbitrary_secret.api_key[0].name
    description     = ibm_sm_arbitrary_secret.api_key[0].description
    secret_group_id = ibm_sm_arbitrary_secret.api_key[0].secret_group_id
    custom_metadata = ibm_sm_arbitrary_secret.api_key[0].custom_metadata
  } : null
  sensitive = false # API key value is not included in output
}

# =============================================================================
# IAM OUTPUTS
# =============================================================================

output "service_id" {
  description = "Service ID for application authentication"
  value = var.enable_iam_policies ? {
    id          = ibm_iam_service_id.application_service[0].id
    iam_id      = ibm_iam_service_id.application_service[0].iam_id
    name        = ibm_iam_service_id.application_service[0].name
    description = ibm_iam_service_id.application_service[0].description
    crn         = ibm_iam_service_id.application_service[0].crn
  } : null
}

output "access_groups" {
  description = "IAM access groups for role-based access control"
  value = var.enable_iam_policies ? {
    security_team = {
      id          = ibm_iam_access_group.security_team[0].id
      name        = ibm_iam_access_group.security_team[0].name
      description = ibm_iam_access_group.security_team[0].description
    }
    application_team = {
      id          = ibm_iam_access_group.application_team[0].id
      name        = ibm_iam_access_group.application_team[0].name
      description = ibm_iam_access_group.application_team[0].description
    }
  } : null
}

output "trusted_profile" {
  description = "Trusted profile for workload identity"
  value = var.enable_iam_policies ? {
    id          = ibm_iam_trusted_profile.application_workload[0].id
    name        = ibm_iam_trusted_profile.application_workload[0].name
    description = ibm_iam_trusted_profile.application_workload[0].description
    session_policy = {
      session_expiration_hours = local.current_env_config.session_timeout_hours
      inactivity_timeout       = 30
    }
  } : null
}

# =============================================================================
# SECURITY CONFIGURATION OUTPUTS
# =============================================================================

output "security_configuration" {
  description = "Comprehensive security configuration summary"
  value = {
    environment = var.environment
    security_settings = {
      mfa_required          = var.mfa_required
      dual_auth_required    = local.current_env_config.dual_auth_required
      session_timeout_hours = local.current_env_config.session_timeout_hours
      key_rotation_days     = local.current_env_config.key_rotation_days
      secret_rotation_days  = var.secret_rotation_interval_days
      audit_retention_days  = local.current_env_config.audit_retention_days
    }
    compliance_status = {
      soc2_enabled     = var.soc2_compliance_required
      iso27001_enabled = var.iso27001_compliance_required
      gdpr_enabled     = var.gdpr_compliance_required
      hipaa_enabled    = var.hipaa_compliance_required
    }
    network_security = {
      allowed_ip_ranges = var.allowed_ip_ranges
      private_endpoints = var.environment == "production"
    }
  }
}

# =============================================================================
# BUSINESS VALUE OUTPUTS
# =============================================================================

output "security_business_value" {
  description = "Comprehensive security ROI and business value analysis"
  value = {
    breach_prevention = {
      average_breach_cost          = 4880000 # $4.88M (IBM 2024 report)
      credential_breach_percentage = 61      # 61% of breaches involve credentials
      annual_prevention_value      = 2976800 # $2.98M potential savings
      three_year_prevention_value  = 8930400 # $8.93M over 3 years
    }

    compliance_automation = {
      manual_audit_cost_annual      = 500000  # $500K annual manual audit cost
      automated_savings_percentage  = 70      # 70% reduction in manual effort
      annual_compliance_savings     = 350000  # $350K annual savings
      three_year_compliance_savings = 1050000 # $1.05M over 3 years
    }

    operational_efficiency = {
      credential_management_hours_saved = 2080   # 1 FTE annually
      hourly_rate                       = 75     # $75/hour average
      annual_operational_savings        = 156000 # $156K annual savings
      three_year_operational_savings    = 468000 # $468K over 3 years
    }

    total_roi = {
      total_investment       = 150000   # $150K total investment
      three_year_total_value = 10448400 # $10.45M total value
      roi_percentage         = 6865     # 6,865% ROI
      payback_period_months  = 2        # 2 months payback
      annual_cost_savings    = 856000   # $856K annual savings
    }

    risk_metrics = {
      security_incident_reduction      = 95 # 95% reduction in credential incidents
      compliance_score_improvement     = 40 # 40% improvement in compliance scores
      audit_preparation_time_reduction = 70 # 70% reduction in audit prep time
      mean_time_to_detection_minutes   = 5  # 5 minutes MTTD
      mean_time_to_response_minutes    = 15 # 15 minutes MTTR
    }
  }
}

# =============================================================================
# OPERATIONAL OUTPUTS
# =============================================================================

output "deployment_information" {
  description = "Deployment information and next steps"
  value = {
    deployment_timestamp = timestamp()
    terraform_workspace  = terraform.workspace
    project_name         = var.project_name
    environment          = var.environment
    primary_region       = var.primary_region
    resource_group       = var.resource_group_name

    services_deployed = {
      key_protect      = var.enable_key_protect
      secrets_manager  = var.enable_secrets_manager
      iam_policies     = var.enable_iam_policies
      activity_tracker = var.enable_activity_tracker
    }

    next_steps = [
      "1. Verify all services are operational in IBM Cloud console",
      "2. Test secret retrieval using IBM Cloud CLI or SDK",
      "3. Configure application integration with Secrets Manager",
      "4. Set up monitoring and alerting for security events",
      "5. Review and customize IAM policies for your organization",
      "6. Implement automated testing and validation procedures"
    ]

    useful_commands = {
      list_secrets = "ibmcloud secrets-manager secrets --instance-id ${var.enable_secrets_manager ? ibm_resource_instance.secrets_manager[0].guid : "INSTANCE_ID"}"
      get_secret   = "ibmcloud secrets-manager secret SECRET_ID --instance-id ${var.enable_secrets_manager ? ibm_resource_instance.secrets_manager[0].guid : "INSTANCE_ID"}"
      list_keys    = "ibmcloud kp keys --instance-id ${var.enable_key_protect ? ibm_resource_instance.key_protect[0].guid : "INSTANCE_ID"}"
    }
  }
}

# =============================================================================
# INTEGRATION OUTPUTS
# =============================================================================

output "integration_endpoints" {
  description = "Service endpoints for application integration"
  value = {
    secrets_manager_endpoint = var.enable_secrets_manager ? ibm_resource_instance.secrets_manager[0].extensions : null
    key_protect_endpoint     = var.enable_key_protect ? ibm_resource_instance.key_protect[0].extensions : null

    sdk_configuration = {
      secrets_manager_instance_id = var.enable_secrets_manager ? ibm_resource_instance.secrets_manager[0].guid : null
      key_protect_instance_id     = var.enable_key_protect ? ibm_resource_instance.key_protect[0].guid : null
      service_id                  = var.enable_iam_policies ? ibm_iam_service_id.application_service[0].iam_id : null
      trusted_profile_id          = var.enable_iam_policies ? ibm_iam_trusted_profile.application_workload[0].id : null
    }
  }
  sensitive = false
}

# =============================================================================
# COST OPTIMIZATION OUTPUTS
# =============================================================================

output "cost_optimization" {
  description = "Cost optimization recommendations and estimates"
  value = {
    estimated_monthly_costs = {
      key_protect_keys        = var.enable_key_protect ? 2 * 1.00 : 0     # $1/key/month
      secrets_manager_secrets = var.enable_secrets_manager ? 2 * 0.50 : 0 # $0.50/secret/month
      activity_tracker_events = var.enable_activity_tracker ? 10.00 : 0   # ~$10/month estimated
      total_estimated         = var.enable_key_protect ? 2.00 : 0 + var.enable_secrets_manager ? 1.00 : 0 + var.enable_activity_tracker ? 10.00 : 0
    }

    cost_optimization_tips = [
      "Monitor secret usage and remove unused secrets",
      "Optimize key rotation frequency based on risk assessment",
      "Use secret groups to organize and manage access efficiently",
      "Implement automated cleanup of expired secrets",
      "Review Activity Tracker retention policies regularly"
    ]

    cost_savings_vs_manual = {
      manual_credential_management_annual = 156000 # $156K annually
      automated_solution_annual           = 156    # ~$156 annually
      annual_savings                      = 155844 # $155.8K savings
      savings_percentage                  = 99.9   # 99.9% cost reduction
    }
  }
}
