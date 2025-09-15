#!/bin/bash

# =============================================================================
# TERRAFORM VALIDATION SCRIPT
# Lab 3.1: Directory Structure and Configuration Files
# =============================================================================
#
# This script performs comprehensive validation of the Terraform configuration
# including syntax checking, formatting verification, security scanning, and
# best practices validation.
#
# Usage:
#   ./validate.sh [options]
#
# Options:
#   --init      Run terraform init before validation
#   --format    Run terraform fmt to fix formatting
#   --plan      Generate and display execution plan
#   --security  Run security scanning (if tfsec is available)
#   --all       Run all validation checks
#   --help      Display this help message
#
# Exit codes:
#   0 - All validations passed
#   1 - Validation failures detected
#   2 - Missing dependencies or configuration errors
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_VERSION_REQUIRED="1.5.0"
VALIDATION_PASSED=true

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_success() {
    print_status "$GREEN" "✅ $1"
}

print_error() {
    print_status "$RED" "❌ $1"
    VALIDATION_PASSED=false
}

print_warning() {
    print_status "$YELLOW" "⚠️  $1"
}

print_info() {
    print_status "$BLUE" "ℹ️  $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to compare versions
version_compare() {
    local version1=$1
    local version2=$2
    
    if [[ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n1)" == "$version2" ]]; then
        return 0  # version1 >= version2
    else
        return 1  # version1 < version2
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command_exists terraform; then
        print_error "Terraform is not installed or not in PATH"
        print_info "Install Terraform from: https://www.terraform.io/downloads"
        exit 2
    fi
    
    # Check Terraform version
    local terraform_version
    terraform_version=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if ! version_compare "$terraform_version" "$TERRAFORM_VERSION_REQUIRED"; then
        print_error "Terraform version $terraform_version is below required version $TERRAFORM_VERSION_REQUIRED"
        exit 2
    fi
    
    print_success "Terraform version $terraform_version meets requirements"
    
    # Check if we're in the right directory
    if [[ ! -f "providers.tf" ]] || [[ ! -f "variables.tf" ]] || [[ ! -f "main.tf" ]] || [[ ! -f "outputs.tf" ]]; then
        print_error "Missing required Terraform files. Are you in the correct directory?"
        print_info "Expected files: providers.tf, variables.tf, main.tf, outputs.tf"
        exit 2
    fi
    
    print_success "All required Terraform files found"
}

# Function to run terraform init
run_terraform_init() {
    print_info "Running terraform init..."
    
    if terraform init -no-color; then
        print_success "Terraform initialization completed"
    else
        print_error "Terraform initialization failed"
        exit 1
    fi
}

# Function to validate Terraform syntax
validate_syntax() {
    print_info "Validating Terraform syntax..."
    
    if terraform validate -no-color; then
        print_success "Terraform syntax validation passed"
    else
        print_error "Terraform syntax validation failed"
        return 1
    fi
}

# Function to check Terraform formatting
check_formatting() {
    print_info "Checking Terraform formatting..."
    
    local format_output
    format_output=$(terraform fmt -check -diff -no-color 2>&1)
    
    if [[ $? -eq 0 ]]; then
        print_success "Terraform formatting is correct"
    else
        print_warning "Terraform formatting issues detected:"
        echo "$format_output"
        print_info "Run 'terraform fmt' to fix formatting issues"
    fi
}

# Function to fix Terraform formatting
fix_formatting() {
    print_info "Fixing Terraform formatting..."
    
    if terraform fmt -no-color; then
        print_success "Terraform formatting applied"
    else
        print_error "Failed to apply Terraform formatting"
    fi
}

# Function to generate and validate plan
generate_plan() {
    print_info "Generating Terraform execution plan..."
    
    # Check if terraform.tfvars exists
    if [[ ! -f "terraform.tfvars" ]]; then
        print_warning "terraform.tfvars not found"
        print_info "Copy terraform.tfvars.example to terraform.tfvars and configure your values"
        print_info "Or set required environment variables (IC_API_KEY, etc.)"
        return 1
    fi
    
    if terraform plan -no-color -out=validation.tfplan; then
        print_success "Terraform plan generation completed"
        
        # Display plan summary
        print_info "Plan summary:"
        terraform show -no-color validation.tfplan | grep -E "Plan:|No changes"
        
        # Clean up plan file
        rm -f validation.tfplan
    else
        print_error "Terraform plan generation failed"
        return 1
    fi
}

# Function to run security scanning
run_security_scan() {
    print_info "Running security scanning..."
    
    if command_exists tfsec; then
        if tfsec . --no-color; then
            print_success "Security scanning completed - no issues found"
        else
            print_warning "Security scanning completed - issues detected"
            print_info "Review the security findings above"
        fi
    else
        print_warning "tfsec not installed - skipping security scan"
        print_info "Install tfsec from: https://github.com/aquasecurity/tfsec"
    fi
}

# Function to validate file structure
validate_file_structure() {
    print_info "Validating file structure..."
    
    local required_files=(
        "providers.tf"
        "variables.tf"
        "main.tf"
        "outputs.tf"
        "terraform.tfvars.example"
        "README.md"
        ".gitignore"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        print_success "All required files present"
    else
        print_error "Missing required files: ${missing_files[*]}"
        return 1
    fi
    
    # Check file sizes (basic sanity check)
    local min_sizes=(
        "providers.tf:500"
        "variables.tf:2000"
        "main.tf:3000"
        "outputs.tf:2000"
        "README.md:5000"
    )
    
    for size_check in "${min_sizes[@]}"; do
        local file="${size_check%:*}"
        local min_size="${size_check#*:}"
        local actual_size
        actual_size=$(wc -c < "$file" 2>/dev/null || echo "0")
        
        if [[ $actual_size -lt $min_size ]]; then
            print_warning "$file seems too small ($actual_size bytes, expected >$min_size)"
        fi
    done
}

# Function to validate variable definitions
validate_variables() {
    print_info "Validating variable definitions..."
    
    # Check for required variables
    local required_vars=(
        "ibmcloud_api_key"
        "project_name"
        "owner"
    )
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "variable \"$var\"" variables.tf; then
            print_error "Required variable '$var' not found in variables.tf"
        fi
    done
    
    # Check for validation blocks
    local validation_count
    validation_count=$(grep -c "validation {" variables.tf || echo "0")
    
    if [[ $validation_count -gt 5 ]]; then
        print_success "Good use of variable validation ($validation_count validation blocks)"
    else
        print_warning "Consider adding more variable validation blocks for better error handling"
    fi
}

# Function to validate outputs
validate_outputs() {
    print_info "Validating output definitions..."
    
    local output_count
    output_count=$(grep -c "output \"" outputs.tf || echo "0")
    
    if [[ $output_count -ge 10 ]]; then
        print_success "Comprehensive outputs defined ($output_count outputs)"
    else
        print_warning "Consider adding more outputs for better integration ($output_count outputs found)"
    fi
    
    # Check for output descriptions
    local described_outputs
    described_outputs=$(grep -c "description =" outputs.tf || echo "0")
    
    if [[ $described_outputs -eq $output_count ]]; then
        print_success "All outputs have descriptions"
    else
        print_warning "Some outputs missing descriptions ($described_outputs/$output_count described)"
    fi
}

# Function to display help
show_help() {
    cat << EOF
Terraform Validation Script for Lab 3.1

Usage: $0 [options]

Options:
    --init      Run terraform init before validation
    --format    Run terraform fmt to fix formatting
    --plan      Generate and display execution plan
    --security  Run security scanning (requires tfsec)
    --all       Run all validation checks
    --help      Display this help message

Examples:
    $0                    # Run basic validation
    $0 --all             # Run comprehensive validation
    $0 --init --plan     # Initialize and generate plan
    $0 --format          # Fix formatting issues

Exit codes:
    0 - All validations passed
    1 - Validation failures detected
    2 - Missing dependencies or configuration errors

For more information, see README.md
EOF
}

# Main execution
main() {
    local run_init=false
    local run_format=false
    local run_plan=false
    local run_security=false
    local run_all=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --init)
                run_init=true
                shift
                ;;
            --format)
                run_format=true
                shift
                ;;
            --plan)
                run_plan=true
                shift
                ;;
            --security)
                run_security=true
                shift
                ;;
            --all)
                run_all=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 2
                ;;
        esac
    done
    
    # Set all flags if --all is specified
    if [[ $run_all == true ]]; then
        run_init=true
        run_format=true
        run_plan=true
        run_security=true
    fi
    
    print_info "Starting Terraform validation for Lab 3.1..."
    print_info "Working directory: $SCRIPT_DIR"
    
    # Run prerequisite checks
    check_prerequisites
    
    # Run terraform init if requested
    if [[ $run_init == true ]]; then
        run_terraform_init
    fi
    
    # Fix formatting if requested
    if [[ $run_format == true ]]; then
        fix_formatting
    fi
    
    # Run core validations
    validate_file_structure
    validate_variables
    validate_outputs
    validate_syntax
    check_formatting
    
    # Run plan if requested
    if [[ $run_plan == true ]]; then
        generate_plan
    fi
    
    # Run security scan if requested
    if [[ $run_security == true ]]; then
        run_security_scan
    fi
    
    # Final status
    if [[ $VALIDATION_PASSED == true ]]; then
        print_success "All validations completed successfully!"
        print_info "Your Terraform configuration is ready for deployment"
        exit 0
    else
        print_error "Validation failures detected"
        print_info "Please fix the issues above before proceeding"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
