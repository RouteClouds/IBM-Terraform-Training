# IBM Cloud IAM Integration - Main Terraform Configuration
# Topic 7.2: Identity and Access Management (IAM) Integration
# Lab 7.2: Enterprise Identity and Access Management Implementation

# =============================================================================
# DATA SOURCES
# =============================================================================

# Get the target resource group
data "ibm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# Get current account information
data "ibm_iam_account_settings" "current_account" {}

# Generate random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# IBM CLOUD APP ID - ENTERPRISE IDENTITY HUB
# =============================================================================

# App ID service instance for enterprise identity management
resource "ibm_resource_instance" "app_id" {
  name              = "${var.project_name}-enterprise-identity-${random_string.suffix.result}"
  service           = "appid"
  plan              = "lite"
  location          = var.region
  resource_group_id = data.ibm_resource_group.resource_group.id

  parameters = {
    name = "Enterprise Identity Management Hub"
  }

  tags = concat(var.default_tags, [
    "service:app-id",
    "purpose:enterprise-identity",
    "environment:${var.environment}"
  ])
}

# =============================================================================
# SAML IDENTITY PROVIDER CONFIGURATION
# =============================================================================

# Primary enterprise SAML identity provider
resource "ibm_appid_idp_saml" "enterprise_saml" {
  count     = var.enable_saml_federation ? 1 : 0
  tenant_id = ibm_resource_instance.app_id.guid
  is_active = true

  config {
    entity_id        = var.saml_entity_id
    sign_in_url      = var.saml_sign_in_url
    display_name     = "Enterprise Active Directory"
    encrypt_response = true
    sign_request     = true
    include_scoping  = true
    certificates     = [] # Required field - certificates would be provided in real deployment
  }
}

# Note: SAML attribute mapping would be configured through App ID console
# The ibm_appid_idp_saml_attribute resource is not available in the current provider version
# Attribute mapping configuration:
# - email: http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress
# - department: http://schemas.company.com/identity/claims/department
# - employee_id: http://schemas.company.com/identity/claims/employeeid
# - manager: http://schemas.company.com/identity/claims/manager
# - cost_center: http://schemas.company.com/identity/claims/costcenter

# =============================================================================
# OIDC IDENTITY PROVIDER CONFIGURATION
# =============================================================================

# Note: OIDC identity provider would be configured through IBM Cloud console
# The ibm_appid_idp_custom resource configuration is not supported in current provider version
# OIDC configuration would include:
# - Issuer: var.oidc_issuer
# - Authorization URL: ${var.oidc_issuer}/oauth2/authorize
# - Token URL: ${var.oidc_issuer}/oauth2/token
# - Client ID: var.oidc_client_id
# - Scopes: openid, profile, email, groups

# =============================================================================
# ENTERPRISE USER DIRECTORY
# =============================================================================

# Note: Enterprise users would be managed through federated identity providers
# The ibm_appid_directory_user resource is not available in the current provider version
# Users would be provisioned through:
# - SAML federation with enterprise Active Directory
# - OIDC integration with cloud identity providers
# - Automated user provisioning through Cloud Functions

# =============================================================================
# ACCESS GROUPS FOR DEPARTMENT-BASED ACCESS CONTROL
# =============================================================================

# Create access groups for each department
resource "ibm_iam_access_group" "department_access_groups" {
  for_each = var.department_access_mappings

  name        = "${var.project_name}-${lower(each.key)}-access-group"
  description = "Access group for ${each.key} department with ${join(", ", each.value.default_permissions)} permissions"

  tags = concat(var.default_tags, [
    "department:${lower(each.key)}",
    "access-type:department",
    "permissions:${join("-", each.value.default_permissions)}"
  ])
}

# Privileged access group for JIT access
resource "ibm_iam_access_group" "privileged_access_group" {
  name        = "${var.project_name}-privileged-access-group"
  description = "Temporary access group for just-in-time privileged operations"

  tags = concat(var.default_tags, [
    "access-type:privileged",
    "temporary:true",
    "jit-access:enabled"
  ])
}

