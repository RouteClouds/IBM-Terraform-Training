# =============================================================================
# TERRAFORM BACKEND CONFIGURATION WITH STATE LOCKING
# Generated automatically by Terraform Code Lab 6.2
# Copy this configuration to your providers.tf file
# =============================================================================

terraform {
  backend "s3" {
    # IBM Cloud Object Storage configuration
    bucket         = "${bucket_name}"
    key           = "infrastructure/terraform.tfstate"
    region        = "${region}"
    endpoint      = "${endpoint}"
    
    # State locking configuration with IBM Cloudant
    dynamodb_table = "${dynamodb_table}"
    dynamodb_endpoint = "${dynamodb_endpoint}"
    
    # Lock timeout and retry settings
    lock_timeout = "${lock_timeout}"
    max_retries  = ${max_retries}
    retry_delay  = "${retry_delay}"
    
    # IBM Cloud specific configurations
    skip_credentials_validation = true
    skip_region_validation     = true
    skip_metadata_api_check    = true
    force_path_style           = true
    encrypt                    = true
    
    # Access credentials (use environment variables)
    # export AWS_ACCESS_KEY_ID="your-cos-access-key"
    # export AWS_SECRET_ACCESS_KEY="your-cos-secret-key"
  }
}
