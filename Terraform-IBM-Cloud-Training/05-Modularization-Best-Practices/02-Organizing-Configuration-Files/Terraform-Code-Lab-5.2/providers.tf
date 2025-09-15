# Terraform Configuration Organization Lab - Provider Configuration
# Demonstrates enterprise-grade provider setup with multi-region support

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.60.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
    
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
  
  # Backend configuration for state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "configuration-organization/terraform.tfstate"
  #   region = "us-south"
  # }
}

# Primary IBM Cloud provider configuration
provider "ibm" {
  alias  = "primary"
  region = var.primary_region
  
  # Enterprise configuration
  generation = 2
  
  # Resource group targeting
  resource_group = var.resource_group_id

  # Retry configuration for enterprise reliability
  max_retries = 3
}

# Secondary region provider for multi-region deployments
provider "ibm" {
  alias  = "secondary"
  region = var.secondary_region
  
  generation     = 2
  resource_group = var.resource_group_id

  max_retries = 3
}

# Disaster recovery region provider
provider "ibm" {
  alias  = "dr"
  region = var.dr_region
  
  generation     = 2
  resource_group = var.resource_group_id

  max_retries = 3
}

# Random provider for generating unique identifiers
provider "random" {
  # No specific configuration required
}

# TLS provider for certificate and key generation
provider "tls" {
  # No specific configuration required
}

# Local provider for file operations
provider "local" {
  # No specific configuration required
}

# Time provider for time-based resources
provider "time" {
  # No specific configuration required
}

# Provider validation and health checks
data "ibm_resource_group" "validation" {
  provider = ibm.primary
  name     = var.resource_group_name
}

# Validate primary region connectivity
data "ibm_is_zones" "primary_zones" {
  provider = ibm.primary
  region   = var.primary_region
}

# Validate secondary region connectivity (if enabled)
data "ibm_is_zones" "secondary_zones" {
  count    = var.enable_multi_region ? 1 : 0
  provider = ibm.secondary
  region   = var.secondary_region
}

# Provider configuration validation
locals {
  provider_validation = {
    primary_region_valid = length(data.ibm_is_zones.primary_zones.zones) > 0
    resource_group_valid = data.ibm_resource_group.validation.id != null
    
    # Multi-region validation
    secondary_region_valid = var.enable_multi_region ? (
      length(data.ibm_is_zones.secondary_zones[0].zones) > 0
    ) : true
    
    # Overall provider health
    providers_healthy = alltrue([
      length(data.ibm_is_zones.primary_zones.zones) > 0,
      data.ibm_resource_group.validation.id != null,
      var.enable_multi_region ? length(data.ibm_is_zones.secondary_zones[0].zones) > 0 : true
    ])
  }
}

# Provider validation checks
check "provider_connectivity" {
  assert {
    condition = local.provider_validation.providers_healthy
    error_message = "Provider connectivity validation failed. Check region availability and resource group access."
  }
}

check "primary_region_availability" {
  assert {
    condition = local.provider_validation.primary_region_valid
    error_message = "Primary region ${var.primary_region} is not available or accessible."
  }
}

check "resource_group_access" {
  assert {
    condition = local.provider_validation.resource_group_valid
    error_message = "Resource group ${var.resource_group_name} is not accessible."
  }
}

# Enterprise provider configuration outputs
output "provider_configuration" {
  description = "Provider configuration and validation status"
  value = {
    primary_region = var.primary_region
    secondary_region = var.secondary_region
    dr_region = var.dr_region
    
    validation_status = local.provider_validation
    
    available_zones = {
      primary = data.ibm_is_zones.primary_zones.zones
      secondary = var.enable_multi_region ? data.ibm_is_zones.secondary_zones[0].zones : []
    }
    
    resource_group = {
      id = data.ibm_resource_group.validation.id
      name = data.ibm_resource_group.validation.name
    }
    
    provider_versions = {
      terraform = "~> 1.5.0"
      ibm = "~> 1.60.0"
      random = "~> 3.5.0"
      tls = "~> 4.0.0"
      local = "~> 2.4.0"
      time = "~> 0.9.0"
    }
  }
}

# Provider health monitoring
output "provider_health" {
  description = "Provider health and connectivity status"
  value = {
    timestamp = timestamp()
    
    connectivity_status = {
      primary_region = local.provider_validation.primary_region_valid ? "healthy" : "unhealthy"
      secondary_region = var.enable_multi_region ? (
        local.provider_validation.secondary_region_valid ? "healthy" : "unhealthy"
      ) : "disabled"
      resource_group = local.provider_validation.resource_group_valid ? "accessible" : "inaccessible"
    }
    
    zone_availability = {
      primary_zones = length(data.ibm_is_zones.primary_zones.zones)
      secondary_zones = var.enable_multi_region ? length(data.ibm_is_zones.secondary_zones[0].zones) : 0
    }
    
    overall_status = local.provider_validation.providers_healthy ? "healthy" : "degraded"
  }
}
