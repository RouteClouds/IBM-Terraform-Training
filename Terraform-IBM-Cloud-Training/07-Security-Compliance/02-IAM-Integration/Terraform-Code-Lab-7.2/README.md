# IBM Cloud IAM Integration - Terraform Code Lab 7.2

## Overview

This Terraform configuration implements a comprehensive **Enterprise Identity and Access Management (IAM) Integration** solution for IBM Cloud. The implementation demonstrates advanced identity patterns, federated authentication, privileged access management, and automated governance workflows.

## Architecture Overview

### Core Components

1. **IBM Cloud App ID** - Central identity hub for enterprise federation
2. **SAML/OIDC Federation** - Integration with enterprise directories
3. **Access Groups & Policies** - Department-based access control
4. **Cloud Functions** - Identity automation and workflows
5. **Privileged Access Management** - Just-in-time access controls
6. **Audit & Compliance** - Comprehensive logging and evidence collection

### Enterprise Features

- **Multi-Factor Authentication** with TOTP, SMS, and email options
- **Conditional Access** with risk-based authentication
- **Federated Identity** supporting SAML 2.0 and OIDC protocols
- **Just-in-Time Access** for privileged operations
- **Automated User Provisioning** with HR system integration
- **Compliance Automation** for SOC2, ISO27001, and GDPR

## Prerequisites

### Required Tools
- **Terraform** >= 1.3.0
- **IBM Cloud CLI** >= 2.0.0
- **IBM Cloud Account** with appropriate permissions

### Required Permissions
- **IAM Administrator** role for access group and policy management
- **Service Administrator** role for App ID and Cloud Functions
- **Resource Group Administrator** role for resource creation

### IBM Cloud Services
- IBM Cloud App ID
- IBM Cloud Functions
- IBM Cloud Object Storage
- IBM Key Protect
- IBM Activity Tracker

## Quick Start

### 1. Clone and Setup

```bash
# Navigate to the Terraform code lab directory
cd Terraform-IBM-Cloud-Training/07-Security-Compliance/02-IAM-Integration/Terraform-Code-Lab-7.2

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the variables file with your specific values
nano terraform.tfvars
```

### 2. Configure Environment Variables

```bash
# Set your IBM Cloud API key
export IBMCLOUD_API_KEY="your-api-key-here"

# Set sensitive variables (optional - can be set in terraform.tfvars)
export TF_VAR_saml_certificate="your-base64-encoded-certificate"
export TF_VAR_oidc_client_secret="your-oidc-client-secret"
export TF_VAR_hr_webhook_token="your-hr-webhook-token"
```

### 3. Deploy the Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Apply the configuration
terraform apply

# Confirm deployment
terraform output
```

## Configuration Guide

### Basic Configuration

#### Project Settings
```hcl
project_name = "iam-integration-lab72"
environment  = "dev"
region      = "us-south"
```

#### Identity Federation
```hcl
# SAML Federation
enable_saml_federation = true
saml_entity_id        = "https://enterprise.company.com/saml"
saml_sign_in_url      = "https://enterprise.company.com/saml/sso"

# OIDC Federation
enable_oidc_federation = true
oidc_issuer           = "https://auth.company.com"
oidc_client_id        = "enterprise-app-client"
```

#### Security Settings
```hcl
# Multi-Factor Authentication
enforce_mfa = true
mfa_type    = "TOTP"

# Session Management
session_timeout_hours             = 8
session_inactivity_timeout_minutes = 30

# Access Control
max_login_attempts = 3
risk_score_threshold = 75
```

### Advanced Configuration

#### Department Access Mappings
```hcl
department_access_mappings = {
  Engineering = {
    access_groups        = ["developers", "ci-cd-pipeline"]
    default_permissions  = ["read", "write", "deploy"]
    elevated_permissions = ["admin", "production-deploy"]
    approval_required    = false
  }
  Finance = {
    access_groups        = ["financial-systems", "audit-access"]
    default_permissions  = ["read", "report"]
    elevated_permissions = ["write", "approve"]
    approval_required    = true
  }
}
```

#### Privileged Access Management
```hcl
enable_jit_access                   = true
jit_max_duration_hours             = 4
privileged_access_approval_required = true
```

#### Compliance Configuration
```hcl
compliance_frameworks = ["SOC2", "ISO27001", "GDPR"]
audit_log_retention_days = 2555  # 7 years
enable_automated_compliance_reporting = true
```

## File Structure

```
Terraform-Code-Lab-7.2/
├── providers.tf              # Provider configurations
├── variables.tf               # Variable definitions (15+ variables)
├── main.tf                   # Main resource configurations
├── outputs.tf                # Output definitions (10+ outputs)
├── terraform.tfvars.example  # Example variable values
├── README.md                 # This documentation
├── functions/                # Cloud Functions source code
│   ├── jit-access-request.js
│   ├── risk-scoring.js
│   ├── user-provisioning.js
│   └── access-review.js
└── scripts/                  # Deployment and utility scripts
    ├── deploy.sh
    ├── validate.sh
    └── cleanup.sh
