# Output Values for IBM Cloud CI/CD Pipeline Integration Lab 8.1
# This file defines comprehensive outputs for CI/CD automation infrastructure

# IBM Cloud Schematics Workspace Outputs
output "schematics_workspace_id" {
  description = "ID of the IBM Cloud Schematics workspace for CI/CD automation"
  value       = var.schematics_workspace_name != "" ? ibm_schematics_workspace.cicd_workspace[0].id : null
}

output "schematics_workspace_name" {
  description = "Name of the IBM Cloud Schematics workspace"
  value       = var.schematics_workspace_name != "" ? ibm_schematics_workspace.cicd_workspace[0].name : null
}

output "schematics_workspace_url" {
  description = "URL to access the Schematics workspace in IBM Cloud console"
  value = var.schematics_workspace_name != "" ? "https://cloud.ibm.com/schematics/workspaces/${ibm_schematics_workspace.cicd_workspace[0].id}" : null
}

output "schematics_workspace_status" {
  description = "Current status of the Schematics workspace"
  value       = var.schematics_workspace_name != "" ? ibm_schematics_workspace.cicd_workspace[0].status : null
}

# IBM Cloud Code Engine Outputs
output "code_engine_project_id" {
  description = "ID of the IBM Cloud Code Engine project for serverless CI/CD execution"
  value       = ibm_code_engine_project.cicd_project.project_id
}

output "code_engine_project_name" {
  description = "Name of the IBM Cloud Code Engine project"
  value       = ibm_code_engine_project.cicd_project.name
}

output "code_engine_webhook_handler_url" {
  description = "URL of the Code Engine webhook handler application"
  value       = ibm_code_engine_app.cicd_webhook_handler.endpoint
}

output "code_engine_webhook_handler_status" {
  description = "Status of the Code Engine webhook handler application"
  value       = ibm_code_engine_app.cicd_webhook_handler.status
}

# IBM Cloud Object Storage Outputs
output "cos_instance_id" {
  description = "ID of the IBM Cloud Object Storage instance for pipeline artifacts"
  value       = ibm_resource_instance.cicd_cos.id
}

output "cos_instance_crn" {
  description = "Cloud Resource Name (CRN) of the COS instance"
  value       = ibm_resource_instance.cicd_cos.crn
}

output "terraform_state_bucket_name" {
  description = "Name of the COS bucket for Terraform state files"
  value       = ibm_cos_bucket.terraform_state_bucket.bucket_name
}

output "terraform_state_bucket_url" {
  description = "URL of the Terraform state bucket"
  value       = "https://${ibm_cos_bucket.terraform_state_bucket.bucket_name}.s3.${var.ibm_region}.cloud-object-storage.appdomain.cloud"
}

output "pipeline_artifacts_bucket_name" {
  description = "Name of the COS bucket for pipeline artifacts"
  value       = ibm_cos_bucket.pipeline_artifacts_bucket.bucket_name
}

output "pipeline_artifacts_bucket_url" {
  description = "URL of the pipeline artifacts bucket"
  value       = "https://${ibm_cos_bucket.pipeline_artifacts_bucket.bucket_name}.s3.${var.ibm_region}.cloud-object-storage.appdomain.cloud"
}

# Monitoring and Logging Outputs
output "activity_tracker_instance_id" {
  description = "ID of the IBM Cloud Activity Tracker instance for audit logging"
  value       = var.enable_logging ? ibm_resource_instance.activity_tracker[0].id : null
}

output "monitoring_instance_id" {
  description = "ID of the IBM Cloud Monitoring instance for pipeline observability"
  value       = var.enable_monitoring ? ibm_resource_instance.monitoring[0].id : null
}

output "log_analysis_instance_id" {
  description = "ID of the IBM Cloud Log Analysis instance for centralized logging"
  value       = var.enable_logging ? ibm_resource_instance.log_analysis[0].id : null
}

output "monitoring_dashboard_url" {
  description = "URL to access the monitoring dashboard"
  value = var.enable_monitoring ? "https://cloud.ibm.com/observe/monitoring/${ibm_resource_instance.monitoring[0].id}" : null
}

output "log_analysis_dashboard_url" {
  description = "URL to access the log analysis dashboard"
  value = var.enable_logging ? "https://cloud.ibm.com/observe/logging/${ibm_resource_instance.log_analysis[0].id}" : null
}

