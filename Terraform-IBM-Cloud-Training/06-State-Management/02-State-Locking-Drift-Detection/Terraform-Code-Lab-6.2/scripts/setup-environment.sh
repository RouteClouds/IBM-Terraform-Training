#!/bin/bash

# =============================================================================
# ENVIRONMENT SETUP SCRIPT
# Subtopic 6.2: State Locking and Drift Detection
# Automated setup for state management lab environment
# =============================================================================

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_DIR}/setup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        error "Required command '$1' not found. Please install it first."
    fi
}

# =============================================================================
# PREREQUISITE CHECKS
# =============================================================================

check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check required commands
    check_command "terraform"
    check_command "ibmcloud"
    check_command "jq"
    check_command "curl"
    
    # Check Terraform version
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
    if [[ $(echo "$TERRAFORM_VERSION 1.5.0" | tr " " "\n" | sort -V | head -n1) != "1.5.0" ]]; then
        error "Terraform version 1.5.0 or higher required. Found: $TERRAFORM_VERSION"
    fi
    
    # Check IBM Cloud CLI login
    if ! ibmcloud target &> /dev/null; then
        error "IBM Cloud CLI not logged in. Run 'ibmcloud login' first."
    fi
    
    log "Prerequisites check completed successfully"
}

# =============================================================================
# CONFIGURATION VALIDATION
# =============================================================================

validate_configuration() {
    log "Validating configuration..."
    
    # Check if terraform.tfvars exists
    if [[ ! -f "${PROJECT_DIR}/terraform.tfvars" ]]; then
        warn "terraform.tfvars not found. Creating from example..."
        cp "${PROJECT_DIR}/terraform.tfvars.example" "${PROJECT_DIR}/terraform.tfvars"
        info "Please edit terraform.tfvars with your specific configuration"
        info "Required: ibm_api_key, ssh_key_name (if using SSH access)"
    fi
    
    # Validate Terraform configuration
    cd "$PROJECT_DIR"
    if ! terraform validate; then
        error "Terraform configuration validation failed"
    fi
    
    log "Configuration validation completed"
}

# =============================================================================
# ENVIRONMENT INITIALIZATION
# =============================================================================

initialize_terraform() {
    log "Initializing Terraform..."
    
    cd "$PROJECT_DIR"
    
    # Initialize Terraform
    if ! terraform init; then
        error "Terraform initialization failed"
    fi
    
    # Create workspace if specified
    if [[ -n "${TF_WORKSPACE:-}" ]]; then
        terraform workspace select "$TF_WORKSPACE" 2>/dev/null || terraform workspace new "$TF_WORKSPACE"
        log "Using Terraform workspace: $TF_WORKSPACE"
    fi
    
    log "Terraform initialization completed"
}

# =============================================================================
# INFRASTRUCTURE DEPLOYMENT
# =============================================================================

deploy_infrastructure() {
    log "Deploying infrastructure..."
    
    cd "$PROJECT_DIR"
    
    # Plan deployment
    log "Creating deployment plan..."
    if ! terraform plan -out=tfplan; then
        error "Terraform planning failed"
    fi
    
    # Apply deployment
    log "Applying deployment plan..."
    if ! terraform apply tfplan; then
        error "Terraform deployment failed"
    fi
    
    # Clean up plan file
    rm -f tfplan
    
    log "Infrastructure deployment completed"
}

# =============================================================================
# STATE LOCKING SETUP
# =============================================================================

setup_state_locking() {
    log "Setting up state locking..."
    
    cd "$PROJECT_DIR"
    
    # Check if state locking is enabled
    LOCKING_ENABLED=$(terraform output -json | jq -r '.state_locking_configuration.value.enabled // false')
    
    if [[ "$LOCKING_ENABLED" == "true" ]]; then
        log "State locking is enabled. Configuring backend..."
        
        # Get backend configuration
        if [[ -f "generated_backend_with_locking.tf" ]]; then
            info "Backend configuration generated. To migrate to locked backend:"
            info "1. Copy the backend configuration from generated_backend_with_locking.tf"
            info "2. Add it to providers.tf (uncomment the backend block)"
            info "3. Run 'terraform init' to migrate state"
            info "4. Confirm migration when prompted"
        else
            warn "Backend configuration not generated. Check state locking setup."
        fi
    else
        info "State locking is disabled. Enable it in terraform.tfvars to use locking features."
    fi
    
    log "State locking setup completed"
}

