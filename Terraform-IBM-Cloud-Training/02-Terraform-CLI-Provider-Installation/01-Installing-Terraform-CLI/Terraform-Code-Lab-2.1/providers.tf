# Provider Configuration for Terraform CLI Installation Lab 2.1
# This file demonstrates provider configuration and version management

terraform {
  # Specify minimum Terraform version required
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
    
    # Time provider for managing time-based resources and scheduling
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    
    # Local provider for creating local files and data processing
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    
    # External provider for running external commands
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.0"
    }
  }
}

# Configure the IBM Cloud Provider
provider "ibm" {
  # IBM Cloud API Key - should be provided via environment variable
  # ibmcloud_api_key = var.ibmcloud_api_key
  
  # Default region for resource provisioning
  region = var.ibm_region
  
  # Enhanced configuration for CLI installation demonstration
  generation = 2  # Use VPC Gen 2 for better performance
}

# Configure the Random Provider
provider "random" {
  # No specific configuration required for random provider
}

# Configure the Time Provider for timestamps and scheduling
provider "time" {
  # No specific configuration required for time provider
}

# Configure the Local Provider for file operations
provider "local" {
  # No specific configuration required for local provider
}

# Configure the External Provider for running commands
provider "external" {
  # No specific configuration required for external provider
}
