#!/bin/bash

# Core Terraform Commands Lab - Validation Script
# Comprehensive validation for command workflow practice

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

print_header() {
    echo -e "${BLUE}============================================================================${NC}"
    echo -e "${BLUE}  Core Terraform Commands Lab - Validation Script${NC}"
    echo -e "${BLUE}  Lab 3.2: Command Workflow Practice and Validation${NC}"
    echo -e "${BLUE}============================================================================${NC}"
    echo ""
}

print_status() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASSED_CHECKS++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

run_check() {
    local check_name="$1"
    local command="$2"
    local expected_result="$3"
    
    ((TOTAL_CHECKS++))
    print_status "Running check: $check_name"
    
    if eval "$command" > /dev/null 2>&1; then
        if [ "$expected_result" = "success" ]; then
            print_success "$check_name passed"
            return 0
        else
            print_error "$check_name failed (unexpected success)"
            return 1
        fi
    else
        if [ "$expected_result" = "failure" ]; then
            print_success "$check_name passed (expected failure)"
            return 0
        else
            print_error "$check_name failed"
            return 1
        fi
    fi
}

validate_prerequisites() {
    print_status "🔍 Validating prerequisites..."
    echo ""
    
    # Check Terraform installation
    run_check "Terraform installation" "terraform version" "success"
    
    if command -v terraform &> /dev/null; then
        TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n1 | cut -d' ' -f2 | sed 's/v//')
        print_info "Terraform version: $TERRAFORM_VERSION"
        
        # Check minimum version requirement
        if [ "$(printf '%s\n' "1.5.0" "$TERRAFORM_VERSION" | sort -V | head -n1)" = "1.5.0" ]; then
            print_success "Terraform version meets requirements (>= 1.5.0)"
            ((PASSED_CHECKS++))
        else
            print_error "Terraform version $TERRAFORM_VERSION is below required 1.5.0"
            ((FAILED_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    fi
    
    # Check for required files
    local required_files=(
        "providers.tf"
        "variables.tf"
        "main.tf"
        "outputs.tf"
        "terraform.tfvars.example"
        "README.md"
        ".gitignore"
    )
    
    for file in "${required_files[@]}"; do
        run_check "Required file: $file" "test -f $file" "success"
    done
    
    # Check for terraform.tfvars
    if [ -f "terraform.tfvars" ]; then
        print_success "terraform.tfvars file exists"
        ((PASSED_CHECKS++))
    else
        print_warning "terraform.tfvars not found - copy from terraform.tfvars.example"
    fi
    ((TOTAL_CHECKS++))
    
    echo ""
}

validate_configuration() {
    print_status "🔧 Validating Terraform configuration..."
    echo ""
    
    # Check Terraform formatting
    run_check "Terraform formatting" "terraform fmt -check=true -diff=false" "success"
    
    # Initialize if needed
    if [ ! -d ".terraform" ]; then
        print_status "Initializing Terraform..."
        if terraform init -no-color > /dev/null 2>&1; then
            print_success "Terraform initialization completed"
            ((PASSED_CHECKS++))
        else
            print_error "Terraform initialization failed"
            ((FAILED_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    else
        print_info "Terraform already initialized"
    fi
    
    # Validate configuration syntax
    run_check "Configuration syntax validation" "terraform validate -no-color" "success"
    
    # Check provider configuration
    if terraform providers > /dev/null 2>&1; then
        print_success "Provider configuration valid"
        ((PASSED_CHECKS++))
        
        # List providers
        print_info "Configured providers:"
        terraform providers | grep -E "provider\[" | sed 's/^/  /'
    else
        print_error "Provider configuration invalid"
        ((FAILED_CHECKS++))
    fi
    ((TOTAL_CHECKS++))
    
    echo ""
}

validate_variables() {
    print_status "📝 Validating variable configuration..."
    echo ""
    
    # Check variable definitions
    local variable_count=$(grep -c "^variable " variables.tf 2>/dev/null || echo "0")
    if [ "$variable_count" -gt 0 ]; then
        print_success "Found $variable_count variable definitions"
        ((PASSED_CHECKS++))
    else
        print_error "No variable definitions found"
        ((FAILED_CHECKS++))
    fi
    ((TOTAL_CHECKS++))
    
    # Check for required variables
    local required_vars=("ibm_api_key" "owner" "project_name")
    for var in "${required_vars[@]}"; do
        if grep -q "variable \"$var\"" variables.tf; then
            print_success "Required variable '$var' defined"
            ((PASSED_CHECKS++))
        else
            print_error "Required variable '$var' missing"
            ((FAILED_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    done
    
    # Check variable validation rules
    local validation_count=$(grep -c "validation {" variables.tf 2>/dev/null || echo "0")
    if [ "$validation_count" -gt 0 ]; then
        print_success "Found $validation_count validation rules"
        ((PASSED_CHECKS++))
    else
        print_warning "No variable validation rules found"
    fi
    ((TOTAL_CHECKS++))
    
    echo ""
}

validate_resources() {
    print_status "🏗️  Validating resource configuration..."
    echo ""
    
    # Check main resource types
    local resource_types=("ibm_is_vpc" "ibm_is_subnet" "ibm_is_security_group" "random_string")
    for resource_type in "${resource_types[@]}"; do
        if grep -q "resource \"$resource_type\"" main.tf; then
            print_success "Resource type '$resource_type' configured"
            ((PASSED_CHECKS++))
        else
            print_error "Resource type '$resource_type' missing"
            ((FAILED_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    done
    
    # Check data sources
    if grep -q "data \"ibm_is_zones\"" main.tf; then
        print_success "Data source for zones configured"
        ((PASSED_CHECKS++))
    else
        print_error "Data source for zones missing"
        ((FAILED_CHECKS++))
    fi
    ((TOTAL_CHECKS++))
    
    # Check local values
    if grep -q "locals {" main.tf; then
        print_success "Local values configured"
        ((PASSED_CHECKS++))
    else
        print_warning "No local values found"
    fi
    ((TOTAL_CHECKS++))
    
    echo ""
}

validate_outputs() {
    print_status "📤 Validating output configuration..."
    echo ""
    
    # Check output definitions
    local output_count=$(grep -c "^output " outputs.tf 2>/dev/null || echo "0")
    if [ "$output_count" -gt 10 ]; then
        print_success "Found $output_count output definitions"
        ((PASSED_CHECKS++))
    else
        print_error "Insufficient output definitions (found $output_count, expected >10)"
        ((FAILED_CHECKS++))
    fi
    ((TOTAL_CHECKS++))
    
    # Check for key outputs
    local required_outputs=("deployment_info" "vpc_info" "cost_estimation" "terraform_commands")
    for output in "${required_outputs[@]}"; do
        if grep -q "output \"$output\"" outputs.tf; then
            print_success "Required output '$output' defined"
            ((PASSED_CHECKS++))
        else
            print_error "Required output '$output' missing"
            ((FAILED_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    done
    
    echo ""
}

validate_security() {
    print_status "🔒 Validating security configuration..."
    echo ""
    
    # Check for sensitive variables
    if grep -q "sensitive.*=.*true" variables.tf; then
        print_success "Sensitive variables properly marked"
        ((PASSED_CHECKS++))
    else
        print_warning "No sensitive variables marked"
    fi
    ((TOTAL_CHECKS++))
    
    # Check .gitignore for sensitive files
    local sensitive_patterns=("*.tfvars" "*.tfstate" ".terraform/")
    for pattern in "${sensitive_patterns[@]}"; do
        if grep -q "$pattern" .gitignore; then
            print_success "Sensitive pattern '$pattern' in .gitignore"
            ((PASSED_CHECKS++))
        else
            print_error "Sensitive pattern '$pattern' missing from .gitignore"
            ((FAILED_CHECKS++))
        fi
        ((TOTAL_CHECKS++))
    done
    
    # Check for hardcoded secrets
    if grep -i -E "(password|secret|key).*=.*['\"][^'\"]*['\"]" *.tf 2>/dev/null; then
        print_error "Potential hardcoded secrets found"
        ((FAILED_CHECKS++))
    else
        print_success "No hardcoded secrets detected"
        ((PASSED_CHECKS++))
    fi
    ((TOTAL_CHECKS++))
    
    echo ""
}

validate_documentation() {
    print_status "📚 Validating documentation..."
    echo ""
    
    # Check README.md content
    if [ -f "README.md" ]; then
        local readme_lines=$(wc -l < README.md)
        if [ "$readme_lines" -gt 100 ]; then
            print_success "README.md has comprehensive content ($readme_lines lines)"
            ((PASSED_CHECKS++))
        else
            print_warning "README.md content may be insufficient ($readme_lines lines)"
        fi
    else
        print_error "README.md file missing"
        ((FAILED_CHECKS++))
    fi
    ((TOTAL_CHECKS++))
    
    # Check for key documentation sections
    local doc_sections=("Quick Start" "Configuration" "Troubleshooting" "Cost")
    for section in "${doc_sections[@]}"; do
        if grep -i "$section" README.md > /dev/null 2>&1; then
            print_success "Documentation section '$section' found"
            ((PASSED_CHECKS++))
        else
            print_warning "Documentation section '$section' missing"
        fi
        ((TOTAL_CHECKS++))
    done
    
    echo ""
}

run_command_tests() {
    print_status "🧪 Running command workflow tests..."
    echo ""
    
    # Test terraform init
    print_status "Testing terraform init..."
    if terraform init -no-color > /dev/null 2>&1; then
        print_success "terraform init successful"
        ((PASSED_CHECKS++))
    else
        print_error "terraform init failed"
        ((FAILED_CHECKS++))
    fi
    ((TOTAL_CHECKS++))
    
    # Test terraform validate
    print_status "Testing terraform validate..."
    if terraform validate -no-color > /dev/null 2>&1; then
        print_success "terraform validate successful"
        ((PASSED_CHECKS++))
    else
        print_error "terraform validate failed"
        ((FAILED_CHECKS++))
    fi
    ((TOTAL_CHECKS++))
    
    # Test terraform plan (if variables are configured)
    if [ -f "terraform.tfvars" ]; then
        print_status "Testing terraform plan..."
        if terraform plan -no-color -out=validation.tfplan > /dev/null 2>&1; then
            print_success "terraform plan successful"
            ((PASSED_CHECKS++))
            
            # Clean up plan file
            rm -f validation.tfplan
        else
            print_error "terraform plan failed (check terraform.tfvars configuration)"
            ((FAILED_CHECKS++))
        fi
    else
        print_warning "Skipping terraform plan test (terraform.tfvars not configured)"
    fi
    ((TOTAL_CHECKS++))
    
    echo ""
}

print_summary() {
    echo ""
    echo -e "${BLUE}============================================================================${NC}"
    echo -e "${BLUE}  Validation Summary${NC}"
    echo -e "${BLUE}============================================================================${NC}"
    echo ""
    
    echo -e "${CYAN}Total Checks:${NC} $TOTAL_CHECKS"
    echo -e "${GREEN}Passed:${NC} $PASSED_CHECKS"
    echo -e "${RED}Failed:${NC} $FAILED_CHECKS"
    
    local success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    echo -e "${PURPLE}Success Rate:${NC} $success_rate%"
    
    echo ""
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        echo -e "${GREEN}🎉 All validations passed! Lab configuration is ready for use.${NC}"
        echo ""
        echo -e "${CYAN}Next Steps:${NC}"
        echo "1. Configure terraform.tfvars with your IBM Cloud API key"
        echo "2. Run terraform plan to review planned changes"
        echo "3. Run terraform apply to deploy infrastructure"
        echo "4. Practice command workflows as outlined in Lab 4"
        echo "5. Run terraform destroy when lab is complete"
    elif [ $success_rate -ge 80 ]; then
        echo -e "${YELLOW}⚠️  Most validations passed, but some issues need attention.${NC}"
        echo -e "${YELLOW}Review the failed checks above and address them before proceeding.${NC}"
    else
        echo -e "${RED}❌ Multiple validation failures detected.${NC}"
        echo -e "${RED}Please address the issues above before using this lab configuration.${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}============================================================================${NC}"
}

# Main execution
main() {
    print_header
    
    validate_prerequisites
    validate_configuration
    validate_variables
    validate_resources
    validate_outputs
    validate_security
    validate_documentation
    run_command_tests
    
    print_summary
    
    # Exit with appropriate code
    if [ $FAILED_CHECKS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"
