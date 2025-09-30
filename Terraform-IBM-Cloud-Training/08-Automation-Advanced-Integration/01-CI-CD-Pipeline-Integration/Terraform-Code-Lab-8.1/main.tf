# Main Configuration for IBM Cloud CI/CD Pipeline Integration Lab 8.1
# This file implements enterprise-grade CI/CD automation infrastructure

# Random suffix for unique resource naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Deployment timestamp for tracking
resource "time_static" "deployment_time" {}

# Local values for resource organization
locals {
  # Resource naming convention
  resource_prefix = "${var.project_name}-${var.environment}"
  unique_suffix   = random_string.suffix.result
  
  # Common tags for all resources
  common_tags = [
    "terraform:managed",
    "lab:8.1",
    "purpose:cicd-automation",
    "environment:${var.environment}",
    "project:${var.project_name}",
    "owner:${var.owner}",
    "cost-center:${var.cost_center}",
    "business-unit:${var.business_unit}",
    "created-by:terraform",
    "deployment-timestamp:${time_static.deployment_time.rfc3339}"
  ]
  
  # Merge additional tags
  all_tags = concat(local.common_tags, [
    for key, value in var.additional_tags : "${key}:${value}"
  ])
  
  # Pipeline configuration
  pipeline_config = {
    environments = var.pipeline_environments
    triggers     = var.pipeline_trigger_events
    security     = var.enable_security_scanning
    compliance   = var.enable_compliance_checks
    monitoring   = var.enable_monitoring
  }
}

# Data source for resource group
data "ibm_resource_group" "cicd_resource_group" {
  name = var.resource_group_name
}

# IBM Cloud Schematics Workspace for CI/CD automation
resource "ibm_schematics_workspace" "cicd_workspace" {
  count = var.schematics_workspace_name != "" ? 1 : 0
  
  name              = "${local.resource_prefix}-schematics-${local.unique_suffix}"
  description       = var.schematics_workspace_description
  location          = var.ibm_region
  resource_group    = data.ibm_resource_group.cicd_resource_group.id
  
  # Template configuration
  template_type = "terraform_v1.6"
  template_source_data_request {
    folder = "."
    type   = var.schematics_template_source_type
    
    # Repository configuration
    dynamic "git_source" {
      for_each = var.schematics_template_repo_url != "" ? [1] : []
      content {
        computed_git_repo_url = var.schematics_template_repo_url
        git_branch           = var.schematics_template_repo_branch
      }
    }
  }
  
  # Workspace variables
  template_inputs = [
    {
      name  = "ibmcloud_api_key"
      type  = "string"
      value = var.ibmcloud_api_key
      secure = true
    },
    {
      name  = "environment"
      type  = "string"
      value = var.environment
    },
    {
      name  = "project_name"
      type  = "string"
      value = var.project_name
    }
  ]
  
  tags = local.all_tags
}

# IBM Cloud Code Engine Project for serverless CI/CD execution
resource "ibm_code_engine_project" "cicd_project" {
  name           = "${local.resource_prefix}-code-engine-${local.unique_suffix}"
  resource_group = data.ibm_resource_group.cicd_resource_group.id
  
  tags = local.all_tags
}

# IBM Cloud Code Engine Application for CI/CD webhook handler
resource "ibm_code_engine_app" "cicd_webhook_handler" {
  project_id = ibm_code_engine_project.cicd_project.project_id
  name       = "${local.resource_prefix}-webhook-handler"
  
  image_reference = "icr.io/codeengine/hello"  # Replace with actual webhook handler image
  
  # Resource allocation
  scale_cpu_limit      = "1"
  scale_memory_limit   = "2G"
  scale_min_instances  = 0
  scale_max_instances  = 10
  scale_initial_instances = 1
  
  # Environment variables for webhook configuration
  run_env_variables {
    name  = "ENVIRONMENT"
    value = var.environment
  }
  
  run_env_variables {
    name  = "PROJECT_NAME"
    value = var.project_name
  }
  
  run_env_variables {
    name  = "SCHEMATICS_WORKSPACE_ID"
    value = var.schematics_workspace_name != "" ? ibm_schematics_workspace.cicd_workspace[0].id : ""
  }
  
  # Secret environment variables
  run_env_variables {
    name  = "IBM_CLOUD_API_KEY"
    value = var.ibmcloud_api_key
    type  = "literal"
  }
}

# IBM Cloud Object Storage for pipeline artifacts and state
resource "ibm_resource_instance" "cicd_cos" {
  name              = "${local.resource_prefix}-cos-${local.unique_suffix}"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = data.ibm_resource_group.cicd_resource_group.id
  
  tags = local.all_tags
}

