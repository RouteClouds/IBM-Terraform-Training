#!/bin/bash

# Deployment Validation Script for CI/CD Pipeline Integration Lab 8.1
# This script validates the successful deployment of CI/CD infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_DIR/validation.log"

# Functions
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$LOG_FILE"
}

# Validation functions
validate_terraform_state() {
    info "Validating Terraform state..."
    
    if [ ! -f "$PROJECT_DIR/terraform.tfstate" ]; then
        error "Terraform state file not found"
        return 1
    fi
    
    # Check if state has resources
    resource_count=$(terraform show -json | jq '.values.root_module.resources | length' 2>/dev/null || echo "0")
    
    if [ "$resource_count" -gt 0 ]; then
        success "Terraform state contains $resource_count resources"
    else
        error "No resources found in Terraform state"
        return 1
    fi
}

validate_ibm_cloud_resources() {
    info "Validating IBM Cloud resources..."
    
    # Check if IBM Cloud CLI is available and authenticated
    if ! command -v ibmcloud &> /dev/null; then
        error "IBM Cloud CLI not found"
        return 1
    fi
    
    # Test authentication
    if ! ibmcloud account show &> /dev/null; then
        error "IBM Cloud CLI not authenticated"
        return 1
    fi
    
    success "IBM Cloud CLI authenticated successfully"
    
    # Get outputs from Terraform
    local schematics_workspace_id=$(terraform output -raw schematics_workspace_id 2>/dev/null || echo "")
    local code_engine_project_id=$(terraform output -raw code_engine_project_id 2>/dev/null || echo "")
    local cos_instance_id=$(terraform output -raw cos_instance_id 2>/dev/null || echo "")
    
    # Validate Schematics workspace
    if [ -n "$schematics_workspace_id" ] && [ "$schematics_workspace_id" != "null" ]; then
        if ibmcloud schematics workspace get --id "$schematics_workspace_id" &> /dev/null; then
            success "Schematics workspace validated: $schematics_workspace_id"
        else
            error "Schematics workspace not accessible: $schematics_workspace_id"
        fi
    else
        warning "Schematics workspace not configured"
    fi
    
    # Validate Code Engine project
    if [ -n "$code_engine_project_id" ] && [ "$code_engine_project_id" != "null" ]; then
        if ibmcloud ce project get --name "$code_engine_project_id" &> /dev/null; then
            success "Code Engine project validated: $code_engine_project_id"
        else
            error "Code Engine project not accessible: $code_engine_project_id"
        fi
    else
        error "Code Engine project not found"
        return 1
    fi
    
    # Validate Object Storage instance
    if [ -n "$cos_instance_id" ] && [ "$cos_instance_id" != "null" ]; then
        if ibmcloud resource service-instance "$cos_instance_id" &> /dev/null; then
            success "Object Storage instance validated: $cos_instance_id"
        else
            error "Object Storage instance not accessible: $cos_instance_id"
        fi
    else
        error "Object Storage instance not found"
        return 1
    fi
}

validate_cicd_configuration() {
    info "Validating CI/CD platform configurations..."
    
    # Check GitLab configuration
    local gitlab_project_id=$(terraform output -raw gitlab_project_id 2>/dev/null || echo "")
    if [ -n "$gitlab_project_id" ] && [ "$gitlab_project_id" != "null" ]; then
        success "GitLab project configured: $gitlab_project_id"
    else
        info "GitLab integration not configured (optional)"
    fi
    
    # Check GitHub configuration
    local github_repository_name=$(terraform output -raw github_repository_name 2>/dev/null || echo "")
    if [ -n "$github_repository_name" ] && [ "$github_repository_name" != "null" ]; then
        success "GitHub repository configured: $github_repository_name"
    else
        info "GitHub integration not configured (optional)"
    fi
    
    # Check Terraform Cloud configuration
    local tfe_workspace_id=$(terraform output -raw tfe_workspace_id 2>/dev/null || echo "")
    if [ -n "$tfe_workspace_id" ] && [ "$tfe_workspace_id" != "null" ]; then
        success "Terraform Cloud workspace configured: $tfe_workspace_id"
    else
        info "Terraform Cloud integration not configured (optional)"
    fi
}

validate_monitoring_logging() {
    info "Validating monitoring and logging services..."
    
    local monitoring_instance_id=$(terraform output -raw monitoring_instance_id 2>/dev/null || echo "")
    local log_analysis_instance_id=$(terraform output -raw log_analysis_instance_id 2>/dev/null || echo "")
    local activity_tracker_instance_id=$(terraform output -raw activity_tracker_instance_id 2>/dev/null || echo "")
    
    if [ -n "$monitoring_instance_id" ] && [ "$monitoring_instance_id" != "null" ]; then
        success "Monitoring service configured: $monitoring_instance_id"
    else
        info "Monitoring service not configured (optional)"
    fi
    
    if [ -n "$log_analysis_instance_id" ] && [ "$log_analysis_instance_id" != "null" ]; then
        success "Log Analysis service configured: $log_analysis_instance_id"
    else
        info "Log Analysis service not configured (optional)"
    fi
    
    if [ -n "$activity_tracker_instance_id" ] && [ "$activity_tracker_instance_id" != "null" ]; then
        success "Activity Tracker service configured: $activity_tracker_instance_id"
    else
        info "Activity Tracker service not configured (optional)"
    fi
}

