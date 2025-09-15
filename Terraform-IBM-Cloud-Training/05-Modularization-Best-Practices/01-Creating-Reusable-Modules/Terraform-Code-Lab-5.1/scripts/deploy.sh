#!/bin/bash
# =============================================================================
# TERRAFORM DEPLOYMENT SCRIPT
# =============================================================================
# Terraform Code Lab 5.1: Creating Reusable Modules
# This script provides automated deployment with safety checks, cost estimation,
# and comprehensive logging for the module creation lab.

set -euo pipefail

# =============================================================================
# CONFIGURATION AND VARIABLES
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_DIR/deployment.log"
PLAN_FILE="$PROJECT_DIR/terraform.tfplan"
COST_FILE="$PROJECT_DIR/cost-estimate.json"
STATE_BACKUP_DIR="$PROJECT_DIR/state-backups"

# Default values
DRY_RUN=false
AUTO_APPROVE=false
DESTROY=false
SKIP_VALIDATION=false
SKIP_COST_CHECK=false
MAX_COST=100.00

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
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_info() {
    log "${BLUE}[INFO]${NC} $1"
}

log_success() {
    log "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    log "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    log "${RED}[ERROR]${NC} $1"
}

print_header() {
    log ""
    log "=============================================================================="
    log "$1"
    log "=============================================================================="
}

