# Main Configuration for Terraform CLI Installation Verification Lab 2.1
# This file demonstrates CLI verification and validation through IBM Cloud resource deployment

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
# EXTERNAL DATA SOURCES FOR CLI VERIFICATION
# =============================================================================

# Verify Terraform CLI version
data "external" "terraform_version" {
  program = ["bash", "-c", "terraform version -json 2>/dev/null || echo '{\"terraform_version\":\"unknown\"}'"]
}

# Check Terraform CLI installation path
data "external" "terraform_path" {
  program = ["bash", "-c", "which terraform >/dev/null 2>&1 && echo '{\"path\":\"'$(which terraform)'\"}' || echo '{\"path\":\"not_found\"}'"]
}

# Verify plugin cache configuration
data "external" "plugin_cache_check" {
  program = ["bash", "-c", "if [ -n \"$TF_PLUGIN_CACHE_DIR\" ]; then echo '{\"cache_dir\":\"'$TF_PLUGIN_CACHE_DIR'\",\"enabled\":\"true\"}'; else echo '{\"cache_dir\":\"not_configured\",\"enabled\":\"false\"}'; fi"]
}

# Check operating system information
data "external" "os_info" {
  program = ["bash", "-c", "echo '{\"os\":\"'$(uname -s)'\",\"arch\":\"'$(uname -m)'\",\"kernel\":\"'$(uname -r)'\"}'"]
}

# Verify IBM Cloud CLI integration (if available)
data "external" "ibmcloud_cli_check" {
  program = ["bash", "-c", "which ibmcloud >/dev/null 2>&1 && echo '{\"installed\":\"true\",\"version\":\"'$(ibmcloud version 2>/dev/null | head -1 | cut -d' ' -f3)'\"}' || echo '{\"installed\":\"false\",\"version\":\"not_available\"}'"]
}

# =============================================================================
# IBM CLOUD DATA SOURCES FOR CONNECTIVITY TESTING
# =============================================================================

# Test IBM Cloud provider connectivity
data "ibm_resource_group" "default" {
  name = "default"
}

# Verify region availability
data "ibm_is_zones" "available_zones" {
  region = var.ibm_region
}

# Check account information
data "ibm_iam_account_settings" "account_settings" {}

# =============================================================================
# LOCAL VALUES FOR CONFIGURATION
# =============================================================================

locals {
  # Resource naming
  name_prefix = "${var.project_name}-${var.environment}-${random_string.lab_suffix.result}"
  
  # CLI verification results
  cli_verification = {
    terraform_installed = data.external.terraform_path.result.path != "not_found"
    terraform_version   = try(jsondecode(data.external.terraform_version.result.terraform_version), "unknown")
    installation_path   = data.external.terraform_path.result.path
    plugin_cache_enabled = data.external.plugin_cache_check.result.enabled == "true"
    plugin_cache_dir    = data.external.plugin_cache_check.result.cache_dir
  }
  
  # System information
  system_info = {
    operating_system = data.external.os_info.result.os
    architecture     = data.external.os_info.result.arch
    kernel_version   = data.external.os_info.result.kernel
  }
  
  # IBM Cloud CLI integration
  ibmcloud_cli = {
    installed = data.external.ibmcloud_cli_check.result.installed == "true"
    version   = data.external.ibmcloud_cli_check.result.version
  }
  
  # Comprehensive tagging strategy
  common_tags = merge(
    var.common_tags,
    {
      "environment"    = var.environment
      "project"        = var.project_name
      "owner"          = var.owner
      "region"         = var.ibm_region
      "created_by"     = "terraform"
      "creation_date"  = formatdate("YYYY-MM-DD", time_static.deployment_time.rfc3339)
      "lab_id"         = "2.1"
      "purpose"        = "cli-verification"
    }
  )
  
  # Convert tags to list format for IBM Cloud resources
  tag_list = [for k, v in local.common_tags : "${k}:${v}"]
}

# =============================================================================
# CLI VERIFICATION RESOURCES
# =============================================================================

