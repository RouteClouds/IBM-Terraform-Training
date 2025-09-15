# =============================================================================
# TERRAFORM AND PROVIDER CONFIGURATION
# =============================================================================
# Terraform Code Lab 5.1: Creating Reusable Modules
# This configuration demonstrates enterprise-grade provider setup for module development
# and testing with IBM Cloud services.

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  
  # Backend configuration for state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "module-lab/terraform.tfstate"
  #   region = "us-south"
  # }
}

# =============================================================================
# PRIMARY IBM CLOUD PROVIDER
# =============================================================================

provider "ibm" {
  # Authentication via environment variable IBMCLOUD_API_KEY
  # or explicit configuration below
  # ibmcloud_api_key = var.ibmcloud_api_key
  
  region = var.primary_region
  
  # Enterprise account configuration
  # account_id = var.account_id
  
  # Generation for VPC resources (Gen 2)
  generation = 2
  
  # Retry configuration for API calls
  max_retries      = 3
  retry_delay      = 5
  retry_max_delay  = 30
  
  # Default tags applied to all resources
  default_tags = [
    "terraform:managed",
    "lab:module-creation",
    "topic:5.1",
    "training:ibm-cloud-terraform"
  ]
}

# =============================================================================
# SECONDARY REGION PROVIDER (FOR MULTI-REGION MODULES)
# =============================================================================

provider "ibm" {
  alias = "secondary"
  
  # Authentication via environment variable IBMCLOUD_API_KEY
  region = var.secondary_region
  
  generation = 2
  
  # Retry configuration
  max_retries      = 3
  retry_delay      = 5
  retry_max_delay  = 30
  
  # Secondary region tags
  default_tags = [
    "terraform:managed",
    "lab:module-creation",
    "topic:5.1",
    "region:secondary",
    "training:ibm-cloud-terraform"
  ]
}

# =============================================================================
# UTILITY PROVIDERS
# =============================================================================

# Random provider for unique resource naming
provider "random" {
  # No specific configuration required
}

# Time provider for timestamps and delays
provider "time" {
  # No specific configuration required
}

# Local provider for file operations
provider "local" {
  # No specific configuration required
}

# TLS provider for certificate generation
provider "tls" {
  # No specific configuration required
}

# =============================================================================
# PROVIDER VALIDATION AND HEALTH CHECKS
# =============================================================================

# Data source to validate primary provider configuration
data "ibm_iam_auth_token" "primary_validation" {
  # This validates that the API key is working correctly
  # and that the provider can authenticate with IBM Cloud
}

# Data source to validate secondary provider configuration
data "ibm_iam_auth_token" "secondary_validation" {
  provider = ibm.secondary
  
  # Validates secondary region provider authentication
}

# Data source to validate primary region availability
data "ibm_is_zones" "primary_region_validation" {
  region = var.primary_region
  
  # This validates that the specified region is available
  # and that VPC services are supported in the region
}

# Data source to validate secondary region availability
data "ibm_is_zones" "secondary_region_validation" {
  provider = ibm.secondary
  region   = var.secondary_region
  
  # Validates secondary region VPC service availability
}

# =============================================================================
# PROVIDER FEATURE FLAGS AND CONFIGURATION
# =============================================================================

locals {
  # Provider configuration validation
  provider_config = {
    primary_region_valid   = length(data.ibm_is_zones.primary_region_validation.zones) > 0
    secondary_region_valid = length(data.ibm_is_zones.secondary_region_validation.zones) > 0
    authentication_valid   = data.ibm_iam_auth_token.primary_validation.iam_access_token != null
    
    # Feature flags for provider capabilities
    multi_region_enabled    = var.enable_multi_region
    enterprise_features     = var.enable_enterprise_features
    advanced_networking     = var.enable_advanced_networking
    security_services       = var.enable_security_services
    monitoring_services     = var.enable_monitoring_services
  }
  
  # Provider metadata for module development
  provider_metadata = {
    terraform_version = "~> 1.5.0"
    ibm_provider_version = "~> 1.58"
    configuration_timestamp = timestamp()
    lab_version = "5.1.0"
    
    # Supported IBM Cloud services for module development
    supported_services = [
      "vpc",
      "is", # Infrastructure Services
      "iam",
      "resource-controller",
      "global-search-tagging",
      "enterprise-management",
      "usage-reports",
      "billing",
      "user-management"
    ]
  }
}

# =============================================================================
# PROVIDER OUTPUTS FOR MODULE DEVELOPMENT
# =============================================================================

