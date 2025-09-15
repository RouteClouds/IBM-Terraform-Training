# Output Values for IBM Cloud Provider Configuration Lab 2.2
# This file provides comprehensive outputs for provider configuration validation and analysis

# =============================================================================
# PROVIDER CONFIGURATION OUTPUTS
# =============================================================================

output "provider_configuration_summary" {
  description = "Comprehensive summary of all provider configurations"
  value = {
    primary_provider = {
      region           = var.ibm_region
      zone             = var.ibm_zone
      timeout          = var.provider_timeout
      max_retries      = var.max_retries
      retry_delay      = var.retry_delay
      private_endpoints = var.use_private_endpoints
      debug_tracing    = var.enable_debug_tracing
    }
    
    multi_region_providers = {
      for region_key, region_config in local.regions : region_key => {
        region = region_config.name
        zones_available = length(region_config.zones)
        resource_group_id = region_config.rg_id
        provider_alias = region_config.provider
      }
    }
    
    environment_providers = {
      enterprise = {
        configured = local.provider_validation.enterprise_configured
        region = var.enterprise_region
        zone = var.enterprise_zone
        security_level = "maximum"
      }
      development = {
        configured = local.provider_validation.dev_configured
        region = var.dev_region
        zone = var.dev_zone
        security_level = "standard"
      }
      staging = {
        configured = local.provider_validation.staging_configured
        region = var.staging_region
        zone = var.staging_zone
        security_level = "enhanced"
      }
      testing = {
        configured = local.provider_validation.testing_configured
        region = var.testing_region
        zone = var.testing_zone
        security_level = "minimal"
      }
      disaster_recovery = {
        configured = local.provider_validation.dr_configured
        region = var.dr_region
        zone = var.dr_zone
        security_level = "maximum"
      }
    }
  }
}

output "authentication_validation_results" {
  description = "Results of authentication validation tests"
  value = {
    primary_authentication = {
      api_key_configured = local.provider_validation.primary_configured
      authentication_method = "api_key"
      validation_status = local.provider_validation.primary_configured ? "valid" : "missing"
    }
    
    service_id_authentication = var.validate_authentication ? {
      service_id_created = length(ibm_iam_service_id.provider_test) > 0
      api_key_generated = length(ibm_iam_service_api_key.provider_test_key) > 0
      access_policy_applied = length(ibm_iam_service_policy.provider_test_policy) > 0
      service_id_id = length(ibm_iam_service_id.provider_test) > 0 ? ibm_iam_service_id.provider_test[0].id : null
    } : {
      validation_skipped = true
      reason = "Authentication validation disabled"
    }
    
    multi_environment_auth = {
      enterprise_configured = local.provider_validation.enterprise_configured
      development_configured = local.provider_validation.dev_configured
      staging_configured = local.provider_validation.staging_configured
      testing_configured = local.provider_validation.testing_configured
      dr_configured = local.provider_validation.dr_configured
    }
  }
}

output "connectivity_test_results" {
  description = "Results of provider connectivity testing"
  value = {
    primary_connectivity = var.test_connectivity ? {
      test_enabled = true
      vpc_created = length(ibm_is_vpc.connectivity_test) > 0
      vpc_id = length(ibm_is_vpc.connectivity_test) > 0 ? ibm_is_vpc.connectivity_test[0].id : null
      vpc_status = length(ibm_is_vpc.connectivity_test) > 0 ? ibm_is_vpc.connectivity_test[0].status : null
      test_result = "successful"
    } : {
      test_enabled = false
      reason = "Connectivity testing disabled"
    }
    
    multi_region_connectivity = var.test_multi_region ? {
      test_enabled = true
      regions_tested = keys(local.regions)
      vpcs_created = length(ibm_is_vpc.multi_region_test)
      test_results = {
        for region_key, vpc in ibm_is_vpc.multi_region_test : region_key => {
          vpc_id = vpc.id
          vpc_status = vpc.status
          region = local.regions[region_key].name
          zones_available = length(local.regions[region_key].zones)
        }
      }
    } : {
      test_enabled = false
      reason = "Multi-region testing disabled"
    }
    
    network_connectivity = {
      private_endpoints_enabled = var.use_private_endpoints
      force_private_endpoints = var.force_private_endpoints
      endpoint_strategy = var.use_private_endpoints ? "private" : "public"
    }
  }
}