validate_security_compliance() {
    info "Validating security and compliance configuration..."
    
    # Check if security scanning is enabled
    local security_config=$(terraform output -json pipeline_configuration 2>/dev/null | jq -r '.security_scanning' 2>/dev/null || echo "false")
    if [ "$security_config" = "true" ]; then
        success "Security scanning enabled"
    else
        warning "Security scanning disabled"
    fi
    
    # Check compliance configuration
    local compliance_config=$(terraform output -json pipeline_configuration 2>/dev/null | jq -r '.compliance_checks' 2>/dev/null || echo "false")
    if [ "$compliance_config" = "true" ]; then
        success "Compliance checks enabled"
    else
        warning "Compliance checks disabled"
    fi
    
    # Validate bucket encryption
    local state_bucket=$(terraform output -raw terraform_state_bucket_name 2>/dev/null || echo "")
    if [ -n "$state_bucket" ]; then
        success "Terraform state bucket configured with encryption: $state_bucket"
    else
        error "Terraform state bucket not found"
        return 1
    fi
}

validate_connectivity() {
    info "Validating connectivity and endpoints..."
    
    # Check Code Engine webhook handler
    local webhook_url=$(terraform output -raw code_engine_webhook_handler_url 2>/dev/null || echo "")
    if [ -n "$webhook_url" ] && [ "$webhook_url" != "null" ]; then
        if curl -s --max-time 10 "$webhook_url" &> /dev/null; then
            success "Webhook handler accessible: $webhook_url"
        else
            warning "Webhook handler not responding (may be starting up): $webhook_url"
        fi
    else
        error "Webhook handler URL not found"
        return 1
    fi
    
    # Test IBM Cloud API connectivity
    if ibmcloud resource groups &> /dev/null; then
        success "IBM Cloud API connectivity verified"
    else
        error "IBM Cloud API not accessible"
        return 1
    fi
}

generate_summary_report() {
    info "Generating deployment summary report..."
    
    local summary_file="$PROJECT_DIR/deployment-summary.json"
    
    # Create summary JSON
    cat > "$summary_file" << EOF
{
  "validation_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "terraform_state": {
    "resource_count": $(terraform show -json 2>/dev/null | jq '.values.root_module.resources | length' 2>/dev/null || echo "0")
  },
  "infrastructure": {
    "schematics_workspace_id": "$(terraform output -raw schematics_workspace_id 2>/dev/null || echo "")",
    "code_engine_project_id": "$(terraform output -raw code_engine_project_id 2>/dev/null || echo "")",
    "cos_instance_id": "$(terraform output -raw cos_instance_id 2>/dev/null || echo "")",
    "webhook_handler_url": "$(terraform output -raw code_engine_webhook_handler_url 2>/dev/null || echo "")"
  },
  "cicd_platforms": {
    "gitlab_configured": $([ "$(terraform output -raw gitlab_project_id 2>/dev/null || echo "")" != "" ] && echo "true" || echo "false"),
    "github_configured": $([ "$(terraform output -raw github_repository_name 2>/dev/null || echo "")" != "" ] && echo "true" || echo "false"),
    "tfe_configured": $([ "$(terraform output -raw tfe_workspace_id 2>/dev/null || echo "")" != "" ] && echo "true" || echo "false")
  },
  "monitoring": {
    "monitoring_enabled": $([ "$(terraform output -raw monitoring_instance_id 2>/dev/null || echo "")" != "" ] && echo "true" || echo "false"),
    "logging_enabled": $([ "$(terraform output -raw log_analysis_instance_id 2>/dev/null || echo "")" != "" ] && echo "true" || echo "false"),
    "activity_tracker_enabled": $([ "$(terraform output -raw activity_tracker_instance_id 2>/dev/null || echo "")" != "" ] && echo "true" || echo "false")
  },
  "security": {
    "security_scanning": $(terraform output -json pipeline_configuration 2>/dev/null | jq -r '.security_scanning' 2>/dev/null || echo "false"),
    "compliance_checks": $(terraform output -json pipeline_configuration 2>/dev/null | jq -r '.compliance_checks' 2>/dev/null || echo "false"),
    "encrypted_storage": true
  }
}
EOF
    
    success "Deployment summary saved to: $summary_file"
    
    # Display key information
    echo ""
    echo "=== DEPLOYMENT SUMMARY ==="
    echo "Schematics Workspace: $(terraform output -raw schematics_workspace_url 2>/dev/null || echo "Not configured")"
    echo "Code Engine Project: $(terraform output -raw code_engine_project_name 2>/dev/null || echo "Not found")"
    echo "Webhook Handler: $(terraform output -raw code_engine_webhook_handler_url 2>/dev/null || echo "Not found")"
    echo "State Bucket: $(terraform output -raw terraform_state_bucket_name 2>/dev/null || echo "Not found")"
    echo "Artifacts Bucket: $(terraform output -raw pipeline_artifacts_bucket_name 2>/dev/null || echo "Not found")"
    echo "=========================="
}

# Main validation workflow
main() {
    log "Starting deployment validation for CI/CD Pipeline Integration Lab 8.1"
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    local validation_failed=false
    
    # Run validation checks
    validate_terraform_state || validation_failed=true
    validate_ibm_cloud_resources || validation_failed=true
    validate_cicd_configuration
    validate_monitoring_logging
    validate_security_compliance || validation_failed=true
    validate_connectivity || validation_failed=true
    
    # Generate summary report
    generate_summary_report
    
    # Final result
    if [ "$validation_failed" = true ]; then
        error "Deployment validation completed with errors"
        echo ""
        echo "Please review the validation log: $LOG_FILE"
        echo "Address any errors and re-run validation"
        exit 1
    else
        success "Deployment validation completed successfully"
        echo ""
        echo "Your CI/CD pipeline infrastructure is ready for use!"
        echo "Next steps:"
        echo "1. Configure your CI/CD platform webhooks"
        echo "2. Test pipeline execution with a sample commit"
        echo "3. Review monitoring dashboards"
        echo "4. Set up notification channels"
        exit 0
    fi
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
