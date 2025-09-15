# IBM Cloud Provider Configuration Examples for Lab 2.2
# This file demonstrates various provider configuration patterns for different use cases

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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

# =============================================================================
# BASIC PROVIDER CONFIGURATION
# =============================================================================

# Default provider configuration for single-region deployment
provider "ibm" {
  # Authentication
  ibmcloud_api_key = var.ibmcloud_api_key
  
  # Regional configuration
  region = var.ibm_region
  zone   = var.ibm_zone
  
  # Resource targeting
  resource_group = var.resource_group_id
  
  # Basic performance settings
  ibmcloud_timeout = var.provider_timeout
  max_retries      = var.max_retries
}

# =============================================================================
# MULTI-REGION PROVIDER CONFIGURATIONS
# =============================================================================

# US South provider (Primary region)
provider "ibm" {
  alias            = "us_south"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "us-south"
  zone             = "us-south-1"
  resource_group   = var.resource_group_id
  
  # Optimized for primary region
  ibmcloud_timeout = 600
  max_retries      = 5
  retry_delay      = 30
  
  # Use private endpoints for better performance
  visibility = var.use_private_endpoints ? "private" : "public"
  endpoints  = var.use_private_endpoints ? "private" : "public"
  
  # Enable tracing for debugging
  ibmcloud_trace = var.enable_debug_tracing
}

# US East provider (Secondary region)
provider "ibm" {
  alias            = "us_east"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "us-east"
  zone             = "us-east-1"
  resource_group   = var.resource_group_id
  
  # Standard configuration for secondary region
  ibmcloud_timeout = 600
  max_retries      = 5
  retry_delay      = 30
  
  visibility = var.use_private_endpoints ? "private" : "public"
  endpoints  = var.use_private_endpoints ? "private" : "public"
}

# EU Germany provider (GDPR compliance region)
provider "ibm" {
  alias            = "eu_de"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "eu-de"
  zone             = "eu-de-1"
  resource_group   = var.resource_group_id
  
  # Enhanced settings for compliance region
  ibmcloud_timeout = 900  # Extended timeout for compliance checks
  max_retries      = 10   # Increased retries for reliability
  retry_delay      = 60   # Longer delay for rate limiting
  
  # Force private endpoints for GDPR compliance
  visibility = "private"
  endpoints  = "private"
  
  # Enable comprehensive tracing for audit requirements
  ibmcloud_trace = true
}

# Japan Tokyo provider (APAC region)
provider "ibm" {
  alias            = "jp_tok"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "jp-tok"
  zone             = "jp-tok-1"
  resource_group   = var.resource_group_id
  
  # Optimized for APAC latency
  ibmcloud_timeout = 1200  # Extended timeout for cross-Pacific latency
  max_retries      = 15    # High retry count for network reliability
  retry_delay      = 120   # Longer delay for international connections
  
  visibility = var.use_private_endpoints ? "private" : "public"
  endpoints  = var.use_private_endpoints ? "private" : "public"
}

# =============================================================================
# ENTERPRISE PROVIDER CONFIGURATIONS
# =============================================================================

# Enterprise production provider with maximum security
provider "ibm" {
  alias            = "enterprise_prod"
  ibmcloud_api_key = var.enterprise_api_key
  region           = var.enterprise_region
  zone             = var.enterprise_zone
  resource_group   = var.enterprise_resource_group_id
  
  # Enterprise security settings
  visibility = "private"  # Force private endpoints
  endpoints  = "private"  # All communications via private network
  
  # Enterprise performance settings
  ibmcloud_timeout = 1800  # 30 minutes for complex enterprise operations
  max_retries      = 20    # Maximum reliability for production
  retry_delay      = 180   # 3-minute delay for enterprise rate limits
  
  # Enterprise monitoring and compliance
  ibmcloud_trace = var.enterprise_enable_tracing
  
  # Classic infrastructure support (if needed)
  iaas_classic_username = var.classic_username
  iaas_classic_api_key  = var.classic_api_key
  
  # VPC generation specification
  generation = 2  # Use VPC Gen 2 for enterprise features
}