print_section() {
    log ""
    log "--- $1 ---"
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    -d, --dry-run           Perform a dry run (plan only, no apply)
    -a, --auto-approve      Auto-approve the deployment (skip confirmation)
    -D, --destroy           Destroy the infrastructure
    -s, --skip-validation   Skip validation checks
    -c, --skip-cost-check   Skip cost estimation
    -m, --max-cost AMOUNT   Maximum allowed cost in USD (default: 100.00)
    -h, --help              Show this help message

EXAMPLES:
    $0                      # Interactive deployment with all checks
    $0 -d                   # Dry run (plan only)
    $0 -a                   # Auto-approve deployment
    $0 -D                   # Destroy infrastructure
    $0 -m 50.00             # Set maximum cost to $50.00

ENVIRONMENT VARIABLES:
    IBMCLOUD_API_KEY        IBM Cloud API key (required)
    TF_VAR_*                Terraform variables
    TF_LOG                  Terraform log level (DEBUG, INFO, WARN, ERROR)

EOF
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

check_prerequisites() {
    print_section "Checking Prerequisites"
    
    # Check required tools
    local tools=("terraform" "ibmcloud" "jq")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool is required but not installed"
            exit 1
        else
            log_success "$tool is available"
        fi
    done
    
    # Check IBM Cloud API key
    if [ -z "${IBMCLOUD_API_KEY:-}" ]; then
        log_error "IBMCLOUD_API_KEY environment variable is not set"
        log_info "Please set your IBM Cloud API key: export IBMCLOUD_API_KEY='your-api-key'"
        exit 1
    else
        log_success "IBM Cloud API key is configured"
    fi
    
    # Check terraform.tfvars file
    if [ ! -f "$PROJECT_DIR/terraform.tfvars" ]; then
        if [ -f "$PROJECT_DIR/terraform.tfvars.example" ]; then
            log_warning "terraform.tfvars not found. Please copy from terraform.tfvars.example"
            log_info "cp terraform.tfvars.example terraform.tfvars"
        else
            log_error "No terraform.tfvars or terraform.tfvars.example found"
        fi
        exit 1
    else
        log_success "terraform.tfvars file found"
    fi
}

validate_configuration() {
    print_section "Validating Configuration"
    
    cd "$PROJECT_DIR"
    
    if [ "$SKIP_VALIDATION" = true ]; then
        log_warning "Skipping validation checks as requested"
        return 0
    fi
    
    # Run validation script if available
    if [ -f "$SCRIPT_DIR/validate.sh" ]; then
        log_info "Running validation script..."
        if bash "$SCRIPT_DIR/validate.sh"; then
            log_success "Validation passed"
        else
            log_error "Validation failed"
            exit 1
        fi
    else
        # Basic validation
        log_info "Running basic Terraform validation..."
        terraform init -backend=false > /dev/null
        if terraform validate; then
            log_success "Terraform configuration is valid"
        else
            log_error "Terraform configuration validation failed"
            exit 1
        fi
    fi
}

authenticate_ibm_cloud() {
    print_section "IBM Cloud Authentication"
    
    log_info "Authenticating with IBM Cloud..."
    if ibmcloud login --apikey "$IBMCLOUD_API_KEY" -r us-south > /dev/null 2>&1; then
        log_success "IBM Cloud authentication successful"
        
        # Show account information
        local account_info=$(ibmcloud account show --output json 2>/dev/null || echo '{}')
        local account_name=$(echo "$account_info" | jq -r '.name // "Unknown"')
        local account_id=$(echo "$account_info" | jq -r '.guid // "Unknown"')
        
        log_info "Account: $account_name ($account_id)"
    else
        log_error "IBM Cloud authentication failed"
        exit 1
    fi
}

backup_state() {
    print_section "Backing Up State"
    
    cd "$PROJECT_DIR"
    
    # Create backup directory
    mkdir -p "$STATE_BACKUP_DIR"
    
    # Backup state file if it exists
    if [ -f "terraform.tfstate" ]; then
        local backup_file="$STATE_BACKUP_DIR/terraform.tfstate.$(date +%Y%m%d-%H%M%S).backup"
        cp "terraform.tfstate" "$backup_file"
        log_success "State backed up to: $backup_file"
    else
        log_info "No existing state file to backup"
    fi
}

estimate_costs() {
    print_section "Cost Estimation"
    
    cd "$PROJECT_DIR"
    
    if [ "$SKIP_COST_CHECK" = true ]; then
        log_warning "Skipping cost estimation as requested"
        return 0
    fi
    
    # Check if infracost is available
    if command -v infracost &> /dev/null; then
        log_info "Running Infracost analysis..."
        
        # Generate cost estimate
        if infracost breakdown --path . --format json --out-file "$COST_FILE" > /dev/null 2>&1; then
            local total_cost=$(jq -r '.totalMonthlyCost // "0"' "$COST_FILE")
            log_success "Cost estimate generated: \$${total_cost}/month"
            
            # Check against maximum cost
            if (( $(echo "$total_cost > $MAX_COST" | bc -l) )); then
                log_error "Estimated cost (\$${total_cost}) exceeds maximum allowed (\$${MAX_COST})"
                log_info "Use --max-cost to increase the limit or optimize your configuration"
                exit 1
            else
                log_success "Cost is within acceptable limits"
            fi
        else
            log_warning "Infracost analysis failed, continuing without cost estimate"
        fi
    else
        log_warning "Infracost not available, skipping cost estimation"
        log_info "Install Infracost for cost analysis: https://www.infracost.io/docs/"
    fi
}

terraform_init() {
    print_section "Terraform Initialization"
    
    cd "$PROJECT_DIR"
    
    log_info "Initializing Terraform..."
    if terraform init; then
        log_success "Terraform initialization completed"
    else
        log_error "Terraform initialization failed"
        exit 1
    fi
}

terraform_plan() {
    print_section "Terraform Planning"
    
    cd "$PROJECT_DIR"
    
    local plan_args=()
    if [ "$DESTROY" = true ]; then
        plan_args+=("-destroy")
        log_info "Creating destruction plan..."
    else
        log_info "Creating deployment plan..."
    fi
    
    plan_args+=("-out=$PLAN_FILE")
    
    if terraform plan "${plan_args[@]}"; then
        log_success "Terraform plan completed successfully"
        
        # Show plan summary
        log_info "Plan summary:"
        terraform show -no-color "$PLAN_FILE" | grep -E "Plan:|No changes" || true
    else
        log_error "Terraform plan failed"
        exit 1
    fi
}

confirm_deployment() {
    if [ "$AUTO_APPROVE" = true ]; then
        log_info "Auto-approve enabled, skipping confirmation"
        return 0
    fi
    
    print_section "Deployment Confirmation"
    
    # Show plan summary
    log_info "Review the plan above carefully."
    
    if [ "$DESTROY" = true ]; then
        log_warning "This will DESTROY all resources managed by this configuration!"
        echo -n "Are you sure you want to destroy the infrastructure? (type 'yes' to confirm): "
    else
        echo -n "Do you want to proceed with the deployment? (y/N): "
    fi
    
    read -r response
    
    if [ "$DESTROY" = true ]; then
        if [ "$response" != "yes" ]; then
            log_info "Deployment cancelled by user"
            exit 0
        fi
    else
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Deployment cancelled by user"
            exit 0
        fi
    fi
    
    log_success "Deployment confirmed"
}

terraform_apply() {
    print_section "Terraform Apply"
    
    cd "$PROJECT_DIR"
    
    if [ "$DRY_RUN" = true ]; then
        log_info "Dry run mode - skipping apply"
        return 0
    fi
    
    if [ "$DESTROY" = true ]; then
        log_info "Applying destruction plan..."
    else
        log_info "Applying deployment plan..."
    fi
    
    if terraform apply "$PLAN_FILE"; then
        if [ "$DESTROY" = true ]; then
            log_success "Infrastructure destroyed successfully"
        else
            log_success "Infrastructure deployed successfully"
        fi
    else
        if [ "$DESTROY" = true ]; then
            log_error "Infrastructure destruction failed"
        else
            log_error "Infrastructure deployment failed"
        fi
        exit 1
    fi
}

show_outputs() {
    if [ "$DESTROY" = true ] || [ "$DRY_RUN" = true ]; then
        return 0
    fi
    
    print_section "Terraform Outputs"
    
    cd "$PROJECT_DIR"
    
    log_info "Retrieving Terraform outputs..."
    if terraform output -json > "$PROJECT_DIR/outputs.json" 2>/dev/null; then
        log_success "Outputs saved to outputs.json"
        
        # Show key outputs
        if command -v jq &> /dev/null; then
            log_info "Key deployment information:"
            
            # VPC information
            local vpc_id=$(jq -r '.vpc_infrastructure.value.vpc.id // "N/A"' "$PROJECT_DIR/outputs.json")
            local vpc_name=$(jq -r '.vpc_infrastructure.value.vpc.name // "N/A"' "$PROJECT_DIR/outputs.json")
            log_info "VPC: $vpc_name ($vpc_id)"
            
            # Instance information
            local instance_count=$(jq -r '.compute_infrastructure.value.summary.total_instances // 0' "$PROJECT_DIR/outputs.json")
            log_info "Instances deployed: $instance_count"
            
            # Cost information
            local estimated_cost=$(jq -r '.cost_tracking.value.estimated_monthly_cost.total_estimated_cost // "N/A"' "$PROJECT_DIR/outputs.json")
            log_info "Estimated monthly cost: \$${estimated_cost}"
        fi
    else
        log_warning "Failed to retrieve outputs"
    fi
}

cleanup() {
    print_section "Cleanup"
    
    cd "$PROJECT_DIR"
    
    # Remove plan file
    if [ -f "$PLAN_FILE" ]; then
        rm -f "$PLAN_FILE"
        log_info "Removed plan file"
    fi
    
    # Clean up temporary files
    find . -name ".terraform.lock.hcl.backup" -delete 2>/dev/null || true
    
    log_success "Cleanup completed"
}

generate_deployment_report() {
    print_section "Generating Deployment Report"
    
    local report_file="$PROJECT_DIR/deployment-report.json"
    local timestamp=$(date -Iseconds)
    local status="SUCCESS"
    
    if [ $? -ne 0 ]; then
        status="FAILED"
    fi
    
    cat > "$report_file" << EOF
{
    "deployment_report": {
        "timestamp": "$timestamp",
        "status": "$status",
        "operation": $([ "$DESTROY" = true ] && echo '"destroy"' || echo '"deploy"'),
        "dry_run": $DRY_RUN,
        "auto_approve": $AUTO_APPROVE,
        "project_directory": "$PROJECT_DIR",
        "configuration": {
            "skip_validation": $SKIP_VALIDATION,
            "skip_cost_check": $SKIP_COST_CHECK,
            "max_cost": $MAX_COST
        },
        "files": {
            "log_file": "$LOG_FILE",
            "cost_file": "$COST_FILE",
            "outputs_file": "$PROJECT_DIR/outputs.json"
        }
    }
}
EOF
    
    log_success "Deployment report generated: $report_file"
}

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

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
                SKIP_VALIDATION=true
                shift
                ;;
            -c|--skip-cost-check)
                SKIP_COST_CHECK=true
                shift
                ;;
            -m|--max-cost)
                MAX_COST="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    parse_arguments "$@"
    
    if [ "$DESTROY" = true ]; then
        print_header "Terraform Infrastructure Destruction - Lab 5.1"
    elif [ "$DRY_RUN" = true ]; then
        print_header "Terraform Dry Run - Lab 5.1"
    else
        print_header "Terraform Infrastructure Deployment - Lab 5.1"
    fi
    
    # Initialize log file
    echo "Deployment started at $(date)" > "$LOG_FILE"
    
    # Execute deployment steps
    check_prerequisites
    validate_configuration
    authenticate_ibm_cloud
    backup_state
    estimate_costs
    terraform_init
    terraform_plan
    confirm_deployment
    terraform_apply
    show_outputs
    cleanup
    generate_deployment_report
    
    # Final summary
    print_header "Deployment Summary"
    
    if [ "$DESTROY" = true ]; then
        log_success "Infrastructure destruction completed successfully!"
    elif [ "$DRY_RUN" = true ]; then
        log_success "Dry run completed successfully!"
        log_info "Review the plan above and run without --dry-run to deploy."
    else
        log_success "Infrastructure deployment completed successfully!"
        log_info "Your module lab environment is ready for use."
    fi
    
    log_info "Detailed log available at: $LOG_FILE"
    log_info "Deployment report available at: $PROJECT_DIR/deployment-report.json"
    
    if [ "$DRY_RUN" = false ] && [ "$DESTROY" = false ]; then
        log_info "Outputs available at: $PROJECT_DIR/outputs.json"
        log_info "Don't forget to run 'terraform destroy' when you're done with the lab!"
    fi
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
