#!/bin/bash
# =============================================================================
# TERRAFORM VALIDATION SCRIPT
# =============================================================================
# Terraform Code Lab 5.1: Creating Reusable Modules
# This script performs comprehensive validation of Terraform configuration
# including syntax, formatting, security, and best practices.

set -euo pipefail

# =============================================================================
# CONFIGURATION AND VARIABLES
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_DIR/validation.log"
EXIT_CODE=0

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
    EXIT_CODE=1
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

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

check_prerequisites() {
    print_section "Checking Prerequisites"
    
    local missing_tools=()
    
    # Check required tools
    local tools=("terraform" "tflint" "tfsec" "jq")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        else
            log_success "$tool is installed"
        fi
    done
    
    # Install missing tools if possible
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_warning "Missing tools: ${missing_tools[*]}"
        
        # Try to install missing tools
        for tool in "${missing_tools[@]}"; do
            case "$tool" in
                "tflint")
                    log_info "Installing tflint..."
                    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash || log_error "Failed to install tflint"
                    ;;
                "tfsec")
                    log_info "Installing tfsec..."
                    curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash || log_error "Failed to install tfsec"
                    ;;
                "jq")
                    log_info "Installing jq..."
                    sudo apt-get update && sudo apt-get install -y jq || log_error "Failed to install jq"
                    ;;
                *)
                    log_error "$tool is required but not installed"
                    ;;
            esac
        done
    fi
}

validate_terraform_syntax() {
    print_section "Terraform Syntax Validation"
    
    cd "$PROJECT_DIR"
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    if terraform init -backend=false > /dev/null 2>&1; then
        log_success "Terraform initialization successful"
    else
        log_error "Terraform initialization failed"
        return 1
    fi
    
    # Validate configuration
    log_info "Validating Terraform configuration..."
    if terraform validate; then
        log_success "Terraform configuration is valid"
    else
        log_error "Terraform configuration validation failed"
        return 1
    fi
    
    # Check formatting
    log_info "Checking Terraform formatting..."
    if terraform fmt -check -recursive; then
        log_success "Terraform formatting is correct"
    else
        log_warning "Terraform formatting issues found. Run 'terraform fmt -recursive' to fix."
    fi
}

validate_with_tflint() {
    print_section "TFLint Validation"
    
    cd "$PROJECT_DIR"
    
    # Initialize tflint
    log_info "Initializing tflint..."
    if tflint --init > /dev/null 2>&1; then
        log_success "TFLint initialization successful"
    else
        log_warning "TFLint initialization failed, continuing with default rules"
    fi
    
    # Run tflint
    log_info "Running tflint analysis..."
    if tflint --format=compact; then
        log_success "TFLint analysis passed"
    else
        log_warning "TFLint found issues (see output above)"
    fi
}

validate_security_with_tfsec() {
    print_section "Security Validation with tfsec"
    
    cd "$PROJECT_DIR"
    
    log_info "Running tfsec security analysis..."
    if tfsec --format=table --no-color .; then
        log_success "tfsec security analysis passed"
    else
        log_warning "tfsec found security issues (see output above)"
    fi
}

validate_variables() {
    print_section "Variables Validation"
    
    cd "$PROJECT_DIR"
    
    # Check if variables.tf exists
    if [ ! -f "variables.tf" ]; then
        log_error "variables.tf file not found"
        return 1
    fi
    
    log_success "variables.tf file exists"
    
    # Check for required variables
    local required_vars=("primary_region" "resource_group_name" "organization_config" "vpc_configuration")
    for var in "${required_vars[@]}"; do
        if grep -q "variable \"$var\"" variables.tf; then
            log_success "Required variable '$var' is defined"
        else
            log_error "Required variable '$var' is missing"
        fi
    done
    
    # Check for variable descriptions
    log_info "Checking variable descriptions..."
    local vars_without_desc=$(grep -c "variable " variables.tf)
    local vars_with_desc=$(grep -A 5 "variable " variables.tf | grep -c "description")
    
    if [ "$vars_without_desc" -eq "$vars_with_desc" ]; then
        log_success "All variables have descriptions"
    else
        log_warning "Some variables are missing descriptions"
    fi
    
    # Check for variable validation
    log_info "Checking variable validation rules..."
    if grep -q "validation {" variables.tf; then
        log_success "Variable validation rules found"
    else
        log_warning "No variable validation rules found"
    fi
}

