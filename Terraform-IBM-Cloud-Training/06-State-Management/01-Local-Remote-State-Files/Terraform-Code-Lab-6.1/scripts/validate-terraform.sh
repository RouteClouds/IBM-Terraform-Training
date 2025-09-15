#!/bin/bash
# =============================================================================
# TERRAFORM VALIDATION SCRIPT
# Subtopic 6.1: Local and Remote State Files
# Comprehensive validation for Terraform configuration and state
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

validate_terraform_installation() {
    log "Validating Terraform installation..."
    
    if ! command -v terraform &> /dev/null; then
        error "Terraform is not installed or not in PATH"
        return 1
    fi
    
    local version=$(terraform version -json | jq -r '.terraform_version')
    success "Terraform version: $version"
    
    # Check minimum version requirement
    if [[ $(echo "$version 1.5.0" | tr " " "\n" | sort -V | head -n1) != "1.5.0" ]]; then
        warning "Terraform version $version may not meet minimum requirements (1.5.0+)"
    fi
}

validate_configuration() {
    log "Validating Terraform configuration..."
    
    # Check for required files
    local required_files=("providers.tf" "variables.tf" "main.tf" "outputs.tf")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "Required file missing: $file"
            return 1
        fi
        success "Found required file: $file"
    done
    
    # Validate syntax
    if terraform validate; then
        success "Configuration syntax is valid"
    else
        error "Configuration validation failed"
        return 1
    fi
    
    # Check for terraform.tfvars
    if [[ -f "terraform.tfvars" ]]; then
        success "Found terraform.tfvars configuration file"
    else
        warning "No terraform.tfvars file found. Using terraform.tfvars.example as reference."
    fi
}

validate_formatting() {
    log "Checking Terraform formatting..."
    
    if terraform fmt -check -recursive; then
        success "All files are properly formatted"
    else
        warning "Some files need formatting. Run 'terraform fmt -recursive' to fix."
    fi
}

validate_state() {
    log "Validating Terraform state..."
    
    if [[ -f "terraform.tfstate" ]]; then
        success "Local state file found"
        
        # Check state file integrity
        if terraform state list &> /dev/null; then
            local resource_count=$(terraform state list | wc -l)
            success "State contains $resource_count resources"
        else
            error "State file appears to be corrupted"
            return 1
        fi
        
        # Check for state backup
        if [[ -f "terraform.tfstate.backup" ]]; then
            success "State backup file found"
        else
            warning "No state backup file found"
        fi
    else
        warning "No local state file found (may be using remote backend)"
    fi
}

validate_backend_configuration() {
    log "Validating backend configuration..."
    
    # Check if backend is configured
    if grep -q "backend" providers.tf; then
        if grep -q "^[[:space:]]*#" providers.tf | grep -q "backend"; then
            warning "Backend configuration is commented out"
        else
            success "Backend configuration is active"
        fi
    else
        warning "No backend configuration found in providers.tf"
    fi
    
    # Check for generated backend file
    if [[ -f "generated_backend.tf" ]]; then
        success "Generated backend configuration found"
    fi
}

validate_variables() {
    log "Validating variable configuration..."
    
    # Check for required variables
    local required_vars=("ibm_api_key" "primary_region" "project_name")
    
    if [[ -f "terraform.tfvars" ]]; then
        for var in "${required_vars[@]}"; do
            if grep -q "^$var" terraform.tfvars; then
                success "Required variable configured: $var"
            else
                error "Required variable missing: $var"
            fi
        done
    else
        warning "No terraform.tfvars file found. Cannot validate variable configuration."
    fi
}

validate_security() {
    log "Performing security validation..."
    
    # Check for hardcoded secrets
    local secret_patterns=("password" "secret" "key" "token")
    local found_secrets=false
    
    for pattern in "${secret_patterns[@]}"; do
        if grep -r -i "$pattern" *.tf 2>/dev/null | grep -v "variable\|description\|#"; then
            warning "Potential hardcoded secret found containing '$pattern'"
            found_secrets=true
        fi
    done
    
    if [[ "$found_secrets" == false ]]; then
        success "No obvious hardcoded secrets found"
    fi
    
    # Check for sensitive variable marking
    if grep -q "sensitive.*=.*true" variables.tf; then
        success "Sensitive variables are properly marked"
    else
        warning "Consider marking sensitive variables with 'sensitive = true'"
    fi
}

validate_cost_optimization() {
    log "Validating cost optimization settings..."
    
    # Check for cost-optimized defaults
    local cost_checks=(
        "auto_delete_volume.*=.*true"
        "plan.*=.*lite"
        "storage_class.*=.*standard"
    )
    
    for check in "${cost_checks[@]}"; do
        if grep -q "$check" *.tf; then
            success "Cost optimization setting found: $check"
        fi
    done
    
    # Check for budget configuration
    if grep -q "budget_alert_threshold" variables.tf; then
        success "Budget alert configuration found"
    else
        warning "Consider adding budget alert configuration"
    fi
}

validate_documentation() {
    log "Validating documentation..."
    
    # Check for README
    if [[ -f "README.md" ]]; then
        success "README.md documentation found"
    else
        warning "No README.md file found"
    fi
    
    # Check for comments in code
    local comment_count=$(grep -c "#" *.tf | awk -F: '{sum += $2} END {print sum}')
    if [[ $comment_count -gt 50 ]]; then
        success "Good code documentation with $comment_count comments"
    else
        warning "Consider adding more comments for better documentation"
    fi
}

run_plan_validation() {
    log "Running terraform plan validation..."
    
    if [[ ! -f "terraform.tfvars" ]]; then
        warning "Skipping plan validation - no terraform.tfvars file"
        return 0
    fi
    
    # Initialize if needed
    if [[ ! -d ".terraform" ]]; then
        log "Initializing Terraform..."
        terraform init
    fi
    
    # Run plan with detailed exit code
    terraform plan -detailed-exitcode -out=validation.tfplan
    local plan_exit=$?
    
    case $plan_exit in
        0)
            success "No changes needed - infrastructure matches configuration"
            ;;
        1)
            error "Plan failed - check configuration and credentials"
            return 1
            ;;
        2)
            warning "Changes detected - review plan output carefully"
            ;;
    esac
    
    # Clean up plan file
    rm -f validation.tfplan
}

# =============================================================================
# MAIN VALIDATION EXECUTION
# =============================================================================

main() {
    log "Starting comprehensive Terraform validation..."
    echo "=============================================="
    
    local validation_functions=(
        "validate_terraform_installation"
        "validate_configuration"
        "validate_formatting"
        "validate_state"
        "validate_backend_configuration"
        "validate_variables"
        "validate_security"
        "validate_cost_optimization"
        "validate_documentation"
        "run_plan_validation"
    )
    
    local failed_validations=0
    
    for func in "${validation_functions[@]}"; do
        echo ""
        if ! $func; then
            ((failed_validations++))
        fi
    done
    
    echo ""
    echo "=============================================="
    
    if [[ $failed_validations -eq 0 ]]; then
        success "All validations passed successfully!"
        log "Terraform configuration is ready for deployment"
        exit 0
    else
        error "$failed_validations validation(s) failed"
        log "Please address the issues above before proceeding"
        exit 1
    fi
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Check if running in correct directory
if [[ ! -f "providers.tf" ]]; then
    error "This script must be run from the Terraform configuration directory"
    error "Expected to find providers.tf in current directory"
    exit 1
fi

# Run main validation
main "$@"
