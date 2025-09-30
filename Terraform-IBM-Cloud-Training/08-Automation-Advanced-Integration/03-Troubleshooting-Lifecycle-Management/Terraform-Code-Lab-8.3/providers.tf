# Terraform Providers Configuration for Topic 8.3
# Troubleshooting & Lifecycle Management Lab Environment

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    # IBM Cloud Provider for infrastructure management
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.60.0"
    }
    
    # Random provider for unique resource naming
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    
    # Time provider for scheduling and delays
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    
    # Local provider for file operations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    
    # HTTP provider for health checks
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
  }
  
  # Backend configuration for state management
  # Uncomment and configure for remote state
  # backend "remote" {
  #   hostname     = "app.terraform.io"
  #   organization = "your-organization"
  #   workspaces {
  #     name = "troubleshooting-lab"
  #   }
  # }
}

# IBM Cloud Provider Configuration
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region          = var.ibm_region
  resource_group  = var.resource_group_name
  
  # Performance optimizations for troubleshooting lab
  max_retries      = 5
  retry_delay      = 30
  request_timeout  = 600  # Extended timeout for complex operations
  
  # Enable private endpoints for enhanced security
  endpoints {
    private_enabled = var.private_endpoints_enabled
    vpc_enabled     = var.vpc_endpoints_enabled
  }
}

# Random provider for unique naming
provider "random" {}

# Time provider for scheduling
provider "time" {}

# Local provider for file operations
provider "local" {}

# HTTP provider for connectivity checks
provider "http" {}

# Data sources for environment information
data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

data "ibm_iam_account_settings" "current" {}

data "ibm_iam_user_profile" "current" {}

data "ibm_regions" "available" {}

# Local values for consistent resource naming and tagging
locals {
  # Resource naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags for all resources
  common_tags = [
    "project:${var.project_name}",
    "environment:${var.environment}",
    "topic:8.3-troubleshooting-lifecycle",
    "lab:terraform-code-lab-8.3",
    "owner:${var.owner_email}",
    "cost-center:${var.cost_center}",
    "created-by:terraform",
    "managed-by:troubleshooting-lab"
  ]
  
  # Troubleshooting configuration
  troubleshooting_config = {
    debug_enabled           = var.debug_enabled
    monitoring_enabled      = var.monitoring_enabled
    self_healing_enabled    = var.self_healing_enabled
    performance_optimization = var.performance_optimization_enabled
    operational_excellence  = var.operational_excellence_enabled
  }
  
  # Performance optimization settings
  performance_config = {
    parallel_operations = var.parallel_operations
    cache_enabled      = var.cache_enabled
    batch_size         = var.batch_size
    timeout_multiplier = var.timeout_multiplier
  }
  
  # Monitoring and alerting configuration
  monitoring_config = {
    metrics_retention_days = var.metrics_retention_days
    log_retention_days    = var.log_retention_days
    alert_threshold_cpu   = var.alert_threshold_cpu
    alert_threshold_memory = var.alert_threshold_memory
    notification_channels = var.notification_channels
  }
  
  # Self-healing configuration
  self_healing_config = {
    health_check_interval = var.health_check_interval
    remediation_timeout   = var.remediation_timeout
    escalation_threshold  = var.escalation_threshold
    auto_recovery_enabled = var.auto_recovery_enabled
  }
  
  # Operational excellence settings
  operational_config = {
    slo_availability_target = var.slo_availability_target
    slo_performance_target  = var.slo_performance_target
    error_budget_percentage = var.error_budget_percentage
    incident_response_time  = var.incident_response_time
  }
  
  # Session and deployment tracking
  deployment_info = {
    session_id        = random_uuid.session.result
    deployment_time   = timestamp()
    terraform_version = terraform.version
    region           = var.ibm_region
    resource_group   = data.ibm_resource_group.group.id
    account_id       = data.ibm_iam_account_settings.current.account_id
    user_id          = data.ibm_iam_user_profile.current.user_id
  }
}

# Generate unique session identifier
resource "random_uuid" "session" {}

# Generate random suffix for unique resource naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create deployment metadata file
resource "local_file" "deployment_metadata" {
  content = jsonencode({
    deployment_info        = local.deployment_info
    troubleshooting_config = local.troubleshooting_config
    performance_config     = local.performance_config
    monitoring_config      = local.monitoring_config
    self_healing_config    = local.self_healing_config
    operational_config     = local.operational_config
    common_tags           = local.common_tags
  })
  filename = "${path.module}/deployment-metadata.json"
}

# Time delay for resource dependencies
resource "time_sleep" "resource_creation_delay" {
  depends_on = [
    data.ibm_resource_group.group,
    random_uuid.session,
    random_string.suffix
  ]
  
  create_duration = "30s"
}
