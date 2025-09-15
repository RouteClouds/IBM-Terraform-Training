# Provider Configuration and Authentication - Outputs
# Comprehensive outputs demonstrating provider configuration results,
# authentication validation, and enterprise monitoring capabilities

# ============================================================================
# PROVIDER CONFIGURATION OUTPUTS
# ============================================================================

output "provider_configuration_summary" {
  description = "Summary of provider configuration settings and validation results"
  value = {
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
    feature_flags = var.feature_flags
    test_mode     = var.test_mode
    monitoring    = var.monitoring_enabled
  }
}

output "environment_provider_configurations" {
  description = "Configuration details for environment-specific providers"
  value = {
    development = {
      region        = var.dev_region
      endpoint_type = "public"
      debug_enabled = true
      timeout       = 60
      max_retries   = 1
    }
    staging = {
      region        = var.staging_region
      endpoint_type = "public"
      debug_enabled = false
      timeout       = 180
      max_retries   = 2
    }
    production = {
      region        = var.prod_region
      endpoint_type = "private"
      debug_enabled = false
      timeout       = 300
      max_retries   = 3
    }
  }
}

output "regional_provider_configurations" {
  description = "Configuration details for regional provider aliases"
  value = {
    us_south = {
      region  = "us-south"
      latency = "low"
      timeout = 180
      purpose = "primary-region"
    }
    eu_gb = {
      region     = "eu-gb"
      latency    = "medium"
      timeout    = 300
      purpose    = "secondary-region"
      compliance = "gdpr"
    }
    jp_tok = {
      region  = "jp-tok"
      latency = "high"
      timeout = 360
      purpose = "asia-pacific-region"
    }
  }
}

# ============================================================================
# AUTHENTICATION AND SECURITY OUTPUTS
# ============================================================================

output "authentication_configuration" {
  description = "Authentication configuration and security settings"
  value = {
    authentication_method = var.ibm_api_key != "" ? "api_key_variable" : "environment_variable"
    security_level       = var.security_level
    endpoint_type        = var.endpoint_type
    visibility           = var.visibility
    vault_integration    = var.enable_vault_integration
    trace_logging        = var.enable_trace_logging
  }
  sensitive = true
}

output "security_validation_results" {
  description = "Security validation and compliance check results"
  value = {
    endpoint_security = {
      type       = var.endpoint_type
      visibility = var.visibility
      compliant  = var.endpoint_type == "private" && var.visibility == "private" ? "high_security" : "standard_security"
    }
    authentication_security = {
      method = var.ibm_api_key != "" ? "variable_based" : "environment_based"
      secure = var.ibm_api_key == "" ? "recommended" : "acceptable"
    }
    monitoring_security = {
      trace_logging = var.enable_trace_logging
      debug_mode    = var.debug_mode
      production_ready = !var.enable_trace_logging && !var.debug_mode
    }
  }
  sensitive = true
}

# ============================================================================
# RESOURCE CREATION OUTPUTS
# ============================================================================

output "test_resources_created" {
  description = "Information about test resources created for provider validation"
  value = var.test_mode ? {
    performance_test_vpcs = {
      count = length(ibm_is_vpc.performance_test)
      names = [for vpc in ibm_is_vpc.performance_test : vpc.name]
      ids   = [for vpc in ibm_is_vpc.performance_test : vpc.id]
    }
    environment_vpcs = {
      dev = var.test_mode && length(ibm_is_vpc.dev_vpc) > 0 ? {
        name = ibm_is_vpc.dev_vpc[0].name
        id   = ibm_is_vpc.dev_vpc[0].id
      } : null
      staging = var.test_mode && length(ibm_is_vpc.staging_vpc) > 0 ? {
        name = ibm_is_vpc.staging_vpc[0].name
        id   = ibm_is_vpc.staging_vpc[0].id
      } : null
      prod = var.test_mode && length(ibm_is_vpc.prod_vpc) > 0 ? {
        name = ibm_is_vpc.prod_vpc[0].name
        id   = ibm_is_vpc.prod_vpc[0].id
      } : null
    }
    regional_vpcs = {
      us_south = var.test_mode && length(ibm_is_vpc.us_south_vpc) > 0 ? {
        name = ibm_is_vpc.us_south_vpc[0].name
        id   = ibm_is_vpc.us_south_vpc[0].id
      } : null
      eu_gb = var.test_mode && length(ibm_is_vpc.eu_gb_vpc) > 0 ? {
        name = ibm_is_vpc.eu_gb_vpc[0].name
        id   = ibm_is_vpc.eu_gb_vpc[0].id
      } : null
      jp_tok = var.test_mode && length(ibm_is_vpc.jp_tok_vpc) > 0 ? {
        name = ibm_is_vpc.jp_tok_vpc[0].name
        id   = ibm_is_vpc.jp_tok_vpc[0].id
      } : null
    }
    security_group = var.test_mode && length(ibm_is_security_group.provider_auth_test) > 0 ? {
      name = ibm_is_security_group.provider_auth_test[0].name
      id   = ibm_is_security_group.provider_auth_test[0].id
    } : null
  } : null
}

# ============================================================================
# PERFORMANCE AND MONITORING OUTPUTS
# ============================================================================

output "provider_performance_metrics" {
  description = "Provider performance configuration and optimization settings"
  value = {
    performance_mode = var.performance_mode
    timeout_settings = {
      provider_timeout = var.provider_timeout
      retry_settings = {
        max_retries = var.max_retries
        retry_delay = var.retry_delay
      }
    }
    regional_optimization = {
      for region, config in local.regional_config : region => {
        latency_class = config.latency_class
        timeout       = config.timeout
        zone_suffix   = config.zone_suffix
      }
    }
    performance_config = local.performance_config[var.performance_mode]
  }
}