validate_outputs() {
    print_section "Outputs Validation"
    
    cd "$PROJECT_DIR"
    
    # Check if outputs.tf exists
    if [ ! -f "outputs.tf" ]; then
        log_error "outputs.tf file not found"
        return 1
    fi
    
    log_success "outputs.tf file exists"
    
    # Check for required outputs
    local required_outputs=("vpc_infrastructure" "integration_endpoints" "cost_tracking" "module_metadata")
    for output in "${required_outputs[@]}"; do
        if grep -q "output \"$output\"" outputs.tf; then
            log_success "Required output '$output' is defined"
        else
            log_error "Required output '$output' is missing"
        fi
    done
    
    # Check for output descriptions
    log_info "Checking output descriptions..."
    local outputs_without_desc=$(grep -c "output " outputs.tf)
    local outputs_with_desc=$(grep -A 5 "output " outputs.tf | grep -c "description")
    
    if [ "$outputs_without_desc" -eq "$outputs_with_desc" ]; then
        log_success "All outputs have descriptions"
    else
        log_warning "Some outputs are missing descriptions"
    fi
}

validate_providers() {
    print_section "Providers Validation"
    
    cd "$PROJECT_DIR"
    
    # Check if providers.tf exists
    if [ ! -f "providers.tf" ]; then
        log_error "providers.tf file not found"
        return 1
    fi
    
    log_success "providers.tf file exists"
    
    # Check for required providers
    local required_providers=("ibm" "random" "time" "local")
    for provider in "${required_providers[@]}"; do
        if grep -q "source.*$provider" providers.tf; then
            log_success "Required provider '$provider' is configured"
        else
            log_error "Required provider '$provider' is missing"
        fi
    done
    
    # Check for version constraints
    log_info "Checking provider version constraints..."
    if grep -q "version.*~>" providers.tf; then
        log_success "Provider version constraints found"
    else
        log_warning "No provider version constraints found"
    fi
}

validate_best_practices() {
    print_section "Best Practices Validation"
    
    cd "$PROJECT_DIR"
    
    # Check for consistent naming
    log_info "Checking naming conventions..."
    if grep -q "local.name_prefix" *.tf; then
        log_success "Consistent naming pattern found"
    else
        log_warning "No consistent naming pattern found"
    fi
    
    # Check for tagging
    log_info "Checking resource tagging..."
    if grep -q "tags.*=" *.tf; then
        log_success "Resource tagging found"
    else
        log_warning "No resource tagging found"
    fi
    
    # Check for comments
    log_info "Checking code documentation..."
    local comment_lines=$(grep -c "^#" *.tf || echo "0")
    local total_lines=$(wc -l *.tf | tail -1 | awk '{print $1}')
    local comment_ratio=$((comment_lines * 100 / total_lines))
    
    if [ "$comment_ratio" -ge 20 ]; then
        log_success "Good code documentation (${comment_ratio}% comments)"
    else
        log_warning "Low code documentation (${comment_ratio}% comments, recommended: 20%+)"
    fi
    
    # Check for sensitive data
    log_info "Checking for sensitive data exposure..."
    if grep -i "password\|secret\|key" *.tf | grep -v "sensitive.*=.*true"; then
        log_warning "Potential sensitive data found without sensitive flag"
    else
        log_success "No exposed sensitive data found"
    fi
}