# COS bucket for Terraform state files
resource "ibm_cos_bucket" "terraform_state_bucket" {
  bucket_name          = "${local.resource_prefix}-terraform-state-${local.unique_suffix}"
  resource_instance_id = ibm_resource_instance.cicd_cos.id
  region_location      = var.ibm_region
  storage_class        = "standard"
  
  # Versioning for state file history
  versioning {
    enable = true
  }
  
  # Lifecycle policy for cost optimization
  expire_rule {
    rule_id = "delete-old-versions"
    enable  = true
    days    = 90
    prefix  = "terraform.tfstate"
  }
}

# COS bucket for pipeline artifacts
resource "ibm_cos_bucket" "pipeline_artifacts_bucket" {
  bucket_name          = "${local.resource_prefix}-pipeline-artifacts-${local.unique_suffix}"
  resource_instance_id = ibm_resource_instance.cicd_cos.id
  region_location      = var.ibm_region
  storage_class        = "standard"
  
  # Lifecycle policy for artifact cleanup
  expire_rule {
    rule_id = "cleanup-old-artifacts"
    enable  = true
    days    = 30
    prefix  = "artifacts/"
  }
}

# IBM Cloud Activity Tracker for audit logging
resource "ibm_resource_instance" "activity_tracker" {
  count = var.enable_logging ? 1 : 0
  
  name              = "${local.resource_prefix}-activity-tracker-${local.unique_suffix}"
  service           = "logdnaat"
  plan              = "lite"
  location          = var.ibm_region
  resource_group_id = data.ibm_resource_group.cicd_resource_group.id
  
  tags = local.all_tags
}

# IBM Cloud Monitoring for pipeline observability
resource "ibm_resource_instance" "monitoring" {
  count = var.enable_monitoring ? 1 : 0
  
  name              = "${local.resource_prefix}-monitoring-${local.unique_suffix}"
  service           = "sysdig-monitor"
  plan              = "lite"
  location          = var.ibm_region
  resource_group_id = data.ibm_resource_group.cicd_resource_group.id
  
  tags = local.all_tags
}

# IBM Cloud Log Analysis for centralized logging
resource "ibm_resource_instance" "log_analysis" {
  count = var.enable_logging ? 1 : 0
  
  name              = "${local.resource_prefix}-log-analysis-${local.unique_suffix}"
  service           = "logdna"
  plan              = "lite"
  location          = var.ibm_region
  resource_group_id = data.ibm_resource_group.cicd_resource_group.id
  
  tags = local.all_tags
}

# GitLab Project for CI/CD pipeline (if GitLab is configured)
resource "gitlab_project" "cicd_project" {
  count = var.gitlab_token != "" && var.gitlab_project_id == "" ? 1 : 0
  
  name        = var.gitlab_project_name
  description = "CI/CD automation project for ${var.project_name}"
  
  # Project configuration
  visibility_level                     = "private"
  issues_enabled                      = true
  merge_requests_enabled              = true
  wiki_enabled                        = true
  snippets_enabled                    = true
  container_registry_enabled         = true
  
  # CI/CD configuration
  builds_enabled                      = true
  auto_cancel_pending_pipelines       = "enabled"
  auto_devops_enabled                 = false
  
  # Security and compliance
  only_allow_merge_if_pipeline_succeeds = true
  only_allow_merge_if_all_discussions_are_resolved = true
  remove_source_branch_after_merge    = true
  
  # Default branch protection
  default_branch = "main"
  
  tags = ["terraform", "cicd", "automation", var.environment]
}

# GitLab CI/CD Variables
resource "gitlab_project_variable" "ibm_cloud_api_key" {
  count = var.gitlab_token != "" ? 1 : 0
  
  project = var.gitlab_project_id != "" ? var.gitlab_project_id : gitlab_project.cicd_project[0].id
  key     = "IBM_CLOUD_API_KEY"
  value   = var.ibmcloud_api_key
  masked  = true
  protected = true
}

resource "gitlab_project_variable" "schematics_workspace_id" {
  count = var.gitlab_token != "" && var.schematics_workspace_name != "" ? 1 : 0
  
  project = var.gitlab_project_id != "" ? var.gitlab_project_id : gitlab_project.cicd_project[0].id
  key     = "SCHEMATICS_WORKSPACE_ID"
  value   = ibm_schematics_workspace.cicd_workspace[0].id
  masked  = false
  protected = true
}

