# Output Values for Terraform CLI Installation Verification Lab 2.1
# This file provides comprehensive outputs for CLI verification and analysis

# =============================================================================
# CLI INSTALLATION VERIFICATION OUTPUTS
# =============================================================================

output "cli_installation_status" {
  description = "Comprehensive Terraform CLI installation verification results"
  value = {
    terraform_installed = local.cli_verification.terraform_installed
    terraform_version   = local.cli_verification.terraform_version
    installation_path   = local.cli_verification.installation_path
    installation_valid  = local.cli_verification.terraform_installed && local.cli_verification.terraform_version != "unknown"
    
    version_details = {
      version_string = local.cli_verification.terraform_version
      version_valid  = local.cli_verification.terraform_version != "unknown"
      meets_requirements = can(regex("^1\\.[5-9]\\.", tostring(local.cli_verification.terraform_version)))
    }
    
    installation_recommendations = [
      !local.cli_verification.terraform_installed ? "Install Terraform CLI from https://terraform.io/downloads" : "✓ Terraform CLI is properly installed",
      local.cli_verification.terraform_version == "unknown" ? "Verify Terraform CLI is in system PATH" : "✓ Terraform version detected successfully",
      !can(regex("^1\\.[5-9]\\.", tostring(local.cli_verification.terraform_version))) ? "Update to Terraform 1.5.0 or higher" : "✓ Terraform version meets requirements"
    ]
  }
}

output "cli_configuration_status" {
  description = "Terraform CLI configuration and optimization status"
  value = {
    plugin_cache = {
      enabled = local.cli_verification.plugin_cache_enabled
      directory = local.cli_verification.plugin_cache_dir
      configured = local.cli_verification.plugin_cache_dir != "not_configured"
      recommendation = local.cli_verification.plugin_cache_enabled ? "✓ Plugin cache is enabled" : "Configure TF_PLUGIN_CACHE_DIR for better performance"
    }
    
    system_integration = {
      operating_system = local.system_info.operating_system
      architecture = local.system_info.architecture
      kernel_version = local.system_info.kernel_version
      platform_supported = contains(["Linux", "Darwin", "Windows"], local.system_info.operating_system)
    }
    
    ibm_cloud_cli_integration = {
      cli_installed = local.ibmcloud_cli.installed
      cli_version = local.ibmcloud_cli.version
      integration_status = local.ibmcloud_cli.installed ? "available" : "not_installed"
      recommendation = local.ibmcloud_cli.installed ? "✓ IBM Cloud CLI available for enhanced integration" : "Consider installing IBM Cloud CLI for additional features"
    }
  }
}

output "provider_verification_results" {
  description = "IBM Cloud provider connectivity and verification results"
  value = {
    provider_connectivity = {
      provider_initialized = true
      authentication_valid = data.ibm_resource_group.default.id != null
      account_access = data.ibm_iam_account_settings.account_settings.account_id != null
      account_id = data.ibm_iam_account_settings.account_settings.account_id
    }
    
    regional_availability = {
      target_region = var.ibm_region
      target_zone = var.ibm_zone
      zones_available = data.ibm_is_zones.available_zones.zones
      zone_count = length(data.ibm_is_zones.available_zones.zones)
      multi_zone_support = length(data.ibm_is_zones.available_zones.zones) >= 3
    }
    
    resource_group_access = {
      default_rg_id = data.ibm_resource_group.default.id
      default_rg_name = data.ibm_resource_group.default.name
      access_verified = data.ibm_resource_group.default.id != null
    }
  }
}