# Security team access group
resource "ibm_iam_access_group" "security_team_access_group" {
  name        = "${var.project_name}-security-team-access-group"
  description = "Access group for security team with comprehensive monitoring and investigation permissions"

  tags = concat(var.default_tags, [
    "department:security",
    "access-type:security",
    "monitoring:enabled"
  ])
}

# =============================================================================
# IAM POLICIES FOR ACCESS CONTROL
# =============================================================================

# Department-specific IAM policies
resource "ibm_iam_access_group_policy" "department_policies" {
  for_each = var.department_access_mappings

  access_group_id = ibm_iam_access_group.department_access_groups[each.key].id

  roles = [
    "Viewer",
    "Operator"
  ]

  resources {
    service = "kms"
  }

  # Add conditional access based on department requirements
  dynamic "rule_conditions" {
    for_each = each.value.approval_required ? [1] : []
    content {
      key      = "approvalRequired"
      operator = "stringEquals"
      value    = ["true"]
    }
  }
}

# Privileged access policy with time-based restrictions
resource "ibm_iam_access_group_policy" "privileged_access_policy" {
  access_group_id = ibm_iam_access_group.privileged_access_group.id

  roles = [
    "Administrator",
    "Manager"
  ]

  resources {
    service = "kms"
  }

  # Time-based access restrictions for JIT
  rule_conditions {
    key      = "dateTime"
    operator = "dateTimeLessThan"
    value    = ["{{jit_expiration_time}}"]
  }

  # Require justification for privileged access
  rule_conditions {
    key      = "justification"
    operator = "stringExists"
    value    = ["true"]
  }
}

# Security team comprehensive access policy
resource "ibm_iam_access_group_policy" "security_team_policy" {
  access_group_id = ibm_iam_access_group.security_team_access_group.id

  roles = [
    "Viewer",
    "Operator",
    "Editor"
  ]

  resources {
    service = "logs"
  }
}

# =============================================================================
# ACCOUNT-LEVEL SECURITY SETTINGS
# =============================================================================

# Configure account-level MFA and security settings
resource "ibm_iam_account_settings" "enterprise_security_settings" {
  # Multi-factor authentication enforcement
  mfa = var.enforce_mfa ? var.mfa_type : "NONE"

  # IP address restrictions (convert list to string)
  allowed_ip_addresses = length(var.corporate_ip_ranges) > 0 ? join(",", var.corporate_ip_ranges) : ""

  # Service ID and API key restrictions
  restrict_create_service_id      = "RESTRICTED"
  restrict_create_platform_apikey = "RESTRICTED"
}

# =============================================================================
# SERVICE IDS FOR AUTOMATION
# =============================================================================

# Service ID for identity automation functions
resource "ibm_iam_service_id" "identity_automation_service_id" {
  name        = "${var.project_name}-identity-automation-service-id"
  description = "Service ID for identity automation functions and workflows"

  tags = concat(var.default_tags, [
    "service-type:automation",
    "purpose:identity-management"
  ])
}

# API key for identity automation service
resource "ibm_iam_service_api_key" "identity_automation_api_key" {
  name           = "${var.project_name}-identity-automation-api-key"
  iam_service_id = ibm_iam_service_id.identity_automation_service_id.iam_id
  description    = "API key for identity automation service operations"
}

# Service policy for identity automation
resource "ibm_iam_service_policy" "identity_automation_policy" {
  iam_service_id = ibm_iam_service_id.identity_automation_service_id.id

  roles = [
    "Viewer",
    "Operator",
    "Editor"
  ]

  resources {
    service = "appid"
  }
}

# =============================================================================
# TRUSTED PROFILES FOR WORKLOAD IDENTITY
# =============================================================================

# Trusted profile for enterprise workloads
resource "ibm_iam_trusted_profile" "enterprise_workload_profile" {
  name        = "${var.project_name}-enterprise-workload-profile"
  description = "Trusted profile for enterprise workload identity and zero trust access"

  # Note: Claim rules would be configured through IBM Cloud console
  # The claim_rules block is not supported in the current provider version
  # Trust conditions would include:
  # - Department-based access (Engineering, Security, Operations)
  # - Access level validation (standard, elevated, privileged)
  # - Time-based access restrictions
  # - Location-based access controls
}