validate_example_files() {
    print_section "Example Files Validation"
    
    cd "$PROJECT_DIR"
    
    # Check for terraform.tfvars.example
    if [ -f "terraform.tfvars.example" ]; then
        log_success "terraform.tfvars.example file exists"
        
        # Check if example file has all required variables
        log_info "Checking example file completeness..."
        local missing_vars=()
        while IFS= read -r line; do
            if [[ $line =~ ^variable[[:space:]]+\"([^\"]+)\" ]]; then
                var_name="${BASH_REMATCH[1]}"
                if ! grep -q "^$var_name\|^#.*$var_name" terraform.tfvars.example; then
                    missing_vars+=("$var_name")
                fi
            fi
        done < variables.tf
        
        if [ ${#missing_vars[@]} -eq 0 ]; then
            log_success "All variables have examples"
        else
            log_warning "Missing examples for variables: ${missing_vars[*]}"
        fi
    else
        log_error "terraform.tfvars.example file not found"
    fi
    
    # Check for README.md
    if [ -f "README.md" ]; then
        log_success "README.md file exists"
    else
        log_warning "README.md file not found"
    fi
}

validate_file_structure() {
    print_section "File Structure Validation"
    
    cd "$PROJECT_DIR"
    
    # Check for required files
    local required_files=("main.tf" "variables.tf" "outputs.tf" "providers.tf")
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            log_success "Required file '$file' exists"
        else
            log_error "Required file '$file' is missing"
        fi
    done
    
    # Check for recommended directories
    local recommended_dirs=("scripts" "templates")
    for dir in "${recommended_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_success "Recommended directory '$dir' exists"
        else
            log_warning "Recommended directory '$dir' is missing"
        fi
    done
    
    # Check file sizes (warn if too large)
    log_info "Checking file sizes..."
    for file in *.tf; do
        if [ -f "$file" ]; then
            local size=$(wc -l < "$file")
            if [ "$size" -gt 500 ]; then
                log_warning "$file is large ($size lines). Consider splitting into smaller files."
            else
                log_success "$file size is reasonable ($size lines)"
            fi
        fi
    done
}

generate_validation_report() {
    print_section "Generating Validation Report"
    
    local report_file="$PROJECT_DIR/validation-report.json"
    local timestamp=$(date -Iseconds)
    
    cat > "$report_file" << EOF
{
    "validation_report": {
        "timestamp": "$timestamp",
        "project_directory": "$PROJECT_DIR",
        "exit_code": $EXIT_CODE,
        "status": $([ $EXIT_CODE -eq 0 ] && echo '"PASSED"' || echo '"FAILED"'),
        "checks_performed": [
            "prerequisites",
            "terraform_syntax",
            "tflint_analysis",
            "security_scan",
            "variables_validation",
            "outputs_validation",
            "providers_validation",
            "best_practices",
            "example_files",
            "file_structure"
        ],
        "recommendations": [
            "Run 'terraform fmt -recursive' to fix formatting issues",
            "Add variable validation rules for better error handling",
            "Ensure all outputs have meaningful descriptions",
            "Add comprehensive comments for complex logic",
            "Review security scan results and address findings"
        ],
        "next_steps": [
            "Run 'terraform plan' to validate resource creation",
            "Execute integration tests with real IBM Cloud resources",
            "Review cost estimates before deployment",
            "Update documentation with any configuration changes"
        ]
    }
}
EOF
    
    log_success "Validation report generated: $report_file"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    print_header "Terraform Module Validation - Lab 5.1"
    
    # Initialize log file
    echo "Validation started at $(date)" > "$LOG_FILE"
    
    # Run validation checks
    check_prerequisites
    validate_terraform_syntax
    validate_with_tflint
    validate_security_with_tfsec
    validate_variables
    validate_outputs
    validate_providers
    validate_best_practices
    validate_example_files
    validate_file_structure
    
    # Generate report
    generate_validation_report
    
    # Final summary
    print_header "Validation Summary"
    
    if [ $EXIT_CODE -eq 0 ]; then
        log_success "All validation checks passed successfully!"
        log_info "Your Terraform module is ready for deployment."
    else
        log_error "Some validation checks failed."
        log_info "Please review the errors above and fix them before proceeding."
    fi
    
    log_info "Detailed log available at: $LOG_FILE"
    log_info "Validation report available at: $PROJECT_DIR/validation-report.json"
    
    exit $EXIT_CODE
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