output "connectivity_test_results" {
  description = "Results of CLI and provider connectivity testing"
  value = var.enable_cli_testing ? {
    cli_testing_enabled = true
    vpc_creation_test = {
      vpc_created = length(ibm_is_vpc.cli_verification) > 0
      vpc_id = length(ibm_is_vpc.cli_verification) > 0 ? ibm_is_vpc.cli_verification[0].id : null
      vpc_status = length(ibm_is_vpc.cli_verification) > 0 ? ibm_is_vpc.cli_verification[0].status : null
      test_result = length(ibm_is_vpc.cli_verification) > 0 ? "successful" : "failed"
    }
    
    subnet_creation_test = {
      subnet_created = length(ibm_is_subnet.cli_test_subnet) > 0
      subnet_id = length(ibm_is_subnet.cli_test_subnet) > 0 ? ibm_is_subnet.cli_test_subnet[0].id : null
      subnet_status = length(ibm_is_subnet.cli_test_subnet) > 0 ? ibm_is_subnet.cli_test_subnet[0].status : null
      test_result = length(ibm_is_subnet.cli_test_subnet) > 0 ? "successful" : "failed"
    }
    
    overall_test_status = (
      length(ibm_is_vpc.cli_verification) > 0 && 
      length(ibm_is_subnet.cli_test_subnet) > 0
    ) ? "all_tests_passed" : "some_tests_failed"
  } : {
    cli_testing_enabled = false
    reason = "CLI testing disabled in configuration"
    recommendation = "Enable cli testing with enable_cli_testing = true"
  }
}

output "performance_test_results" {
  description = "CLI and provider performance testing results"
  value = var.enable_performance_testing ? {
    performance_testing_enabled = true
    test_configuration = {
      resources_tested = var.performance_test_count
      test_start_time = time_static.performance_start[0].rfc3339
      test_end_time = time_static.performance_end[0].rfc3339
      parallel_creation = true
    }
    
    resource_creation_results = {
      vpcs_created = length(ibm_is_vpc.performance_test)
      creation_successful = length(ibm_is_vpc.performance_test) == var.performance_test_count
      success_rate = "${(length(ibm_is_vpc.performance_test) / var.performance_test_count) * 100}%"
    }
    
    performance_metrics = {
      total_resources = var.performance_test_count
      successful_resources = length(ibm_is_vpc.performance_test)
      failed_resources = var.performance_test_count - length(ibm_is_vpc.performance_test)
      test_duration = "See timestamps for calculation"
    }
    
    performance_recommendations = [
      length(ibm_is_vpc.performance_test) == var.performance_test_count ? "✓ All performance test resources created successfully" : "Some performance test resources failed - check logs",
      "Monitor resource creation times for optimization opportunities",
      "Consider plugin cache configuration for improved performance"
    ]
  } : {
    performance_testing_enabled = false
    reason = "Performance testing disabled in configuration"
    recommendation = "Enable performance testing with enable_performance_testing = true"
  }
}

output "validation_script_status" {
  description = "Status of generated validation and testing scripts"
  value = var.generate_validation_scripts ? {
    scripts_generated = true
    cli_validation_script = {
      generated = length(local_file.cli_validation_script) > 0
      filename = length(local_file.cli_validation_script) > 0 ? local_file.cli_validation_script[0].filename : null
      executable = true
      purpose = "Comprehensive CLI installation and configuration validation"
    }
    
    performance_test_script = {
      generated = length(local_file.performance_test_script) > 0
      filename = length(local_file.performance_test_script) > 0 ? local_file.performance_test_script[0].filename : null
      executable = true
      purpose = "Automated performance testing and benchmarking"
    }
    
    usage_instructions = [
      "Run ./cli-validation.sh to validate CLI installation",
      "Run ./performance-test.sh to execute performance tests",
      "Review generated reports for detailed analysis",
      "Scripts are executable and ready for automation"
    ]
  } : {
    scripts_generated = false
    reason = "Script generation disabled in configuration"
    recommendation = "Enable script generation with generate_validation_scripts = true"
  }
}

