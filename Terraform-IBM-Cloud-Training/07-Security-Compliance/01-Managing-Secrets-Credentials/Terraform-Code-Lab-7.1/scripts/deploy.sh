#!/bin/bash

# IBM Cloud Terraform Training - Topic 7.1: Managing Secrets and Credentials
# Terraform Code Lab 7.1 - Deployment Script
#
# This script automates the deployment of enterprise secrets management
# infrastructure with comprehensive validation and error handling.
#
# Author: IBM Cloud Terraform Training Team
# Version: 1.0.0
# Last Updated: 2024-09-15

set -e  # Exit on any error

# =============================================================================
# CONFIGURATION AND VARIABLES
# =============================================================================

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_DIR}/deployment.log"
TERRAFORM_DIR="$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="${ENVIRONMENT:-development}"
PROJECT_NAME="${PROJECT_NAME:-security-lab}"
AUTO_APPROVE="${AUTO_APPROVE:-false}"
SKIP_VALIDATION="${SKIP_VALIDATION:-false}"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        "DEBUG")
            echo -e "${BLUE}[DEBUG]${NC} $message" | tee -a "$LOG_FILE"
            ;;
    esac
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Error handler
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# =============================================================================
# PREREQUISITE CHECKS
# =============================================================================

check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check required commands
    local required_commands=("terraform" "ibmcloud" "jq" "curl")
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            error_exit "Required command '$cmd' not found. Please install it first."
        fi
    done
    
    # Check Terraform version
    local tf_version=$(terraform version -json | jq -r '.terraform_version')
    log "INFO" "Terraform version: $tf_version"
    
    # Check IBM Cloud CLI login
    if ! ibmcloud target >/dev/null 2>&1; then
        error_exit "IBM Cloud CLI not logged in. Please run 'ibmcloud login' first."
    fi
    
    # Check API key
    if [[ -z "$IBMCLOUD_API_KEY" ]]; then
        log "WARN" "IBMCLOUD_API_KEY environment variable not set."
        log "INFO" "Please set it with: export IBMCLOUD_API_KEY='your-api-key'"
    fi
    
    # Check terraform.tfvars exists
    if [[ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]]; then
        log "WARN" "terraform.tfvars not found. Using terraform.tfvars.example as reference."
        log "INFO" "Copy terraform.tfvars.example to terraform.tfvars and customize it."
    fi
    
    log "INFO" "Prerequisites check completed successfully."
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

validate_configuration() {
    if [[ "$SKIP_VALIDATION" == "true" ]]; then
        log "INFO" "Skipping configuration validation."
        return 0
    fi
    
    log "INFO" "Validating Terraform configuration..."
    
    cd "$TERRAFORM_DIR"
    
    # Terraform format check
    if ! terraform fmt -check=true -diff=true; then
        log "WARN" "Terraform files are not properly formatted. Running terraform fmt..."
        terraform fmt
    fi
    
    # Terraform validation
    if ! terraform validate; then
        error_exit "Terraform configuration validation failed."
    fi
    
    log "INFO" "Configuration validation completed successfully."
}

validate_ibm_cloud_access() {
    log "INFO" "Validating IBM Cloud access..."
    
    # Check current target
    local current_target=$(ibmcloud target --output json 2>/dev/null || echo "{}")
    local region=$(echo "$current_target" | jq -r '.region // "none"')
    local resource_group=$(echo "$current_target" | jq -r '.resource_group.name // "none"')
    
    log "INFO" "Current IBM Cloud target:"
    log "INFO" "  Region: $region"
    log "INFO" "  Resource Group: $resource_group"
    
    # Test API access
    if ! ibmcloud resource groups >/dev/null 2>&1; then
        error_exit "Unable to access IBM Cloud resources. Check your permissions."
    fi
    
    log "INFO" "IBM Cloud access validation completed successfully."
}

# =============================================================================
# DEPLOYMENT FUNCTIONS
# =============================================================================

terraform_init() {
    log "INFO" "Initializing Terraform..."
    
    cd "$TERRAFORM_DIR"
    
    if ! terraform init -upgrade; then
        error_exit "Terraform initialization failed."
    fi
    
    log "INFO" "Terraform initialization completed successfully."
}

terraform_plan() {
    log "INFO" "Creating Terraform execution plan..."
    
    cd "$TERRAFORM_DIR"
    
    local plan_file="${TERRAFORM_DIR}/terraform.plan"
    
    if ! terraform plan -out="$plan_file" -detailed-exitcode; then
        local exit_code=$?
        if [[ $exit_code -eq 2 ]]; then
            log "INFO" "Terraform plan shows changes to be applied."
        else
            error_exit "Terraform plan failed."
        fi
    else
        log "INFO" "No changes detected in Terraform plan."
    fi
    
    log "INFO" "Terraform plan completed successfully."
}

