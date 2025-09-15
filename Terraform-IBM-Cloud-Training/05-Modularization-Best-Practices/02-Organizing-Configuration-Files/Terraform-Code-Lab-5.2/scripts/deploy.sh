#!/bin/bash
# Configuration Organization Lab - Deployment Script
# Enterprise-grade deployment automation with safety checks

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEPLOYMENT_LOG="$PROJECT_ROOT/deployment.log"
STATE_BACKUP_DIR="$PROJECT_ROOT/state-backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Default values
DRY_RUN=false
AUTO_APPROVE=false
DESTROY=false
BACKUP_STATE=true
VALIDATE_BEFORE_DEPLOY=true

# Usage information
usage() {
    cat << EOF
Configuration Organization Lab - Deployment Script

Usage: $0 [OPTIONS]

OPTIONS:
    -d, --dry-run           Run terraform plan only (no deployment)
    -a, --auto-approve      Auto-approve deployment (skip confirmation)
    -D, --destroy           Destroy infrastructure instead of creating
    -s, --skip-validation   Skip pre-deployment validation
    -b, --no-backup         Skip state backup
    -h, --help              Show this help message

EXAMPLES:
    $0                      # Interactive deployment with validation
    $0 -d                   # Dry run (plan only)
    $0 -a                   # Auto-approve deployment
    $0 -D                   # Destroy infrastructure
    $0 -d -s                # Dry run without validation

ENVIRONMENT VARIABLES:
    TF_VAR_ibmcloud_api_key    IBM Cloud API key
    TF_LOG                     Terraform log level (DEBUG, INFO, WARN, ERROR)
    TF_LOG_PATH               Path to Terraform log file

EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -a|--auto-approve)
                AUTO_APPROVE=true
                shift
                ;;
            -D|--destroy)
                DESTROY=true
                shift
                ;;
            -s|--skip-validation)
                VALIDATE_BEFORE_DEPLOY=false
                shift
                ;;
            -b|--no-backup)
                BACKUP_STATE=false
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$DEPLOYMENT_LOG"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$DEPLOYMENT_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$DEPLOYMENT_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$DEPLOYMENT_LOG"
}

log_section() {
    echo -e "${PURPLE}[SECTION]${NC} $1" | tee -a "$DEPLOYMENT_LOG"
    echo "============================================" | tee -a "$DEPLOYMENT_LOG"
}

# Initialize deployment log
init_deployment_log() {
    mkdir -p "$(dirname "$DEPLOYMENT_LOG")"
    
    cat > "$DEPLOYMENT_LOG" << EOF
Configuration Organization Lab - Deployment Log
Started: $(date -Iseconds)
Project: $PROJECT_ROOT
Operation: $([ "$DESTROY" = true ] && echo "DESTROY" || echo "DEPLOY")
Dry Run: $DRY_RUN
Auto Approve: $AUTO_APPROVE
============================================

EOF
}

# Check prerequisites
check_prerequisites() {
    log_section "Checking Prerequisites"
    
    # Check required tools
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed or not in PATH"
        return 1
    fi
    
    # Check Terraform version
    local tf_version=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || echo "unknown")
    log_info "Terraform version: $tf_version"
    
    # Check for required environment variables
    if [ -z "${TF_VAR_ibmcloud_api_key:-}" ]; then
        log_error "TF_VAR_ibmcloud_api_key environment variable is not set"
        log_info "Set your IBM Cloud API key: export TF_VAR_ibmcloud_api_key='your-api-key'"
        return 1
    fi
    
    # Check for terraform.tfvars file
    if [ ! -f "$PROJECT_ROOT/terraform.tfvars" ]; then
        log_warning "terraform.tfvars file not found"
        log_info "Copy terraform.tfvars.example to terraform.tfvars and customize"
        
        if [ -f "$PROJECT_ROOT/terraform.tfvars.example" ]; then
            log_info "Would you like to copy the example file? (y/n)"
            if [ "$AUTO_APPROVE" = false ]; then
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    cp "$PROJECT_ROOT/terraform.tfvars.example" "$PROJECT_ROOT/terraform.tfvars"
                    log_success "Copied terraform.tfvars.example to terraform.tfvars"
                    log_warning "Please review and customize terraform.tfvars before proceeding"
                    return 1
                fi
            fi
        fi
    fi
    
    log_success "Prerequisites check completed"
    return 0
}

# Backup Terraform state
backup_state() {
    if [ "$BACKUP_STATE" = false ]; then
        log_info "Skipping state backup (disabled)"
        return 0
    fi
    
    log_section "Backing Up Terraform State"
    
    mkdir -p "$STATE_BACKUP_DIR"
    
    if [ -f "$PROJECT_ROOT/terraform.tfstate" ]; then
        local backup_file="$STATE_BACKUP_DIR/terraform.tfstate.$(date +%Y%m%d-%H%M%S).backup"
        cp "$PROJECT_ROOT/terraform.tfstate" "$backup_file"
        log_success "State backed up to: $backup_file"
    else
        log_info "No local state file found (using remote backend or first deployment)"
    fi
    
    return 0
}

