# Provider Configuration and Authentication - Main Configuration
# Demonstrates comprehensive provider usage patterns, authentication methods,
# and enterprise security configurations with practical examples

# ============================================================================
# LOCAL VALUES AND COMPUTED CONFIGURATIONS
# ============================================================================

locals {
  # Common resource naming convention
  name_prefix = "${var.resource_prefix}-${var.environment}"
  
  # Regional configuration mapping
  regional_config = {
    "us-south" = {
      zone_suffix    = "1"
      latency_class  = "low"
      endpoint_type  = "public"
      timeout        = 180
    }
    "us-east" = {
      zone_suffix    = "1"
      latency_class  = "low"
      endpoint_type  = "public"
      timeout        = 200
    }
    "eu-gb" = {
      zone_suffix    = "1"
      latency_class  = "medium"
      endpoint_type  = "public"
      timeout        = 300
    }
    "eu-de" = {
      zone_suffix    = "1"
      latency_class  = "medium"
      endpoint_type  = "public"
      timeout        = 320
    }
    "jp-tok" = {
      zone_suffix    = "1"
      latency_class  = "high"
      endpoint_type  = "public"
      timeout        = 360
    }
  }
  
  # Performance configuration based on mode
  performance_config = {
    "fast" = {
      timeout     = 120
      max_retries = 2
      retry_delay = 3
    }
    "balanced" = {
      timeout     = 300
      max_retries = 3
      retry_delay = 5
    }
    "conservative" = {
      timeout     = 600
      max_retries = 5
      retry_delay = 10
    }
  }
  
  # Security configuration based on level
  security_config = {
    "basic" = {
      endpoint_type = "public"
      visibility    = "public"
      trace_enabled = true
    }
    "standard" = {
      endpoint_type = "public"
      visibility    = "public"
      trace_enabled = false
    }
    "high" = {
      endpoint_type = "private"
      visibility    = "private"
      trace_enabled = false
    }
    "maximum" = {
      endpoint_type = "private"
      visibility    = "private"
      trace_enabled = false
    }
  }
  
  # Common tags for all resources
  common_tags = merge(var.common_tags, {
    "Owner"       = var.owner
    "Project"     = var.project_name
    "CostCenter"  = var.cost_center
    "CreatedBy"   = "terraform"
    "CreatedAt"   = timestamp()
  })
}

# ============================================================================
# PROVIDER CONFIGURATION VALIDATION RESOURCES
# ============================================================================

# Generate unique identifiers for testing
resource "random_string" "provider_test_suffix" {
  count   = var.provider_test_resources
  length  = 8
  special = false
  upper   = false
}

# Test provider connectivity with time resources
resource "time_static" "provider_test_start" {
  count = var.test_mode ? 1 : 0
}

resource "time_sleep" "provider_initialization_delay" {
  count = var.test_mode ? 1 : 0
  
  depends_on = [time_static.provider_test_start]
  
  create_duration = "10s"
}

resource "time_static" "provider_test_end" {
  count = var.test_mode ? 1 : 0
  
  depends_on = [time_sleep.provider_initialization_delay]
}

# ============================================================================
# MULTI-ENVIRONMENT RESOURCE EXAMPLES
# ============================================================================

# Development environment VPC (using dev provider alias)
resource "ibm_is_vpc" "dev_vpc" {
  provider = ibm.dev
  count    = var.test_mode ? 1 : 0
  
  name           = "${local.name_prefix}-dev-vpc"
  resource_group = var.dev_resource_group_id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["environment:development", "provider:dev-alias"]
  )
}

# Staging environment VPC (using staging provider alias)
resource "ibm_is_vpc" "staging_vpc" {
  provider = ibm.staging
  count    = var.test_mode ? 1 : 0
  
  name           = "${local.name_prefix}-staging-vpc"
  resource_group = var.staging_resource_group_id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["environment:staging", "provider:staging-alias"]
  )
}

# Production environment VPC (using prod provider alias)
resource "ibm_is_vpc" "prod_vpc" {
  provider = ibm.prod
  count    = var.test_mode ? 1 : 0
  
  name           = "${local.name_prefix}-prod-vpc"
  resource_group = var.prod_resource_group_id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["environment:production", "provider:prod-alias"]
  )
}

# ============================================================================
# MULTI-REGION RESOURCE EXAMPLES
# ============================================================================

# US South region VPC (using us_south provider alias)
resource "ibm_is_vpc" "us_south_vpc" {
  provider = ibm.us_south
  count    = var.test_mode ? 1 : 0
  
  name           = "${local.name_prefix}-us-south-vpc"
  resource_group = var.resource_group_id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["region:us-south", "provider:us-south-alias"]
  )
}

# EU GB region VPC (using eu_gb provider alias)
resource "ibm_is_vpc" "eu_gb_vpc" {
  provider = ibm.eu_gb
  count    = var.test_mode ? 1 : 0
  
  name           = "${local.name_prefix}-eu-gb-vpc"
  resource_group = var.resource_group_id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["region:eu-gb", "provider:eu-gb-alias"]
  )
}