# Trusted profile policy for workload access
resource "ibm_iam_trusted_profile_policy" "workload_access_policy" {
  profile_id = ibm_iam_trusted_profile.enterprise_workload_profile.id

  roles = [
    "Viewer",
    "Operator"
  ]

  resources {
    service = "containers-kubernetes"
  }
}

# =============================================================================
# CLOUD FUNCTIONS FOR IDENTITY AUTOMATION
# =============================================================================

# Cloud Functions namespace for identity automation
resource "ibm_function_namespace" "identity_automation_namespace" {
  name              = "${var.project_name}-identity-automation-${random_string.suffix.result}"
  resource_group_id = data.ibm_resource_group.resource_group.id

  # Note: Tags are not supported for Cloud Functions namespace in current provider version
  # Tags would include: service:cloud-functions, purpose:identity-automation
}

# JIT access request function
resource "ibm_function_action" "jit_access_request" {
  count     = var.enable_jit_access ? 1 : 0
  name      = "${var.project_name}-jit-access-request"
  namespace = ibm_function_namespace.identity_automation_namespace.name

  exec {
    kind = "nodejs:18"
    code = base64encode(file("${path.module}/functions/jit-access-request.js"))
  }

  # Note: Parameters would be set as environment variables
  # MAX_ACCESS_DURATION: var.jit_max_duration_hours
  # APPROVAL_REQUIRED: var.privileged_access_approval_required
  # PRIVILEGED_ACCESS_GROUP_ID: ibm_iam_access_group.privileged_access_group.id
}

# Risk scoring function for conditional access
resource "ibm_function_action" "risk_scoring" {
  count     = var.enable_conditional_access ? 1 : 0
  name      = "${var.project_name}-risk-scoring"
  namespace = ibm_function_namespace.identity_automation_namespace.name

  exec {
    kind = "nodejs:18"
    code = base64encode(file("${path.module}/functions/risk-scoring.js"))
  }

  # Note: Parameters would be set as environment variables
  # RISK_THRESHOLD: var.risk_score_threshold
  # SIEM_ENDPOINT: var.siem_endpoint
}

# User provisioning automation function
resource "ibm_function_action" "user_provisioning" {
  count     = var.hr_system_integration_enabled ? 1 : 0
  name      = "${var.project_name}-user-provisioning"
  namespace = ibm_function_namespace.identity_automation_namespace.name

  exec {
    kind = "nodejs:18"
    code = base64encode(file("${path.module}/functions/user-provisioning.js"))
  }

  # Note: Parameters would be set as environment variables
  # APPID_INSTANCE_GUID: ibm_resource_instance.app_id.guid
  # DEPARTMENT_MAPPINGS: jsonencode(var.department_access_mappings)
}

# Access review automation function
resource "ibm_function_action" "access_review" {
  name      = "${var.project_name}-access-review"
  namespace = ibm_function_namespace.identity_automation_namespace.name

  exec {
    kind = "nodejs:18"
    code = base64encode(file("${path.module}/functions/access-review.js"))
  }

  # Note: Parameters would be set as environment variables
  # COMPLIANCE_FRAMEWORKS: jsonencode(var.compliance_frameworks)
  # NOTIFICATION_CHANNELS: jsonencode(var.notification_channels)
}

# =============================================================================
# CLOUD OBJECT STORAGE FOR AUDIT LOGS
# =============================================================================

# COS instance for audit log storage
resource "ibm_resource_instance" "audit_cos_instance" {
  name              = "${var.project_name}-audit-logs-cos-${random_string.suffix.result}"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = data.ibm_resource_group.resource_group.id

  tags = concat(var.default_tags, [
    "service:cloud-object-storage",
    "purpose:audit-logs",
    "compliance:required"
  ])
}

