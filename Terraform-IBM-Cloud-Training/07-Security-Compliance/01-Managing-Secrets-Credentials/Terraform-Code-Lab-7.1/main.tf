# IBM Cloud Terraform Training - Topic 7.1: Managing Secrets and Credentials
# Terraform Code Lab 7.1 - Main Configuration
#
# This file contains the main resource definitions for enterprise secrets management
# including Key Protect, Secrets Manager, IAM, and Activity Tracker integration.
#
# Author: IBM Cloud Terraform Training Team
# Version: 1.0.0
# Last Updated: 2024-09-15

# =============================================================================
# RANDOM RESOURCES FOR SECURE GENERATION
# =============================================================================

# Generate secure database password if not provided
resource "random_password" "database_password" {
  count   = var.database_password == null ? 1 : 0
  length  = 32
  special = true
  upper   = true
  lower   = true
  numeric = true

  # Ensure password meets complexity requirements
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}

# Generate API key for service authentication
resource "random_password" "api_key" {
  length  = 64
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Generate unique identifiers for resources
resource "random_id" "unique_suffix" {
  byte_length = 4
}

# =============================================================================
# IBM CLOUD KEY PROTECT - ENCRYPTION KEY MANAGEMENT
# =============================================================================

# Key Protect instance for FIPS 140-2 Level 3 encryption
resource "ibm_resource_instance" "key_protect" {
  count             = var.enable_key_protect ? 1 : 0
  name              = "${local.naming_prefix}-key-protect-${random_id.unique_suffix.hex}"
  resource_group_id = data.ibm_resource_group.security.id
  service           = "kms"
  plan              = "tiered-pricing"
  location          = var.primary_region

  parameters = {
    # Enable dual authorization for production environments
    dual_auth_delete = local.current_env_config.dual_auth_required
    # Restrict to private network for enhanced security
    allowed_network = var.environment == "production" ? "private-only" : "public-and-private"
  }

  tags = concat(local.common_tags, [
    "service:key-protect",
    "purpose:encryption-key-management",
    "compliance:fips-140-2-level-3"
  ])

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# Master encryption key for application secrets
resource "ibm_kms_key" "master_key" {
  count        = var.enable_key_protect ? 1 : 0
  instance_id  = ibm_resource_instance.key_protect[0].guid
  key_name     = "${local.naming_prefix}-master-key"
  standard_key = false # Root key for encryption hierarchy

  description = "Master encryption key for ${var.project_name} application secrets and compliance"

  # Key rotation is managed through Key Protect policies
  # Dual authorization is configured at the service level

  # Tags for enterprise governance (managed through resource groups and policies)
}

# Data encryption key for application data
resource "ibm_kms_key" "data_encryption_key" {
  count        = var.enable_key_protect ? 1 : 0
  instance_id  = ibm_resource_instance.key_protect[0].guid
  key_name     = "${local.naming_prefix}-data-key"
  standard_key = true # Standard key for data encryption

  description = "Data encryption key for ${var.project_name} application data protection"

  # Wrap with master key for hierarchical key management
  encrypted_nonce = ibm_kms_key.master_key[0].id
}

# =============================================================================
# IBM CLOUD SECRETS MANAGER - CENTRALIZED SECRETS MANAGEMENT
# =============================================================================

# Secrets Manager instance for centralized secrets lifecycle management
resource "ibm_resource_instance" "secrets_manager" {
  count             = var.enable_secrets_manager ? 1 : 0
  name              = "${local.naming_prefix}-secrets-manager-${random_id.unique_suffix.hex}"
  resource_group_id = data.ibm_resource_group.security.id
  service           = "secrets-manager"
  plan              = "standard"
  location          = var.primary_region

  parameters = {
    # Integrate with Key Protect for encryption
    kms_key_crn = var.enable_key_protect ? ibm_kms_key.master_key[0].crn : null
  }

  tags = concat(local.common_tags, [
    "service:secrets-manager",
    "purpose:secrets-lifecycle-management",
    "compliance:automated-rotation"
  ])

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }

  depends_on = [ibm_kms_key.master_key]
}

# Secret group for application secrets organization
resource "ibm_sm_secret_group" "application_secrets" {
  count       = var.enable_secrets_manager ? 1 : 0
  instance_id = ibm_resource_instance.secrets_manager[0].guid
  name        = "${local.naming_prefix}-app-secrets"
  description = "Application secrets for ${var.project_name} with automated rotation and governance"
}

# Secret group for database credentials
resource "ibm_sm_secret_group" "database_secrets" {
  count       = var.enable_secrets_manager ? 1 : 0
  instance_id = ibm_resource_instance.secrets_manager[0].guid
  name        = "${local.naming_prefix}-db-secrets"
  description = "Database credentials with ${var.secret_rotation_interval_days}-day rotation policy"
}

# Database credentials with automated rotation
resource "ibm_sm_username_password_secret" "database_credentials" {
  count           = var.enable_secrets_manager ? 1 : 0
  instance_id     = ibm_resource_instance.secrets_manager[0].guid
  secret_group_id = ibm_sm_secret_group.database_secrets[0].secret_group_id
  name            = "${local.naming_prefix}-db-credentials"
  description     = "Database credentials with automated ${var.secret_rotation_interval_days}-day rotation"

  username = var.database_username
  password = var.database_password != null ? var.database_password : random_password.database_password[0].result

  # Automated rotation configuration
  rotation {
    auto_rotate = true
    interval    = var.secret_rotation_interval_days
    unit        = "day"
  }

  # Custom metadata for tracking and governance
  custom_metadata = {
    application = var.application_name
    environment = var.environment
    owner       = var.team_email
    purpose     = "database-authentication"
    compliance  = "automated-rotation"
  }

  # Version metadata
  version_custom_metadata = {
    created_by      = "terraform"
    rotation_policy = "${var.secret_rotation_interval_days}-day-automated"
  }
}

# API key secret for service authentication
resource "ibm_sm_arbitrary_secret" "api_key" {
  count           = var.enable_secrets_manager ? 1 : 0
  instance_id     = ibm_resource_instance.secrets_manager[0].guid
  secret_group_id = ibm_sm_secret_group.application_secrets[0].secret_group_id
  name            = "${local.naming_prefix}-api-key"
  description     = "Application API key for service authentication"

  payload = random_password.api_key.result

  # Custom metadata
  custom_metadata = {
    application = var.application_name
    environment = var.environment
    purpose     = "api-authentication"
    created_by  = "terraform"
  }
}

# =============================================================================
# IAM SERVICE IDS AND ACCESS POLICIES
# =============================================================================

# Service ID for application authentication
resource "ibm_iam_service_id" "application_service" {
  count       = var.enable_iam_policies ? 1 : 0
  name        = "${local.naming_prefix}-service-id"
  description = "Service ID for ${var.project_name} application authentication and secrets access"

  tags = concat(local.common_tags, [
    "service:iam",
    "purpose:service-authentication",
    "application:${var.application_name}"
  ])
}

# Access group for security team
resource "ibm_iam_access_group" "security_team" {
  count       = var.enable_iam_policies ? 1 : 0
  name        = "${local.naming_prefix}-security-team"
  description = "Security team with full access to security services for ${var.project_name}"

  tags = concat(local.common_tags, [
    "purpose:security-team-access",
    "role:administrator"
  ])
}

# Access group for application team
resource "ibm_iam_access_group" "application_team" {
  count       = var.enable_iam_policies ? 1 : 0
  name        = "${local.naming_prefix}-application-team"
  description = "Application team with limited secrets access for ${var.project_name}"

  tags = concat(local.common_tags, [
    "purpose:application-team-access",
    "role:secrets-reader"
  ])
}

# Policy for security team - Key Protect access
resource "ibm_iam_access_group_policy" "security_team_key_protect" {
  count           = var.enable_iam_policies && var.enable_key_protect ? 1 : 0
  access_group_id = ibm_iam_access_group.security_team[0].id

  roles = ["Administrator", "Manager"]

  resources {
    service           = "kms"
    resource_group_id = data.ibm_resource_group.security.id
  }

  # Time-based access restrictions for enhanced security
  rule_conditions {
    key      = "dateTime"
    operator = "dateTimeGreaterThan"
    value    = ["09:00:00Z"]
  }

  rule_conditions {
    key      = "dateTime"
    operator = "dateTimeLessThan"
    value    = ["17:00:00Z"]
  }
}

# Policy for security team - Secrets Manager access
resource "ibm_iam_access_group_policy" "security_team_secrets_manager" {
  count           = var.enable_iam_policies && var.enable_secrets_manager ? 1 : 0
  access_group_id = ibm_iam_access_group.security_team[0].id

  roles = ["Manager", "SecretsReader", "SecretsWriter"]

  resources {
    service           = "secrets-manager"
    resource_group_id = data.ibm_resource_group.security.id
  }
}

# Policy for application team - limited secrets access
resource "ibm_iam_access_group_policy" "application_team_secrets" {
  count           = var.enable_iam_policies && var.enable_secrets_manager ? 1 : 0
  access_group_id = ibm_iam_access_group.application_team[0].id

  roles = ["SecretsReader"]

  resources {
    service           = "secrets-manager"
    resource_group_id = data.ibm_resource_group.security.id
    attributes = {
      "secretGroupId" = ibm_sm_secret_group.application_secrets[0].secret_group_id
    }
  }
}

# Policy for service ID - application secrets access
resource "ibm_iam_service_policy" "application_service_secrets" {
  count  = var.enable_iam_policies && var.enable_secrets_manager ? 1 : 0
  iam_id = ibm_iam_service_id.application_service[0].iam_id

  roles = ["SecretsReader"]

  resources {
    service           = "secrets-manager"
    resource_group_id = data.ibm_resource_group.security.id
    attributes = {
      "secretGroupId" = ibm_sm_secret_group.application_secrets[0].secret_group_id
    }
  }
}

# =============================================================================
# TRUSTED PROFILES FOR WORKLOAD IDENTITY
# =============================================================================

# Trusted profile for application workloads
resource "ibm_iam_trusted_profile" "application_workload" {
  count       = var.enable_iam_policies ? 1 : 0
  name        = "${local.naming_prefix}-workload-profile"
  description = "Trusted profile for ${var.project_name} application workloads with time-based access"

  # Trust conditions for compute resources
  # Trust policy and session policy are configured separately
}

# Policy for trusted profile - secrets access
resource "ibm_iam_trusted_profile_policy" "workload_secrets_access" {
  count      = var.enable_iam_policies && var.enable_secrets_manager ? 1 : 0
  profile_id = ibm_iam_trusted_profile.application_workload[0].id

  roles = ["SecretsReader"]

  resources {
    service           = "secrets-manager"
    resource_group_id = data.ibm_resource_group.security.id
    attributes = {
      "secretGroupId" = ibm_sm_secret_group.application_secrets[0].secret_group_id
    }
  }
}