# =============================================================================
# DRIFT DETECTION SETUP
# =============================================================================

setup_drift_detection() {
    log "Setting up drift detection..."
    
    cd "$PROJECT_DIR"
    
    # Check if drift detection is enabled
    DRIFT_ENABLED=$(terraform output -json | jq -r '.drift_detection_setup.value.enabled // false')
    
    if [[ "$DRIFT_ENABLED" == "true" ]]; then
        log "Drift detection is enabled. Configuring monitoring..."
        
        # Get drift detection configuration
        if [[ -f "drift_detection_config.json" ]]; then
            SCHEDULE=$(jq -r '.schedule' drift_detection_config.json)
            THRESHOLD=$(jq -r '.severity_threshold' drift_detection_config.json)
            
            info "Drift detection configured:"
            info "  Schedule: $SCHEDULE"
            info "  Severity threshold: $THRESHOLD"
            info "  Configuration file: drift_detection_config.json"
        fi
        
        # Test drift detection function
        FUNCTION_NAME=$(terraform output -json | jq -r '.cloud_functions_details.value.drift_function_id // empty')
        if [[ -n "$FUNCTION_NAME" ]]; then
            log "Testing drift detection function..."
            if ibmcloud fn action invoke "$FUNCTION_NAME" --result; then
                log "Drift detection function test successful"
            else
                warn "Drift detection function test failed"
            fi
        fi
    else
        info "Drift detection is disabled. Enable it in terraform.tfvars to use monitoring features."
    fi
    
    log "Drift detection setup completed"
}

# =============================================================================
# VALIDATION AND TESTING
# =============================================================================

validate_deployment() {
    log "Validating deployment..."
    
    cd "$PROJECT_DIR"
    
    # Get deployment outputs
    terraform output -json > outputs.json
    
    # Validate infrastructure
    VPC_ID=$(jq -r '.vpc_infrastructure.value.vpc_id' outputs.json)
    VSI_ID=$(jq -r '.compute_resources.value.vsi_id' outputs.json)
    
    if [[ "$VPC_ID" != "null" && "$VSI_ID" != "null" ]]; then
        log "Infrastructure validation successful"
        info "VPC ID: $VPC_ID"
        info "VSI ID: $VSI_ID"
    else
        error "Infrastructure validation failed"
    fi
    
    # Validate state backend
    BUCKET_NAME=$(jq -r '.state_backend_configuration.value.bucket_name' outputs.json)
    if [[ "$BUCKET_NAME" != "null" ]]; then
        log "State backend validation successful"
        info "State bucket: $BUCKET_NAME"
    else
        error "State backend validation failed"
    fi
    
    # Clean up
    rm -f outputs.json
    
    log "Deployment validation completed"
}

# =============================================================================
# CLEANUP FUNCTIONS
# =============================================================================

cleanup_on_error() {
    warn "Setup failed. Cleaning up partial deployment..."
    cd "$PROJECT_DIR"
    
    # Attempt to destroy resources
    if [[ -f "terraform.tfstate" ]]; then
        terraform destroy -auto-approve || warn "Cleanup may be incomplete"
    fi
    
    error "Setup failed. Check $LOG_FILE for details."
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    log "Starting State Locking and Drift Detection Lab Setup"
    log "=============================================="
    
    # Set up error handling
    trap cleanup_on_error ERR
    
    # Execute setup steps
    check_prerequisites
    validate_configuration
    initialize_terraform
    deploy_infrastructure
    setup_state_locking
    setup_drift_detection
    validate_deployment
    
    log "=============================================="
    log "Setup completed successfully!"
    log ""
    log "Next steps:"
    log "1. Review the deployment outputs"
    log "2. Test state locking with concurrent operations"
    log "3. Simulate drift and verify detection"
    log "4. Explore monitoring and alerting features"
    log ""
    log "For detailed instructions, see Lab-13.md"
    log "For troubleshooting, check $LOG_FILE"
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