terraform_apply() {
    log "INFO" "Applying Terraform configuration..."
    
    cd "$TERRAFORM_DIR"
    
    local plan_file="${TERRAFORM_DIR}/terraform.plan"
    local apply_args=""
    
    if [[ "$AUTO_APPROVE" == "true" ]]; then
        apply_args="-auto-approve"
        log "INFO" "Auto-approve enabled. Applying without confirmation."
    fi
    
    if [[ -f "$plan_file" ]]; then
        if ! terraform apply $apply_args "$plan_file"; then
            error_exit "Terraform apply failed."
        fi
    else
        if ! terraform apply $apply_args; then
            error_exit "Terraform apply failed."
        fi
    fi
    
    log "INFO" "Terraform apply completed successfully."
}

# =============================================================================
# POST-DEPLOYMENT VALIDATION
# =============================================================================

validate_deployment() {
    log "INFO" "Validating deployment..."
    
    cd "$TERRAFORM_DIR"
    
    # Get Terraform outputs
    local outputs=$(terraform output -json 2>/dev/null || echo "{}")
    
    # Validate Key Protect instance
    local kp_instance=$(echo "$outputs" | jq -r '.key_protect_instance.value // null')
    if [[ "$kp_instance" != "null" ]]; then
        local kp_id=$(echo "$kp_instance" | jq -r '.id')
        log "INFO" "Key Protect instance created: $kp_id"
    fi
    
    # Validate Secrets Manager instance
    local sm_instance=$(echo "$outputs" | jq -r '.secrets_manager_instance.value // null')
    if [[ "$sm_instance" != "null" ]]; then
        local sm_id=$(echo "$sm_instance" | jq -r '.id')
        log "INFO" "Secrets Manager instance created: $sm_id"
    fi
    
    # Validate IAM resources
    local service_id=$(echo "$outputs" | jq -r '.service_id.value.id // null')
    if [[ "$service_id" != "null" ]]; then
        log "INFO" "Service ID created: $service_id"
    fi
    
    log "INFO" "Deployment validation completed successfully."
}

generate_summary() {
    log "INFO" "Generating deployment summary..."
    
    cd "$TERRAFORM_DIR"
    
    local outputs=$(terraform output -json 2>/dev/null || echo "{}")
    local summary_file="${PROJECT_DIR}/deployment-summary.json"
    
    # Create deployment summary
    cat > "$summary_file" << EOF
{
  "deployment_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project_name": "$PROJECT_NAME",
  "environment": "$ENVIRONMENT",
  "terraform_outputs": $outputs,
  "deployment_status": "success"
}
EOF
    
    log "INFO" "Deployment summary saved to: $summary_file"
    
    # Display key information
    echo ""
    echo "=========================================="
    echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉"
    echo "=========================================="
    echo ""
    echo "Project: $PROJECT_NAME"
    echo "Environment: $ENVIRONMENT"
    echo "Timestamp: $(date)"
    echo ""
    echo "Next Steps:"
    echo "1. Review the deployment summary in: $summary_file"
    echo "2. Check IBM Cloud console for created resources"
    echo "3. Test secret retrieval using IBM Cloud CLI"
    echo "4. Configure application integration"
    echo "5. Set up monitoring and alerting"
    echo ""
    echo "Useful Commands:"
    echo "  terraform output                    # View all outputs"
    echo "  terraform show                      # Show current state"
    echo "  ibmcloud resource service-instances # List service instances"
    echo ""
}

# =============================================================================
# CLEANUP FUNCTION
# =============================================================================

cleanup() {
    log "INFO" "Cleaning up temporary files..."
    
    cd "$TERRAFORM_DIR"
    
    # Remove plan file
    if [[ -f "terraform.plan" ]]; then
        rm -f "terraform.plan"
        log "INFO" "Removed terraform.plan file."
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    log "INFO" "Starting IBM Cloud Terraform deployment..."
    log "INFO" "Project: $PROJECT_NAME"
    log "INFO" "Environment: $ENVIRONMENT"
    log "INFO" "Log file: $LOG_FILE"
    
    # Trap cleanup on exit
    trap cleanup EXIT
    
    # Execute deployment steps
    check_prerequisites
    validate_ibm_cloud_access
    validate_configuration
    terraform_init
    terraform_plan
    terraform_apply
    validate_deployment
    generate_summary
    
    log "INFO" "Deployment completed successfully!"
}

# =============================================================================
# SCRIPT ENTRY POINT
# =============================================================================

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -p|--project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -a|--auto-approve)
            AUTO_APPROVE="true"
            shift
            ;;
        -s|--skip-validation)
            SKIP_VALIDATION="true"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -e, --environment ENV     Set environment (development|staging|production)"
            echo "  -p, --project NAME        Set project name"
            echo "  -a, --auto-approve        Auto-approve Terraform apply"
            echo "  -s, --skip-validation     Skip configuration validation"
            echo "  -h, --help               Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  IBMCLOUD_API_KEY         IBM Cloud API key"
            echo "  ENVIRONMENT              Environment name"
            echo "  PROJECT_NAME             Project name"
            echo ""
            exit 0
            ;;
        *)
            error_exit "Unknown option: $1"
            ;;
    esac
done

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

# Execute main function
main "$@"