# Asia Pacific region VPC (using jp_tok provider alias)
resource "ibm_is_vpc" "jp_tok_vpc" {
  provider = ibm.jp_tok
  count    = var.test_mode ? 1 : 0
  
  name           = "${local.name_prefix}-jp-tok-vpc"
  resource_group = var.resource_group_id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["region:jp-tok", "provider:jp-tok-alias"]
  )
}

# ============================================================================
# PROVIDER PERFORMANCE TESTING RESOURCES
# ============================================================================

# Resource group for testing (if not provided)
data "ibm_resource_group" "default" {
  count = var.resource_group_id == null ? 1 : 0
  name  = "default"
}

# Test resource creation with different provider configurations
resource "ibm_is_vpc" "performance_test" {
  count = var.test_mode ? var.provider_test_resources : 0
  
  name           = "${local.name_prefix}-perf-test-${count.index + 1}"
  resource_group = var.resource_group_id != null ? var.resource_group_id : data.ibm_resource_group.default[0].id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "test:performance",
      "index:${count.index + 1}",
      "provider:main"
    ]
  )
}

# ============================================================================
# AUTHENTICATION AND SECURITY VALIDATION
# ============================================================================

# Create security group to test provider authentication
resource "ibm_is_security_group" "provider_auth_test" {
  count = var.test_mode ? 1 : 0
  
  name           = "${local.name_prefix}-auth-test-sg"
  vpc            = var.test_mode ? ibm_is_vpc.performance_test[0].id : null
  resource_group = var.resource_group_id != null ? var.resource_group_id : data.ibm_resource_group.default[0].id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["test:authentication", "resource:security-group"]
  )
}

# Security group rule to test provider permissions
resource "ibm_is_security_group_rule" "provider_auth_rule" {
  count = var.test_mode ? 1 : 0
  
  group     = ibm_is_security_group.provider_auth_test[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# ============================================================================
# PROVIDER CONFIGURATION DOCUMENTATION
# ============================================================================

# Generate provider configuration documentation
resource "local_file" "provider_config_documentation" {
  count = var.test_mode ? 1 : 0
  
  filename = "provider-configuration-report.json"
  content = jsonencode({
    provider_configuration = {
      main_provider = {
        region            = var.ibm_region
        timeout           = var.provider_timeout
        max_retries       = var.max_retries
        retry_delay       = var.retry_delay
        endpoint_type     = var.endpoint_type
        visibility        = var.visibility
        trace_logging     = var.enable_trace_logging
        security_level    = var.security_level
        performance_mode  = var.performance_mode
      }
      environment_providers = {
        development = {
          region        = var.dev_region
          endpoint_type = "public"
          debug_enabled = true
        }
        staging = {
          region        = var.staging_region
          endpoint_type = "public"
          debug_enabled = false
        }
        production = {
          region        = var.prod_region
          endpoint_type = "private"
          debug_enabled = false
        }
      }
      regional_providers = {
        us_south = {
          region  = "us-south"
          latency = "low"
          timeout = 180
        }
        eu_gb = {
          region  = "eu-gb"
          latency = "medium"
          timeout = 300
        }
        jp_tok = {
          region  = "jp-tok"
          latency = "high"
          timeout = 360
        }
      }
      feature_flags = var.feature_flags
      test_results = {
        test_start_time = var.test_mode ? time_static.provider_test_start[0].rfc3339 : null
        test_end_time   = var.test_mode ? time_static.provider_test_end[0].rfc3339 : null
        resources_created = var.test_mode ? var.provider_test_resources : 0
      }
    }
    metadata = {
      generated_at = timestamp()
      terraform_version = "1.5.0"
      provider_version = "1.58.0"
      lab_version = "3.3"
    }
  })
}

# ============================================================================
# PROVIDER MONITORING AND METRICS
# ============================================================================

# Create monitoring configuration file
resource "local_file" "provider_monitoring_config" {
  count = var.monitoring_enabled ? 1 : 0
  
  filename = "provider-monitoring-config.yaml"
  content = yamlencode({
    monitoring = {
      enabled = var.monitoring_enabled
      metrics = {
        provider_performance = true
        authentication_events = true
        error_tracking = true
        resource_creation_time = true
      }
      alerts = {
        authentication_failures = true
        timeout_errors = true
        rate_limit_exceeded = true
        provider_unavailable = true
      }
      logging = {
        level = var.debug_mode ? "DEBUG" : "INFO"
        trace_enabled = var.enable_trace_logging
        custom_headers = true
      }
    }
    providers = {
      main = {
        alias = "default"
        region = var.ibm_region
        monitoring_enabled = true
      }
      environments = [
        {
          alias = "dev"
          region = var.dev_region
          monitoring_enabled = true
        },
        {
          alias = "staging"
          region = var.staging_region
          monitoring_enabled = true
        },
        {
          alias = "prod"
          region = var.prod_region
          monitoring_enabled = true
        }
      ]
    }
  })
}
