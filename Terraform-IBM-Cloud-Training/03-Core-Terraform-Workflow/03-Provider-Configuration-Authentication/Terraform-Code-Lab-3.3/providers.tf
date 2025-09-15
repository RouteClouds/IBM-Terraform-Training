# Provider Configuration and Authentication - Lab 3.3
# Comprehensive provider configuration demonstrating authentication methods,
# performance optimization, and enterprise security patterns

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    # Primary IBM Cloud provider
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }
    
    # Supporting providers for comprehensive functionality
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
    
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
    
    # External secret management (optional)
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.20.0"
    }
  }
}

# ============================================================================
# PRIMARY IBM CLOUD PROVIDER CONFIGURATION
# ============================================================================

# Main IBM Cloud provider with comprehensive configuration
provider "ibm" {
  # Authentication - Uses environment variables by default
  # IC_API_KEY, IC_REGION, IC_RESOURCE_GROUP_ID

  # Override with variables if needed
  ibmcloud_api_key = var.ibm_api_key != "" ? var.ibm_api_key : null
  region           = var.ibm_region

  # Performance optimization settings
  ibmcloud_timeout = var.provider_timeout
  max_retries      = var.max_retries
}

# ============================================================================
# MULTI-ENVIRONMENT PROVIDER ALIASES
# ============================================================================

# Development environment provider
provider "ibm" {
  alias = "dev"

  ibmcloud_api_key = var.dev_api_key != "" ? var.dev_api_key : var.ibm_api_key
  region           = var.dev_region

  # Development-optimized settings
  ibmcloud_timeout = 60
  max_retries      = 1
}

# Staging environment provider
provider "ibm" {
  alias = "staging"

  ibmcloud_api_key = var.staging_api_key != "" ? var.staging_api_key : var.ibm_api_key
  region           = var.staging_region

  # Staging-optimized settings
  ibmcloud_timeout = 180
  max_retries      = 2
}

# Production environment provider
provider "ibm" {
  alias = "prod"

  ibmcloud_api_key = var.prod_api_key != "" ? var.prod_api_key : var.ibm_api_key
  region           = var.prod_region

  # Production-optimized settings
  ibmcloud_timeout = 300
  max_retries      = 3
}

# ============================================================================
# MULTI-REGION PROVIDER ALIASES
# ============================================================================

# US South region provider (Primary)
provider "ibm" {
  alias = "us_south"

  ibmcloud_api_key = var.ibm_api_key
  region           = "us-south"

  # Optimized for US South
  ibmcloud_timeout = 180
  max_retries      = 2
}

# EU GB region provider (Secondary)
provider "ibm" {
  alias = "eu_gb"

  ibmcloud_api_key = var.ibm_api_key
  region           = "eu-gb"

  # Optimized for EU GB (higher latency)
  ibmcloud_timeout = 300
  max_retries      = 3
}

# Asia Pacific region provider (Tertiary)
provider "ibm" {
  alias = "jp_tok"

  ibmcloud_api_key = var.ibm_api_key
  region           = "jp-tok"

  # Optimized for Asia Pacific (highest latency)
  ibmcloud_timeout = 360
  max_retries      = 4
}

# ============================================================================
# SUPPORTING PROVIDER CONFIGURATIONS
# ============================================================================

# Random provider for generating unique identifiers
provider "random" {
  # No specific configuration required
}

# Time provider for timestamp and delay operations
provider "time" {
  # No specific configuration required
}

# Local provider for file operations
provider "local" {
  # No specific configuration required
}

# HTTP provider for external API calls
provider "http" {
  # No specific configuration required
}

# TLS provider for certificate operations
provider "tls" {
  # No specific configuration required
}

# Vault provider for secret management (optional)
# Note: Configure only when vault integration is needed
# provider "vault" {
#   address = var.vault_address
#   token   = var.vault_token
# }

# ============================================================================
# PROVIDER FEATURE FLAGS AND EXPERIMENTAL SETTINGS
# ============================================================================

# Advanced provider configuration with feature flags
provider "ibm" {
  alias = "advanced"

  ibmcloud_api_key = var.ibm_api_key
  region           = var.ibm_region

  # Advanced performance settings
  ibmcloud_timeout = var.provider_timeout
  max_retries      = var.max_retries

  # Feature flags and advanced settings are demonstrated in variables
  # but not all are supported by the current provider version
}