# Create a VPC to test CLI functionality
resource "ibm_is_vpc" "cli_verification" {
  count = var.enable_cli_testing ? 1 : 0
  
  name           = "${local.name_prefix}-cli-test"
  resource_group = data.ibm_resource_group.default.id
  tags           = concat(local.tag_list, ["purpose:cli-verification"])
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Create a subnet for comprehensive testing
resource "ibm_is_subnet" "cli_test_subnet" {
  count = var.enable_cli_testing ? 1 : 0
  
  name            = "${local.name_prefix}-cli-subnet"
  vpc             = ibm_is_vpc.cli_verification[0].id
  zone            = var.ibm_zone
  ipv4_cidr_block = "10.240.0.0/24"
  resource_group  = data.ibm_resource_group.default.id
  tags            = concat(local.tag_list, ["purpose:subnet-test"])
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# =============================================================================
# PERFORMANCE TESTING RESOURCES
# =============================================================================

# Performance test: Multiple resource creation
resource "ibm_is_vpc" "performance_test" {
  count = var.enable_performance_testing ? var.performance_test_count : 0
  
  name           = "${local.name_prefix}-perf-${count.index + 1}"
  resource_group = data.ibm_resource_group.default.id
  tags           = concat(local.tag_list, ["purpose:performance-test", "instance:${count.index + 1}"])
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Performance measurement timestamps
resource "time_static" "performance_start" {
  count = var.enable_performance_testing ? 1 : 0
}

resource "time_static" "performance_end" {
  count = var.enable_performance_testing ? 1 : 0
  
  depends_on = [ibm_is_vpc.performance_test]
}

# =============================================================================
# VALIDATION SCRIPT GENERATION
# =============================================================================

# Generate CLI validation script
resource "local_file" "cli_validation_script" {
  count = var.generate_validation_scripts ? 1 : 0
  
  filename = "${path.module}/cli-validation.sh"
  content = templatefile("${path.module}/cli-validation.sh.tpl", {
    terraform_version = local.cli_verification.terraform_version
    installation_path = local.cli_verification.installation_path
    plugin_cache_dir  = local.cli_verification.plugin_cache_dir
    project_name      = var.project_name
    environment       = var.environment
  })
  
  file_permission = "0755"
}

# Generate performance test script
resource "local_file" "performance_test_script" {
  count = var.generate_validation_scripts ? 1 : 0
  
  filename = "${path.module}/performance-test.sh"
  content = templatefile("${path.module}/performance-test.sh.tpl", {
    test_count       = var.performance_test_count
    project_name     = var.project_name
    environment      = var.environment
    region           = var.ibm_region
  })
  
  file_permission = "0755"
}

# =============================================================================
# COMPREHENSIVE VALIDATION REPORT
# =============================================================================

# Generate comprehensive validation report
resource "local_file" "cli_validation_report" {
  filename = "${path.module}/cli-validation-report.json"
  content = jsonencode({
    validation_metadata = {
      timestamp     = time_static.deployment_time.rfc3339
      lab_id        = "2.1"
      project_name  = var.project_name
      environment   = var.environment
      region        = var.ibm_region
    }
    
    cli_installation = {
      terraform_installed = local.cli_verification.terraform_installed
      terraform_version   = local.cli_verification.terraform_version
      installation_path   = local.cli_verification.installation_path
      plugin_cache_enabled = local.cli_verification.plugin_cache_enabled
      plugin_cache_dir    = local.cli_verification.plugin_cache_dir
    }
    
    system_environment = {
      operating_system = local.system_info.operating_system
      architecture     = local.system_info.architecture
      kernel_version   = local.system_info.kernel_version
    }
    
    ibm_cloud_integration = {
      cli_installed = local.ibmcloud_cli.installed
      cli_version   = local.ibmcloud_cli.version
      provider_connectivity = true
      account_access = data.ibm_iam_account_settings.account_settings.account_id != null
    }
    
    connectivity_tests = {
      provider_initialized = true
      resource_group_access = data.ibm_resource_group.default.id != null
      region_availability = length(data.ibm_is_zones.available_zones.zones) > 0
      available_zones = data.ibm_is_zones.available_zones.zones
    }
    
    resource_deployment = {
      cli_testing_enabled = var.enable_cli_testing
      performance_testing_enabled = var.enable_performance_testing
      validation_scripts_generated = var.generate_validation_scripts
      resources_created = (
        (var.enable_cli_testing ? 2 : 0) +
        (var.enable_performance_testing ? var.performance_test_count : 0)
      )
    }
    
    performance_metrics = var.enable_performance_testing ? {
      test_start_time = time_static.performance_start[0].rfc3339
      test_end_time   = time_static.performance_end[0].rfc3339
      resources_tested = var.performance_test_count
      parallel_creation = true
    } : null
    
    recommendations = [
      !local.cli_verification.terraform_installed ? "Install Terraform CLI" : null,
      !local.cli_verification.plugin_cache_enabled ? "Configure plugin cache for better performance" : null,
      !local.ibmcloud_cli.installed ? "Consider installing IBM Cloud CLI for enhanced integration" : null,
      length(data.ibm_is_zones.available_zones.zones) < 3 ? "Region has limited zone availability" : null
    ]
    
    next_steps = [
      "Review CLI installation and configuration",
      "Test provider functionality with sample resources",
      "Configure plugin cache for improved performance",
      "Proceed to Topic 2.2: Configuring IBM Cloud Provider",
      "Implement organization-specific CLI standards"
    ]
  })
}

# =============================================================================
# COST TRACKING AND MONITORING
# =============================================================================

# Cost tracking report
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
        (var.enable_cli_testing ? 1 : 0) +
        (var.enable_performance_testing ? var.performance_test_count : 0)
      )
      subnets_created = var.enable_cli_testing ? 1 : 0
      scripts_generated = var.generate_validation_scripts ? 2 : 0
    }
    
    estimated_costs = {
      vpcs = "Free tier - no charges"
      subnets = "Free tier - no charges"
      scripts = "No charges - local files"
      total_estimated = "$0.00 USD/month"
    }
    
    cost_optimization_tips = [
      "All lab resources use free tier services",
      "Clean up resources after lab completion",
      "Monitor IBM Cloud billing dashboard",
      "Use resource groups for cost organization"
    ]
  })
}