# GitLab CI/CD Outputs
output "gitlab_project_id" {
  description = "ID of the GitLab project for CI/CD pipeline"
  value = var.gitlab_token != "" ? (
    var.gitlab_project_id != "" ? var.gitlab_project_id : gitlab_project.cicd_project[0].id
  ) : null
}

output "gitlab_project_url" {
  description = "URL of the GitLab project"
  value = var.gitlab_token != "" ? (
    var.gitlab_project_id != "" ? "https://gitlab.com/project/${var.gitlab_project_id}" : gitlab_project.cicd_project[0].web_url
  ) : null
}

output "gitlab_project_ssh_url" {
  description = "SSH URL for GitLab project clone"
  value = var.gitlab_token != "" && var.gitlab_project_id == "" ? gitlab_project.cicd_project[0].ssh_url_to_repo : null
}

output "gitlab_project_http_url" {
  description = "HTTP URL for GitLab project clone"
  value = var.gitlab_token != "" && var.gitlab_project_id == "" ? gitlab_project.cicd_project[0].http_url_to_repo : null
}

# GitHub Actions Outputs
output "github_repository_name" {
  description = "Name of the GitHub repository for CI/CD pipeline"
  value = var.github_token != "" ? (
    var.github_repository_name != "" ? var.github_repository_name : github_repository.cicd_repository[0].name
  ) : null
}

output "github_repository_url" {
  description = "URL of the GitHub repository"
  value = var.github_token != "" ? (
    var.github_repository_name != "" ? "https://github.com/${var.github_organization}/${var.github_repository_name}" : github_repository.cicd_repository[0].html_url
  ) : null
}

output "github_repository_clone_url" {
  description = "Clone URL for GitHub repository"
  value = var.github_token != "" && var.github_repository_name == "" ? github_repository.cicd_repository[0].clone_url : null
}

output "github_repository_ssh_url" {
  description = "SSH URL for GitHub repository clone"
  value = var.github_token != "" && var.github_repository_name == "" ? github_repository.cicd_repository[0].ssh_clone_url : null
}

# Terraform Cloud/Enterprise Outputs
output "tfe_workspace_id" {
  description = "ID of the Terraform Cloud workspace for CI/CD integration"
  value = var.tfe_token != "" ? (
    var.tfe_workspace_name != "" ? data.tfe_workspace.cicd_workspace[0].id : tfe_workspace.cicd_workspace[0].id
  ) : null
}

output "tfe_workspace_name" {
  description = "Name of the Terraform Cloud workspace"
  value = var.tfe_token != "" ? (
    var.tfe_workspace_name != "" ? data.tfe_workspace.cicd_workspace[0].name : tfe_workspace.cicd_workspace[0].name
  ) : null
}

output "tfe_workspace_url" {
  description = "URL to access the Terraform Cloud workspace"
  value = var.tfe_token != "" ? "https://${var.tfe_hostname}/app/${var.tfe_organization}/workspaces/${var.tfe_workspace_name != "" ? data.tfe_workspace.cicd_workspace[0].name : tfe_workspace.cicd_workspace[0].name}" : null
}

# Resource Group and Region Information
output "resource_group_id" {
  description = "ID of the IBM Cloud resource group used for CI/CD resources"
  value       = data.ibm_resource_group.cicd_resource_group.id
}

output "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  value       = data.ibm_resource_group.cicd_resource_group.name
}

output "deployment_region" {
  description = "IBM Cloud region where CI/CD infrastructure was deployed"
  value       = var.ibm_region
}

# Deployment Metadata
output "deployment_timestamp" {
  description = "Timestamp when the CI/CD infrastructure was deployed"
  value       = time_static.deployment_time.rfc3339
}

output "random_suffix" {
  description = "Random suffix used for unique resource naming"
  value       = random_string.suffix.result
}

output "resource_prefix" {
  description = "Resource prefix used for naming convention"
  value       = local.resource_prefix
}