# Run pre-deployment validation
run_validation() {
    if [ "$VALIDATE_BEFORE_DEPLOY" = false ]; then
        log_info "Skipping pre-deployment validation (disabled)"
        return 0
    fi
    
    log_section "Running Pre-Deployment Validation"
    
    if [ -f "$SCRIPT_DIR/validate.sh" ]; then
        log_info "Running validation script..."
        if bash "$SCRIPT_DIR/validate.sh"; then
            log_success "Validation completed successfully"
        else
            log_error "Validation failed"
            return 1
        fi
    else
        log_warning "Validation script not found - running basic checks"
        
        # Basic validation
        cd "$PROJECT_ROOT"
        
        if terraform validate; then
            log_success "Terraform validation passed"
        else
            log_error "Terraform validation failed"
            return 1
        fi
    fi
    
    return 0
}

# Initialize Terraform
initialize_terraform() {
    log_section "Initializing Terraform"
    
    cd "$PROJECT_ROOT"
    
    log_info "Running terraform init..."
    if terraform init -upgrade; then
        log_success "Terraform initialization completed"
    else
        log_error "Terraform initialization failed"
        return 1
    fi
    
    return 0
}

# Generate and display plan
generate_plan() {
    log_section "Generating Terraform Plan"
    
    cd "$PROJECT_ROOT"
    
    local plan_file="terraform.plan"
    local plan_output="plan-output.txt"
    
    log_info "Generating execution plan..."
    
    if [ "$DESTROY" = true ]; then
        if terraform plan -destroy -out="$plan_file" | tee "$plan_output"; then
            log_success "Destroy plan generated successfully"
        else
            log_error "Failed to generate destroy plan"
            return 1
        fi
    else
        if terraform plan -out="$plan_file" | tee "$plan_output"; then
            log_success "Plan generated successfully"
        else
            log_error "Failed to generate plan"
            return 1
        fi
    fi
    
    # Display plan summary
    log_info "Plan Summary:"
    if grep -q "No changes" "$plan_output"; then
        log_info "No changes detected"
    else
        local add_count=$(grep -c "will be created" "$plan_output" 2>/dev/null || echo "0")
        local change_count=$(grep -c "will be updated" "$plan_output" 2>/dev/null || echo "0")
        local destroy_count=$(grep -c "will be destroyed" "$plan_output" 2>/dev/null || echo "0")
        
        log_info "Resources to add: $add_count"
        log_info "Resources to change: $change_count"
        log_info "Resources to destroy: $destroy_count"
    fi
    
    return 0
}

# Estimate costs (if infracost is available)
estimate_costs() {
    if ! command -v infracost &> /dev/null; then
        log_info "Infracost not available - skipping cost estimation"
        return 0
    fi
    
    log_section "Estimating Costs"
    
    cd "$PROJECT_ROOT"
    
    log_info "Generating cost estimate..."
    if infracost breakdown --path . --format table > cost-estimate.txt 2>/dev/null; then
        log_success "Cost estimate generated"
        cat cost-estimate.txt | tee -a "$DEPLOYMENT_LOG"
    else
        log_warning "Cost estimation failed or not available for this configuration"
    fi
    
    return 0
}

# Apply or destroy infrastructure
apply_changes() {
    if [ "$DRY_RUN" = true ]; then
        log_info "Dry run mode - skipping apply/destroy"
        return 0
    fi
    
    local operation=$([ "$DESTROY" = true ] && echo "Destroying" || echo "Applying")
    log_section "$operation Infrastructure"
    
    cd "$PROJECT_ROOT"
    
    # Confirmation prompt (unless auto-approved)
    if [ "$AUTO_APPROVE" = false ]; then
        echo
        log_warning "This will $([ "$DESTROY" = true ] && echo "DESTROY" || echo "CREATE/MODIFY") infrastructure in IBM Cloud"
        echo -n "Do you want to continue? (yes/no): "
        read -r response
        
        if [[ ! "$response" =~ ^[Yy][Ee][Ss]$ ]]; then
            log_info "Operation cancelled by user"
            return 1
        fi
    fi
    
    # Apply changes
    local plan_file="terraform.plan"
    
    if [ -f "$plan_file" ]; then
        log_info "Applying planned changes..."
        if terraform apply "$plan_file"; then
            log_success "$([ "$DESTROY" = true ] && echo "Destruction" || echo "Deployment") completed successfully"
        else
            log_error "$([ "$DESTROY" = true ] && echo "Destruction" || echo "Deployment") failed"
            return 1
        fi
    else
        log_error "Plan file not found - cannot apply changes"
        return 1
    fi
    
    return 0
}

