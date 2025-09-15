#!/bin/bash

# Git Collaboration Lab - Deployment Script
# Automated deployment script with Git workflow integration

set -euo pipefail

# =============================================================================
# CONFIGURATION AND VARIABLES
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_ROOT}/deployment.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Default values
ENVIRONMENT="${ENVIRONMENT:-development}"
WORKFLOW_PATTERN="${WORKFLOW_PATTERN:-gitflow}"
DRY_RUN="${DRY_RUN:-false}"
SKIP_VALIDATION="${SKIP_VALIDATION:-false}"
AUTO_APPROVE="${AUTO_APPROVE:-false}"
VERBOSE="${VERBOSE:-false}"

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
    echo -e "${TIMESTAMP} - $1" | tee -a "$LOG_FILE"
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

show_usage() {
    cat << EOF
Git Collaboration Lab - Deployment Script

Usage: $0 [OPTIONS]

OPTIONS:
    -e, --environment ENVIRONMENT    Target environment (development, staging, production)
    -w, --workflow PATTERN          Git workflow pattern (gitflow, github-flow, gitlab-flow)
    -d, --dry-run                   Perform dry run without applying changes
    -s, --skip-validation           Skip validation steps
    -a, --auto-approve              Auto-approve Terraform apply
    -v, --verbose                   Enable verbose output
    -h, --help                      Show this help message

EXAMPLES:
    $0 --environment development --workflow gitflow
    $0 --environment staging --dry-run
    $0 --environment production --auto-approve

ENVIRONMENT VARIABLES:
    IBMCLOUD_API_KEY               IBM Cloud API key (required)
    TF_VAR_ibmcloud_api_key       Terraform variable for IBM Cloud API key
    ENVIRONMENT                    Target environment
    WORKFLOW_PATTERN              Git workflow pattern
    DRY_RUN                       Enable dry run mode
    SKIP_VALIDATION               Skip validation steps
    AUTO_APPROVE                  Auto-approve Terraform apply
    VERBOSE                       Enable verbose output

EOF
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check required tools
    local required_tools=("terraform" "git" "jq" "curl")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "Required tool '$tool' is not installed"
            exit 1
        fi
    done
    
    # Check IBM Cloud CLI (optional but recommended)
    if ! command -v "ibmcloud" &> /dev/null; then
        log_warning "IBM Cloud CLI is not installed - some features may be limited"
    fi
    
    # Check API key
    if [[ -z "${IBMCLOUD_API_KEY:-}" && -z "${TF_VAR_ibmcloud_api_key:-}" ]]; then
        log_error "IBM Cloud API key not found. Set IBMCLOUD_API_KEY or TF_VAR_ibmcloud_api_key environment variable"
        exit 1
    fi
    
    # Check Terraform configuration
    if [[ ! -f "${PROJECT_ROOT}/main.tf" ]]; then
        log_error "Terraform configuration not found in ${PROJECT_ROOT}"
        exit 1
    fi
    
    log_success "Prerequisites check completed"
}

validate_git_workflow() {
    log_info "Validating Git workflow configuration..."
    
    # Check if we're in a Git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_warning "Not in a Git repository - some workflow features may be limited"
        return 0
    fi
    
    # Get current branch
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    log_info "Current branch: $current_branch"
    
    # Validate branch based on workflow pattern
    case "$WORKFLOW_PATTERN" in
        "gitflow")
            if [[ ! "$current_branch" =~ ^(main|develop|feature/.*|release/.*|hotfix/.*)$ ]]; then
                log_warning "Current branch '$current_branch' doesn't follow GitFlow naming convention"
            fi
            ;;
        "github-flow")
            if [[ "$current_branch" == "main" && "$ENVIRONMENT" != "production" ]]; then
                log_warning "Deploying from main branch to non-production environment"
            fi
            ;;
        "gitlab-flow")
            if [[ ! "$current_branch" =~ ^(main|$ENVIRONMENT|feature/.*)$ ]]; then
                log_warning "Current branch '$current_branch' doesn't follow GitLab Flow for environment '$ENVIRONMENT'"
            fi
            ;;
        "trunk-based")
            if [[ "$current_branch" != "main" ]]; then
                log_warning "Trunk-based development should deploy from main branch"
            fi
            ;;
    esac
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        log_warning "Uncommitted changes detected - consider committing before deployment"
    fi
    
    log_success "Git workflow validation completed"
}

validate_terraform() {
    log_info "Validating Terraform configuration..."
    
    cd "$PROJECT_ROOT"
    
    # Format check
    if ! terraform fmt -check=true -diff=true; then
        log_error "Terraform formatting issues detected. Run 'terraform fmt' to fix"
        if [[ "$SKIP_VALIDATION" != "true" ]]; then
            exit 1
        fi
    fi
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    if [[ "$VERBOSE" == "true" ]]; then
        terraform init
    else
        terraform init > /dev/null
    fi
    
    # Validate configuration
    log_info "Validating Terraform configuration..."
    if ! terraform validate; then
        log_error "Terraform validation failed"
        if [[ "$SKIP_VALIDATION" != "true" ]]; then
            exit 1
        fi
    fi
    
    log_success "Terraform validation completed"
}

