# Enhanced Provider Configuration for Cost Optimization Lab 1.2
# This file defines the required providers with enhanced features for cost optimization

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
  }
}

# Configure the IBM Cloud Provider with enhanced features
provider "ibm" {
  # IBM Cloud API Key - should be provided via environment variable or terraform.tfvars
  # ibmcloud_api_key = var.ibmcloud_api_key
  
  # Default region for resource provisioning
  region = var.ibm_region
  
  # Default resource group for organizing resources
  # This will be looked up using data source in main.tf
  
  # Enhanced configuration for cost optimization
  generation = 2  # Use VPC Gen 2 for better performance and cost efficiency
}

# Configure the Random Provider
provider "random" {
  # No specific configuration required for random provider
}

# Configure the Time Provider for scheduling and timestamps
provider "time" {
  # No specific configuration required for time provider
}

# Configure the Local Provider for file operations
provider "local" {
  # No specific configuration required for local provider
}
