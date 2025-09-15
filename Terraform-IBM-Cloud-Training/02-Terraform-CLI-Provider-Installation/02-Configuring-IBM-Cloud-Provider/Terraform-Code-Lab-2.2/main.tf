# Main Configuration for IBM Cloud Provider Lab 2.2
# This file demonstrates comprehensive provider configuration patterns and resource deployment

# =============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# =============================================================================

resource "random_string" "lab_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

resource "time_static" "deployment_time" {}

# =============================================================================
# DATA SOURCES FOR PROVIDER VALIDATION
# =============================================================================

# Primary region data sources
data "ibm_resource_group" "default" {
  name = "default"
}

data "ibm_is_zones" "primary_zones" {
  region = var.ibm_region
}

# Multi-region data sources for validation
data "ibm_resource_group" "us_south" {
  provider = ibm.us_south
  name     = "default"
}

data "ibm_resource_group" "us_east" {
  provider = ibm.us_east
  name     = "default"
}

data "ibm_resource_group" "eu_de" {
  provider = ibm.eu_de
  name     = "default"
}

data "ibm_resource_group" "jp_tok" {
  provider = ibm.jp_tok
  name     = "default"
}

# Zone data for each region
data "ibm_is_zones" "us_south_zones" {
  provider = ibm.us_south
  region   = "us-south"
}

data "ibm_is_zones" "us_east_zones" {
  provider = ibm.us_east
  region   = "us-east"
}

data "ibm_is_zones" "eu_de_zones" {
  provider = ibm.eu_de
  region   = "eu-de"
}

data "ibm_is_zones" "jp_tok_zones" {
  provider = ibm.jp_tok
  region   = "jp-tok"
}

# =============================================================================
# LOCAL VALUES FOR CONFIGURATION
# =============================================================================

locals {
  # Resource naming
  name_prefix = "${var.project_name}-${var.environment}-${random_string.lab_suffix.result}"
  
  # Comprehensive tagging strategy
  common_tags = merge(
    var.common_tags,
    var.environment_tags,
    {
      "environment"    = var.environment
      "project"        = var.project_name
      "owner"          = var.owner
      "region"         = var.ibm_region
      "created_by"     = "terraform"
      "creation_date"  = formatdate("YYYY-MM-DD", time_static.deployment_time.rfc3339)
      "lab_id"         = "2.2"
      "cost_center"    = var.cost_center
    }
  )
  
  # Convert tags to list format for IBM Cloud resources
  tag_list = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    var.additional_tags
  )
  
  # Regional configuration mapping
  regions = {
    us_south = {
      provider = "us_south"
      name     = "us-south"
      zones    = data.ibm_is_zones.us_south_zones.zones
      rg_id    = data.ibm_resource_group.us_south.id
    }
    us_east = {
      provider = "us_east"
      name     = "us-east"
      zones    = data.ibm_is_zones.us_east_zones.zones
      rg_id    = data.ibm_resource_group.us_east.id
    }
    eu_de = {
      provider = "eu_de"
      name     = "eu-de"
      zones    = data.ibm_is_zones.eu_de_zones.zones
      rg_id    = data.ibm_resource_group.eu_de.id
    }
    jp_tok = {
      provider = "jp_tok"
      name     = "jp-tok"
      zones    = data.ibm_is_zones.jp_tok_zones.zones
      rg_id    = data.ibm_resource_group.jp_tok.id
    }
  }
  
  # Provider configuration validation
  provider_validation = {
    primary_configured    = var.ibmcloud_api_key != null
    enterprise_configured = var.enterprise_api_key != null
    dev_configured       = var.dev_api_key != null
    staging_configured   = var.staging_api_key != null
    testing_configured   = var.testing_api_key != null
    dr_configured        = var.dr_api_key != null
  }
}

# =============================================================================
# PROVIDER CONNECTIVITY TESTING
# =============================================================================