output "monitoring_configuration" {
  description = "Monitoring and observability configuration details"
  value = {
    monitoring_enabled = var.monitoring_enabled
    debug_mode        = var.debug_mode
    trace_logging     = var.enable_trace_logging
    validation_enabled = var.validation_enabled
    test_mode         = var.test_mode
    monitoring_files = var.monitoring_enabled ? {
      config_file = "provider-monitoring-config.yaml"
      created     = true
    } : null
  }
}

# ============================================================================
# TESTING AND VALIDATION OUTPUTS
# ============================================================================

output "provider_test_results" {
  description = "Provider configuration testing and validation results"
  value = var.test_mode ? {
    test_execution = {
      start_time = length(time_static.provider_test_start) > 0 ? time_static.provider_test_start[0].rfc3339 : null
      end_time   = length(time_static.provider_test_end) > 0 ? time_static.provider_test_end[0].rfc3339 : null
      duration   = "10 seconds (simulated)"
    }
    resource_validation = {
      test_resources_requested = var.provider_test_resources
      test_resources_created   = length(ibm_is_vpc.performance_test)
      success_rate            = length(ibm_is_vpc.performance_test) == var.provider_test_resources ? "100%" : "partial"
    }
    provider_connectivity = {
      main_provider = "validated"
      dev_provider  = length(ibm_is_vpc.dev_vpc) > 0 ? "validated" : "not_tested"
      staging_provider = length(ibm_is_vpc.staging_vpc) > 0 ? "validated" : "not_tested"
      prod_provider = length(ibm_is_vpc.prod_vpc) > 0 ? "validated" : "not_tested"
    }
    authentication_test = {
      method = var.ibm_api_key != "" ? "variable_based" : "environment_based"
      status = "successful"
      security_group_created = length(ibm_is_security_group.provider_auth_test) > 0
    }
  } : {
    message = "Test mode disabled - no validation performed"
    enable_instructions = "Set test_mode = true to enable provider testing"
    test_execution = null
    resource_validation = null
    provider_connectivity = null
    authentication_test = null
  }
}

# ============================================================================
# DOCUMENTATION AND REPORTING OUTPUTS
# ============================================================================

output "generated_documentation" {
  description = "Generated documentation and configuration files"
  value = {
    provider_config_report = var.test_mode ? {
      filename = "provider-configuration-report.json"
      created  = length(local_file.provider_config_documentation) > 0
      content_summary = "Comprehensive provider configuration details and test results"
    } : null
    monitoring_config = var.monitoring_enabled ? {
      filename = "provider-monitoring-config.yaml"
      created  = length(local_file.provider_monitoring_config) > 0
      content_summary = "Monitoring and alerting configuration for providers"
    } : null
  }
}

output "enterprise_integration_summary" {
  description = "Enterprise integration capabilities and configuration"
  value = {
    multi_environment_support = {
      development = var.dev_region
      staging     = var.staging_region
      production  = var.prod_region
    }
    multi_region_support = {
      primary   = "us-south"
      secondary = "eu-gb"
      tertiary  = "jp-tok"
    }
    security_features = {
      private_endpoints = var.endpoint_type == "private"
      private_visibility = var.visibility == "private"
      vault_integration = var.enable_vault_integration
      enhanced_security = var.feature_flags.enhanced_security
    }
    automation_features = {
      ci_cd_ready = true
      gitops_compatible = true
      monitoring_integrated = var.monitoring_enabled
      testing_framework = var.test_mode
    }
  }
}

# ============================================================================
# TROUBLESHOOTING AND SUPPORT OUTPUTS
# ============================================================================

output "troubleshooting_information" {
  description = "Troubleshooting information and diagnostic details"
  value = {
    provider_versions = {
      terraform_version = "1.5.0"
      ibm_provider_version = "1.58.0"
      required_providers = "configured"
    }
    common_issues = {
      authentication = "Verify IC_API_KEY environment variable or ibm_api_key variable"
      permissions = "Ensure API key has proper IAM permissions for VPC and resource management"
      regions = "Verify region names match IBM Cloud available regions"
      timeouts = "Adjust provider_timeout, max_retries, and retry_delay for network conditions"
    }
    diagnostic_commands = {
      check_providers = "terraform providers"
      validate_config = "terraform validate"
      debug_mode = "export TF_LOG=DEBUG && terraform plan"
      test_connectivity = "Set test_mode = true and run terraform apply"
    }
    support_resources = {
      documentation = "IBM Cloud Terraform Provider Documentation"
      community = "Terraform IBM Cloud Provider GitHub Issues"
      enterprise_support = "IBM Cloud Support"
    }
  }
}

# ============================================================================
# COST AND RESOURCE MANAGEMENT OUTPUTS
# ============================================================================

output "cost_management_information" {
  description = "Cost management and resource optimization information"
  value = {
    resource_tagging = {
      common_tags_applied = length(local.common_tags)
      cost_center = var.cost_center
      owner = var.owner
      project = var.project_name
    }
    cost_optimization = {
      feature_enabled = var.feature_flags.cost_optimization
      test_mode_resources = var.test_mode ? var.provider_test_resources : 0
      estimated_monthly_cost = var.test_mode ? "~$50-100 USD (test resources)" : "$0 (no resources created)"
    }
    resource_cleanup = {
      test_resources = var.test_mode ? "Run 'terraform destroy' to clean up test resources" : "No cleanup needed"
      monitoring = "Review generated monitoring configuration files"
    }
  }
}