run_security_scan() {
    log_info "Running security scan..."
    
    cd "$PROJECT_ROOT"
    
    # Check if tfsec is available
    if command -v tfsec &> /dev/null; then
        log_info "Running tfsec security scan..."
        if ! tfsec . --format json > tfsec-results.json; then
            log_warning "tfsec scan found security issues - check tfsec-results.json"
        else
            log_success "tfsec security scan passed"
        fi
    else
        log_warning "tfsec not installed - skipping security scan"
    fi
    
    # Check if checkov is available
    if command -v checkov &> /dev/null; then
        log_info "Running Checkov security scan..."
        if ! checkov -d . --framework terraform --output json > checkov-results.json; then
            log_warning "Checkov scan found security issues - check checkov-results.json"
        else
            log_success "Checkov security scan passed"
        fi
    else
        log_warning "Checkov not installed - skipping security scan"
    fi
}

run_cost_analysis() {
    log_info "Running cost analysis..."
    
    cd "$PROJECT_ROOT"
    
    # Check if Infracost is available
    if command -v infracost &> /dev/null; then
        log_info "Running Infracost analysis..."
        if infracost breakdown --path . --format json > infracost-results.json; then
            # Extract cost information
            local monthly_cost
            monthly_cost=$(jq -r '.totalMonthlyCost // "0"' infracost-results.json)
            log_info "Estimated monthly cost: \$${monthly_cost}"
            
            # Check against budget threshold (example: $1000)
            local budget_threshold=1000
            if (( $(echo "$monthly_cost > $budget_threshold" | bc -l) )); then
                log_warning "Estimated cost (\$${monthly_cost}) exceeds budget threshold (\$${budget_threshold})"
            else
                log_success "Cost analysis passed - within budget"
            fi
        else
            log_warning "Infracost analysis failed"
        fi
    else
        log_warning "Infracost not installed - skipping cost analysis"
    fi
}

plan_deployment() {
    log_info "Planning Terraform deployment..."
    
    cd "$PROJECT_ROOT"
    
    # Set environment-specific variables
    export TF_VAR_environment="$ENVIRONMENT"
    export TF_VAR_workflow_pattern="$WORKFLOW_PATTERN"
    
    # Create plan
    local plan_file="terraform-${ENVIRONMENT}.tfplan"
    local plan_args=("-out=$plan_file")
    
    if [[ "$VERBOSE" == "true" ]]; then
        plan_args+=("-detailed-exitcode")
    fi
    
    if terraform plan "${plan_args[@]}"; then
        log_success "Terraform plan completed successfully"
        
        # Show plan summary
        log_info "Plan summary:"
        terraform show -json "$plan_file" | jq -r '.planned_values.root_module.resources[] | "\(.type).\(.name)"' | sort | uniq -c
        
        return 0
    else
        local exit_code=$?
        if [[ $exit_code -eq 2 ]]; then
            log_info "Terraform plan completed with changes"
            return 0
        else
            log_error "Terraform plan failed"
            return 1
        fi
    fi
}

apply_deployment() {
    log_info "Applying Terraform deployment..."
    
    cd "$PROJECT_ROOT"
    
    local plan_file="terraform-${ENVIRONMENT}.tfplan"
    local apply_args=("$plan_file")
    
    if [[ "$AUTO_APPROVE" == "true" ]]; then
        apply_args=("-auto-approve")
    fi
    
    if terraform apply "${apply_args[@]}"; then
        log_success "Terraform apply completed successfully"
        
        # Save outputs
        terraform output -json > "terraform-outputs-${ENVIRONMENT}.json"
        log_info "Outputs saved to terraform-outputs-${ENVIRONMENT}.json"
        
        return 0
    else
        log_error "Terraform apply failed"
        return 1
    fi
}

cleanup() {
    log_info "Cleaning up temporary files..."
    
    cd "$PROJECT_ROOT"
    
    # Remove plan files
    rm -f terraform-*.tfplan
    
    # Remove temporary scan results (optional)
    if [[ "${KEEP_SCAN_RESULTS:-false}" != "true" ]]; then
        rm -f tfsec-results.json checkov-results.json infracost-results.json
    fi
    
    log_success "Cleanup completed"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    log_info "Starting Git Collaboration Lab deployment"
    log_info "Environment: $ENVIRONMENT"
    log_info "Workflow Pattern: $WORKFLOW_PATTERN"
    log_info "Dry Run: $DRY_RUN"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -w|--workflow)
                WORKFLOW_PATTERN="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN="true"
                shift
                ;;
            -s|--skip-validation)
                SKIP_VALIDATION="true"
                shift
                ;;
            -a|--auto-approve)
                AUTO_APPROVE="true"
                shift
                ;;
            -v|--verbose)
                VERBOSE="true"
                shift
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
    
    # Trap for cleanup
    trap cleanup EXIT
    
    # Execute deployment steps
    check_prerequisites
    validate_git_workflow
    
    if [[ "$SKIP_VALIDATION" != "true" ]]; then
        validate_terraform
        run_security_scan
        run_cost_analysis
    fi
    
    if ! plan_deployment; then
        log_error "Deployment planning failed"
        exit 1
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry run completed - no changes applied"
        exit 0
    fi
    
    if ! apply_deployment; then
        log_error "Deployment failed"
        exit 1
    fi
    
    log_success "Git Collaboration Lab deployment completed successfully"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
