# IBM Cloud IAM Integration - Terraform Providers Configuration
# Topic 7.2: Identity and Access Management (IAM) Integration
# Lab 7.2: Enterprise Identity and Access Management Implementation

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    # IBM Cloud provider for all IBM Cloud resources
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }

    # Random provider for generating unique identifiers
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }

    # Time provider for time-based resources and delays
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }

    # Local provider for local data processing
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }

    # Template provider for dynamic configuration generation
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

# IBM Cloud provider configuration
provider "ibm" {
  # IBM Cloud API key (set via environment variable IBMCLOUD_API_KEY)
  # ibmcloud_api_key = var.ibmcloud_api_key

  # Target region for resource deployment
  region = var.region

  # IBM Cloud generation for VPC resources (2 for VPC Gen 2)
  generation = 2

  # Retry configuration for API calls
  max_retries = 3

  # Note: IBM provider does not support default_tags
  # Tags are applied individually to each resource
}

# Random provider configuration
provider "random" {
  # No specific configuration required
}

# Time provider configuration  
provider "time" {
  # No specific configuration required
}

# Local provider configuration
provider "local" {
  # No specific configuration required
}

# Template provider configuration
provider "template" {
  # No specific configuration required
}