output "security_configuration_status" {
  description = "Comprehensive security configuration status"
  value = {
    endpoint_security = {
      private_endpoints_enabled = var.use_private_endpoints
      force_private_endpoints = var.force_private_endpoints
      staging_private_endpoints = var.staging_use_private_endpoints
    }
    
    authentication_security = {
      api_key_authentication = local.provider_validation.primary_configured
      service_id_authentication = var.validate_authentication
      classic_infrastructure = var.enable_classic_infrastructure
      classic_credentials_configured = var.classic_username != null && var.classic_api_key != null
    }
    
    monitoring_and_audit = {
      debug_tracing_enabled = var.enable_debug_tracing
      enterprise_tracing = var.enterprise_enable_tracing
      staging_tracing = var.staging_enable_tracing
      kubernetes_tracing = var.kubernetes_enable_tracing
      audit_logging_enabled = var.enable_audit_logging
    }
    
    compliance_features = {
      vpc_generation = var.vpc_generation
      custom_endpoints_configured = length(keys(var.custom_endpoints)) > 0
      enterprise_compliance = var.enterprise_api_key != null
    }
  }
}

output "performance_metrics" {
  description = "Provider performance testing results and metrics"
  value = var.performance_testing_enabled ? {
    performance_testing_enabled = true
    test_start_time = time_static.performance_start[0].rfc3339
    test_end_time = time_static.performance_end[0].rfc3339
    resources_created = length(ibm_is_vpc.performance_test)
    parallel_creation = true
    
    provider_settings = {
      timeout_configuration = var.provider_timeout
      retry_configuration = var.max_retries
      retry_delay = var.retry_delay
    }
    
    performance_recommendations = [
      var.provider_timeout < 600 ? "Consider increasing provider timeout for complex operations" : "Provider timeout appropriately configured",
      var.max_retries < 5 ? "Consider increasing max retries for better reliability" : "Retry configuration is adequate",
      !var.use_private_endpoints ? "Private endpoints can improve performance" : "Private endpoints configured for optimal performance"
    ]
  } : {
    performance_testing_enabled = false
    reason = "Performance testing disabled"
    recommendations = [
      "Enable performance testing to establish baseline metrics",
      "Monitor provider operation times in production environments",
      "Implement performance monitoring and alerting"
    ]
  }
}

output "resource_deployment_summary" {
  description = "Summary of all resources deployed during provider configuration testing"
  value = {
    deployment_metadata = {
      lab_id = "2.2"
      project_name = var.project_name
      environment = var.environment
      deployment_time = time_static.deployment_time.rfc3339
      resource_prefix = local.name_prefix
    }
    
    vpc_resources = {
      connectivity_test_vpcs = var.test_connectivity ? length(ibm_is_vpc.connectivity_test) : 0
      multi_region_vpcs = var.test_multi_region ? length(ibm_is_vpc.multi_region_test) : 0
      enterprise_vpcs = var.enterprise_api_key != null ? length(ibm_is_vpc.enterprise_demo) : 0
      development_vpcs = var.dev_api_key != null ? length(ibm_is_vpc.development_demo) : 0
      performance_test_vpcs = var.performance_testing_enabled ? length(ibm_is_vpc.performance_test) : 0
      total_vpcs = (
        (var.test_connectivity ? length(ibm_is_vpc.connectivity_test) : 0) +
        (var.test_multi_region ? length(ibm_is_vpc.multi_region_test) : 0) +
        (var.enterprise_api_key != null ? length(ibm_is_vpc.enterprise_demo) : 0) +
        (var.dev_api_key != null ? length(ibm_is_vpc.development_demo) : 0) +
        (var.performance_testing_enabled ? length(ibm_is_vpc.performance_test) : 0)
      )
    }
    
    subnet_resources = {
      enterprise_subnets = var.enterprise_api_key != null ? length(ibm_is_subnet.enterprise_subnet) : 0
      total_subnets = var.enterprise_api_key != null ? length(ibm_is_subnet.enterprise_subnet) : 0
    }
    
    iam_resources = {
      service_ids = var.validate_authentication ? length(ibm_iam_service_id.provider_test) : 0
      api_keys = var.validate_authentication ? length(ibm_iam_service_api_key.provider_test_key) : 0
      policies = var.validate_authentication ? length(ibm_iam_service_policy.provider_test_policy) : 0
    }
    
    tagging_strategy = {
      common_tags_applied = length(local.common_tags)
      tag_list_length = length(local.tag_list)
      cost_tracking_enabled = var.enable_cost_tracking
      cost_center = var.cost_center
    }
  }
}

