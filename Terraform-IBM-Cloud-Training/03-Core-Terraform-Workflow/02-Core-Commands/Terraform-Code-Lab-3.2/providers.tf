# Core Terraform Commands Lab - Provider Configuration
# Demonstrates provider setup for command workflow practice

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    # IBM Cloud Provider for infrastructure resources
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }
    
    # Random provider for unique resource naming
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    
    # Time provider for resource timing and delays
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    
    # Local provider for file generation and local resources
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    
    # Null provider for command execution and triggers
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }
}

# IBM Cloud Provider Configuration
provider "ibm" {
  # Authentication via environment variable IC_API_KEY
  # or via terraform.tfvars file
  ibmcloud_api_key = var.ibm_api_key
  region           = var.ibm_region
  
  # Optional: Specify resource group
  # resource_group_id = var.resource_group_id
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

# Null Provider Configuration
provider "null" {
  # No specific configuration required
}
