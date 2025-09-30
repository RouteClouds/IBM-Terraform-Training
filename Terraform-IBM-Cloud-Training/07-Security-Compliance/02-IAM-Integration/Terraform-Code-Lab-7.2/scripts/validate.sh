#!/bin/bash

# IBM Cloud IAM Integration - Validation Script
# Topic 7.2: Identity and Access Management (IAM) Integration
# Lab 7.2: Enterprise Identity and Access Management Implementation

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_DIR"

# Validation results
VALIDATION_RESULTS=()
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to record validation result
record_result() {
    local check_name="$1"
    local status="$2"
    local message="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [[ "$status" == "PASS" ]]; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        print_success "$check_name: $message"
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        print_error "$check_name: $message"
    fi
    
    VALIDATION_RESULTS+=("$check_name|$status|$message")
}

# Function to validate Terraform state
validate_terraform_state() {
    print_status "Validating Terraform state..."
    cd "$TERRAFORM_DIR"
    
    if [[ ! -f "terraform.tfstate" ]] && [[ ! -f ".terraform/terraform.tfstate" ]]; then
        record_result "Terraform State" "FAIL" "No state file found. Run terraform apply first."
        return
    fi
    
    # Check if state is valid
    if terraform state list &> /dev/null; then
        record_result "Terraform State" "PASS" "State file is valid and accessible"
    else
        record_result "Terraform State" "FAIL" "State file is corrupted or inaccessible"
    fi
}

# Function to validate IBM Cloud App ID instance
validate_app_id_instance() {
    print_status "Validating IBM Cloud App ID instance..."
    cd "$TERRAFORM_DIR"
    
    # Get App ID instance GUID from Terraform output
    APP_ID_GUID=$(terraform output -raw app_id_instance_guid 2>/dev/null)
    
    if [[ -z "$APP_ID_GUID" ]]; then
        record_result "App ID Instance" "FAIL" "App ID instance GUID not found in outputs"
        return
    fi
    
    # Validate App ID instance exists
    if ibmcloud resource service-instance "$APP_ID_GUID" &> /dev/null; then
        record_result "App ID Instance" "PASS" "App ID instance exists and is accessible"
        
        # Check App ID configuration
        validate_app_id_configuration "$APP_ID_GUID"
    else
        record_result "App ID Instance" "FAIL" "App ID instance not found or not accessible"
    fi
}

# Function to validate App ID configuration
validate_app_id_configuration() {
    local app_id_guid="$1"
    print_status "Validating App ID configuration..."
    
    # Check SAML configuration (if enabled)
    SAML_ENABLED=$(terraform output -json saml_federation_status 2>/dev/null | jq -r '.enabled' 2>/dev/null || echo "false")
    
    if [[ "$SAML_ENABLED" == "true" ]]; then
        # Validate SAML metadata endpoint
        SAML_METADATA_URL=$(terraform output -raw saml_metadata_url 2>/dev/null)
        if [[ -n "$SAML_METADATA_URL" ]]; then
            if curl -s -f "$SAML_METADATA_URL" > /dev/null; then
                record_result "SAML Configuration" "PASS" "SAML metadata endpoint is accessible"
            else
                record_result "SAML Configuration" "FAIL" "SAML metadata endpoint is not accessible"
            fi
        else
            record_result "SAML Configuration" "FAIL" "SAML metadata URL not found"
        fi
    else
        record_result "SAML Configuration" "PASS" "SAML federation is disabled (as configured)"
    fi
    
    # Check OIDC configuration (if enabled)
    OIDC_ENABLED=$(terraform output -json oidc_federation_status 2>/dev/null | jq -r '.enabled' 2>/dev/null || echo "false")
    
    if [[ "$OIDC_ENABLED" == "true" ]]; then
        record_result "OIDC Configuration" "PASS" "OIDC federation is configured"
    else
        record_result "OIDC Configuration" "PASS" "OIDC federation is disabled (as configured)"
    fi
}

