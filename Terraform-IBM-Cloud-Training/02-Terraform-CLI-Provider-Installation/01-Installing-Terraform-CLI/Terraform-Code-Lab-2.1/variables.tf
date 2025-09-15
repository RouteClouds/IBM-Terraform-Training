# Variable Definitions for Terraform CLI Installation Lab 2.1
# This file demonstrates variable usage and validation for CLI installation verification

# IBM Cloud Authentication and Region Configuration
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.ibmcloud_api_key) > 0
    error_message = "IBM Cloud API key must not be empty."
  }
}

variable "ibm_region" {
  description = "IBM Cloud region for CLI testing and verification"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd", "jp-osa", "br-sao", "ca-tor"
    ], var.ibm_region)
    error_message = "IBM region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group for CLI verification"
  type        = string
  default     = "default"
}

# Project and Environment Configuration
variable "project_name" {
  description = "Name of the project for CLI installation verification"
  type        = string
  default     = "terraform-cli-verification"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name for CLI testing"
  type        = string
  default     = "cli-test"
  
  validation {
    condition = contains([
      "dev", "staging", "prod", "cli-test", "verification"
    ], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, cli-test, verification."
  }
}

variable "owner" {
  description = "Owner of the CLI verification resources"
  type        = string
  default     = "terraform-student"
}

# CLI Installation Verification Configuration
variable "terraform_version_constraint" {
  description = "Terraform version constraint for verification"
  type        = string
  default     = ">= 1.5.0"
  
  validation {
    condition     = can(regex("^[><=!~\\s0-9\\.]+$", var.terraform_version_constraint))
    error_message = "Terraform version constraint must be a valid version constraint string."
  }
}

variable "verify_cli_installation" {
  description = "Enable CLI installation verification tests"
  type        = bool
  default     = true
}

variable "verify_provider_installation" {
  description = "Enable provider installation verification"
  type        = bool
  default     = true
}

variable "verify_plugin_cache" {
  description = "Enable plugin cache verification"
  type        = bool
  default     = true
}

variable "create_verification_resources" {
  description = "Create actual IBM Cloud resources for verification"
  type        = bool
  default     = false  # Set to false to avoid costs during CLI testing
}

# CLI Configuration Testing
variable "cli_config_file_path" {
  description = "Path to Terraform CLI configuration file for testing"
  type        = string
  default     = "~/.terraformrc"
}

variable "plugin_cache_dir" {
  description = "Plugin cache directory for verification"
  type        = string
  default     = "~/.terraform.d/plugin-cache"
}

variable "enable_checkpoint" {
  description = "Enable Terraform checkpoint for version checking"
  type        = bool
  default     = false  # Disabled for enterprise environments
}

variable "log_level" {
  description = "Terraform log level for CLI testing"
  type        = string
  default     = "INFO"
  
  validation {
    condition = contains([
      "TRACE", "DEBUG", "INFO", "WARN", "ERROR"
    ], var.log_level)
    error_message = "Log level must be one of: TRACE, DEBUG, INFO, WARN, ERROR."
  }
}

# Version Management Configuration
variable "terraform_versions_to_test" {
  description = "List of Terraform versions to test (for version management verification)"
  type        = list(string)
  default     = ["1.5.7", "1.6.0"]
  
  validation {
    condition     = length(var.terraform_versions_to_test) > 0
    error_message = "At least one Terraform version must be specified for testing."
  }
}

variable "use_version_manager" {
  description = "Whether to use a version manager (tfenv) for testing"
  type        = bool
  default     = false  # Set based on platform availability
}

# Performance Testing Configuration
variable "measure_init_performance" {
  description = "Enable performance measurement for terraform init"
  type        = bool
  default     = true
}

variable "test_plugin_cache_performance" {
  description = "Test plugin cache performance improvement"
  type        = bool
  default     = true
}

variable "performance_test_iterations" {
  description = "Number of iterations for performance testing"
  type        = number
  default     = 3
  
  validation {
    condition     = var.performance_test_iterations >= 1 && var.performance_test_iterations <= 10
    error_message = "Performance test iterations must be between 1 and 10."
  }
}

# Operating System Detection
variable "operating_system" {
  description = "Operating system for CLI installation verification"
  type        = string
  default     = "auto-detect"
  
  validation {
    condition = contains([
      "windows", "macos", "linux", "auto-detect"
    ], var.operating_system)
    error_message = "Operating system must be one of: windows, macos, linux, auto-detect."
  }
}

variable "installation_method" {
  description = "Installation method used for verification"
  type        = string
  default     = "manual"
  
  validation {
    condition = contains([
      "manual", "package-manager", "homebrew", "chocolatey", "docker", "tfenv"
    ], var.installation_method)
    error_message = "Installation method must be a valid installation approach."
  }
}

# Resource Tagging for CLI Verification
variable "tags" {
  description = "List of tags to apply to verification resources"
  type        = list(string)
  default     = ["terraform-cli", "installation-verification", "lab-2.1"]
}

variable "additional_tags" {
  description = "Additional tags for CLI verification resources"
  type        = map(string)
  default     = {}
}

# Testing and Validation Configuration
variable "run_validation_tests" {
  description = "Run comprehensive validation tests after CLI installation"
  type        = bool
  default     = true
}

variable "test_timeout_seconds" {
  description = "Timeout for CLI verification tests in seconds"
  type        = number
  default     = 300
  
  validation {
    condition     = var.test_timeout_seconds >= 60 && var.test_timeout_seconds <= 1800
    error_message = "Test timeout must be between 60 and 1800 seconds."
  }
}

variable "generate_verification_report" {
  description = "Generate a detailed verification report"
  type        = bool
  default     = true
}

# Network and Proxy Configuration
variable "proxy_configuration" {
  description = "Proxy configuration for CLI testing"
  type = object({
    enabled    = bool
    http_proxy = optional(string)
    https_proxy = optional(string)
    no_proxy   = optional(string)
  })
  default = {
    enabled = false
  }
}

variable "test_network_connectivity" {
  description = "Test network connectivity for provider downloads"
  type        = bool
  default     = true
}

# Enterprise Configuration Testing
variable "test_enterprise_features" {
  description = "Test enterprise-specific CLI features"
  type        = bool
  default     = false
}

variable "credential_helper_config" {
  description = "Test credential helper configuration"
  type        = bool
  default     = false
}

variable "provider_mirror_config" {
  description = "Test provider mirror configuration"
  type        = bool
  default     = false
}
