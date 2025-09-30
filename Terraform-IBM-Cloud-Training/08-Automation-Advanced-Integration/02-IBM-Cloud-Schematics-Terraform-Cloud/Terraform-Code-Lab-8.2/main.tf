# IBM Cloud Schematics & Terraform Cloud Integration - Main Configuration
# Topic 8.2: Advanced Integration Lab Environment
# Version: 1.0.0

# =============================================================================
# IBM CLOUD SCHEMATICS WORKSPACE
# =============================================================================

# Primary Schematics workspace for infrastructure automation
resource "ibm_schematics_workspace" "main_workspace" {
  name        = "${local.workspace_name}-${random_string.suffix.result}"
  description = var.workspace_description
  location    = var.ibm_region
  
  # Resource group assignment
  resource_group = local.resource_group_id
  
  # Template configuration from Git repository
  template_repo {
    url    = var.workspace_template_repo
    branch = var.workspace_template_branch
    folder = var.workspace_template_folder
  }
  
  # Workspace variables for template execution
  template_data {
    folder = var.workspace_template_folder
    type   = "terraform_v1.5"
    
    # Environment variables for workspace execution
    env_values = [
      {
        name   = "TF_LOG"
        value  = "INFO"
        secure = false
      },
      {
        name   = "IBMCLOUD_API_KEY"
        value  = var.ibmcloud_api_key
        secure = true
      }
    ]
    
    # Terraform variables for infrastructure deployment
    variablestore = [
      {
        name  = "region"
        value = var.ibm_region
        type  = "string"
      },
      {
        name  = "resource_group"
        value = var.resource_group_name
        type  = "string"
      },
      {
        name  = "project_name"
        value = var.project_name
        type  = "string"
      },
      {
        name  = "environment"
        value = var.environment
        type  = "string"
      }
    ]
  }
  
  # Workspace tags for organization and cost tracking
  tags = [
    for key, value in local.common_tags : "${key}:${value}"
  ]
  
  # Workspace settings
  frozen     = false
  locked     = false
  
  # Lifecycle management
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      template_repo[0].url  # Ignore URL changes to prevent recreation
    ]
  }
}

# =============================================================================
# TERRAFORM CLOUD INTEGRATION
# =============================================================================

# Terraform Cloud workspace for hybrid automation
resource "tfe_workspace" "hybrid_workspace" {
  count = var.enable_terraform_cloud_integration ? 1 : 0
  
  name         = "${local.workspace_name}-hybrid-${random_string.suffix.result}"
  organization = var.terraform_cloud_organization
  description  = "Hybrid workspace integrating with IBM Cloud Schematics"
  
  # Workspace configuration
  auto_apply            = false
  file_triggers_enabled = true
  queue_all_runs       = false
  speculative_enabled  = true
  
  # VCS integration (optional)
  # vcs_repo {
  #   identifier     = "organization/repository"
  #   branch         = var.workspace_template_branch
  #   oauth_token_id = var.vcs_oauth_token_id
  # }
  
  # Working directory
  working_directory = var.workspace_template_folder
  
  # Terraform version
  terraform_version = "~> 1.5.0"
  
  # Workspace tags
  tag_names = [
    "ibm-cloud",
    "schematics",
    "hybrid",
    var.environment,
    var.project_name
  ]
}

# Terraform Cloud workspace variables
resource "tfe_variable" "workspace_variables" {
  for_each = var.enable_terraform_cloud_integration ? {
    "ibmcloud_api_key" = {
      value       = var.ibmcloud_api_key
      category    = "env"
      sensitive   = true
      description = "IBM Cloud API key for authentication"
    }
    "TF_VAR_region" = {
      value       = var.ibm_region
      category    = "env"
      sensitive   = false
      description = "IBM Cloud region"
    }
    "TF_VAR_resource_group" = {
      value       = var.resource_group_name
      category    = "env"
      sensitive   = false
      description = "IBM Cloud resource group"
    }
    "project_name" = {
      value       = var.project_name
      category    = "terraform"
      sensitive   = false
      description = "Project name for resource naming"
    }
    "environment" = {
      value       = var.environment
      category    = "terraform"
      sensitive   = false
      description = "Environment name"
    }
  } : {}
  
  workspace_id = tfe_workspace.hybrid_workspace[0].id
  key          = each.key
  value        = each.value.value
  category     = each.value.category
  sensitive    = each.value.sensitive
  description  = each.value.description
}

