# =============================================================================
# TERRAFORM AND PROVIDER CONFIGURATION
# Lab 3.1: Directory Structure and Configuration Files
# =============================================================================

terraform {
  # Specify minimum Terraform version required for this configuration
  required_version = ">= 1.5.0"
  
  # Define required providers with version constraints
  required_providers {
    # IBM Cloud Provider for managing IBM Cloud resources
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }
    
    # Random provider for generating unique resource names
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    
    # Time provider for managing time-based resources and delays
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    
    # Local provider for local file operations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

# =============================================================================
# IBM CLOUD PROVIDER CONFIGURATION
# =============================================================================

# Default IBM Cloud provider configuration
provider "ibm" {
  # IBM Cloud API Key - provided via environment variable IC_API_KEY
  # or through terraform.tfvars file
  # ibmcloud_api_key = var.ibmcloud_api_key
  
  # Default region for resource provisioning
  region = var.ibm_region
  
  # Optional: Specify IBM Cloud account ID for multi-account scenarios
  # account_id = var.account_id
}

# =============================================================================
# ADDITIONAL PROVIDER CONFIGURATIONS
# =============================================================================

# Random provider configuration
provider "random" {
  # No specific configuration required for random provider
}

# Time provider configuration
provider "time" {
  # No specific configuration required for time provider
}

# Local provider configuration
provider "local" {
  # No specific configuration required for local provider
}
