# =============================================================================
# TERRAFORM PROVIDER CONFIGURATION
# Topic 4.1: Defining and Managing IBM Cloud Resources
# =============================================================================

# Terraform version and provider requirements
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    # IBM Cloud Provider for infrastructure resources
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }
    
    # Random provider for unique resource naming
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }
    
    # Time provider for timestamps and scheduling
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
    
    # Local provider for data processing
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.0"
    }
    
    # Template provider for file generation
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
  
  # Backend configuration for state management
  # Uncomment and configure for team collaboration
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "topic-4.1/terraform.tfstate"
  #   region = "us-south"
  # }
}

# =============================================================================
# IBM CLOUD PROVIDER CONFIGURATION
# =============================================================================

# Primary IBM Cloud provider configuration
provider "ibm" {
  # Authentication via API key (set via environment variable or terraform.tfvars)
  ibmcloud_api_key = var.ibmcloud_api_key
  
  # Default region for resource deployment
  region = var.ibm_region
  
  # Default resource group for all resources
  # resource_group_id = var.resource_group_id
  
  # Note: IBM Cloud provider doesn't support default_tags
  # Tags are applied individually to each resource in main.tf
}

# =============================================================================
# SUPPORTING PROVIDER CONFIGURATIONS
# =============================================================================

# Random provider for generating unique identifiers
provider "random" {
  # No specific configuration required
}

# Time provider for timestamp generation
provider "time" {
  # No specific configuration required
}

# Local provider for local file operations
provider "local" {
  # No specific configuration required
}

# Template provider for dynamic file generation
provider "template" {
  # No specific configuration required
}

# =============================================================================
# PROVIDER ALIASES FOR MULTI-REGION DEPLOYMENT
# =============================================================================

# Secondary region provider for disaster recovery
provider "ibm" {
  alias            = "secondary"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.secondary_region
  
  default_tags = {
    "managed-by"     = "terraform"
    "topic"          = "4.1-resource-provisioning"
    "training-program" = "ibm-cloud-terraform"
    "created-by"     = "terraform-code-lab"
    "deployment-type" = "disaster-recovery"
  }
}

# Development environment provider with specific configuration
provider "ibm" {
  alias            = "development"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibm_region
  
  default_tags = {
    "managed-by"     = "terraform"
    "topic"          = "4.1-resource-provisioning"
    "training-program" = "ibm-cloud-terraform"
    "created-by"     = "terraform-code-lab"
    "environment"    = "development"
    "cost-center"    = "training"
  }
}

# Production environment provider with enhanced configuration
provider "ibm" {
  alias            = "production"
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibm_region
  
  default_tags = {
    "managed-by"     = "terraform"
    "topic"          = "4.1-resource-provisioning"
    "training-program" = "ibm-cloud-terraform"
    "created-by"     = "terraform-code-lab"
    "environment"    = "production"
    "compliance"     = "required"
    "backup"         = "enabled"
    "monitoring"     = "enhanced"
  }
}

# =============================================================================
# PROVIDER FEATURE FLAGS AND EXPERIMENTAL FEATURES
# =============================================================================

# Configure provider-specific features
# These settings optimize provider behavior for the lab environment

# IBM Cloud provider experimental features
# Uncomment to enable specific experimental features
# provider "ibm" {
#   experimental {
#     # Enable experimental VPC features
#     vpc_next_generation = true
#     
#     # Enable experimental security features
#     enhanced_security = true
#     
#     # Enable experimental cost optimization features
#     cost_optimization = true
#   }
# }

# =============================================================================
# PROVIDER VALIDATION AND HEALTH CHECKS
# =============================================================================

# Data source to validate provider configuration
data "ibm_iam_auth_token" "token_validation" {
  # This data source validates that the API key is working correctly
  # and that the provider can authenticate with IBM Cloud
}

# Data source to validate region availability
data "ibm_is_zones" "region_validation" {
  region = var.ibm_region
  
  # This validates that the specified region is available
  # and that VPC services are supported in the region
}

# Data source to validate resource group access
data "ibm_resource_group" "validation" {
  name = var.resource_group_name
  
  # This validates that the specified resource group exists
  # and that the API key has access to it
}

# =============================================================================
# PROVIDER CONFIGURATION OUTPUTS
# =============================================================================

# Output provider configuration for validation
output "provider_configuration" {
  description = "Provider configuration validation and information"
  sensitive   = true
  value = {
    # Primary provider information
    primary_region = var.ibm_region
    secondary_region = var.secondary_region
    
    # Authentication validation
    api_key_configured = var.ibmcloud_api_key != "" ? true : false
    auth_token_valid = data.ibm_iam_auth_token.token_validation.iam_access_token != null
    
    # Region validation
    available_zones = data.ibm_is_zones.region_validation.zones
    zone_count = length(data.ibm_is_zones.region_validation.zones)
    
    # Resource group validation
    resource_group_id = data.ibm_resource_group.validation.id
    resource_group_name = data.ibm_resource_group.validation.name
    
    # Provider versions
    terraform_version = "~> 1.0"
    ibm_provider_version = "~> 1.58.0"
    
    # Configuration status
    configuration_valid = (
      var.ibmcloud_api_key != "" &&
      data.ibm_iam_auth_token.token_validation.iam_access_token != null &&
      length(data.ibm_is_zones.region_validation.zones) > 0 &&
      data.ibm_resource_group.validation.id != null
    )
  }
  
  # Sensitive attribute already set above
}

# =============================================================================
# PROVIDER CONFIGURATION NOTES
# =============================================================================

/*
PROVIDER CONFIGURATION BEST PRACTICES:

1. **Version Pinning**: Always specify provider versions to ensure consistency
   across different environments and team members.

2. **Authentication**: Use environment variables or secure vaults for API keys.
   Never commit API keys to version control.

3. **Default Tags**: Use provider-level default tags to ensure consistent
   tagging across all resources without manual intervention.

4. **Multi-Region**: Configure provider aliases for multi-region deployments
   and disaster recovery scenarios.

5. **Validation**: Include data sources to validate provider configuration
   and catch authentication or permission issues early.

6. **Backend Configuration**: Configure remote state backend for team
   collaboration and state locking.

ENVIRONMENT VARIABLE CONFIGURATION:

Set the following environment variables for secure authentication:
export IBMCLOUD_API_KEY="your-api-key-here"
export TF_VAR_ibmcloud_api_key="your-api-key-here"

TERRAFORM CLOUD CONFIGURATION:

For Terraform Cloud or Enterprise, configure workspace variables:
- ibmcloud_api_key (sensitive)
- ibm_region
- resource_group_name

TROUBLESHOOTING:

Common provider configuration issues:
1. Invalid API key: Check key format and permissions
2. Region not available: Verify region supports required services
3. Resource group access: Ensure API key has access to resource group
4. Version conflicts: Update provider versions if compatibility issues occur

For detailed troubleshooting, run:
terraform init -upgrade
terraform validate
terraform plan
*/
