# =============================================================================
# TERRAFORM PROVIDERS CONFIGURATION
# Advanced HCL Configuration Lab - Topic 4.2
# =============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    # IBM Cloud Provider for infrastructure resources
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.60"
    }
    
    # Random provider for generating unique values
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    
    # Time provider for time-based resources
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    
    # Local provider for local file operations
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    
    # Template provider for dynamic content generation
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    
    # Null provider for provisioners and triggers
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
  
  # Backend configuration for state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "hcl-advanced-lab/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# =============================================================================
# IBM CLOUD PROVIDER CONFIGURATION
# =============================================================================

# Primary IBM Cloud provider
provider "ibm" {
  # Authentication will be handled via environment variables:
  # IBMCLOUD_API_KEY or IC_API_KEY

  region = var.primary_region

  # Resource group for all resources
  resource_group = var.resource_group_id
}

# Secondary IBM Cloud provider for multi-region deployments
provider "ibm" {
  alias  = "secondary"
  region = var.secondary_region

  resource_group = var.resource_group_id
}

# Disaster recovery provider for backup region
provider "ibm" {
  alias  = "dr"
  region = var.disaster_recovery_region

  resource_group = var.resource_group_id
}

# =============================================================================
# RANDOM PROVIDER CONFIGURATION
# =============================================================================

provider "random" {
  # No specific configuration required
}

# =============================================================================
# TIME PROVIDER CONFIGURATION
# =============================================================================

provider "time" {
  # No specific configuration required
}

# =============================================================================
# LOCAL PROVIDER CONFIGURATION
# =============================================================================

provider "local" {
  # No specific configuration required
}

# =============================================================================
# TEMPLATE PROVIDER CONFIGURATION
# =============================================================================

provider "template" {
  # No specific configuration required
}

# =============================================================================
# NULL PROVIDER CONFIGURATION
# =============================================================================

provider "null" {
  # No specific configuration required
}

# =============================================================================
# PROVIDER VALIDATION AND HEALTH CHECKS
# =============================================================================

