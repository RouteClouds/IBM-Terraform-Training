# =============================================================================
# TERRAFORM AND PROVIDER CONFIGURATION
# Subtopic 6.1: Local and Remote State Files
# =============================================================================

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    # IBM Cloud provider for infrastructure management
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }
    
    # Random provider for unique resource naming
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }
    
    # Time provider for deployment tracking
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    
    # Local provider for file operations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
  
  # Backend configuration for remote state management
  # This block will be configured during the lab exercises
  # Uncomment and configure after completing Exercise 2
  /*
  backend "s3" {
    bucket                      = "terraform-state-lab-bucket"
    key                        = "infrastructure/terraform.tfstate"
    region                     = "us-south"
    endpoint                   = "s3.us-south.cloud-object-storage.appdomain.cloud"
    skip_credentials_validation = true
    skip_region_validation     = true
    skip_metadata_api_check    = true
    force_path_style           = true
    encrypt                    = true
  }
  */
}

# =============================================================================
# IBM CLOUD PROVIDER CONFIGURATION
# =============================================================================

# Primary IBM Cloud provider
provider "ibm" {
  ibmcloud_api_key = var.ibm_api_key
  region           = var.primary_region
  
  # Provider configuration for state management
  ibmcloud_timeout = var.provider_timeout
  max_retries      = var.max_retries
}

# =============================================================================
# SUPPORTING PROVIDERS
# =============================================================================

# Random provider for unique resource naming
provider "random" {
  # No specific configuration required
}

# Time provider for deployment tracking
provider "time" {
  # No specific configuration required
}

# Local provider for file operations
provider "local" {
  # No specific configuration required
}