output "system_environment_analysis" {
  description = "Comprehensive system environment analysis for Terraform CLI"
  value = {
    operating_system_details = {
      os_name = local.system_info.operating_system
      architecture = local.system_info.architecture
      kernel_version = local.system_info.kernel_version
      platform_compatibility = {
        terraform_supported = contains(["Linux", "Darwin", "Windows"], local.system_info.operating_system)
        architecture_supported = contains(["x86_64", "amd64", "arm64"], local.system_info.architecture)
        recommended_platform = local.system_info.operating_system == "Linux" && local.system_info.architecture == "x86_64"
      }
    }
    
    environment_optimization = {
      plugin_cache_status = local.cli_verification.plugin_cache_enabled
      path_configuration = local.cli_verification.installation_path != "not_found"
      integration_tools = {
        ibm_cloud_cli = local.ibmcloud_cli.installed
        terraform_cli = local.cli_verification.terraform_installed
      }
    }
    
    optimization_recommendations = [
      !local.cli_verification.plugin_cache_enabled ? "Configure TF_PLUGIN_CACHE_DIR environment variable" : "✓ Plugin cache is configured",
      !local.ibmcloud_cli.installed ? "Install IBM Cloud CLI for enhanced workflow integration" : "✓ IBM Cloud CLI is available",
      local.system_info.operating_system != "Linux" ? "Consider Linux for optimal Terraform performance" : "✓ Running on recommended platform"
    ]
  }
}

output "resource_deployment_summary" {
  description = "Summary of all resources deployed during CLI verification"
  value = {
    deployment_metadata = {
      lab_id = "2.1"
      project_name = var.project_name
      environment = var.environment
      deployment_time = time_static.deployment_time.rfc3339
      resource_prefix = local.name_prefix
    }
    
    resource_inventory = {
      vpcs_created = (
        (var.enable_cli_testing ? 1 : 0) +
        (var.enable_performance_testing ? length(ibm_is_vpc.performance_test) : 0)
      )
      subnets_created = var.enable_cli_testing ? 1 : 0
      scripts_generated = var.generate_validation_scripts ? 2 : 0
      reports_generated = 2  # Always generate validation and cost reports
    }
    
    tagging_strategy = {
      common_tags_applied = length(local.common_tags)
      tag_list_length = length(local.tag_list)
      cost_tracking_enabled = var.enable_cost_tracking
      cost_center = var.cost_center
    }
    
    cleanup_information = {
      cleanup_command = "terraform destroy"
      estimated_cleanup_time = "5-10 minutes"
      resources_to_cleanup = (
        (var.enable_cli_testing ? 2 : 0) +
        (var.enable_performance_testing ? var.performance_test_count : 0)
      )
    }
  }
}

output "cost_management_summary" {
  description = "Cost management and resource optimization information"
  value = {
    cost_analysis = {
      estimated_monthly_cost = "$0.00 USD"
      cost_breakdown = {
        vpcs = "Free tier - no charges"
        subnets = "Free tier - no charges"
        scripts = "No charges - local files"
        reports = "No charges - local files"
      }
      
      cost_optimization_notes = [
        "All lab resources use free tier services",
        "No ongoing charges for VPC and subnet resources",
        "Local files and scripts incur no cloud costs",
        "Clean up resources after lab completion"
      ]
    }
    
    resource_efficiency = {
      minimal_resource_usage = true
      free_tier_optimized = true
      cleanup_automated = true
      cost_tracking_enabled = var.enable_cost_tracking
    }
    
    budget_management = var.enable_cost_tracking ? {
      cost_center = var.cost_center
      budget_threshold = var.budget_alert_threshold
      owner = var.owner
      tracking_enabled = true
    } : {
      tracking_enabled = false
      recommendation = "Enable cost tracking for production environments"
    }
  }
}

