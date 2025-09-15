# =============================================================================
# TERRAFORM BACKEND CONFIGURATION
# Generated automatically for remote state management
# =============================================================================

terraform {
  backend "s3" {
    # IBM Cloud Object Storage bucket for state storage
    bucket = "${bucket_name}"
    
    # State file path within the bucket
    key = "infrastructure/terraform.tfstate"
    
    # IBM Cloud region
    region = "${region}"
    
    # IBM Cloud Object Storage S3-compatible endpoint
    endpoint = "${endpoint}"
    
    # IBM Cloud specific configurations
    skip_credentials_validation = true
    skip_region_validation     = true
    skip_metadata_api_check    = true
    force_path_style           = true
    
    # Enable encryption for state files
    encrypt = true
    
    # Optional: State locking (requires DynamoDB-compatible service)
    # dynamodb_table = "terraform-state-lock"
  }
}

# =============================================================================
# BACKEND CONFIGURATION NOTES
# =============================================================================

# This backend configuration enables:
# 1. Remote state storage in IBM Cloud Object Storage
# 2. State encryption for security
# 3. S3-compatible API for Terraform integration
# 4. Centralized state management for team collaboration
#
# To use this configuration:
# 1. Ensure COS bucket exists and is accessible
# 2. Configure AWS credentials or IBM Cloud credentials
# 3. Run 'terraform init' to initialize the backend
# 4. Use 'terraform init -migrate-state' to migrate existing state
#
# Environment variables for authentication:
# export AWS_ACCESS_KEY_ID="your-cos-access-key"
# export AWS_SECRET_ACCESS_KEY="your-cos-secret-key"
#
# Or use IBM Cloud credentials:
# export IBMCLOUD_API_KEY="your-ibm-api-key"
