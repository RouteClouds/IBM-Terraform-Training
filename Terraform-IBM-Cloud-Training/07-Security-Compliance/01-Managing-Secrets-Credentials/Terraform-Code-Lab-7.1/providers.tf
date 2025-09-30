# IBM Cloud Terraform Training - Topic 7.1: Managing Secrets and Credentials
# Terraform Code Lab 7.1 - Provider Configuration
#
# This file configures the required providers for enterprise secrets management
# with IBM Cloud security services including Key Protect, Secrets Manager, and IAM.
#
# Author: IBM Cloud Terraform Training Team
# Version: 1.0.0
# Last Updated: 2024-09-15

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # IBM Cloud Provider for all IBM Cloud resources
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }

    # Random provider for generating secure passwords and tokens
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }

    # Time provider for time-based operations and delays
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }

    # TLS provider for certificate and key generation
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }

    # Local provider for local file operations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }

  # Backend configuration for secure state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket                      = "your-terraform-state-bucket"
  #   key                         = "security/secrets-management/terraform.tfstate"
  #   region                      = "us-south"
  #   endpoint                    = "s3.us-south.cloud-object-storage.appdomain.cloud"
  #   skip_credentials_validation = true
  #   skip_region_validation      = true
  # }
}

# IBM Cloud Provider Configuration
provider "ibm" {
  # IBM Cloud API Key - set via environment variable IBMCLOUD_API_KEY
  # or use ibmcloud_api_key variable
  ibmcloud_api_key = var.ibmcloud_api_key

  # Default region for resource deployment
  region = var.primary_region
}

# Random Provider Configuration
provider "random" {
  # No specific configuration required
}

# Time Provider Configuration  
provider "time" {
  # No specific configuration required
}

# TLS Provider Configuration
provider "tls" {
  # No specific configuration required
}

# Local Provider Configuration
provider "local" {
  # No specific configuration required
}

# Data source for resource group
data "ibm_resource_group" "security" {
  name = var.resource_group_name
}

# Data source for current account information
data "ibm_iam_account_settings" "current" {}

# Data source for available regions (using resource groups as alternative)
# data "ibm_regions" "available" {} # Not available in current provider version

# Data source for available zones in primary region
data "ibm_is_zones" "primary" {
  region = var.primary_region
}

# Local values for common configurations
locals {
  # Common tags for all resources
  common_tags = [
    "project:${var.project_name}",
    "environment:${var.environment}",
    "topic:security-compliance",
    "subtopic:secrets-management",
    "training:ibm-terraform",
    "created-by:terraform",
    "created-on:${formatdate("YYYY-MM-DD", timestamp())}"
  ]

  # Environment-specific configurations
  environment_config = {
    development = {
      key_rotation_days     = 90
      session_timeout_hours = 8
      mfa_required          = false
      audit_retention_days  = 30
      dual_auth_required    = false
    }

    staging = {
      key_rotation_days     = 30
      session_timeout_hours = 4
      mfa_required          = true
      audit_retention_days  = 90
      dual_auth_required    = false
    }

    production = {
      key_rotation_days     = 7
      session_timeout_hours = 1
      mfa_required          = true
      audit_retention_days  = 2555 # 7 years for compliance
      dual_auth_required    = true
    }
  }

  # Current environment configuration
  current_env_config = local.environment_config[var.environment]

  # Naming conventions
  naming_prefix = "${var.project_name}-${var.environment}"

  # Security service names
  key_protect_name     = "${local.naming_prefix}-key-protect"
  secrets_manager_name = "${local.naming_prefix}-secrets-manager"
  cos_instance_name    = "${local.naming_prefix}-audit-storage"
  monitoring_name      = "${local.naming_prefix}-monitoring"

  # Network and security configurations
  allowed_ip_ranges = var.environment == "production" ? var.production_ip_ranges : var.development_ip_ranges

  # Compliance requirements based on environment
  compliance_requirements = {
    soc2_required     = var.environment == "production"
    iso27001_required = var.environment == "production"
    gdpr_required     = var.gdpr_compliance_required
    hipaa_required    = var.hipaa_compliance_required
  }
}

# Validation checks for provider configuration
check "provider_validation" {
  assert {
    condition     = can(data.ibm_resource_group.security.id)
    error_message = "Resource group '${var.resource_group_name}' not found. Please verify the resource group exists and you have access."
  }

  # Region validation removed due to data source limitations
  # assert {
  #   condition = contains(data.ibm_regions.available.regions, var.primary_region)
  #   error_message = "Primary region '${var.primary_region}' is not available. Please choose a valid IBM Cloud region."
  # }

  assert {
    condition     = length(data.ibm_is_zones.primary.zones) >= 1
    error_message = "No availability zones found in region '${var.primary_region}'. Please verify the region supports VPC infrastructure."
  }
}

# Output provider information for debugging
output "provider_info" {
  description = "Provider configuration information for debugging"
  value = {
    terraform_workspace     = terraform.workspace
    ibm_provider_version    = "~> 1.58.0"
    primary_region          = var.primary_region
    resource_group_id       = data.ibm_resource_group.security.id
    available_zones         = data.ibm_is_zones.primary.zones
    environment_config      = local.current_env_config
    compliance_requirements = local.compliance_requirements
  }
}