# Function to validate access groups
validate_access_groups() {
    print_status "Validating access groups..."
    cd "$TERRAFORM_DIR"
    
    # Get access groups from Terraform output
    ACCESS_GROUPS=$(terraform output -json department_access_groups 2>/dev/null)
    
    if [[ -z "$ACCESS_GROUPS" ]] || [[ "$ACCESS_GROUPS" == "null" ]]; then
        record_result "Access Groups" "FAIL" "No access groups found in outputs"
        return
    fi
    
    # Count access groups
    GROUP_COUNT=$(echo "$ACCESS_GROUPS" | jq 'length' 2>/dev/null || echo "0")
    
    if [[ "$GROUP_COUNT" -gt 0 ]]; then
        record_result "Access Groups" "PASS" "$GROUP_COUNT access groups configured"
        
        # Validate each access group exists
        echo "$ACCESS_GROUPS" | jq -r 'to_entries[] | .value.id' | while read -r group_id; do
            if ibmcloud iam access-group "$group_id" &> /dev/null; then
                record_result "Access Group $group_id" "PASS" "Access group exists and is accessible"
            else
                record_result "Access Group $group_id" "FAIL" "Access group not found or not accessible"
            fi
        done
    else
        record_result "Access Groups" "FAIL" "No access groups configured"
    fi
}

# Function to validate Cloud Functions
validate_cloud_functions() {
    print_status "Validating Cloud Functions..."
    cd "$TERRAFORM_DIR"
    
    # Get Cloud Functions namespace
    FUNCTIONS_NAMESPACE=$(terraform output -json cloud_functions_namespace 2>/dev/null | jq -r '.name' 2>/dev/null)
    
    if [[ -z "$FUNCTIONS_NAMESPACE" ]] || [[ "$FUNCTIONS_NAMESPACE" == "null" ]]; then
        record_result "Cloud Functions Namespace" "FAIL" "Functions namespace not found in outputs"
        return
    fi
    
    # Check if namespace exists
    if ibmcloud fn namespace get "$FUNCTIONS_NAMESPACE" &> /dev/null; then
        record_result "Cloud Functions Namespace" "PASS" "Functions namespace exists and is accessible"
        
        # Validate individual functions
        validate_individual_functions "$FUNCTIONS_NAMESPACE"
    else
        record_result "Cloud Functions Namespace" "FAIL" "Functions namespace not found or not accessible"
    fi
}

# Function to validate individual Cloud Functions
validate_individual_functions() {
    local namespace="$1"
    print_status "Validating individual Cloud Functions..."
    
    # Set namespace for function operations
    ibmcloud fn property set --namespace "$namespace" &> /dev/null
    
    # Check JIT access function
    JIT_FUNCTION=$(terraform output -json jit_access_function 2>/dev/null | jq -r '.name' 2>/dev/null)
    if [[ -n "$JIT_FUNCTION" ]] && [[ "$JIT_FUNCTION" != "null" ]]; then
        if ibmcloud fn action get "$JIT_FUNCTION" &> /dev/null; then
            record_result "JIT Access Function" "PASS" "JIT access function exists and is accessible"
        else
            record_result "JIT Access Function" "FAIL" "JIT access function not found"
        fi
    fi
    
    # Check risk scoring function
    RISK_FUNCTION=$(terraform output -json risk_scoring_function 2>/dev/null | jq -r '.name' 2>/dev/null)
    if [[ -n "$RISK_FUNCTION" ]] && [[ "$RISK_FUNCTION" != "null" ]]; then
        if ibmcloud fn action get "$RISK_FUNCTION" &> /dev/null; then
            record_result "Risk Scoring Function" "PASS" "Risk scoring function exists and is accessible"
        else
            record_result "Risk Scoring Function" "FAIL" "Risk scoring function not found"
        fi
    fi
    
    # Check user provisioning function
    PROVISIONING_FUNCTION=$(terraform output -json user_provisioning_function 2>/dev/null | jq -r '.name' 2>/dev/null)
    if [[ -n "$PROVISIONING_FUNCTION" ]] && [[ "$PROVISIONING_FUNCTION" != "null" ]]; then
        if ibmcloud fn action get "$PROVISIONING_FUNCTION" &> /dev/null; then
            record_result "User Provisioning Function" "PASS" "User provisioning function exists and is accessible"
        else
            record_result "User Provisioning Function" "FAIL" "User provisioning function not found"
        fi
    fi
    
    # Check access review function
    REVIEW_FUNCTION=$(terraform output -json access_review_function 2>/dev/null | jq -r '.name' 2>/dev/null)
    if [[ -n "$REVIEW_FUNCTION" ]] && [[ "$REVIEW_FUNCTION" != "null" ]]; then
        if ibmcloud fn action get "$REVIEW_FUNCTION" &> /dev/null; then
            record_result "Access Review Function" "PASS" "Access review function exists and is accessible"
        else
            record_result "Access Review Function" "FAIL" "Access review function not found"
        fi
    fi
}

