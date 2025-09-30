# IBM Cloud Schematics & Terraform Cloud Integration - Outputs Configuration
# Topic 8.2: Advanced Integration Lab Environment
# Version: 1.0.0

# =============================================================================
# SCHEMATICS WORKSPACE OUTPUTS
# =============================================================================

output "schematics_workspace_id" {
  description = "ID of the main Schematics workspace"
  value       = ibm_schematics_workspace.main_workspace.id
  sensitive   = false
}

output "schematics_workspace_name" {
  description = "Name of the main Schematics workspace"
  value       = ibm_schematics_workspace.main_workspace.name
  sensitive   = false
}

output "schematics_workspace_url" {
  description = "URL to access the Schematics workspace in IBM Cloud console"
  value       = "https://cloud.ibm.com/schematics/workspaces/${ibm_schematics_workspace.main_workspace.id}"
  sensitive   = false
}

output "schematics_workspace_status" {
  description = "Current status of the Schematics workspace"
  value       = ibm_schematics_workspace.main_workspace.status
  sensitive   = false
}

output "schematics_workspace_location" {
  description = "Location/region of the Schematics workspace"
  value       = ibm_schematics_workspace.main_workspace.location
  sensitive   = false
}

output "network_workspace_id" {
  description = "ID of the network dependency workspace"
  value       = ibm_schematics_workspace.network_workspace.id
  sensitive   = false
}

output "network_workspace_name" {
  description = "Name of the network dependency workspace"
  value       = ibm_schematics_workspace.network_workspace.name
  sensitive   = false
}

# =============================================================================
# TERRAFORM CLOUD INTEGRATION OUTPUTS
# =============================================================================

output "terraform_cloud_workspace_id" {
  description = "ID of the Terraform Cloud workspace"
  value       = var.enable_terraform_cloud_integration ? tfe_workspace.hybrid_workspace[0].id : null
  sensitive   = false
}

output "terraform_cloud_workspace_name" {
  description = "Name of the Terraform Cloud workspace"
  value       = var.enable_terraform_cloud_integration ? tfe_workspace.hybrid_workspace[0].name : null
  sensitive   = false
}

output "terraform_cloud_workspace_url" {
  description = "URL to access the Terraform Cloud workspace"
  value = var.enable_terraform_cloud_integration ? (
    "https://${var.terraform_cloud_hostname}/app/${var.terraform_cloud_organization}/workspaces/${tfe_workspace.hybrid_workspace[0].name}"
  ) : null
  sensitive = false
}

output "terraform_cloud_organization" {
  description = "Terraform Cloud organization name"
  value       = var.terraform_cloud_organization
  sensitive   = false
}

# =============================================================================
# ACCESS CONTROL AND SECURITY OUTPUTS
# =============================================================================

output "iam_access_group_id" {
  description = "ID of the IAM access group for team collaboration"
  value       = ibm_iam_access_group.schematics_team.id
  sensitive   = false
}

output "iam_access_group_name" {
  description = "Name of the IAM access group"
  value       = ibm_iam_access_group.schematics_team.name
  sensitive   = false
}

output "team_members_count" {
  description = "Number of team members added to the access group"
  value       = length(var.team_members)
  sensitive   = false
}

output "workspace_access_level" {
  description = "Access level configured for workspace users"
  value       = var.workspace_access_level
  sensitive   = false
}

# =============================================================================
# MONITORING AND LOGGING OUTPUTS
# =============================================================================

output "activity_tracker_id" {
  description = "ID of the Activity Tracker instance for audit logging"
  value       = var.enable_audit_logging ? ibm_resource_instance.activity_tracker[0].id : null
  sensitive   = false
}

output "activity_tracker_dashboard_url" {
  description = "URL to access the Activity Tracker dashboard"
  value = var.enable_audit_logging ? (
    "https://cloud.ibm.com/observe/activitytracker/${ibm_resource_instance.activity_tracker[0].id}"
  ) : null
  sensitive = false
}

output "log_analysis_id" {
  description = "ID of the Log Analysis instance for workspace monitoring"
  value       = var.monitoring_enabled ? ibm_resource_instance.log_analysis[0].id : null
  sensitive   = false
}