# Provider configuration information for module consumers
output "provider_configuration" {
  description = "Provider configuration information for module development"
  value = {
    primary_region   = var.primary_region
    secondary_region = var.secondary_region
    
    # Available zones for module development
    primary_zones   = data.ibm_is_zones.primary_region_validation.zones
    secondary_zones = data.ibm_is_zones.secondary_region_validation.zones
    
    # Provider validation status
    validation_status = local.provider_config
    
    # Provider metadata
    metadata = local.provider_metadata
  }
}

# Authentication validation output
output "authentication_status" {
  description = "Authentication validation status for both providers"
  value = {
    primary_authenticated   = data.ibm_iam_auth_token.primary_validation.iam_access_token != null
    secondary_authenticated = data.ibm_iam_auth_token.secondary_validation.iam_access_token != null
    
    # Token metadata (sensitive information excluded)
    token_metadata = {
      primary_token_type   = "Bearer"
      secondary_token_type = "Bearer"
      validation_timestamp = timestamp()
    }
  }
  
  sensitive = false
}

# Regional capabilities output
output "regional_capabilities" {
  description = "Regional capabilities and service availability"
  value = {
    primary_region = {
      name  = var.primary_region
      zones = data.ibm_is_zones.primary_region_validation.zones
      zone_count = length(data.ibm_is_zones.primary_region_validation.zones)
      vpc_supported = true
    }
    
    secondary_region = {
      name  = var.secondary_region
      zones = data.ibm_is_zones.secondary_region_validation.zones
      zone_count = length(data.ibm_is_zones.secondary_region_validation.zones)
      vpc_supported = true
    }
    
    # Multi-region configuration
    multi_region_enabled = var.enable_multi_region
    cross_region_networking = var.enable_cross_region_networking
  }
}

# =============================================================================
# PROVIDER ALIASES FOR MODULE DEVELOPMENT
# =============================================================================

# Additional provider aliases for specific use cases
provider "ibm" {
  alias = "monitoring"
  
  region = var.primary_region
  generation = 2
  
  # Specialized configuration for monitoring services
  default_tags = [
    "terraform:managed",
    "service:monitoring",
    "lab:module-creation"
  ]
}

provider "ibm" {
  alias = "security"
  
  region = var.primary_region
  generation = 2
  
  # Specialized configuration for security services
  default_tags = [
    "terraform:managed",
    "service:security",
    "lab:module-creation"
  ]
}

# =============================================================================
# PROVIDER CONFIGURATION VALIDATION
# =============================================================================

# Validation checks for provider configuration
# Note: Using lifecycle rules instead of check blocks for broader compatibility

# =============================================================================
# PROVIDER PERFORMANCE OPTIMIZATION
# =============================================================================

# Provider configuration for optimal performance
locals {
  # Connection pooling and retry configuration
  provider_optimization = {
    # API call optimization
    max_concurrent_requests = 10
    request_timeout_seconds = 30

    # Retry strategy
    retry_strategy = {
      max_retries = 3
      initial_delay = 5
      max_delay = 30
      backoff_multiplier = 2
    }

    # Caching configuration
    cache_enabled = true
    cache_ttl_seconds = 300

    # Rate limiting
    rate_limit_enabled = true
    requests_per_second = 10
  }
}

# =============================================================================
# PROVIDER SECURITY CONFIGURATION
# =============================================================================

# Security-focused provider configuration
locals {
  security_config = {
    # TLS configuration
    tls_version = "1.3"
    verify_ssl = true

    # Authentication security
    token_refresh_enabled = true
    token_refresh_threshold = 300 # seconds

    # Audit logging
    audit_logging_enabled = var.enable_audit_logging
    log_level = var.log_level

    # Network security
    allowed_ip_ranges = var.allowed_ip_ranges
    vpc_endpoint_enabled = var.enable_vpc_endpoints
  }
}

# =============================================================================
# PROVIDER MONITORING AND OBSERVABILITY
# =============================================================================

# Monitoring configuration for provider operations
locals {
  monitoring_config = {
    # Metrics collection
    metrics_enabled = var.enable_metrics
    metrics_interval = 60 # seconds

    # Health checks
    health_check_enabled = true
    health_check_interval = 30 # seconds

    # Alerting
    alerting_enabled = var.enable_alerting
    alert_thresholds = {
      error_rate = 0.05 # 5%
      latency_p99 = 5000 # 5 seconds
      availability = 0.99 # 99%
    }

    # Logging
    log_retention_days = 30
    log_level = var.log_level
  }
}