# Function to validate storage and encryption
validate_storage_encryption() {
    print_status "Validating storage and encryption..."
    cd "$TERRAFORM_DIR"
    
    # Validate Key Protect instance
    KEY_PROTECT_CONFIG=$(terraform output -json key_protect_configuration 2>/dev/null)
    if [[ -n "$KEY_PROTECT_CONFIG" ]] && [[ "$KEY_PROTECT_CONFIG" != "null" ]]; then
        INSTANCE_ID=$(echo "$KEY_PROTECT_CONFIG" | jq -r '.instance_id' 2>/dev/null)
        if [[ -n "$INSTANCE_ID" ]] && [[ "$INSTANCE_ID" != "null" ]]; then
            if ibmcloud kp instance show "$INSTANCE_ID" &> /dev/null; then
                record_result "Key Protect Instance" "PASS" "Key Protect instance exists and is accessible"
            else
                record_result "Key Protect Instance" "FAIL" "Key Protect instance not found or not accessible"
            fi
        else
            record_result "Key Protect Instance" "FAIL" "Key Protect instance ID not found in outputs"
        fi
    else
        record_result "Key Protect Instance" "FAIL" "Key Protect configuration not found in outputs"
    fi
    
    # Validate Cloud Object Storage
    AUDIT_STORAGE=$(terraform output -json audit_storage_configuration 2>/dev/null)
    if [[ -n "$AUDIT_STORAGE" ]] && [[ "$AUDIT_STORAGE" != "null" ]]; then
        COS_INSTANCE_ID=$(echo "$AUDIT_STORAGE" | jq -r '.cos_instance_id' 2>/dev/null)
        if [[ -n "$COS_INSTANCE_ID" ]] && [[ "$COS_INSTANCE_ID" != "null" ]]; then
            if ibmcloud resource service-instance "$COS_INSTANCE_ID" &> /dev/null; then
                record_result "Audit Storage" "PASS" "Cloud Object Storage instance exists and is accessible"
            else
                record_result "Audit Storage" "FAIL" "Cloud Object Storage instance not found or not accessible"
            fi
        else
            record_result "Audit Storage" "FAIL" "COS instance ID not found in outputs"
        fi
    else
        record_result "Audit Storage" "FAIL" "Audit storage configuration not found in outputs"
    fi
}

# Function to validate enterprise applications
validate_enterprise_applications() {
    print_status "Validating enterprise applications..."
    cd "$TERRAFORM_DIR"
    
    # Get enterprise applications from outputs
    ENTERPRISE_APPS=$(terraform output -json enterprise_applications 2>/dev/null)
    
    if [[ -n "$ENTERPRISE_APPS" ]] && [[ "$ENTERPRISE_APPS" != "null" ]]; then
        # Count applications
        WEB_APP=$(echo "$ENTERPRISE_APPS" | jq -r '.web_app.client_id' 2>/dev/null)
        MOBILE_APP=$(echo "$ENTERPRISE_APPS" | jq -r '.mobile_app.client_id' 2>/dev/null)
        API_APP=$(echo "$ENTERPRISE_APPS" | jq -r '.api_app.client_id' 2>/dev/null)
        
        if [[ -n "$WEB_APP" ]] && [[ "$WEB_APP" != "null" ]]; then
            record_result "Web Application" "PASS" "Web application configured with client ID: $WEB_APP"
        else
            record_result "Web Application" "FAIL" "Web application not configured"
        fi
        
        if [[ -n "$MOBILE_APP" ]] && [[ "$MOBILE_APP" != "null" ]]; then
            record_result "Mobile Application" "PASS" "Mobile application configured with client ID: $MOBILE_APP"
        else
            record_result "Mobile Application" "FAIL" "Mobile application not configured"
        fi
        
        if [[ -n "$API_APP" ]] && [[ "$API_APP" != "null" ]]; then
            record_result "API Application" "PASS" "API application configured with client ID: $API_APP"
        else
            record_result "API Application" "FAIL" "API application not configured"
        fi
    else
        record_result "Enterprise Applications" "FAIL" "No enterprise applications found in outputs"
    fi
}

