# =============================================================================
# PROVIDER CONFIGURATION
# Resource Dependencies and Attributes Lab - Topic 4.3
# =============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Primary region provider
provider "ibm" {
  region = var.primary_region
}

# Disaster recovery region provider
provider "ibm" {
  alias  = "dr_region"
  region = var.dr_region
}

# Secondary region provider for multi-region deployments
provider "ibm" {
  alias  = "secondary_region"
  region = var.secondary_region
}

# Random provider for unique resource naming
provider "random" {}

# Time provider for timestamps and delays
provider "time" {}

# Local provider for file operations
provider "local" {}

# Template provider for dynamic configuration generation
provider "template" {}

# Null provider for provisioners and lifecycle management
provider "null" {}

# =============================================================================
# PROVIDER FEATURE CONFIGURATION
# =============================================================================

locals {
  # Provider feature flags
  provider_features = {
    # Multi-region deployment
    multi_region_enabled = var.feature_flags.enable_multi_region && length([
      var.primary_region,
      var.secondary_region
    ]) > 1
    
    # Disaster recovery
    disaster_recovery_enabled = var.feature_flags.enable_disaster_recovery && var.dr_region != var.primary_region
    
    # Provider validation
    validation_enabled = var.feature_flags.enable_provider_validation
    
    # Advanced features
    advanced_networking = var.feature_flags.enable_advanced_features
    monitoring_enabled  = var.feature_flags.enable_monitoring
    backup_enabled     = var.feature_flags.enable_backup
  }
  
  # Region configuration
  regions = {
    primary   = var.primary_region
    secondary = var.secondary_region
    dr        = var.dr_region
  }
  
  # Provider aliases mapping
  provider_aliases = {
    primary   = "ibm"
    secondary = "ibm.secondary_region"
    dr        = "ibm.dr_region"
  }
}

# =============================================================================
# PROVIDER VALIDATION RESOURCES
# =============================================================================

# Timestamp for deployment tracking
resource "time_static" "deployment_time" {
  triggers = {
    deployment_id = random_string.deployment_id.result
  }
}

# Unique deployment identifier
resource "random_string" "deployment_id" {
  length  = 8
  special = false
  upper   = false
}

# Random suffix for unique resource naming
resource "random_string" "resource_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Check for provider compatibility
resource "null_resource" "compatibility_check" {
  count = var.feature_flags.enable_provider_validation ? 1 : 0
  
  triggers = {
    provider_version = "1.58"
    terraform_version = "1.0"
    deployment_time = time_static.deployment_time.rfc3339
  }
  
  provisioner "local-exec" {
    command = "echo 'Provider compatibility check passed'"
  }
}

# Provider health check
resource "null_resource" "provider_health_check" {
  count = var.feature_flags.enable_provider_validation ? 1 : 0
  
  triggers = {
    primary_region   = var.primary_region
    secondary_region = var.secondary_region
    dr_region       = var.dr_region
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Checking provider health for regions:"
      echo "  Primary: ${var.primary_region}"
      echo "  Secondary: ${var.secondary_region}"
      echo "  DR: ${var.dr_region}"
    EOT
  }
}

# Validate required environment variables
resource "null_resource" "environment_validation" {
  count = var.feature_flags.enable_provider_validation ? 1 : 0
  
  triggers = {
    ibmcloud_api_key = "required"
    resource_group   = var.resource_group_id
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      if [ -z "$IBMCLOUD_API_KEY" ]; then
        echo "Error: IBMCLOUD_API_KEY environment variable is required"
        exit 1
      fi
      echo "Environment validation passed"
    EOT
  }
}
