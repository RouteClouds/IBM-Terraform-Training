# Git Collaboration Lab - Provider Configuration
# Enterprise provider setup for version control and collaboration workflows

terraform {
  # Terraform version constraint for team consistency
  required_version = ">= 1.5.0"
  
  # Provider version constraints for reproducible builds
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.60.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
    
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }
  
  # Remote state backend configuration for team collaboration
  # This configuration supports multiple environments and team workflows
  backend "s3" {
    # Backend configuration will be provided via backend config files
    # or environment variables for different environments
    
    # Example configuration (customize for your environment):
    # bucket                      = "terraform-state-git-lab"
    # key                        = "infrastructure/git-collaboration/terraform.tfstate"
    # region                     = "us-south"
    # endpoint                   = "s3.us-south.cloud-object-storage.appdomain.cloud"
    # skip_credentials_validation = true
    # skip_region_validation     = true
    # skip_metadata_api_check    = true
    # force_path_style           = true
    # encrypt                    = true
    
    # State locking configuration
    # dynamodb_table = "terraform-locks-git-lab"
  }
}

# Primary IBM Cloud provider configuration
provider "ibm" {
  alias = "primary"
  
  # IBM Cloud API key from environment variable
  ibmcloud_api_key = var.ibmcloud_api_key
  
  # Regional configuration
  region = var.regional_configuration.primary_region
  
  # Resource group targeting for organized resource management
  resource_group = var.resource_group_id
  
  # Provider configuration for enterprise reliability
  max_retries = 3
  
  # Note: IBM provider doesn't support default_tags - tags applied individually to resources
}

# Secondary region provider for multi-region deployments
provider "ibm" {
  alias = "secondary"
  
  ibmcloud_api_key = var.ibmcloud_api_key
  region          = var.regional_configuration.secondary_region
  resource_group  = var.resource_group_id
  max_retries     = 3
}

# Disaster recovery region provider
provider "ibm" {
  alias = "dr"
  
  ibmcloud_api_key = var.ibmcloud_api_key
  region          = var.regional_configuration.dr_region
  resource_group  = var.resource_group_id
  max_retries     = 3
}

# Random provider for generating unique identifiers
provider "random" {
  # No specific configuration required
}

# TLS provider for certificate and key generation
provider "tls" {
  # No specific configuration required
}

# Local provider for file operations and local resources
provider "local" {
  # No specific configuration required
}

# Time provider for time-based resources and delays
provider "time" {
  # No specific configuration required
}

# Null provider for provisioners and external integrations
provider "null" {
  # No specific configuration required
}

# Provider validation and health checks
# These data sources validate provider connectivity and permissions

data "ibm_resource_group" "validation" {
  provider = ibm.primary
  name     = var.organization_config.resource_group_name
}

data "ibm_iam_account_settings" "account_validation" {
  provider = ibm.primary
}

# Regional availability validation
data "ibm_is_zones" "primary_zones" {
  provider = ibm.primary
  region   = var.regional_configuration.primary_region
}

data "ibm_is_zones" "secondary_zones" {
  provider = ibm.secondary
  region   = var.regional_configuration.secondary_region
}

# Provider configuration validation
locals {
  # Validate provider configuration
  provider_validation = {
    primary_region_valid   = length(data.ibm_is_zones.primary_zones.zones) > 0
    secondary_region_valid = length(data.ibm_is_zones.secondary_zones.zones) > 0
    resource_group_valid   = data.ibm_resource_group.validation.id != null
    account_valid         = data.ibm_iam_account_settings.account_validation.account_id != null
  }
  
  # Default tags applied to all resources
  default_tags = merge(
    var.organization_config.default_tags,
    {
      "terraform-managed"    = "true"
      "lab-exercise"        = "git-collaboration"
      "provider-validation" = "enabled"
      "last-updated"       = formatdate("YYYY-MM-DD", timestamp())
    }
  )
}

# Provider configuration outputs for debugging and validation
output "provider_configuration" {
  description = "Provider configuration and validation status"
  value = {
    terraform_version = var.terraform_version_constraint
    
    provider_versions = {
      ibm    = "~> 1.60.0"
      random = "~> 3.5.0"
      tls    = "~> 4.0.0"
      local  = "~> 2.4.0"
      time   = "~> 0.9.0"
      null   = "~> 3.2.0"
    }
    
    regional_configuration = {
      primary_region   = var.regional_configuration.primary_region
      secondary_region = var.regional_configuration.secondary_region
      dr_region       = var.regional_configuration.dr_region
    }
    
    validation_status = local.provider_validation
    health_status     = local.provider_health
    
    backend_configuration = {
      type                = "s3"
      state_locking      = "enabled"
      encryption         = "enabled"
      multi_environment  = "supported"
    }
  }
  
  sensitive = false
}

# Provider health check resource
resource "null_resource" "provider_health_check" {
  # Trigger health check on provider configuration changes
  triggers = {
    provider_config_hash = md5(jsonencode({
      primary_region   = var.regional_configuration.primary_region
      secondary_region = var.regional_configuration.secondary_region
      dr_region       = var.regional_configuration.dr_region
      resource_group   = var.resource_group_id
    }))
  }
  
  # Validate all providers are healthy
  provisioner "local-exec" {
    command = local.provider_health.all_providers_healthy ? "echo 'All providers healthy'" : "echo 'Provider validation failed' && exit 1"
  }
  
  depends_on = [
    data.ibm_resource_group.validation,
    data.ibm_iam_account_settings.account_validation,
    data.ibm_is_zones.primary_zones,
    data.ibm_is_zones.secondary_zones
  ]
}

# Time delay for provider initialization
resource "time_sleep" "provider_initialization" {
  depends_on = [null_resource.provider_health_check]
  
  create_duration = "10s"
  
  triggers = {
    provider_health = local.provider_health.all_providers_healthy
  }
}

# Provider configuration documentation
locals {
  provider_documentation = {
    description = "Enterprise provider configuration for Git collaboration workflows"
    
    features = [
      "Multi-region provider support for disaster recovery",
      "Remote state backend with locking for team collaboration",
      "Provider health validation and monitoring",
      "Consistent tagging across all resources",
      "Version constraints for reproducible deployments"
    ]
    
    best_practices = [
      "Use environment-specific backend configurations",
      "Implement provider health checks in CI/CD pipelines",
      "Maintain consistent provider versions across environments",
      "Use provider aliases for multi-region deployments",
      "Validate provider connectivity before resource creation"
    ]
    
    troubleshooting = {
      authentication_issues = "Verify IBMCLOUD_API_KEY environment variable is set"
      region_availability   = "Check IBM Cloud service availability in target regions"
      state_backend_issues  = "Verify S3 bucket and DynamoDB table configuration"
      version_conflicts     = "Use terraform init -upgrade to update provider versions"
    }
  }
}
