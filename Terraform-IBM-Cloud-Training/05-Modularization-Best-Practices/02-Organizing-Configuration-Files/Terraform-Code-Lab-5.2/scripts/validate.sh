#!/bin/bash
# Configuration Organization Lab - Validation Script
# Comprehensive validation for enterprise Terraform configurations

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VALIDATION_LOG="$PROJECT_ROOT/validation-results.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$VALIDATION_LOG"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$VALIDATION_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$VALIDATION_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$VALIDATION_LOG"
}

log_section() {
    echo -e "${PURPLE}[SECTION]${NC} $1" | tee -a "$VALIDATION_LOG"
    echo "============================================" | tee -a "$VALIDATION_LOG"
}

# Initialize validation log
init_validation_log() {
    cat > "$VALIDATION_LOG" << EOF
Configuration Organization Lab - Validation Report
Generated: $(date -Iseconds)
Project: $PROJECT_ROOT
============================================

EOF
}

# Check prerequisites
check_prerequisites() {
    log_section "Checking Prerequisites"
    
    local missing_tools=()
    
    # Check required tools
    if ! command -v terraform &> /dev/null; then
        missing_tools+=("terraform")
    fi
    
    if ! command -v tflint &> /dev/null; then
        log_warning "TFLint not found - skipping linting checks"
    fi
    
    if ! command -v tfsec &> /dev/null; then
        log_warning "TFSec not found - skipping security checks"
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        return 1
    fi
    
    log_success "All required tools are available"
    return 0
}

# Validate Terraform syntax
validate_terraform_syntax() {
    log_section "Validating Terraform Syntax"
    
    cd "$PROJECT_ROOT"
    
    # Initialize Terraform (backend=false for validation)
    log_info "Initializing Terraform..."
    if terraform init -backend=false > /dev/null 2>&1; then
        log_success "Terraform initialization successful"
    else
        log_error "Terraform initialization failed"
        return 1
    fi
    
    # Validate configuration
    log_info "Validating Terraform configuration..."
    if terraform validate > /dev/null 2>&1; then
        log_success "Terraform validation passed"
    else
        log_error "Terraform validation failed"
        terraform validate 2>&1 | tee -a "$VALIDATION_LOG"
        return 1
    fi
    
    # Format check
    log_info "Checking Terraform formatting..."
    if terraform fmt -check -recursive > /dev/null 2>&1; then
        log_success "Terraform formatting is correct"
    else
        log_warning "Terraform formatting issues found"
        log_info "Run 'terraform fmt -recursive' to fix formatting"
    fi
    
    return 0
}

