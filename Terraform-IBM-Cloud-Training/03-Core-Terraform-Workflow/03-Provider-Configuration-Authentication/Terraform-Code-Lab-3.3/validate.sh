#!/bin/bash

# Provider Configuration and Authentication - Validation Script
# Comprehensive validation for Terraform provider configuration lab
# Tests authentication, configuration, and enterprise patterns

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Function to run a validation check
run_check() {
    local check_name="$1"
    local check_command="$2"
    local success_message="$3"
    local error_message="$4"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    log_info "Running check: $check_name"
    
    if eval "$check_command" > /dev/null 2>&1; then
        log_success "$success_message"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        log_error "$error_message"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Function to check if a file exists and has content
check_file_exists() {
    local file_path="$1"
    local min_size="${2:-1}"
    
    if [[ -f "$file_path" && $(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo 0) -ge $min_size ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check environment variables
check_environment_variables() {
    log_info "Checking environment variables..."
    
    if [[ -n "$IC_API_KEY" ]]; then
        log_success "IC_API_KEY environment variable is set"
    else
        log_warning "IC_API_KEY environment variable not set (will use variable or fail)"
    fi
    
    if [[ -n "$IC_REGION" ]]; then
        log_success "IC_REGION environment variable is set to: $IC_REGION"
    else
        log_warning "IC_REGION environment variable not set (will use default)"
    fi
    
    if [[ -n "$IC_RESOURCE_GROUP_ID" ]]; then
        log_success "IC_RESOURCE_GROUP_ID environment variable is set"
    else
        log_warning "IC_RESOURCE_GROUP_ID environment variable not set (will use default)"
    fi
}

# Function to validate Terraform installation
validate_terraform() {
    log_info "Validating Terraform installation..."
    
    run_check "Terraform Installation" \
        "command -v terraform" \
        "Terraform is installed and available in PATH" \
        "Terraform is not installed or not in PATH"
    
    if command -v terraform > /dev/null 2>&1; then
        local tf_version=$(terraform version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n1 | cut -d' ' -f2 | sed 's/v//')
        log_info "Terraform version: $tf_version"
        
        # Check minimum version (1.5.0)
        if [[ "$(printf '%s\n' "1.5.0" "$tf_version" | sort -V | head -n1)" == "1.5.0" ]]; then
            log_success "Terraform version meets requirements (>= 1.5.0)"
        else
            log_warning "Terraform version $tf_version may not meet requirements (>= 1.5.0)"
        fi
    fi
}

# Function to validate configuration files
validate_configuration_files() {
    log_info "Validating configuration files..."
    
    run_check "providers.tf exists" \
        "check_file_exists 'providers.tf' 1000" \
        "providers.tf exists and has substantial content" \
        "providers.tf is missing or too small"
    
    run_check "variables.tf exists" \
        "check_file_exists 'variables.tf' 1000" \
        "variables.tf exists and has substantial content" \
        "variables.tf is missing or too small"
    
    run_check "main.tf exists" \
        "check_file_exists 'main.tf' 1000" \
        "main.tf exists and has substantial content" \
        "main.tf is missing or too small"
    
    run_check "outputs.tf exists" \
        "check_file_exists 'outputs.tf' 1000" \
        "outputs.tf exists and has substantial content" \
        "outputs.tf is missing or too small"
    
    run_check "terraform.tfvars.example exists" \
        "check_file_exists 'terraform.tfvars.example' 500" \
        "terraform.tfvars.example exists with example configuration" \
        "terraform.tfvars.example is missing or incomplete"
    
    run_check "README.md exists" \
        "check_file_exists 'README.md' 1000" \
        "README.md exists with comprehensive documentation" \
        "README.md is missing or incomplete"
    
    run_check ".gitignore exists" \
        "check_file_exists '.gitignore' 500" \
        ".gitignore exists with security-focused exclusions" \
        ".gitignore is missing or incomplete"
}

# Function to validate Terraform syntax
validate_terraform_syntax() {
    log_info "Validating Terraform syntax..."
    
    run_check "Terraform initialization" \
        "terraform init -backend=false" \
        "Terraform initialization completed successfully" \
        "Terraform initialization failed"
    
    run_check "Terraform validation" \
        "terraform validate" \
        "Terraform configuration is valid" \
        "Terraform configuration has syntax errors"
    
    run_check "Terraform formatting" \
        "terraform fmt -check" \
        "Terraform configuration is properly formatted" \
        "Terraform configuration needs formatting (run 'terraform fmt')"
}

# Function to validate provider configuration
validate_provider_configuration() {
    log_info "Validating provider configuration..."
    
    # Check if providers.tf contains required providers
    if [[ -f "providers.tf" ]]; then
        run_check "IBM Cloud provider configured" \
            "grep -q 'IBM-Cloud/ibm' providers.tf" \
            "IBM Cloud provider is configured" \
            "IBM Cloud provider configuration not found"
        
        run_check "Provider version constraints" \
            "grep -q 'version.*=.*\"~>' providers.tf" \
            "Provider version constraints are specified" \
            "Provider version constraints not found"
        
        run_check "Provider aliases configured" \
            "grep -q 'alias.*=' providers.tf" \
            "Provider aliases are configured for multi-environment support" \
            "Provider aliases not found"
        
        run_check "Supporting providers configured" \
            "grep -q 'hashicorp/random' providers.tf && grep -q 'hashicorp/time' providers.tf" \
            "Supporting providers (random, time) are configured" \
            "Supporting providers not found"
    fi
}

# Function to validate variable definitions
validate_variable_definitions() {
    log_info "Validating variable definitions..."
    
    if [[ -f "variables.tf" ]]; then
        local var_count=$(grep -c "^variable " variables.tf 2>/dev/null || echo 0)
        
        if [[ $var_count -ge 25 ]]; then
            log_success "Found $var_count variable definitions (meets requirement of 25+)"
        else
            log_warning "Found only $var_count variable definitions (requirement: 25+)"
        fi
        
        run_check "Authentication variables" \
            "grep -q 'ibm_api_key' variables.tf && grep -q 'ibm_region' variables.tf" \
            "Authentication variables are defined" \
            "Authentication variables not found"
        
        run_check "Multi-environment variables" \
            "grep -q 'dev_api_key' variables.tf && grep -q 'staging_api_key' variables.tf && grep -q 'prod_api_key' variables.tf" \
            "Multi-environment variables are defined" \
            "Multi-environment variables not found"
        
        run_check "Performance configuration variables" \
            "grep -q 'provider_timeout' variables.tf && grep -q 'max_retries' variables.tf" \
            "Performance configuration variables are defined" \
            "Performance configuration variables not found"
        
        run_check "Security configuration variables" \
            "grep -q 'endpoint_type' variables.tf && grep -q 'security_level' variables.tf" \
            "Security configuration variables are defined" \
            "Security configuration variables not found"
        
        run_check "Variable validation blocks" \
            "grep -q 'validation {' variables.tf" \
            "Variable validation blocks are implemented" \
            "Variable validation blocks not found"
    fi
}

# Function to validate outputs
validate_outputs() {
    log_info "Validating output definitions..."
    
    if [[ -f "outputs.tf" ]]; then
        local output_count=$(grep -c "^output " outputs.tf 2>/dev/null || echo 0)
        
        if [[ $output_count -ge 10 ]]; then
            log_success "Found $output_count output definitions (meets requirement of 10+)"
        else
            log_warning "Found only $output_count output definitions (requirement: 10+)"
        fi
        
        run_check "Provider configuration outputs" \
            "grep -q 'provider_configuration' outputs.tf" \
            "Provider configuration outputs are defined" \
            "Provider configuration outputs not found"
        
        run_check "Authentication outputs" \
            "grep -q 'authentication' outputs.tf" \
            "Authentication outputs are defined" \
            "Authentication outputs not found"
        
        run_check "Test results outputs" \
            "grep -q 'test_results' outputs.tf" \
            "Test results outputs are defined" \
            "Test results outputs not found"
        
        run_check "Troubleshooting outputs" \
            "grep -q 'troubleshooting' outputs.tf" \
            "Troubleshooting outputs are defined" \
            "Troubleshooting outputs not found"
    fi
}

# Function to test provider connectivity (if credentials available)
test_provider_connectivity() {
    log_info "Testing provider connectivity..."
    
    if [[ -n "$IC_API_KEY" ]] || [[ -f "terraform.tfvars" ]]; then
        run_check "Terraform plan execution" \
            "terraform plan -var='test_mode=false' -out=test.tfplan" \
            "Terraform plan executed successfully (provider connectivity confirmed)" \
            "Terraform plan failed (check credentials and permissions)"
        
        # Clean up plan file
        rm -f test.tfplan
    else
        log_warning "Skipping provider connectivity test (no credentials available)"
        log_info "To test connectivity, set IC_API_KEY environment variable or create terraform.tfvars"
    fi
}

# Function to validate security configurations
validate_security_configurations() {
    log_info "Validating security configurations..."
    
    run_check "Sensitive variable marking" \
        "grep -q 'sensitive.*=.*true' variables.tf" \
        "Sensitive variables are properly marked" \
        "Sensitive variable marking not found"
    
    run_check "GitIgnore security" \
        "grep -q '*.tfvars' .gitignore && grep -q '*.key' .gitignore" \
        "GitIgnore includes security-sensitive file patterns" \
        "GitIgnore security patterns not found"
    
    run_check "Private endpoint configuration" \
        "grep -q 'endpoint_type.*=.*\"private\"' providers.tf" \
        "Private endpoint configuration is available" \
        "Private endpoint configuration not found"
    
    run_check "Custom headers for tracking" \
        "grep -q 'custom_headers' providers.tf" \
        "Custom headers for tracking are configured" \
        "Custom headers configuration not found"
}

# Function to validate enterprise patterns
validate_enterprise_patterns() {
    log_info "Validating enterprise patterns..."
    
    run_check "Multi-environment provider aliases" \
        "grep -q 'alias.*=.*\"dev\"' providers.tf && grep -q 'alias.*=.*\"staging\"' providers.tf && grep -q 'alias.*=.*\"prod\"' providers.tf" \
        "Multi-environment provider aliases are configured" \
        "Multi-environment provider aliases not found"
    
    run_check "Regional provider aliases" \
        "grep -q 'alias.*=.*\"us_south\"' providers.tf && grep -q 'alias.*=.*\"eu_gb\"' providers.tf" \
        "Regional provider aliases are configured" \
        "Regional provider aliases not found"
    
    run_check "Feature flags configuration" \
        "grep -q 'feature_flags' variables.tf" \
        "Feature flags configuration is available" \
        "Feature flags configuration not found"
    
    run_check "Resource tagging patterns" \
        "grep -q 'common_tags' variables.tf && grep -q 'tags.*=' main.tf" \
        "Resource tagging patterns are implemented" \
        "Resource tagging patterns not found"
}

# Function to validate documentation quality
validate_documentation() {
    log_info "Validating documentation quality..."
    
    if [[ -f "README.md" ]]; then
        run_check "README.md comprehensive content" \
            "test $(wc -l < README.md) -ge 200" \
            "README.md has comprehensive content (200+ lines)" \
            "README.md content is insufficient"
        
        run_check "README.md contains setup instructions" \
            "grep -q -i 'setup\|installation\|getting started' README.md" \
            "README.md contains setup instructions" \
            "README.md missing setup instructions"
        
        run_check "README.md contains troubleshooting" \
            "grep -q -i 'troubleshoot\|debug\|error' README.md" \
            "README.md contains troubleshooting guidance" \
            "README.md missing troubleshooting guidance"
        
        run_check "README.md contains security guidance" \
            "grep -q -i 'security\|credential\|authentication' README.md" \
            "README.md contains security guidance" \
            "README.md missing security guidance"
    fi
}

# Main validation function
main() {
    echo "============================================================================"
    echo "Provider Configuration and Authentication - Validation Script"
    echo "============================================================================"
    echo ""
    
    # Run all validation checks
    check_environment_variables
    echo ""
    
    validate_terraform
    echo ""
    
    validate_configuration_files
    echo ""
    
    validate_terraform_syntax
    echo ""
    
    validate_provider_configuration
    echo ""
    
    validate_variable_definitions
    echo ""
    
    validate_outputs
    echo ""
    
    validate_security_configurations
    echo ""
    
    validate_enterprise_patterns
    echo ""
    
    validate_documentation
    echo ""
    
    test_provider_connectivity
    echo ""
    
    # Summary
    echo "============================================================================"
    echo "VALIDATION SUMMARY"
    echo "============================================================================"
    echo "Total checks: $TOTAL_CHECKS"
    echo "Passed: $PASSED_CHECKS"
    echo "Failed: $FAILED_CHECKS"
    echo ""
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        log_success "🎉 All validation checks passed! Provider configuration lab is ready."
        echo ""
        echo "Next steps:"
        echo "1. Set up your IBM Cloud credentials (IC_API_KEY environment variable)"
        echo "2. Run 'terraform plan' to test provider connectivity"
        echo "3. Run 'terraform apply -var=\"test_mode=true\"' to deploy test resources"
        echo "4. Review outputs with 'terraform output'"
        echo "5. Clean up with 'terraform destroy' when finished"
        exit 0
    else
        log_error "❌ $FAILED_CHECKS validation check(s) failed. Please review and fix issues."
        echo ""
        echo "Common fixes:"
        echo "1. Run 'terraform fmt' to format configuration files"
        echo "2. Check variable definitions and validation blocks"
        echo "3. Ensure all required files are present and have sufficient content"
        echo "4. Review provider configuration for required aliases and settings"
        exit 1
    fi
}

# Run main function
main "$@"