```

## Resource Overview

### Identity Resources
- **1x IBM Cloud App ID** instance for enterprise identity hub
- **2x Identity Providers** (SAML and OIDC federation)
- **6x Enterprise Users** for testing and demonstration
- **3x Enterprise Applications** (web, mobile, API)

### Access Control Resources
- **4x Access Groups** (department-based + privileged + security)
- **6x IAM Policies** for granular access control
- **1x Trusted Profile** for workload identity
- **1x Service ID** with API key for automation

### Automation Resources
- **1x Cloud Functions Namespace** for identity automation
- **4x Cloud Functions** (JIT access, risk scoring, provisioning, reviews)
- **2x Encryption Keys** (audit logs, identity data)

### Storage and Monitoring
- **1x Cloud Object Storage** instance with immutable audit bucket
- **1x Key Protect** instance for encryption key management
- **1x Activity Tracker** instance for comprehensive audit trail

## Deployment Scenarios

### Development Environment
```bash
# Quick development setup
terraform apply -var="environment=dev" -var="session_timeout_hours=4"
```

### Staging Environment
```bash
# Staging with enhanced monitoring
terraform apply -var="environment=staging" -var="enable_real_time_alerts=true"
```

### Production Environment
```bash
# Production with full compliance
terraform apply -var="environment=prod" -var="audit_log_retention_days=2555"
```

## Validation and Testing

### 1. Infrastructure Validation
```bash
# Validate Terraform configuration
terraform validate

# Check resource state
terraform state list

# Verify outputs
terraform output deployment_summary
```

### 2. Identity Federation Testing
```bash
# Test SAML metadata endpoint
curl -s "$(terraform output -raw saml_metadata_url)" | xmllint --format -

# Verify App ID configuration
ibmcloud appid idps --tenant-id "$(terraform output -raw app_id_instance_guid)"
```

### 3. Access Control Validation
```bash
# List created access groups
ibmcloud iam access-groups

# Verify policies
ibmcloud iam access-group-policies "$(terraform output -json department_access_groups | jq -r '.Engineering.id')"
```

### 4. Function Testing
```bash
# Test JIT access function
ibmcloud fn action invoke "$(terraform output -json jit_access_function | jq -r '.name')" \
  --param user '{"email":"test@company.com"}' \
  --param justification "Emergency production access" \
  --result
```

## Security Best Practices

### 1. Credential Management
- **Never commit sensitive values** to version control
- **Use environment variables** for API keys and secrets
- **Rotate credentials regularly** (quarterly recommended)
- **Implement least privilege** access principles

### 2. Network Security
- **Configure IP restrictions** with corporate network ranges
- **Implement network segmentation** for sensitive operations
- **Use VPN or private endpoints** for administrative access
- **Monitor network traffic** for anomalous patterns

### 3. Access Control
- **Enable MFA for all users** with TOTP preferred
- **Implement conditional access** with risk-based policies
- **Use JIT access** for privileged operations
- **Conduct regular access reviews** (quarterly minimum)

### 4. Monitoring and Auditing
- **Enable comprehensive logging** for all identity operations
- **Configure real-time alerts** for security events
- **Implement SIEM integration** for correlation and analysis
- **Maintain immutable audit trails** for compliance

## Troubleshooting

### Common Issues

#### 1. Provider Authentication
```bash
# Verify IBM Cloud CLI authentication
ibmcloud auth

# Check API key permissions
ibmcloud iam api-key-get "your-api-key-name"
```

#### 2. Resource Creation Failures
```bash
# Check resource group permissions
ibmcloud resource groups

# Verify service availability in region
ibmcloud catalog service appid --output json
```

#### 3. Federation Configuration
```bash
# Validate SAML certificate format
echo "$SAML_CERTIFICATE" | base64 -d | openssl x509 -text -noout

# Test OIDC endpoint connectivity
curl -s "$OIDC_ISSUER/.well-known/openid_configuration"
```

#### 4. Function Deployment Issues
```bash
# Check Cloud Functions namespace
ibmcloud fn namespace list

# Verify function logs
ibmcloud fn activation logs --last
```

### Error Resolution

#### Resource Already Exists
```bash
# Import existing resources
terraform import ibm_resource_instance.app_id "existing-resource-id"
```

#### Permission Denied
```bash
# Check IAM permissions
ibmcloud iam user-policies "your-user-email"

# Verify resource group access
ibmcloud resource group "your-resource-group"
```

## Maintenance and Operations

### Regular Tasks

#### Weekly
- Review security alerts and incidents
- Monitor function execution logs
- Validate backup and recovery procedures

#### Monthly
- Conduct access reviews for privileged accounts
- Update risk scoring algorithms
- Review and update IP allow lists

#### Quarterly
- Complete comprehensive access reviews
- Update compliance documentation
- Rotate service credentials
- Conduct disaster recovery testing

### Monitoring Dashboards

#### Security Metrics
- Authentication success/failure rates
- MFA adoption and usage patterns
- Conditional access policy triggers
- Privileged access usage statistics

#### Operational Metrics
- Function execution success rates
- API response times and availability
- Storage utilization and costs
- Compliance framework adherence

## Cost Optimization

### Resource Sizing
- **App ID Lite Plan**: Free tier suitable for development and testing
- **Cloud Functions**: Pay-per-execution model for cost efficiency
- **Object Storage**: Standard tier with lifecycle policies
- **Key Protect**: Tiered pricing based on key operations

### Cost Monitoring
```bash
# Check current costs
ibmcloud billing account-usage

# Monitor resource usage
terraform output implementation_metrics
```

## Support and Documentation

### Additional Resources
- [IBM Cloud App ID Documentation](https://cloud.ibm.com/docs/appid)
- [IBM Cloud IAM Best Practices](https://cloud.ibm.com/docs/account?topic=account-account_management_service)
- [Terraform IBM Provider Documentation](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)

### Getting Help
- **IBM Cloud Support**: For service-specific issues
- **Terraform Community**: For configuration and best practices
- **Security Team**: For compliance and security questions

This comprehensive IAM integration provides enterprise-grade identity management with automated governance, compliance, and security controls suitable for production environments.