# =============================================================================
# IAM ACCESS CONTROL
# =============================================================================

# IAM access group for team collaboration
resource "ibm_iam_access_group" "schematics_team" {
  name        = "${var.access_group_name}-${random_string.suffix.result}"
  description = "Access group for Schematics workspace team members"
  
  tags = [
    for key, value in local.common_tags : "${key}:${value}"
  ]
}

# IAM access group policy for Schematics access
resource "ibm_iam_access_group_policy" "schematics_policy" {
  access_group_id = ibm_iam_access_group.schematics_team.id
  
  roles = [
    var.workspace_access_level == "viewer" ? "Viewer" : 
    var.workspace_access_level == "operator" ? "Operator" : "Manager"
  ]
  
  resources {
    service           = "schematics"
    resource_group_id = local.resource_group_id
  }
}

# IAM access group policy for resource group access
resource "ibm_iam_access_group_policy" "resource_group_policy" {
  access_group_id = ibm_iam_access_group.schematics_team.id
  
  roles = ["Viewer", "Editor"]
  
  resources {
    resource_type     = "resource-group"
    resource          = local.resource_group_id
  }
}

# Add team members to access group
resource "ibm_iam_access_group_members" "team_members" {
  count = length(var.team_members) > 0 ? 1 : 0
  
  access_group_id = ibm_iam_access_group.schematics_team.id
  ibm_ids         = var.team_members
}

# =============================================================================
# COST TRACKING AND BUDGET MANAGEMENT
# =============================================================================

# Cost tracking configuration (using resource tags)
resource "ibm_resource_tag" "cost_tracking" {
  count = var.enable_cost_tracking ? 1 : 0
  
  resource_id = ibm_schematics_workspace.main_workspace.id
  
  tags = [
    "cost-center:${var.cost_center}",
    "budget-limit:${var.budget_limit}",
    "budget-alert:${var.budget_alert_threshold}",
    "auto-cleanup:${var.auto_destroy_schedule != "" ? "enabled" : "disabled"}"
  ]
}

# =============================================================================
# MONITORING AND LOGGING
# =============================================================================

# Activity tracker for audit logging
resource "ibm_resource_instance" "activity_tracker" {
  count = var.enable_audit_logging ? 1 : 0
  
  name              = "${local.resource_prefix}-activity-tracker-${random_string.suffix.result}"
  service           = "logdnaat"
  plan              = "lite"
  location          = var.ibm_region
  resource_group_id = local.resource_group_id
  
  parameters = {
    "default_receiver" = true
  }
  
  tags = [
    for key, value in local.common_tags : "${key}:${value}"
  ]
}

# Log Analysis instance for workspace logs
resource "ibm_resource_instance" "log_analysis" {
  count = var.monitoring_enabled ? 1 : 0
  
  name              = "${local.resource_prefix}-log-analysis-${random_string.suffix.result}"
  service           = "logdna"
  plan              = "lite"
  location          = var.ibm_region
  resource_group_id = local.resource_group_id
  
  tags = [
    for key, value in local.common_tags : "${key}:${value}"
  ]
}

# =============================================================================
# WORKSPACE DEPENDENCIES AND ORCHESTRATION
# =============================================================================

# Example dependency workspace (network infrastructure)
resource "ibm_schematics_workspace" "network_workspace" {
  name        = "${local.workspace_name}-network-${random_string.suffix.result}"
  description = "Network infrastructure workspace for dependency demonstration"
  location    = var.ibm_region
  
  resource_group = local.resource_group_id
  
  template_repo {
    url    = var.workspace_template_repo
    branch = var.workspace_template_branch
    folder = "examples/vpc-network"
  }
  
  template_data {
    folder = "examples/vpc-network"
    type   = "terraform_v1.5"
    
    env_values = [
      {
        name   = "IBMCLOUD_API_KEY"
        value  = var.ibmcloud_api_key
        secure = true
      }
    ]
    
    variablestore = [
      {
        name  = "region"
        value = var.ibm_region
        type  = "string"
      },
      {
        name  = "resource_group"
        value = var.resource_group_name
        type  = "string"
      }
    ]
  }
  
  tags = [
    for key, value in local.common_tags : "${key}:${value}"
  ]
  
  # This workspace should be created first
  lifecycle {
    create_before_destroy = true
  }
}