output "log_analysis_dashboard_url" {
  description = "URL to access the Log Analysis dashboard"
  value = var.monitoring_enabled ? (
    "https://cloud.ibm.com/observe/logging/${ibm_resource_instance.log_analysis[0].id}"
  ) : null
  sensitive = false
}

# =============================================================================
# COST TRACKING AND BUDGET OUTPUTS
# =============================================================================

output "budget_configuration" {
  description = "Budget and cost tracking configuration"
  value = {
    budget_limit           = var.budget_limit
    alert_threshold        = var.budget_alert_threshold
    cost_center           = var.cost_center
    cost_tracking_enabled = var.enable_cost_tracking
    auto_cleanup_schedule = var.auto_destroy_schedule
  }
  sensitive = false
}

output "cost_tracking_tags" {
  description = "Tags applied for cost tracking and management"
  value       = var.enable_cost_tracking ? ibm_resource_tag.cost_tracking[0].tags : []
  sensitive   = false
}

# =============================================================================
# PROJECT AND ENVIRONMENT OUTPUTS
# =============================================================================

output "project_configuration" {
  description = "Project and environment configuration summary"
  value = {
    project_name      = var.project_name
    environment       = var.environment
    region           = var.ibm_region
    resource_group   = var.resource_group_name
    owner_email      = var.owner_email
    compliance_level = var.compliance_level
  }
  sensitive = false
}

output "resource_naming_info" {
  description = "Resource naming information and conventions"
  value = {
    resource_prefix = local.resource_prefix
    random_suffix   = random_string.suffix.result
    workspace_name  = local.workspace_name
    timestamp       = local.timestamp
  }
  sensitive = false
}

# =============================================================================
# INTEGRATION STATUS OUTPUTS
# =============================================================================

output "integration_status" {
  description = "Status of various integrations and features"
  value = {
    terraform_cloud_integration = var.enable_terraform_cloud_integration
    cost_tracking_enabled      = var.enable_cost_tracking
    audit_logging_enabled      = var.enable_audit_logging
    monitoring_enabled         = var.monitoring_enabled
    team_collaboration_setup   = length(var.team_members) > 0
  }
  sensitive = false
}

output "workspace_dependencies" {
  description = "Information about workspace dependencies and orchestration"
  value = {
    main_workspace_id    = ibm_schematics_workspace.main_workspace.id
    network_workspace_id = ibm_schematics_workspace.network_workspace.id
    dependency_order     = ["network", "main"]
    orchestration_ready  = true
  }
  sensitive = false
}

# =============================================================================
# QUICK ACCESS URLS
# =============================================================================

output "quick_access_urls" {
  description = "Quick access URLs for common tasks and dashboards"
  value = {
    schematics_console = "https://cloud.ibm.com/schematics"
    main_workspace     = "https://cloud.ibm.com/schematics/workspaces/${ibm_schematics_workspace.main_workspace.id}"
    network_workspace  = "https://cloud.ibm.com/schematics/workspaces/${ibm_schematics_workspace.network_workspace.id}"
    iam_access_groups  = "https://cloud.ibm.com/iam/groups"
    cost_tracking      = "https://cloud.ibm.com/billing/usage"
    terraform_cloud    = var.enable_terraform_cloud_integration ? "https://${var.terraform_cloud_hostname}/app/${var.terraform_cloud_organization}" : null
  }
  sensitive = false
}

# =============================================================================
# DEPLOYMENT SUMMARY
# =============================================================================

output "deployment_summary" {
  description = "Comprehensive deployment summary for documentation"
  value = {
    deployment_timestamp    = local.timestamp
    total_workspaces       = 2
    schematics_workspaces  = [ibm_schematics_workspace.main_workspace.name, ibm_schematics_workspace.network_workspace.name]
    terraform_cloud_workspace = var.enable_terraform_cloud_integration ? tfe_workspace.hybrid_workspace[0].name : "Not configured"
    access_group_created   = ibm_iam_access_group.schematics_team.name
    monitoring_services    = compact([
      var.enable_audit_logging ? "Activity Tracker" : null,
      var.monitoring_enabled ? "Log Analysis" : null
    ])
    cost_tracking_enabled  = var.enable_cost_tracking
    team_members_added     = length(var.team_members)
    ready_for_use         = true
  }
  sensitive = false
}