# Development environment provider with relaxed settings
provider "ibm" {
  alias            = "development"
  ibmcloud_api_key = var.dev_api_key
  region           = var.dev_region
  zone             = var.dev_zone
  resource_group   = var.dev_resource_group_id
  
  # Development-friendly settings
  ibmcloud_timeout = 300   # 5 minutes for development speed
  max_retries      = 3     # Lower retries for faster feedback
  retry_delay      = 15    # Quick retry for development iteration
  
  # Public endpoints for development convenience
  visibility = "public"
  endpoints  = "public"
  
  # Enable detailed tracing for development debugging
  ibmcloud_trace = true
}

# Staging environment provider with production-like settings
provider "ibm" {
  alias            = "staging"
  ibmcloud_api_key = var.staging_api_key
  region           = var.staging_region
  zone             = var.staging_zone
  resource_group   = var.staging_resource_group_id
  
  # Production-like settings for staging validation
  ibmcloud_timeout = 900   # 15 minutes similar to production
  max_retries      = 10    # High reliability for staging tests
  retry_delay      = 60    # Production-like retry delays
  
  # Mixed endpoint strategy for staging validation
  visibility = var.staging_use_private_endpoints ? "private" : "public"
  endpoints  = var.staging_use_private_endpoints ? "private" : "public"
  
  # Conditional tracing for staging debugging
  ibmcloud_trace = var.staging_enable_tracing
}

# =============================================================================
# SERVICE-SPECIFIC PROVIDER CONFIGURATIONS
# =============================================================================

# Provider optimized for Kubernetes workloads
provider "ibm" {
  alias            = "kubernetes"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.kubernetes_region
  resource_group   = var.kubernetes_resource_group_id
  
  # Kubernetes-optimized settings
  ibmcloud_timeout = 2400  # 40 minutes for cluster operations
  max_retries      = 25    # High retry count for cluster stability
  retry_delay      = 240   # 4-minute delay for cluster operations
  
  # Private endpoints for secure cluster communication
  visibility = "private"
  endpoints  = "private"
  
  # Enable tracing for cluster debugging
  ibmcloud_trace = var.kubernetes_enable_tracing
}

# Provider optimized for database workloads
provider "ibm" {
  alias            = "database"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.database_region
  resource_group   = var.database_resource_group_id
  
  # Database-optimized settings
  ibmcloud_timeout = 3600  # 60 minutes for database operations
  max_retries      = 30    # Maximum retries for database reliability
  retry_delay      = 300   # 5-minute delay for database operations
  
  # Private endpoints for database security
  visibility = "private"
  endpoints  = "private"
  
  # Comprehensive tracing for database operations
  ibmcloud_trace = true
}

# =============================================================================
# TESTING AND VALIDATION PROVIDER
# =============================================================================

# Provider for testing and validation scenarios
provider "ibm" {
  alias            = "testing"
  ibmcloud_api_key = var.testing_api_key
  region           = var.testing_region
  zone             = var.testing_zone
  resource_group   = var.testing_resource_group_id
  
  # Testing-optimized settings
  ibmcloud_timeout = 180   # 3 minutes for quick testing feedback
  max_retries      = 2     # Minimal retries for fast failure detection
  retry_delay      = 10    # Quick retry for testing iteration
  
  # Public endpoints for testing accessibility
  visibility = "public"
  endpoints  = "public"
  
  # Always enable tracing for testing analysis
  ibmcloud_trace = true
}

# =============================================================================
# DISASTER RECOVERY PROVIDER
# =============================================================================

# Provider for disaster recovery region
provider "ibm" {
  alias            = "disaster_recovery"
  ibmcloud_api_key = var.dr_api_key
  region           = var.dr_region
  zone             = var.dr_zone
  resource_group   = var.dr_resource_group_id
  
  # Disaster recovery optimized settings
  ibmcloud_timeout = 1800  # 30 minutes for DR operations
  max_retries      = 50    # Maximum retries for DR reliability
  retry_delay      = 300   # 5-minute delay for DR stability
  
  # Private endpoints for secure DR operations
  visibility = "private"
  endpoints  = "private"
  
  # Enable comprehensive tracing for DR audit
  ibmcloud_trace = true
  
  # VPC generation for DR compatibility
  generation = 2
}
