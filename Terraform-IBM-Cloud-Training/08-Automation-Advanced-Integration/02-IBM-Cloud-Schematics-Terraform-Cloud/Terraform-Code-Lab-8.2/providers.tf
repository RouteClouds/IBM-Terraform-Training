# IBM Cloud Schematics & Terraform Cloud Integration - Providers Configuration
# Topic 8.2: Advanced Integration Lab Environment
# Version: 1.0.0

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    # IBM Cloud Provider for Schematics and infrastructure resources
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.60.0"
    }
    
    # Terraform Cloud Provider for workspace integration
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.50.0"
    }
    
    # Random provider for generating unique resource names
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    
    # Time provider for resource scheduling and delays
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
  
  # Optional: Configure remote state backend
  # Uncomment and configure for production use
  # backend "remote" {
  #   hostname     = "app.terraform.io"
  #   organization = var.terraform_cloud_organization
  #   
  #   workspaces {
  #     name = var.terraform_cloud_workspace_name
  #   }
  # }
}

# IBM Cloud Provider Configuration
provider "ibm" {
  # IBM Cloud API Key - set via environment variable IBMCLOUD_API_KEY
  # or use ibmcloud_api_key variable
  ibmcloud_api_key = var.ibmcloud_api_key
  
  # IBM Cloud Region for resource deployment
  region = var.ibm_region
  
  # Resource Group for organizing resources
  resource_group = var.resource_group_name
  
  # Optional: Configure specific endpoints for different services
  # endpoints {
  #   schematics = "https://schematics.cloud.ibm.com"
  #   iam        = "https://iam.cloud.ibm.com"
  # }
}

# Terraform Cloud Provider Configuration
provider "tfe" {
  # Terraform Cloud API Token - set via environment variable TFE_TOKEN
  # or use terraform_cloud_token variable
  token = var.terraform_cloud_token
  
  # Terraform Cloud hostname (default: app.terraform.io)
  hostname = var.terraform_cloud_hostname
}

# Random Provider Configuration
provider "random" {
  # No specific configuration required
}

# Time Provider Configuration  
provider "time" {
  # No specific configuration required
}

# Data source for current IBM Cloud account information
data "ibm_iam_account_settings" "current_account" {}

# Data source for current user information
data "ibm_iam_user_profile" "current_user" {}

# Data source for available IBM Cloud regions
data "ibm_regions" "available_regions" {}

# Data source for resource group information
data "ibm_resource_group" "target_group" {
  name = var.resource_group_name
}

# Local values for common resource naming and tagging
locals {
  # Common resource prefix for consistent naming
  resource_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner_email
    CreatedBy   = "terraform"
    Purpose     = "schematics-terraform-cloud-integration"
    CostCenter  = var.cost_center
    Compliance  = var.compliance_level
  }
  
  # Workspace naming convention
  workspace_name = "${local.resource_prefix}-workspace"
  
  # Current timestamp for resource tracking
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
  
  # Account and user information
  account_id = data.ibm_iam_account_settings.current_account.account_id
  user_id    = data.ibm_iam_user_profile.current_user.user_id
  
  # Resource group ID
  resource_group_id = data.ibm_resource_group.target_group.id
}

# Random suffix for unique resource naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

# Time offset for scheduled operations
resource "time_offset" "deployment_time" {
  offset_hours = var.deployment_delay_hours
}

# Output provider information for debugging
output "provider_info" {
  description = "Provider configuration information"
  value = {
    ibm_region           = var.ibm_region
    resource_group       = var.resource_group_name
    terraform_cloud_org  = var.terraform_cloud_organization
    account_id          = local.account_id
    deployment_timestamp = local.timestamp
  }
  sensitive = false
}

# Output random suffix for reference
output "resource_suffix" {
  description = "Random suffix for unique resource naming"
  value       = random_string.suffix.result
  sensitive   = false
}