# COS bucket for immutable audit logs
resource "ibm_cos_bucket" "audit_logs_bucket" {
  bucket_name          = "${var.project_name}-audit-logs-${var.environment}-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.audit_cos_instance.id
  region_location      = var.region
  storage_class        = "standard"

  # Note: Object lock and activity tracking configuration would be set through IBM Cloud console
  # Object lock configuration for compliance:
  # - Mode: COMPLIANCE
  # - Retention: var.audit_log_retention_days
  # Activity tracking configuration:
  # - Read data events: enabled
  # - Write data events: enabled
  # - Management events: enabled
}

# =============================================================================
# KEY PROTECT FOR ENCRYPTION KEY MANAGEMENT
# =============================================================================

# Key Protect instance for encryption keys
resource "ibm_resource_instance" "key_protect_instance" {
  name              = "${var.project_name}-key-protect-${random_string.suffix.result}"
  service           = "kms"
  plan              = "tiered-pricing"
  location          = var.region
  resource_group_id = data.ibm_resource_group.resource_group.id

  tags = concat(var.default_tags, [
    "service:key-protect",
    "purpose:encryption",
    "compliance:required"
  ])
}

# Root key for audit log encryption
resource "ibm_kms_key" "audit_encryption_key" {
  instance_id  = ibm_resource_instance.key_protect_instance.guid
  key_name     = "${var.project_name}-audit-encryption-key"
  standard_key = false

  description = "Root key for encrypting audit logs and compliance data"
}

# Root key for identity data encryption
resource "ibm_kms_key" "identity_encryption_key" {
  instance_id  = ibm_resource_instance.key_protect_instance.guid
  key_name     = "${var.project_name}-identity-encryption-key"
  standard_key = false

  description = "Root key for encrypting identity and authentication data"
}

# =============================================================================
# ACTIVITY TRACKER FOR COMPREHENSIVE AUDIT TRAIL
# =============================================================================

# Activity Tracker instance for audit trail
resource "ibm_resource_instance" "activity_tracker" {
  name              = "${var.project_name}-activity-tracker-${random_string.suffix.result}"
  service           = "logdnaat"
  plan              = "lite"
  location          = var.region
  resource_group_id = data.ibm_resource_group.resource_group.id

  tags = concat(var.default_tags, [
    "service:activity-tracker",
    "purpose:audit-trail",
    "compliance:required"
  ])
}

# =============================================================================
# ENTERPRISE APPLICATIONS FOR SSO
# =============================================================================

# Enterprise web application for SSO
resource "ibm_appid_application" "enterprise_web_app" {
  tenant_id = ibm_resource_instance.app_id.guid
  name      = "${var.project_name}-enterprise-web-app"
  type      = "regularwebapp"

  # Note: OAuth configuration would be set through IBM Cloud console
  # OAuth configuration for web application:
  # - Redirect URIs: https://app.company.com/auth/callback
  # - Post logout URIs: https://app.company.com/logout
  # - Auth method: client_secret_post
  # - Grant types: authorization_code, refresh_token
}

# Enterprise mobile application for SSO
resource "ibm_appid_application" "enterprise_mobile_app" {
  tenant_id = ibm_resource_instance.app_id.guid
  name      = "${var.project_name}-enterprise-mobile-app"
  type      = "singlepageapp" # Note: nativeapp type not supported, using singlepageapp for mobile

  # Note: OAuth configuration would be set through IBM Cloud console
  # OAuth configuration for mobile application:
  # - Redirect URIs: com.company.app://auth/callback
  # - Auth method: none (public client)
  # - Grant types: authorization_code, refresh_token
}

# API application for service-to-service authentication
resource "ibm_appid_application" "api_application" {
  tenant_id = ibm_resource_instance.app_id.guid
  name      = "${var.project_name}-api-application"
  type      = "singlepageapp"

  # Note: OAuth configuration would be set through IBM Cloud console
  # OAuth configuration for API application:
  # - Redirect URIs: https://api.company.com/auth/callback
  # - Auth method: client_secret_post
  # - Grant types: client_credentials, authorization_code
}