# Pipeline Configuration Summary
output "pipeline_configuration" {
  description = "Summary of CI/CD pipeline configuration"
  value = {
    environments          = var.pipeline_environments
    trigger_events       = var.pipeline_trigger_events
    security_scanning    = var.enable_security_scanning
    compliance_checks    = var.enable_compliance_checks
    cost_estimation      = var.enable_cost_estimation
    drift_detection      = var.enable_drift_detection
    monitoring_enabled   = var.enable_monitoring
    logging_enabled      = var.enable_logging
    security_tools       = var.security_scanning_tools
    compliance_frameworks = var.compliance_frameworks
    timeout_minutes      = var.pipeline_timeout_minutes
    parallel_limit       = var.parallel_execution_limit
  }
}

# Applied Tags Information
output "applied_tags" {
  description = "Tags applied to all CI/CD resources"
  value       = local.all_tags
}

# Cost and Billing Information
output "cost_estimation" {
  description = "Estimated monthly cost breakdown for CI/CD infrastructure"
  value = {
    schematics_workspace = var.schematics_workspace_name != "" ? "$10-50/month (based on usage)" : "Not deployed"
    code_engine_project  = "$5-25/month (based on executions)"
    object_storage       = "$5-15/month (based on storage and requests)"
    monitoring_services  = var.enable_monitoring ? "$10-30/month" : "Not enabled"
    logging_services     = var.enable_logging ? "$10-30/month" : "Not enabled"
    total_estimated      = "$40-150/month (varies by usage)"
    note                = "Actual costs may vary based on usage patterns and selected service plans"
  }
}

# Security and Compliance Summary
output "security_compliance_summary" {
  description = "Summary of security and compliance features enabled"
  value = {
    security_scanning_enabled    = var.enable_security_scanning
    compliance_checks_enabled    = var.enable_compliance_checks
    audit_logging_enabled       = var.enable_logging
    monitoring_enabled          = var.enable_monitoring
    security_tools_configured   = var.security_scanning_tools
    compliance_frameworks       = var.compliance_frameworks
    encrypted_storage           = true
    access_control_enabled      = true
    vulnerability_scanning      = var.enable_security_scanning
  }
}

# Connection and Access Information
output "connection_information" {
  description = "Information for connecting to and using the CI/CD infrastructure"
  value = {
    schematics_cli_command = var.schematics_workspace_name != "" ? "ibmcloud schematics workspace get --id ${ibm_schematics_workspace.cicd_workspace[0].id}" : null
    code_engine_cli_command = "ibmcloud ce project select --name ${ibm_code_engine_project.cicd_project.name}"
    webhook_endpoint       = ibm_code_engine_app.cicd_webhook_handler.endpoint
    state_bucket_access    = "Configure backend with bucket: ${ibm_cos_bucket.terraform_state_bucket.bucket_name}"
    monitoring_access      = var.enable_monitoring ? "Access via IBM Cloud console or CLI" : "Not configured"
    logging_access         = var.enable_logging ? "Access via IBM Cloud console or CLI" : "Not configured"
  }
}

# Lab Summary for Documentation
output "lab_summary" {
  description = "Comprehensive summary of deployed CI/CD infrastructure for lab documentation"
  value = {
    infrastructure = {
      schematics_workspace = var.schematics_workspace_name != "" ? {
        id   = ibm_schematics_workspace.cicd_workspace[0].id
        name = ibm_schematics_workspace.cicd_workspace[0].name
        url  = "https://cloud.ibm.com/schematics/workspaces/${ibm_schematics_workspace.cicd_workspace[0].id}"
      } : null
      code_engine_project = {
        id   = ibm_code_engine_project.cicd_project.project_id
        name = ibm_code_engine_project.cicd_project.name
      }
      object_storage = {
        instance_id = ibm_resource_instance.cicd_cos.id
        state_bucket = ibm_cos_bucket.terraform_state_bucket.bucket_name
        artifacts_bucket = ibm_cos_bucket.pipeline_artifacts_bucket.bucket_name
      }
    }
    cicd_platforms = {
      gitlab_configured = var.gitlab_token != ""
      github_configured = var.github_token != ""
      tfe_configured    = var.tfe_token != ""
    }
    features_enabled = {
      security_scanning = var.enable_security_scanning
      compliance_checks = var.enable_compliance_checks
      monitoring       = var.enable_monitoring
      logging          = var.enable_logging
      drift_detection  = var.enable_drift_detection
    }
    deployment_info = {
      timestamp     = time_static.deployment_time.rfc3339
      region        = var.ibm_region
      environment   = var.environment
      project_name  = var.project_name
      resource_prefix = local.resource_prefix
    }
  }
}
