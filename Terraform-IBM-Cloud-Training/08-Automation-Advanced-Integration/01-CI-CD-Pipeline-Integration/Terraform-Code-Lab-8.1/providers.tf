# Provider Configuration for IBM Cloud CI/CD Pipeline Integration Lab 8.1
# This file configures the required providers for implementing enterprise CI/CD automation

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    # IBM Cloud Provider for infrastructure management
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.60.0"
    }
    
    # GitLab Provider for CI/CD pipeline configuration
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 16.0"
    }
    
    # GitHub Provider for GitHub Actions integration
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    
    # TFE Provider for Terraform Cloud integration
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.50.0"
    }
    
    # Random Provider for generating unique identifiers
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    
    # Time Provider for deployment timestamps
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    
    # Local Provider for local file operations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    
    # Template Provider for configuration templating
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    
    # HTTP Provider for API interactions
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
  
  # Backend configuration for remote state management
  backend "s3" {
    # IBM Cloud Object Storage backend configuration
    # This will be configured via backend config file or environment variables
    # Example configuration:
    # bucket                      = "terraform-state-bucket"
    # key                         = "cicd-pipeline/terraform.tfstate"
    # region                      = "us-south"
    # endpoint                    = "s3.us-south.cloud-object-storage.appdomain.cloud"
    # access_key                  = "access_key_from_service_credentials"
    # secret_key                  = "secret_key_from_service_credentials"
    # skip_credentials_validation = true
    # skip_region_validation      = true
  }
}

# IBM Cloud Provider Configuration
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibm_region
  
  # Additional provider configuration
  generation       = 2  # VPC Generation 2
  ibmcloud_timeout = 300 # 5 minutes timeout for API calls
  
  # Default tags applied to all resources
  default_tags = [
    "terraform:managed",
    "lab:8.1",
    "purpose:cicd-automation",
    "environment:${var.environment}"
  ]
}

# GitLab Provider Configuration
provider "gitlab" {
  token    = var.gitlab_token
  base_url = var.gitlab_base_url
  
  # Rate limiting configuration
  early_auth_check = true
  
  # Default configuration for GitLab resources
  default_branch = "main"
}

# GitHub Provider Configuration
provider "github" {
  token = var.github_token
  owner = var.github_organization
  
  # GitHub Enterprise configuration (if applicable)
  base_url = var.github_base_url
  
  # Default configuration
  write_delay_ms      = 1000
  read_delay_ms       = 0
  retry_delay_ms      = 1000
  max_retries         = 3
  retry_on_http_codes = [502, 503, 504]
}

# Terraform Cloud Provider Configuration
provider "tfe" {
  hostname = var.tfe_hostname
  token    = var.tfe_token
  
  # Organization configuration
  organization = var.tfe_organization
  
  # SSL verification (set to false for self-hosted TFE)
  ssl_skip_verify = var.tfe_ssl_skip_verify
}

# Random Provider Configuration
provider "random" {
  # No specific configuration required
}

# Time Provider Configuration
provider "time" {
  # No specific configuration required
}

# Local Provider Configuration
provider "local" {
  # No specific configuration required
}

# Template Provider Configuration
provider "template" {
  # No specific configuration required
}

# HTTP Provider Configuration
provider "http" {
  # No specific configuration required
}

# Data sources for provider validation and information
data "ibm_iam_account_settings" "account_settings" {
  # Validate IBM Cloud account access
}

data "ibm_resource_group" "cicd_resource_group" {
  name = var.resource_group_name
}

data "ibm_is_zones" "regional_zones" {
  region = var.ibm_region
}

# GitLab project data source (if project exists)
data "gitlab_project" "cicd_project" {
  count = var.gitlab_project_id != "" ? 1 : 0
  id    = var.gitlab_project_id
}

# GitHub repository data source (if repository exists)
data "github_repository" "cicd_repository" {
  count = var.github_repository_name != "" ? 1 : 0
  name  = var.github_repository_name
}

# Terraform Cloud workspace data source (if workspace exists)
data "tfe_workspace" "cicd_workspace" {
  count        = var.tfe_workspace_name != "" ? 1 : 0
  name         = var.tfe_workspace_name
  organization = var.tfe_organization
}

# Local values for provider configuration validation
locals {
  # Provider validation flags
  ibm_provider_configured    = var.ibmcloud_api_key != ""
  gitlab_provider_configured = var.gitlab_token != ""
  github_provider_configured = var.github_token != ""
  tfe_provider_configured    = var.tfe_token != ""
  
  # Provider configuration summary
  configured_providers = [
    local.ibm_provider_configured ? "ibm" : null,
    local.gitlab_provider_configured ? "gitlab" : null,
    local.github_provider_configured ? "github" : null,
    local.tfe_provider_configured ? "tfe" : null
  ]
  
  # Remove null values
  active_providers = compact(local.configured_providers)
  
  # Validation messages
  provider_validation = {
    ibm_cloud = local.ibm_provider_configured ? "✅ IBM Cloud provider configured" : "❌ IBM Cloud API key required"
    gitlab    = local.gitlab_provider_configured ? "✅ GitLab provider configured" : "⚠️ GitLab token not provided (optional)"
    github    = local.github_provider_configured ? "✅ GitHub provider configured" : "⚠️ GitHub token not provided (optional)"
    tfe       = local.tfe_provider_configured ? "✅ Terraform Cloud provider configured" : "⚠️ TFE token not provided (optional)"
  }
  
  # Common tags for all resources
  common_tags = [
    "terraform:managed",
    "lab:8.1",
    "purpose:cicd-automation",
    "environment:${var.environment}",
    "project:${var.project_name}",
    "owner:${var.owner}",
    "created-by:terraform",
    "managed-by:cicd-pipeline"
  ]
  
  # Resource naming convention
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # Deployment metadata
  deployment_metadata = {
    terraform_version = "1.6.0"
    provider_versions = {
      ibm    = "~> 1.60.0"
      gitlab = "~> 16.0"
      github = "~> 5.0"
      tfe    = "~> 0.50.0"
    }
    deployment_timestamp = timestamp()
    deployment_region     = var.ibm_region
    deployment_zone       = data.ibm_is_zones.regional_zones.zones[0]
  }
}

# Validation checks for required providers
resource "null_resource" "provider_validation" {
  # Ensure IBM Cloud provider is properly configured
  lifecycle {
    precondition {
      condition     = local.ibm_provider_configured
      error_message = "IBM Cloud API key is required for this configuration."
    }
    
    precondition {
      condition     = contains(["us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd"], var.ibm_region)
      error_message = "IBM Cloud region must be a valid region."
    }
    
    precondition {
      condition     = var.resource_group_name != ""
      error_message = "Resource group name is required."
    }
  }
  
  triggers = {
    ibm_api_key_hash = sha256(var.ibmcloud_api_key)
    region           = var.ibm_region
    resource_group   = var.resource_group_name
  }
}

# Output provider configuration status
output "provider_configuration_status" {
  description = "Status of provider configurations"
  value = {
    active_providers      = local.active_providers
    validation_messages   = local.provider_validation
    deployment_metadata   = local.deployment_metadata
    resource_prefix       = local.resource_prefix
    common_tags          = local.common_tags
  }
}