# Test primary provider connectivity
resource "ibm_is_vpc" "connectivity_test" {
  count = var.test_connectivity ? 1 : 0
  
  name           = "${local.name_prefix}-connectivity-test"
  resource_group = data.ibm_resource_group.default.id
  tags           = concat(local.tag_list, ["purpose:connectivity-test"])
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Multi-region connectivity testing
resource "ibm_is_vpc" "multi_region_test" {
  for_each = var.test_multi_region ? local.regions : {}
  
  provider       = ibm.${each.value.provider}
  name           = "${local.name_prefix}-${each.value.name}-test"
  resource_group = each.value.rg_id
  tags           = concat(local.tag_list, ["region:${each.value.name}", "purpose:multi-region-test"])
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# =============================================================================
# AUTHENTICATION VALIDATION RESOURCES
# =============================================================================

# Service ID for provider authentication testing
resource "ibm_iam_service_id" "provider_test" {
  count = var.validate_authentication ? 1 : 0
  
  name        = "${local.name_prefix}-provider-test"
  description = "Service ID for provider authentication testing"
  tags        = local.tag_list
}

# API key for the test service ID
resource "ibm_iam_service_api_key" "provider_test_key" {
  count = var.validate_authentication ? 1 : 0
  
  name           = "${local.name_prefix}-test-key"
  iam_service_id = ibm_iam_service_id.provider_test[0].iam_id
  description    = "API key for provider testing"
  
  # Store key securely (in real environments, use proper secret management)
  file = "provider-test-key.json"
}

# Access policy for the test service ID
resource "ibm_iam_service_policy" "provider_test_policy" {
  count = var.validate_authentication ? 1 : 0
  
  iam_service_id = ibm_iam_service_id.provider_test[0].id
  roles          = ["Viewer"]
  
  resources {
    service = "is"  # VPC Infrastructure Services
    region  = var.ibm_region
  }
}

# =============================================================================
# ENTERPRISE SECURITY DEMONSTRATION
# =============================================================================

# Enterprise VPC with comprehensive security
resource "ibm_is_vpc" "enterprise_demo" {
  count = var.enterprise_api_key != null ? 1 : 0
  
  provider                    = ibm.enterprise_prod
  name                        = "${local.name_prefix}-enterprise-vpc"
  resource_group              = var.enterprise_resource_group_id
  address_prefix_management   = "manual"
  default_network_acl_name    = "${local.name_prefix}-enterprise-acl"
  default_routing_table_name  = "${local.name_prefix}-enterprise-rt"
  default_security_group_name = "${local.name_prefix}-enterprise-sg"
  
  tags = concat(local.tag_list, [
    "tier:enterprise",
    "security:high",
    "compliance:required"
  ])
  
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

# Enterprise subnet with enhanced security
resource "ibm_is_subnet" "enterprise_subnet" {
  count = var.enterprise_api_key != null ? 1 : 0
  
  provider        = ibm.enterprise_prod
  name            = "${local.name_prefix}-enterprise-subnet"
  vpc             = ibm_is_vpc.enterprise_demo[0].id
  zone            = var.enterprise_zone
  ipv4_cidr_block = "10.240.0.0/24"
  resource_group  = var.enterprise_resource_group_id
  
  tags = concat(local.tag_list, [
    "tier:enterprise",
    "zone:${var.enterprise_zone}",
    "network:private"
  ])
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# =============================================================================
# DEVELOPMENT ENVIRONMENT DEMONSTRATION
# =============================================================================

# Development VPC with relaxed settings
resource "ibm_is_vpc" "development_demo" {
  count = var.dev_api_key != null ? 1 : 0
  
  provider       = ibm.development
  name           = "${local.name_prefix}-dev-vpc"
  resource_group = var.dev_resource_group_id
  tags           = concat(local.tag_list, ["tier:development", "purpose:testing"])
  
  timeouts {
    create = "5m"
    delete = "5m"
  }
}

# =============================================================================
# PERFORMANCE TESTING RESOURCES
# =============================================================================

# Performance test: Multiple resources creation
resource "ibm_is_vpc" "performance_test" {
  count = var.performance_testing_enabled ? 3 : 0
  
  name           = "${local.name_prefix}-perf-test-${count.index + 1}"
  resource_group = data.ibm_resource_group.default.id
  tags           = concat(local.tag_list, ["purpose:performance-test", "instance:${count.index + 1}"])
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Performance measurement timestamps
resource "time_static" "performance_start" {
  count = var.performance_testing_enabled ? 1 : 0
}

resource "time_static" "performance_end" {
  count = var.performance_testing_enabled ? 1 : 0
  
  depends_on = [ibm_is_vpc.performance_test]
}

# =============================================================================
# PROVIDER CONFIGURATION VALIDATION
# =============================================================================

# Validation report generation
resource "local_file" "provider_validation_report" {
  count = var.enable_provider_testing ? 1 : 0
  
  filename = "${path.module}/provider-validation-report.json"
  content = jsonencode({
    validation_metadata = {
      timestamp     = time_static.deployment_time.rfc3339
      lab_id        = "2.2"
      project_name  = var.project_name
      environment   = var.environment
      primary_region = var.ibm_region
    }
    
    provider_configurations = {
      primary_provider = {
        configured = local.provider_validation.primary_configured
        region     = var.ibm_region
        zone       = var.ibm_zone
        timeout    = var.provider_timeout
        retries    = var.max_retries
      }
      
      enterprise_provider = {
        configured = local.provider_validation.enterprise_configured
        region     = var.enterprise_region
        zone       = var.enterprise_zone
        security   = "enhanced"
      }
      
      multi_region_providers = {
        us_south = {
          configured = true
          zones      = length(data.ibm_is_zones.us_south_zones.zones)
        }
        us_east = {
          configured = true
          zones      = length(data.ibm_is_zones.us_east_zones.zones)
        }
        eu_de = {
          configured = true
          zones      = length(data.ibm_is_zones.eu_de_zones.zones)
        }
        jp_tok = {
          configured = true
          zones      = length(data.ibm_is_zones.jp_tok_zones.zones)
        }
      }
    }
    
    connectivity_tests = {
      primary_connectivity = var.test_connectivity
      multi_region_testing = var.test_multi_region
      authentication_validation = var.validate_authentication
      performance_testing = var.performance_testing_enabled
    }
    
    security_configuration = {
      private_endpoints_enabled = var.use_private_endpoints
      debug_tracing_enabled = var.enable_debug_tracing
      audit_logging_enabled = var.enable_audit_logging
      classic_infrastructure = var.enable_classic_infrastructure
    }
    
    resource_deployment = {
      connectivity_test_vpc = var.test_connectivity ? 1 : 0
      multi_region_vpcs = var.test_multi_region ? length(local.regions) : 0
      enterprise_resources = var.enterprise_api_key != null ? 2 : 0
      development_resources = var.dev_api_key != null ? 1 : 0
      performance_test_resources = var.performance_testing_enabled ? 3 : 0
    }
    
    performance_metrics = var.performance_testing_enabled ? {
      test_start_time = time_static.performance_start[0].rfc3339
      test_end_time   = time_static.performance_end[0].rfc3339
      resources_created = 3
      parallel_creation = true
    } : null
    
    recommendations = [
      !local.provider_validation.primary_configured ? "Configure primary IBM Cloud API key" : null,
      !var.use_private_endpoints ? "Consider enabling private endpoints for enhanced security" : null,
      !var.enable_audit_logging ? "Enable audit logging for compliance requirements" : null,
      var.max_retries < 5 ? "Consider increasing max_retries for better reliability" : null,
      var.provider_timeout < 600 ? "Consider increasing provider timeout for complex operations" : null
    ]
    
    next_steps = [
      "Review provider configuration validation results",
      "Implement recommended security enhancements",
      "Test provider configurations in target environments",
      "Proceed to Topic 3: Core Terraform Workflow",
      "Develop organization-specific provider standards"
    ]
  })
}

# =============================================================================
# COST TRACKING AND MONITORING
# =============================================================================

# Cost tracking tags for all resources
resource "local_file" "cost_tracking_report" {
  count = var.enable_cost_tracking ? 1 : 0
  
  filename = "${path.module}/cost-tracking-report.json"
  content = jsonencode({
    cost_tracking = {
      enabled       = var.enable_cost_tracking
      cost_center   = var.cost_center
      budget_alert  = var.budget_alert_threshold
      project_name  = var.project_name
      environment   = var.environment
      owner         = var.owner
    }
    
    resource_inventory = {
      vpcs_created = (
        (var.test_connectivity ? 1 : 0) +
        (var.test_multi_region ? length(local.regions) : 0) +
        (var.enterprise_api_key != null ? 1 : 0) +
        (var.dev_api_key != null ? 1 : 0) +
        (var.performance_testing_enabled ? 3 : 0)
      )
      
      subnets_created = (
        (var.enterprise_api_key != null ? 1 : 0)
      )
      
      service_ids_created = var.validate_authentication ? 1 : 0
      api_keys_created = var.validate_authentication ? 1 : 0
    }
    
    estimated_costs = {
      vpcs = "Free tier - no charges"
      subnets = "Free tier - no charges"
      service_ids = "Free tier - no charges"
      api_keys = "Free tier - no charges"
      total_estimated = "$0.00 USD/month"
    }
    
    cost_optimization_tips = [
      "All lab resources are designed to use free tier services",
      "Clean up resources after lab completion using 'terraform destroy'",
      "Monitor IBM Cloud billing dashboard for any unexpected charges",
      "Use resource groups for better cost organization and tracking"
    ]
  })
}