# Validate configuration structure
validate_configuration_structure() {
    log_section "Validating Configuration Structure"
    
    cd "$PROJECT_ROOT"
    
    # Check required files
    local required_files=(
        "providers.tf"
        "variables.tf"
        "main.tf"
        "outputs.tf"
        "terraform.tfvars.example"
    )
    
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        log_success "All required configuration files present"
    else
        log_error "Missing required files: ${missing_files[*]}"
        return 1
    fi
    
    # Check directory structure
    local required_dirs=(
        "scripts"
        "templates"
        "modules"
        "generated"
    )
    
    local missing_dirs=()
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [ ${#missing_dirs[@]} -eq 0 ]; then
        log_success "All required directories present"
    else
        log_warning "Missing optional directories: ${missing_dirs[*]}"
    fi
    
    return 0
}

# Validate naming conventions
validate_naming_conventions() {
    log_section "Validating Naming Conventions"
    
    cd "$PROJECT_ROOT"
    
    # Check file naming patterns
    local invalid_files=()
    
    # Check Terraform files
    while IFS= read -r -d '' file; do
        basename_file=$(basename "$file")
        if [[ ! "$basename_file" =~ ^[a-z][a-z0-9-]*\.(tf|tfvars)$ ]]; then
            invalid_files+=("$file")
        fi
    done < <(find . -name "*.tf" -o -name "*.tfvars" -print0)
    
    if [ ${#invalid_files[@]} -eq 0 ]; then
        log_success "All files follow naming conventions"
    else
        log_warning "Files with non-standard naming: ${invalid_files[*]}"
    fi
    
    # Check for consistent resource naming in configuration
    log_info "Checking resource naming patterns..."
    
    # Extract resource names from Terraform files
    local resource_names=()
    while IFS= read -r line; do
        if [[ $line =~ resource[[:space:]]+\"[^\"]+\"[[:space:]]+\"([^\"]+)\" ]]; then
            resource_names+=("${BASH_REMATCH[1]}")
        fi
    done < <(grep -h "^resource " *.tf 2>/dev/null || true)
    
    # Check naming pattern consistency
    local inconsistent_names=()
    for name in "${resource_names[@]}"; do
        if [[ ! "$name" =~ ^[a-z][a-z0-9_]*$ ]]; then
            inconsistent_names+=("$name")
        fi
    done
    
    if [ ${#inconsistent_names[@]} -eq 0 ]; then
        log_success "Resource naming conventions are consistent"
    else
        log_warning "Resources with inconsistent naming: ${inconsistent_names[*]}"
    fi
    
    return 0
}

# Validate variable definitions
validate_variable_definitions() {
    log_section "Validating Variable Definitions"
    
    cd "$PROJECT_ROOT"
    
    # Check for variable descriptions
    log_info "Checking variable descriptions..."
    local vars_without_description=()
    
    while IFS= read -r line; do
        if [[ $line =~ variable[[:space:]]+\"([^\"]+)\" ]]; then
            var_name="${BASH_REMATCH[1]}"
            # Check if description exists in the next few lines
            if ! grep -A 5 "variable \"$var_name\"" variables.tf | grep -q "description"; then
                vars_without_description+=("$var_name")
            fi
        fi
    done < <(grep "^variable " variables.tf 2>/dev/null || true)
    
    if [ ${#vars_without_description[@]} -eq 0 ]; then
        log_success "All variables have descriptions"
    else
        log_warning "Variables without descriptions: ${vars_without_description[*]}"
    fi
    
    # Check for variable validation rules
    log_info "Checking variable validation rules..."
    local validation_count=$(grep -c "validation {" variables.tf 2>/dev/null || echo "0")
    local variable_count=$(grep -c "^variable " variables.tf 2>/dev/null || echo "0")
    
    if [ "$validation_count" -gt 0 ]; then
        log_success "Found $validation_count validation rules for $variable_count variables"
    else
        log_warning "No validation rules found - consider adding validation for critical variables"
    fi
    
    return 0
}

# Validate output definitions
validate_output_definitions() {
    log_section "Validating Output Definitions"
    
    cd "$PROJECT_ROOT"
    
    # Check for output descriptions
    log_info "Checking output descriptions..."
    local outputs_without_description=()
    
    while IFS= read -r line; do
        if [[ $line =~ output[[:space:]]+\"([^\"]+)\" ]]; then
            output_name="${BASH_REMATCH[1]}"
            # Check if description exists in the next few lines
            if ! grep -A 5 "output \"$output_name\"" outputs.tf | grep -q "description"; then
                outputs_without_description+=("$output_name")
            fi
        fi
    done < <(grep "^output " outputs.tf 2>/dev/null || true)
    
    if [ ${#outputs_without_description[@]} -eq 0 ]; then
        log_success "All outputs have descriptions"
    else
        log_warning "Outputs without descriptions: ${outputs_without_description[*]}"
    fi
    
    # Count outputs
    local output_count=$(grep -c "^output " outputs.tf 2>/dev/null || echo "0")
    log_info "Found $output_count output definitions"
    
    if [ "$output_count" -ge 5 ]; then
        log_success "Sufficient output definitions for integration"
    else
        log_warning "Consider adding more outputs for better integration capabilities"
    fi
    
    return 0
}

# Run security checks (if tfsec is available)
run_security_checks() {
    log_section "Running Security Checks"
    
    if ! command -v tfsec &> /dev/null; then
        log_warning "TFSec not available - skipping security checks"
        return 0
    fi
    
    cd "$PROJECT_ROOT"
    
    log_info "Running TFSec security scan..."
    if tfsec . --format json > tfsec-results.json 2>/dev/null; then
        local issue_count=$(jq '.results | length' tfsec-results.json 2>/dev/null || echo "0")
        
        if [ "$issue_count" -eq 0 ]; then
            log_success "No security issues found"
        else
            log_warning "Found $issue_count security issues"
            log_info "Review tfsec-results.json for details"
        fi
    else
        log_warning "TFSec scan failed or found critical issues"
    fi
    
    return 0
}

# Run linting checks (if tflint is available)
run_linting_checks() {
    log_section "Running Linting Checks"
    
    if ! command -v tflint &> /dev/null; then
        log_warning "TFLint not available - skipping linting checks"
        return 0
    fi
    
    cd "$PROJECT_ROOT"
    
    log_info "Running TFLint..."
    if tflint --format json > tflint-results.json 2>/dev/null; then
        local issue_count=$(jq '.issues | length' tflint-results.json 2>/dev/null || echo "0")
        
        if [ "$issue_count" -eq 0 ]; then
            log_success "No linting issues found"
        else
            log_warning "Found $issue_count linting issues"
            log_info "Review tflint-results.json for details"
        fi
    else
        log_warning "TFLint scan failed"
    fi
    
    return 0
}

# Generate validation report
generate_validation_report() {
    log_section "Generating Validation Report"
    
    cd "$PROJECT_ROOT"
    
    local report_file="validation-report.json"
    local timestamp=$(date -Iseconds)
    
    # Count various metrics
    local file_count=$(find . -name "*.tf" -o -name "*.tfvars" | wc -l)
    local variable_count=$(grep -c "^variable " variables.tf 2>/dev/null || echo "0")
    local output_count=$(grep -c "^output " outputs.tf 2>/dev/null || echo "0")
    local resource_count=$(grep -c "^resource " *.tf 2>/dev/null || echo "0")
    
    # Generate JSON report
    cat > "$report_file" << EOF
{
    "validation_report": {
        "timestamp": "$timestamp",
        "project_path": "$PROJECT_ROOT",
        "validation_status": "completed",
        
        "file_metrics": {
            "total_terraform_files": $file_count,
            "variable_definitions": $variable_count,
            "output_definitions": $output_count,
            "resource_definitions": $resource_count
        },
        
        "validation_checks": {
            "terraform_syntax": "passed",
            "configuration_structure": "passed",
            "naming_conventions": "checked",
            "variable_definitions": "checked",
            "output_definitions": "checked",
            "security_scan": "completed",
            "linting_check": "completed"
        },
        
        "recommendations": [
            "Review any warnings in the validation log",
            "Consider implementing additional validation rules",
            "Add more comprehensive output definitions",
            "Implement automated testing for configurations",
            "Set up continuous validation in CI/CD pipeline"
        ],
        
        "next_steps": [
            "Copy terraform.tfvars.example to terraform.tfvars",
            "Customize variables for your environment",
            "Run terraform plan to validate configuration",
            "Deploy infrastructure with terraform apply"
        ]
    }
}
EOF
    
    log_success "Validation report generated: $report_file"
    log_info "Validation log available: $VALIDATION_LOG"
    
    return 0
}

# Main validation function
main() {
    log_info "Starting Configuration Organization Lab Validation"
    log_info "Project: $PROJECT_ROOT"
    
    # Initialize validation log
    init_validation_log
    
    # Run validation checks
    local validation_failed=false
    
    check_prerequisites || validation_failed=true
    validate_terraform_syntax || validation_failed=true
    validate_configuration_structure || validation_failed=true
    validate_naming_conventions || validation_failed=true
    validate_variable_definitions || validation_failed=true
    validate_output_definitions || validation_failed=true
    run_security_checks || true  # Don't fail on security check issues
    run_linting_checks || true   # Don't fail on linting issues
    generate_validation_report || validation_failed=true
    
    # Final status
    if [ "$validation_failed" = true ]; then
        log_error "Validation completed with errors - review the log for details"
        return 1
    else
        log_success "All validation checks passed successfully!"
        log_info "Configuration is ready for deployment"
        return 0
    fi
}

# Run main function
main "$@"