resource "gitlab_project_variable" "environment" {
  count = var.gitlab_token != "" ? 1 : 0
  
  project = var.gitlab_project_id != "" ? var.gitlab_project_id : gitlab_project.cicd_project[0].id
  key     = "ENVIRONMENT"
  value   = var.environment
  masked  = false
  protected = false
}

# GitHub Repository for CI/CD pipeline (if GitHub is configured)
resource "github_repository" "cicd_repository" {
  count = var.github_token != "" && var.github_repository_name == "" ? 1 : 0
  
  name        = "${var.project_name}-cicd-automation"
  description = "CI/CD automation repository for ${var.project_name}"
  
  # Repository configuration
  visibility = "private"
  
  # Features
  has_issues      = true
  has_projects    = true
  has_wiki        = true
  has_downloads   = true
  
  # Security
  vulnerability_alerts = true
  
  # Branch protection will be configured separately
  auto_init = true
  
  # Template configuration
  gitignore_template = "Terraform"
  license_template   = "mit"
}

# GitHub Actions Secrets
resource "github_actions_secret" "ibm_cloud_api_key" {
  count = var.github_token != "" ? 1 : 0
  
  repository      = var.github_repository_name != "" ? var.github_repository_name : github_repository.cicd_repository[0].name
  secret_name     = "IBM_CLOUD_API_KEY"
  plaintext_value = var.ibmcloud_api_key
}

resource "github_actions_secret" "schematics_workspace_id" {
  count = var.github_token != "" && var.schematics_workspace_name != "" ? 1 : 0
  
  repository      = var.github_repository_name != "" ? var.github_repository_name : github_repository.cicd_repository[0].name
  secret_name     = "SCHEMATICS_WORKSPACE_ID"
  plaintext_value = ibm_schematics_workspace.cicd_workspace[0].id
}

# Terraform Cloud Workspace (if TFE is configured)
resource "tfe_workspace" "cicd_workspace" {
  count = var.tfe_token != "" && var.tfe_workspace_name == "" ? 1 : 0
  
  name         = "${var.project_name}-${var.environment}-cicd"
  organization = var.tfe_organization
  description  = "CI/CD automation workspace for ${var.project_name}"
  
  # Workspace configuration
  auto_apply        = false
  queue_all_runs    = false
  speculative_enabled = true
  
  # VCS configuration (will be set up separately)
  working_directory = "/"
  
  tags = ["terraform", "cicd", "automation", var.environment]
}

# Terraform Cloud Variables
resource "tfe_variable" "ibm_cloud_api_key" {
  count = var.tfe_token != "" ? 1 : 0
  
  workspace_id = var.tfe_workspace_name != "" ? data.tfe_workspace.cicd_workspace[0].id : tfe_workspace.cicd_workspace[0].id
  key          = "ibmcloud_api_key"
  value        = var.ibmcloud_api_key
  category     = "terraform"
  sensitive    = true
  description  = "IBM Cloud API key for authentication"
}

resource "tfe_variable" "environment" {
  count = var.tfe_token != "" ? 1 : 0
  
  workspace_id = var.tfe_workspace_name != "" ? data.tfe_workspace.cicd_workspace[0].id : tfe_workspace.cicd_workspace[0].id
  key          = "environment"
  value        = var.environment
  category     = "terraform"
  description  = "Environment name for resource organization"
}

# Local file for GitLab CI configuration template
resource "local_file" "gitlab_ci_template" {
  count = var.gitlab_token != "" ? 1 : 0
  
  filename = "${path.module}/templates/.gitlab-ci.yml"
  content = templatefile("${path.module}/templates/gitlab-ci.yml.tpl", {
    environment           = var.environment
    project_name         = var.project_name
    enable_security_scan = var.enable_security_scanning
    enable_compliance    = var.enable_compliance_checks
    pipeline_environments = var.pipeline_environments
    security_tools       = var.security_scanning_tools
    compliance_frameworks = var.compliance_frameworks
  })
}

# Local file for GitHub Actions workflow template
resource "local_file" "github_actions_template" {
  count = var.github_token != "" ? 1 : 0
  
  filename = "${path.module}/templates/.github/workflows/terraform.yml"
  content = templatefile("${path.module}/templates/github-actions.yml.tpl", {
    environment           = var.environment
    project_name         = var.project_name
    enable_security_scan = var.enable_security_scanning
    enable_compliance    = var.enable_compliance_checks
    pipeline_environments = var.pipeline_environments
    security_tools       = var.security_scanning_tools
    compliance_frameworks = var.compliance_frameworks
  })
}