output "lab_completion_assessment" {
  description = "Comprehensive lab completion assessment and next steps"
  value = {
    lab_metadata = {
      lab_id = "LAB-2.1-001"
      lab_name = "Terraform CLI Installation and Verification"
      completion_timestamp = time_static.deployment_time.rfc3339
      student_environment = var.environment
      validation_id = random_string.lab_suffix.result
    }
    
    completion_criteria = {
      cli_installed = local.cli_verification.terraform_installed
      version_compatible = can(regex("^1\\.[5-9]\\.", tostring(local.cli_verification.terraform_version)))
      provider_connectivity = data.ibm_resource_group.default.id != null
      resource_deployment = var.enable_cli_testing ? length(ibm_is_vpc.cli_verification) > 0 : true
      validation_successful = (
        local.cli_verification.terraform_installed &&
        data.ibm_resource_group.default.id != null &&
        (!var.enable_cli_testing || length(ibm_is_vpc.cli_verification) > 0)
      )
    }
    
    learning_objectives_achieved = {
      terraform_cli_installation = local.cli_verification.terraform_installed
      version_management = local.cli_verification.terraform_version != "unknown"
      provider_configuration = data.ibm_resource_group.default.id != null
      basic_resource_deployment = !var.enable_cli_testing || length(ibm_is_vpc.cli_verification) > 0
      troubleshooting_skills = var.generate_validation_scripts
    }
    
    readiness_assessment = {
      ready_for_next_topic = (
        local.cli_verification.terraform_installed &&
        data.ibm_resource_group.default.id != null
      )
      
      overall_score = sum([
        local.cli_verification.terraform_installed ? 25 : 0,
        local.cli_verification.terraform_version != "unknown" ? 25 : 0,
        data.ibm_resource_group.default.id != null ? 25 : 0,
        (!var.enable_cli_testing || length(ibm_is_vpc.cli_verification) > 0) ? 25 : 0
      ])
      
      performance_level = sum([
        local.cli_verification.terraform_installed ? 25 : 0,
        local.cli_verification.terraform_version != "unknown" ? 25 : 0,
        data.ibm_resource_group.default.id != null ? 25 : 0,
        (!var.enable_cli_testing || length(ibm_is_vpc.cli_verification) > 0) ? 25 : 0
      ]) >= 75 ? "proficient" : "needs_improvement"
    }
    
    next_steps = {
      immediate_actions = [
        "Review CLI installation and configuration results",
        "Test provider functionality with additional resources",
        "Configure plugin cache for improved performance"
      ]
      
      learning_progression = [
        "✅ Proceed to Lab 2.2: Configuring IBM Cloud Provider",
        "📚 Explore advanced CLI features and commands",
        "🔧 Implement CLI automation and scripting",
        "👥 Develop team CLI standards and best practices"
      ]
      
      troubleshooting_resources = [
        "Review generated validation reports",
        "Execute validation scripts for detailed analysis",
        "Consult Terraform documentation for advanced features",
        "Practice with additional IBM Cloud resources"
      ]
    }
  }
}

output "troubleshooting_information" {
  description = "Troubleshooting information and diagnostic guidance"
  value = {
    common_issues = {
      cli_not_found = {
        symptom = "terraform command not found"
        solution = "Add Terraform binary to system PATH or reinstall"
        verification = "Run 'which terraform' to check installation path"
      }
      
      version_mismatch = {
        symptom = "Terraform version too old"
        solution = "Update to Terraform 1.5.0 or higher"
        verification = "Run 'terraform version' to check current version"
      }
      
      provider_auth_failure = {
        symptom = "IBM Cloud authentication errors"
        solution = "Verify API key and permissions"
        verification = "Check IBM Cloud console for API key status"
      }
      
      resource_creation_failure = {
        symptom = "Resource creation timeouts or errors"
        solution = "Check network connectivity and region availability"
        verification = "Review Terraform logs and IBM Cloud status"
      }
    }
    
    diagnostic_commands = [
      "terraform version",
      "terraform providers",
      "terraform validate",
      "terraform plan",
      "which terraform"
    ]
    
    support_resources = {
      terraform_documentation = "https://terraform.io/docs"
      ibm_cloud_provider_docs = "https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs"
      community_support = "https://discuss.hashicorp.com/c/terraform-providers"
      ibm_cloud_support = "https://cloud.ibm.com/docs/terraform"
    }
  }
}