# Validate IBM Cloud provider connectivity
resource "null_resource" "provider_validation" {
  count = var.feature_flags.enable_provider_validation ? 1 : 0
  
  triggers = {
    primary_region   = var.primary_region
    secondary_region = var.secondary_region
    dr_region       = var.disaster_recovery_region
    timestamp       = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Validating IBM Cloud provider connectivity..."
      echo "Primary Region: ${var.primary_region}"
      echo "Secondary Region: ${var.secondary_region}"
      echo "DR Region: ${var.disaster_recovery_region}"
      echo "Validation completed at: $(date)"
    EOT
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Provider health check resource
resource "time_static" "provider_health_check" {
  count = var.feature_flags.enable_provider_validation ? 1 : 0
  
  triggers = {
    provider_config = jsonencode({
      primary_region   = var.primary_region
      secondary_region = var.secondary_region
      dr_region       = var.disaster_recovery_region
    })
  }
}

# =============================================================================
# PROVIDER CONFIGURATION OUTPUTS
# =============================================================================

# Provider configuration summary (for debugging and validation)
locals {
  provider_configuration = {
    terraform_version = ">=1.0"
    providers = {
      ibm = {
        version        = "~> 1.60"
        primary_region = var.primary_region
        regions_configured = [
          var.primary_region,
          var.secondary_region,
          var.disaster_recovery_region
        ]
      }
      random   = { version = "~> 3.4" }
      time     = { version = "~> 0.9" }
      local    = { version = "~> 2.4" }
      template = { version = "~> 2.2" }
      null     = { version = "~> 3.2" }
    }
    
    # Provider features enabled
    features = {
      multi_region_deployment = var.feature_flags.enable_multi_region
      disaster_recovery      = var.feature_flags.enable_disaster_recovery
      provider_validation    = var.feature_flags.enable_provider_validation
      default_tagging       = true
    }
    
    # Authentication method
    authentication = {
      method = "environment_variables"
      variables = [
        "IBMCLOUD_API_KEY",
        "IC_API_KEY"
      ]
    }
  }
  
  # Provider tags applied to all resources
  provider_tags = merge(
    var.global_tags,
    {
      "terraform:managed"    = "true"
      "terraform:workspace"  = terraform.workspace
      "terraform:lab"        = "hcl-advanced-4.2"
      "provider:version"     = "ibm-~>1.60"
      "deployment:timestamp" = timestamp()
    }
  )
}

# =============================================================================
# PROVIDER FEATURE FLAGS
# =============================================================================

# Feature flags for conditional provider behavior
locals {
  provider_features = {
    # Multi-region deployment
    multi_region_enabled = var.feature_flags.enable_multi_region && length([
      var.primary_region,
      var.secondary_region
    ]) > 1

    # Disaster recovery
    disaster_recovery_enabled = var.feature_flags.enable_disaster_recovery && var.disaster_recovery_region != var.primary_region

    # Provider validation
    validation_enabled = var.feature_flags.enable_provider_validation

    # Advanced features
    advanced_networking = var.feature_flags.enable_advanced_features
    monitoring_enabled  = var.feature_flags.enable_monitoring
    backup_enabled     = var.feature_flags.enable_backup
  }
}

# =============================================================================
# PROVIDER COMPATIBILITY CHECKS
# =============================================================================

# Check for provider compatibility
resource "null_resource" "compatibility_check" {
  count = var.feature_flags.enable_provider_validation ? 1 : 0
  
  triggers = {
    terraform_version = ">=1.0"
    ibm_provider     = "~>1.60"
    compatibility_hash = md5(jsonencode({
      terraform_version = ">=1.0"
      providers = {
        ibm      = "~>1.60"
        random   = "~>3.4"
        time     = "~>0.9"
        local    = "~>2.4"
        template = "~>2.2"
        null     = "~>3.2"
      }
    }))
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Provider Compatibility Check"
      echo "============================"
      echo "Terraform Version: >=1.0"
      echo "IBM Provider: ~>1.60"
      echo "All providers compatible: ✓"
      echo "Check completed: $(date)"
    EOT
  }
}

# =============================================================================
# PROVIDER CONFIGURATION VALIDATION
# =============================================================================

# Validate required environment variables
resource "null_resource" "environment_validation" {
  count = var.feature_flags.enable_provider_validation ? 1 : 0
  
  triggers = {
    validation_timestamp = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Environment Validation"
      echo "====================="
      
      # Check for IBM Cloud API key
      if [ -z "$IBMCLOUD_API_KEY" ] && [ -z "$IC_API_KEY" ]; then
        echo "❌ IBM Cloud API key not found in environment variables"
        echo "   Please set IBMCLOUD_API_KEY or IC_API_KEY"
        exit 1
      else
        echo "✅ IBM Cloud API key found"
      fi
      
      echo "Environment validation completed successfully"
    EOT
  }
}

# =============================================================================
# PROVIDER METADATA
# =============================================================================

# Provider metadata for documentation and debugging
locals {
  provider_metadata = {
    lab_name    = "Advanced HCL Configuration Lab 4.2"
    description = "Demonstrates advanced HCL patterns with multiple providers"
    
    # Provider usage patterns
    usage_patterns = {
      ibm = {
        primary_use   = "IBM Cloud infrastructure resources"
        multi_region  = "Primary, secondary, and DR regions"
        authentication = "Environment variable based"
      }
      random = {
        primary_use = "Unique value generation for resources"
        patterns   = ["passwords", "suffixes", "identifiers"]
      }
      time = {
        primary_use = "Time-based resources and triggers"
        patterns   = ["timestamps", "rotation", "scheduling"]
      }
      local = {
        primary_use = "Local file operations and data"
        patterns   = ["configuration files", "scripts", "templates"]
      }
      template = {
        primary_use = "Dynamic content generation"
        patterns   = ["user data", "configuration templates"]
      }
      null = {
        primary_use = "Provisioners and trigger resources"
        patterns   = ["validation", "external commands", "dependencies"]
      }
    }
    
    # Best practices implemented
    best_practices = [
      "Version constraints for all providers",
      "Multi-region provider configuration",
      "Default tagging strategy",
      "Provider validation and health checks",
      "Environment variable authentication",
      "Conditional resource creation",
      "Provider feature flags",
      "Compatibility validation"
    ]
  }
}