# Display outputs
display_outputs() {
    if [ "$DRY_RUN" = true ] || [ "$DESTROY" = true ]; then
        return 0
    fi
    
    log_section "Deployment Outputs"
    
    cd "$PROJECT_ROOT"
    
    log_info "Retrieving Terraform outputs..."
    if terraform output -json > outputs.json 2>/dev/null; then
        log_success "Outputs retrieved successfully"
        
        # Display key outputs
        if command -v jq &> /dev/null; then
            echo
            log_info "Key Infrastructure Information:"
            
            # VPC information
            local vpc_id=$(jq -r '.integration_endpoints.value.vpc_id // "N/A"' outputs.json)
            log_info "VPC ID: $vpc_id"
            
            # Cost information
            local total_cost=$(jq -r '.cost_analysis.value.total_monthly_cost // "N/A"' outputs.json)
            log_info "Estimated Monthly Cost: \$${total_cost}"
            
            # SSH key information
            local ssh_key_file=$(jq -r '.development_info.value.ssh_key_info.private_key_file // "N/A"' outputs.json)
            if [ "$ssh_key_file" != "N/A" ]; then
                log_info "SSH Private Key: $ssh_key_file"
            fi
        fi
    else
        log_warning "Could not retrieve outputs"
    fi
    
    return 0
}

# Generate deployment report
generate_deployment_report() {
    log_section "Generating Deployment Report"
    
    cd "$PROJECT_ROOT"
    
    local report_file="deployment-report.json"
    local timestamp=$(date -Iseconds)
    local operation=$([ "$DESTROY" = true ] && echo "destroy" || echo "deploy")
    local status=$([ $? -eq 0 ] && echo "success" || echo "failed")
    
    cat > "$report_file" << EOF
{
    "deployment_report": {
        "timestamp": "$timestamp",
        "operation": "$operation",
        "status": "$status",
        "dry_run": $DRY_RUN,
        "auto_approve": $AUTO_APPROVE,
        "project_path": "$PROJECT_ROOT",
        
        "configuration": {
            "terraform_version": "$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || echo 'unknown')",
            "validation_performed": $VALIDATE_BEFORE_DEPLOY,
            "state_backed_up": $BACKUP_STATE
        },
        
        "files_generated": [
            "deployment.log",
            "terraform.plan",
            "plan-output.txt",
            "outputs.json",
            "deployment-report.json"
        ],
        
        "next_steps": [
            "Review deployment outputs for infrastructure details",
            "Test connectivity to deployed resources",
            "Set up monitoring and alerting",
            "Document any manual configuration steps",
            "Plan for backup and disaster recovery"
        ]
    }
}
EOF
    
    log_success "Deployment report generated: $report_file"
    return 0
}

# Cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."
    
    cd "$PROJECT_ROOT"
    
    # Remove plan file (contains sensitive information)
    if [ -f "terraform.plan" ]; then
        rm -f "terraform.plan"
        log_info "Removed terraform.plan file"
    fi
    
    # Keep other files for review
    log_info "Deployment artifacts preserved for review"
}

# Main deployment function
main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    # Initialize deployment log
    init_deployment_log
    
    log_info "Starting Configuration Organization Lab Deployment"
    log_info "Operation: $([ "$DESTROY" = true ] && echo "DESTROY" || echo "DEPLOY")"
    log_info "Dry Run: $DRY_RUN"
    log_info "Auto Approve: $AUTO_APPROVE"
    
    # Set up error handling
    trap cleanup EXIT
    
    # Run deployment steps
    local deployment_failed=false
    
    check_prerequisites || deployment_failed=true
    
    if [ "$deployment_failed" = false ]; then
        backup_state || deployment_failed=true
        run_validation || deployment_failed=true
        initialize_terraform || deployment_failed=true
        generate_plan || deployment_failed=true
        estimate_costs || true  # Don't fail on cost estimation issues
        apply_changes || deployment_failed=true
        display_outputs || true  # Don't fail on output issues
        generate_deployment_report || true  # Don't fail on report generation
    fi
    
    # Final status
    if [ "$deployment_failed" = true ]; then
        log_error "Deployment failed - review the log for details"
        log_info "Deployment log: $DEPLOYMENT_LOG"
        return 1
    else
        if [ "$DRY_RUN" = true ]; then
            log_success "Dry run completed successfully!"
            log_info "Review the plan and run without -d to deploy"
        elif [ "$DESTROY" = true ]; then
            log_success "Infrastructure destroyed successfully!"
        else
            log_success "Deployment completed successfully!"
            log_info "Infrastructure is ready for use"
        fi
        
        log_info "Deployment log: $DEPLOYMENT_LOG"
        return 0
    fi
}

# Run main function
main "$@"