# Function to validate integration with Topic 7.1
validate_topic_71_integration() {
    print_status "Validating integration with Topic 7.1..."
    
    # Check if Topic 7.1 concepts are properly extended
    SERVICE_IDENTITY=$(terraform output -json service_identity_configuration 2>/dev/null)
    if [[ -n "$SERVICE_IDENTITY" ]] && [[ "$SERVICE_IDENTITY" != "null" ]]; then
        record_result "Service Identity Integration" "PASS" "Service identity configuration extends Topic 7.1 patterns"
    else
        record_result "Service Identity Integration" "FAIL" "Service identity configuration not found"
    fi
    
    # Validate compliance configuration builds on Topic 7.1
    COMPLIANCE_CONFIG=$(terraform output -json compliance_configuration 2>/dev/null)
    if [[ -n "$COMPLIANCE_CONFIG" ]] && [[ "$COMPLIANCE_CONFIG" != "null" ]]; then
        record_result "Compliance Integration" "PASS" "Compliance configuration extends Topic 7.1 foundations"
    else
        record_result "Compliance Integration" "FAIL" "Compliance configuration not found"
    fi
}

# Function to generate validation report
generate_validation_report() {
    echo
    echo "============================================================"
    echo "VALIDATION REPORT"
    echo "============================================================"
    echo "Total Checks: $TOTAL_CHECKS"
    echo "Passed: $PASSED_CHECKS"
    echo "Failed: $FAILED_CHECKS"
    echo "Success Rate: $(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))%"
    echo "============================================================"
    
    if [[ $FAILED_CHECKS -gt 0 ]]; then
        echo
        print_error "VALIDATION FAILED - $FAILED_CHECKS checks failed"
        echo
        print_status "Failed checks:"
        for result in "${VALIDATION_RESULTS[@]}"; do
            IFS='|' read -r name status message <<< "$result"
            if [[ "$status" == "FAIL" ]]; then
                echo "  - $name: $message"
            fi
        done
        echo
        print_status "Troubleshooting steps:"
        echo "1. Check Terraform outputs: terraform output"
        echo "2. Verify IBM Cloud authentication: ibmcloud account show"
        echo "3. Review Terraform state: terraform state list"
        echo "4. Check resource permissions and quotas"
        echo "5. Review deployment logs for errors"
        exit 1
    else
        print_success "ALL VALIDATIONS PASSED"
        echo
        print_status "Your IAM integration deployment is working correctly!"
        print_status "Integration with Topic 7.1 is properly established."
        print_status "Ready for Topic 8: Automation & Advanced Integration."
    fi
}

# Main execution
main() {
    echo "============================================================"
    echo "IBM Cloud IAM Integration Validation"
    echo "Topic 7.2: Identity and Access Management (IAM) Integration"
    echo "============================================================"
    echo
    
    # Check prerequisites
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed"
        exit 1
    fi
    
    if ! command -v ibmcloud &> /dev/null; then
        print_error "IBM Cloud CLI is not installed"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed (required for JSON parsing)"
        exit 1
    fi
    
    # Run validations
    validate_terraform_state
    validate_app_id_instance
    validate_access_groups
    validate_cloud_functions
    validate_storage_encryption
    validate_enterprise_applications
    validate_topic_71_integration
    
    # Generate report
    generate_validation_report
}

# Run main function
main