output "cost_management_information" {
  description = "Cost management and tracking information"
  value = {
    cost_tracking = {
      enabled = var.enable_cost_tracking
      cost_center = var.cost_center
      budget_alert_threshold = var.budget_alert_threshold
      owner = var.owner
    }
    
    resource_costs = {
      estimated_monthly_cost = "$0.00 USD"
      cost_breakdown = {
        vpcs = "Free tier - no charges"
        subnets = "Free tier - no charges"
        service_ids = "Free tier - no charges"
        api_keys = "Free tier - no charges"
      }
      
      cost_optimization_notes = [
        "All lab resources use free tier services",
        "No ongoing charges for VPC and subnet resources",
        "IAM resources (Service IDs, API keys) are free",
        "Clean up resources after lab completion"
      ]
    }
    
    cleanup_instructions = {
      command = "terraform destroy"
      estimated_cleanup_time = "5-10 minutes"
      resources_to_cleanup = (
        (var.test_connectivity ? length(ibm_is_vpc.connectivity_test) : 0) +
        (var.test_multi_region ? length(ibm_is_vpc.multi_region_test) : 0) +
        (var.enterprise_api_key != null ? (length(ibm_is_vpc.enterprise_demo) + length(ibm_is_subnet.enterprise_subnet)) : 0) +
        (var.dev_api_key != null ? length(ibm_is_vpc.development_demo) : 0) +
        (var.performance_testing_enabled ? length(ibm_is_vpc.performance_test) : 0) +
        (var.validate_authentication ? (length(ibm_iam_service_id.provider_test) + length(ibm_iam_service_api_key.provider_test_key) + length(ibm_iam_service_policy.provider_test_policy)) : 0)
      )
    }
  }
}

output "lab_completion_assessment" {
  description = "Comprehensive lab completion assessment and next steps"
  value = {
    lab_metadata = {
      lab_id = "LAB-2.2-001"
      lab_name = "IBM Cloud Provider Configuration"
      completion_timestamp = time_static.deployment_time.rfc3339
      student_environment = var.environment
      validation_id = random_string.lab_suffix.result
    }
    
    learning_objectives_achieved = {
      provider_configuration = local.provider_validation.primary_configured
      multi_region_setup = var.test_multi_region
      authentication_methods = var.validate_authentication
      security_implementation = var.use_private_endpoints
      performance_optimization = var.performance_testing_enabled
      enterprise_patterns = var.enterprise_api_key != null
    }
    
    technical_achievements = {
      providers_configured = length([
        for k, v in local.provider_validation : k if v
      ])
      regions_tested = var.test_multi_region ? length(local.regions) : 1
      security_features_enabled = sum([
        var.use_private_endpoints ? 1 : 0,
        var.enable_audit_logging ? 1 : 0,
        var.validate_authentication ? 1 : 0
      ])
      performance_tests_completed = var.performance_testing_enabled ? 1 : 0
    }
    
    readiness_assessment = {
      basic_configuration_ready = local.provider_validation.primary_configured
      multi_region_ready = var.test_multi_region
      enterprise_ready = var.enterprise_api_key != null && var.use_private_endpoints
      security_compliant = var.use_private_endpoints && var.enable_audit_logging
      performance_optimized = var.provider_timeout >= 600 && var.max_retries >= 5
      
      overall_readiness_score = sum([
        local.provider_validation.primary_configured ? 20 : 0,
        var.test_multi_region ? 20 : 0,
        (var.enterprise_api_key != null && var.use_private_endpoints) ? 20 : 0,
        (var.use_private_endpoints && var.enable_audit_logging) ? 20 : 0,
        (var.provider_timeout >= 600 && var.max_retries >= 5) ? 20 : 0
      ])
    }
    
    next_steps = {
      immediate_actions = [
        "Review provider configuration validation results",
        "Test provider configurations in target environments",
        "Implement organization-specific security policies"
      ]
      
      learning_progression = [
        "✅ Complete Topic 3: Core Terraform Workflow",
        "📚 Explore advanced provider features and configurations",
        "🔧 Implement CI/CD integration with provider configurations",
        "👥 Develop team collaboration standards",
        "🚀 Begin production infrastructure automation projects"
      ]
      
      advanced_topics = [
        "Implement provider configuration in CI/CD pipelines",
        "Explore IBM Cloud provider advanced features",
        "Design multi-account enterprise architectures",
        "Implement comprehensive monitoring and alerting"
      ]
    }
  }
}

output "troubleshooting_information" {
  description = "Troubleshooting information and diagnostic data"
  value = {
    common_configuration_issues = {
      authentication_failures = "Verify API key validity and permissions"
      network_connectivity = "Check firewall rules and proxy settings"
      timeout_errors = "Increase provider timeout values"
      rate_limiting = "Implement appropriate retry delays"
    }
    
    diagnostic_commands = [
      "terraform validate",
      "terraform plan",
      "terraform providers",
      "terraform show",
      "terraform state list"
    ]
    
    provider_debugging = {
      enable_tracing = "Set ibmcloud_trace = true in provider configuration"
      log_level = "Set TF_LOG=DEBUG environment variable"
      api_debugging = "Use IBM Cloud CLI for API connectivity testing"
    }
    
    support_resources = {
      terraform_documentation = "https://developer.hashicorp.com/terraform/docs"
      ibm_cloud_provider_docs = "https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs"
      ibm_cloud_support = "https://cloud.ibm.com/docs/terraform"
      community_forum = "https://discuss.hashicorp.com/c/terraform-providers"
    }
  }
}
