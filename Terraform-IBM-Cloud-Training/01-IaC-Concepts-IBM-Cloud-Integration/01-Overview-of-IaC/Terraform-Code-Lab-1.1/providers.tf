# Terraform Provider Configuration for IBM Cloud
# This file defines the required providers and their versions for the IaC training lab

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
    
    # Time provider for managing time-based resources
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}

# Configure the IBM Cloud Provider
provider "ibm" {
  # IBM Cloud API Key - should be provided via environment variable or terraform.tfvars
  # ibmcloud_api_key = var.ibmcloud_api_key
  
  # Default region for resource provisioning
  region = var.ibm_region
  
  # Default resource group for organizing resources
  # This will be looked up using data source in main.tf
}

# Configure the Random Provider
provider "random" {
  # No specific configuration required for random provider
}

# Configure the Time Provider  
provider "time" {
  # No specific configuration required for time provider
}
