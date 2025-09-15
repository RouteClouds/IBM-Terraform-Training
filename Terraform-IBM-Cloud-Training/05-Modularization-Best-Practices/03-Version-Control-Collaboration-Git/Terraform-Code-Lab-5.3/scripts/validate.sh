#!/bin/bash

# Git Collaboration Lab - Validation Script
# Comprehensive validation for Git workflows and Terraform configurations

set -euo pipefail

# =============================================================================
# CONFIGURATION AND VARIABLES
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_ROOT}/validation.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Validation options
VALIDATE_TERRAFORM="${VALIDATE_TERRAFORM:-true}"
VALIDATE_GIT="${VALIDATE_GIT:-true}"
VALIDATE_SECURITY="${VALIDATE_SECURITY:-true}"
VALIDATE_COST="${VALIDATE_COST:-true}"
VALIDATE_POLICY="${VALIDATE_POLICY:-true}"
VERBOSE="${VERBOSE:-false}"
FAIL_FAST="${FAIL_FAST:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Validation results
VALIDATION_RESULTS=()
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

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
    log "${GREEN}[PASS]${NC} $1"
    ((PASSED_CHECKS++))
}

log_warning() {
    log "${YELLOW}[WARN]${NC} $1"
    ((WARNING_CHECKS++))
}

log_error() {
    log "${RED}[FAIL]${NC} $1"
    ((FAILED_CHECKS++))
    if [[ "$FAIL_FAST" == "true" ]]; then
        exit 1
    fi
}

add_result() {
    local status="$1"
    local check="$2"
    local message="$3"
    
    VALIDATION_RESULTS+=("$status|$check|$message")
    ((TOTAL_CHECKS++))
}

show_usage() {
    cat << EOF
Git Collaboration Lab - Validation Script

Usage: $0 [OPTIONS]

OPTIONS:
    --terraform                     Validate Terraform configuration (default: true)
    --no-terraform                  Skip Terraform validation
    --git                          Validate Git workflow (default: true)
    --no-git                       Skip Git validation
    --security                     Validate security configuration (default: true)
    --no-security                  Skip security validation
    --cost                         Validate cost configuration (default: true)
    --no-cost                      Skip cost validation
    --policy                       Validate policy configuration (default: true)
    --no-policy                    Skip policy validation
    --verbose                      Enable verbose output
    --fail-fast                    Exit on first failure
    -h, --help                     Show this help message

EXAMPLES:
    $0                             Run all validations
    $0 --no-security --no-cost     Skip security and cost validations
    $0 --terraform --git           Run only Terraform and Git validations
    $0 --verbose --fail-fast       Run with verbose output and fail fast

EOF
}

# =============================================================================
# TERRAFORM VALIDATION FUNCTIONS
# =============================================================================

validate_terraform_syntax() {
    log_info "Validating Terraform syntax..."
    
    cd "$PROJECT_ROOT"
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        add_result "FAIL" "terraform-install" "Terraform is not installed"
        log_error "Terraform is not installed"
        return 1
    fi
    
    # Check Terraform version
    local tf_version
    tf_version=$(terraform version -json | jq -r '.terraform_version')
    log_info "Terraform version: $tf_version"
    add_result "PASS" "terraform-version" "Terraform version $tf_version detected"
    log_success "Terraform version check passed"
    
    # Format check
    if terraform fmt -check=true -diff=true > /dev/null 2>&1; then
        add_result "PASS" "terraform-format" "Terraform formatting is correct"
        log_success "Terraform formatting check passed"
    else
        add_result "FAIL" "terraform-format" "Terraform formatting issues detected"
        log_error "Terraform formatting issues detected. Run 'terraform fmt' to fix"
        return 1
    fi
    
    # Initialize Terraform
    if terraform init -backend=false > /dev/null 2>&1; then
        add_result "PASS" "terraform-init" "Terraform initialization successful"
        log_success "Terraform initialization passed"
    else
        add_result "FAIL" "terraform-init" "Terraform initialization failed"
        log_error "Terraform initialization failed"
        return 1
    fi
    
    # Validate configuration
    if terraform validate > /dev/null 2>&1; then
        add_result "PASS" "terraform-validate" "Terraform validation successful"
        log_success "Terraform validation passed"
    else
        add_result "FAIL" "terraform-validate" "Terraform validation failed"
        log_error "Terraform validation failed"
        return 1
    fi
    
    return 0
}

validate_terraform_files() {
    log_info "Validating Terraform file structure..."
    
    cd "$PROJECT_ROOT"
    
    # Check required files
    local required_files=("main.tf" "variables.tf" "outputs.tf" "providers.tf")
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            add_result "PASS" "file-$file" "Required file $file exists"
            log_success "File $file exists"
        else
            add_result "FAIL" "file-$file" "Required file $file is missing"
            log_error "Required file $file is missing"
        fi
    done
    
    # Check example files
    if [[ -f "terraform.tfvars.example" ]]; then
        add_result "PASS" "file-tfvars-example" "Example tfvars file exists"
        log_success "terraform.tfvars.example exists"
    else
        add_result "WARN" "file-tfvars-example" "Example tfvars file is missing"
        log_warning "terraform.tfvars.example is missing"
    fi
    
    # Check README
    if [[ -f "README.md" ]]; then
        add_result "PASS" "file-readme" "README.md exists"
        log_success "README.md exists"
    else
        add_result "WARN" "file-readme" "README.md is missing"
        log_warning "README.md is missing"
    fi
    
    return 0
}

validate_terraform_best_practices() {
    log_info "Validating Terraform best practices..."
    
    cd "$PROJECT_ROOT"
    
    # Check for variable descriptions
    local vars_without_desc
    vars_without_desc=$(grep -c 'variable.*{' variables.tf || true)
    local vars_with_desc
    vars_with_desc=$(grep -c 'description.*=' variables.tf || true)
    
    if [[ $vars_with_desc -eq $vars_without_desc ]]; then
        add_result "PASS" "variable-descriptions" "All variables have descriptions"
        log_success "All variables have descriptions"
    else
        add_result "WARN" "variable-descriptions" "Some variables missing descriptions"
        log_warning "Some variables are missing descriptions"
    fi
    
    # Check for output descriptions
    local outputs_without_desc
    outputs_without_desc=$(grep -c 'output.*{' outputs.tf || true)
    local outputs_with_desc
    outputs_with_desc=$(grep -c 'description.*=' outputs.tf || true)
    
    if [[ $outputs_with_desc -eq $outputs_without_desc ]]; then
        add_result "PASS" "output-descriptions" "All outputs have descriptions"
        log_success "All outputs have descriptions"
    else
        add_result "WARN" "output-descriptions" "Some outputs missing descriptions"
        log_warning "Some outputs are missing descriptions"
    fi
    
    # Check for resource tags
    if grep -q 'tags.*=' main.tf; then
        add_result "PASS" "resource-tags" "Resources have tags"
        log_success "Resources have tags"
    else
        add_result "WARN" "resource-tags" "Resources may be missing tags"
        log_warning "Resources may be missing tags"
    fi
    
    return 0
}

# =============================================================================
# GIT VALIDATION FUNCTIONS
# =============================================================================

validate_git_repository() {
    log_info "Validating Git repository..."
    
    # Check if we're in a Git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        add_result "PASS" "git-repository" "Git repository detected"
        log_success "Git repository detected"
    else
        add_result "WARN" "git-repository" "Not in a Git repository"
        log_warning "Not in a Git repository"
        return 1
    fi
    
    # Check Git configuration
    if git config user.name > /dev/null 2>&1 && git config user.email > /dev/null 2>&1; then
        add_result "PASS" "git-config" "Git user configuration is set"
        log_success "Git user configuration is set"
    else
        add_result "WARN" "git-config" "Git user configuration is incomplete"
        log_warning "Git user configuration is incomplete"
    fi
    
    # Check for remote repository
    if git remote -v | grep -q origin; then
        add_result "PASS" "git-remote" "Git remote origin is configured"
        log_success "Git remote origin is configured"
    else
        add_result "WARN" "git-remote" "Git remote origin is not configured"
        log_warning "Git remote origin is not configured"
    fi
    
    return 0
}

validate_git_workflow() {
    log_info "Validating Git workflow configuration..."
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        return 1
    fi
    
    # Check current branch
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    log_info "Current branch: $current_branch"
    
    # Check for common workflow files
    if [[ -f ".github/workflows/terraform.yml" || -f ".github/workflows/ci.yml" ]]; then
        add_result "PASS" "github-workflows" "GitHub workflows detected"
        log_success "GitHub workflows detected"
    else
        add_result "WARN" "github-workflows" "GitHub workflows not found"
        log_warning "GitHub workflows not found"
    fi
    
    # Check for CODEOWNERS file
    if [[ -f ".github/CODEOWNERS" ]]; then
        add_result "PASS" "codeowners" "CODEOWNERS file exists"
        log_success "CODEOWNERS file exists"
    else
        add_result "WARN" "codeowners" "CODEOWNERS file not found"
        log_warning "CODEOWNERS file not found"
    fi
    
    # Check for pre-commit hooks
    if [[ -f ".pre-commit-config.yaml" ]]; then
        add_result "PASS" "pre-commit" "Pre-commit configuration exists"
        log_success "Pre-commit configuration exists"
    else
        add_result "WARN" "pre-commit" "Pre-commit configuration not found"
        log_warning "Pre-commit configuration not found"
    fi
    
    # Check for uncommitted changes
    if git diff-index --quiet HEAD --; then
        add_result "PASS" "git-clean" "No uncommitted changes"
        log_success "No uncommitted changes"
    else
        add_result "WARN" "git-clean" "Uncommitted changes detected"
        log_warning "Uncommitted changes detected"
    fi
    
    return 0
}

# =============================================================================
# SECURITY VALIDATION FUNCTIONS
# =============================================================================

validate_security_configuration() {
    log_info "Validating security configuration..."
    
    cd "$PROJECT_ROOT"
    
    # Check for sensitive data in files
    local sensitive_patterns=("password" "secret" "key" "token" "credential")
    local found_sensitive=false
    
    for pattern in "${sensitive_patterns[@]}"; do
        if grep -ri "$pattern" . --include="*.tf" --include="*.tfvars" | grep -v "variable\|description\|example" > /dev/null 2>&1; then
            found_sensitive=true
            break
        fi
    done
    
    if [[ "$found_sensitive" == "false" ]]; then
        add_result "PASS" "sensitive-data" "No sensitive data found in configuration files"
        log_success "No sensitive data found in configuration files"
    else
        add_result "WARN" "sensitive-data" "Potential sensitive data found in configuration files"
        log_warning "Potential sensitive data found in configuration files"
    fi
    
    # Check for security group rules
    if grep -q "security_group" main.tf; then
        add_result "PASS" "security-groups" "Security groups configured"
        log_success "Security groups configured"
    else
        add_result "WARN" "security-groups" "Security groups not found"
        log_warning "Security groups not found"
    fi
    
    # Check for encryption settings
    if grep -q "encrypt" main.tf || grep -q "kms" main.tf; then
        add_result "PASS" "encryption" "Encryption configuration found"
        log_success "Encryption configuration found"
    else
        add_result "WARN" "encryption" "Encryption configuration not found"
        log_warning "Encryption configuration not found"
    fi
    
    return 0
}

run_security_tools() {
    log_info "Running security scanning tools..."
    
    cd "$PROJECT_ROOT"
    
    # Check if tfsec is available and run it
    if command -v tfsec &> /dev/null; then
        if tfsec . --no-color --format json > tfsec-results.json 2>/dev/null; then
            local issues
            issues=$(jq '.results | length' tfsec-results.json 2>/dev/null || echo "0")
            if [[ "$issues" -eq 0 ]]; then
                add_result "PASS" "tfsec-scan" "tfsec security scan passed"
                log_success "tfsec security scan passed"
            else
                add_result "WARN" "tfsec-scan" "tfsec found $issues security issues"
                log_warning "tfsec found $issues security issues"
            fi
        else
            add_result "WARN" "tfsec-scan" "tfsec scan failed to run"
            log_warning "tfsec scan failed to run"
        fi
    else
        add_result "WARN" "tfsec-install" "tfsec is not installed"
        log_warning "tfsec is not installed"
    fi
    
    # Check if checkov is available and run it
    if command -v checkov &> /dev/null; then
        if checkov -d . --framework terraform --quiet --output json > checkov-results.json 2>/dev/null; then
            local failed_checks
            failed_checks=$(jq '.summary.failed' checkov-results.json 2>/dev/null || echo "0")
            if [[ "$failed_checks" -eq 0 ]]; then
                add_result "PASS" "checkov-scan" "Checkov security scan passed"
                log_success "Checkov security scan passed"
            else
                add_result "WARN" "checkov-scan" "Checkov found $failed_checks failed checks"
                log_warning "Checkov found $failed_checks failed checks"
            fi
        else
            add_result "WARN" "checkov-scan" "Checkov scan failed to run"
            log_warning "Checkov scan failed to run"
        fi
    else
        add_result "WARN" "checkov-install" "Checkov is not installed"
        log_warning "Checkov is not installed"
    fi
    
    return 0
}

# =============================================================================
# COST VALIDATION FUNCTIONS
# =============================================================================

validate_cost_configuration() {
    log_info "Validating cost configuration..."
    
    cd "$PROJECT_ROOT"
    
    # Check for cost-related variables
    if grep -q "cost\|budget" variables.tf; then
        add_result "PASS" "cost-variables" "Cost-related variables found"
        log_success "Cost-related variables found"
    else
        add_result "WARN" "cost-variables" "Cost-related variables not found"
        log_warning "Cost-related variables not found"
    fi
    
    # Check for resource tagging for cost allocation
    if grep -q "cost.*tag\|tag.*cost" main.tf variables.tf; then
        add_result "PASS" "cost-tags" "Cost allocation tags configured"
        log_success "Cost allocation tags configured"
    else
        add_result "WARN" "cost-tags" "Cost allocation tags not found"
        log_warning "Cost allocation tags not found"
    fi
    
    # Run Infracost if available
    if command -v infracost &> /dev/null; then
        if infracost breakdown --path . --format json > infracost-results.json 2>/dev/null; then
            local monthly_cost
            monthly_cost=$(jq -r '.totalMonthlyCost // "0"' infracost-results.json)
            add_result "PASS" "cost-analysis" "Cost analysis completed - Monthly cost: \$${monthly_cost}"
            log_success "Cost analysis completed - Monthly cost: \$${monthly_cost}"
        else
            add_result "WARN" "cost-analysis" "Cost analysis failed to run"
            log_warning "Cost analysis failed to run"
        fi
    else
        add_result "WARN" "infracost-install" "Infracost is not installed"
        log_warning "Infracost is not installed"
    fi
    
    return 0
}

# =============================================================================
# POLICY VALIDATION FUNCTIONS
# =============================================================================

validate_policy_configuration() {
    log_info "Validating policy configuration..."
    
    cd "$PROJECT_ROOT"
    
    # Check for policy-related configuration
    if grep -q "policy\|compliance" variables.tf main.tf; then
        add_result "PASS" "policy-config" "Policy configuration found"
        log_success "Policy configuration found"
    else
        add_result "WARN" "policy-config" "Policy configuration not found"
        log_warning "Policy configuration not found"
    fi
    
    # Check for OPA/Conftest policies
    if [[ -d "policies" ]] || [[ -f "policy.rego" ]]; then
        add_result "PASS" "opa-policies" "OPA policies found"
        log_success "OPA policies found"
    else
        add_result "WARN" "opa-policies" "OPA policies not found"
        log_warning "OPA policies not found"
    fi
    
    # Run Conftest if available
    if command -v conftest &> /dev/null; then
        if [[ -d "policies" ]]; then
            if conftest verify --policy policies . > /dev/null 2>&1; then
                add_result "PASS" "conftest-verify" "Conftest policy verification passed"
                log_success "Conftest policy verification passed"
            else
                add_result "WARN" "conftest-verify" "Conftest policy verification failed"
                log_warning "Conftest policy verification failed"
            fi
        else
            add_result "WARN" "conftest-policies" "No policies directory found for Conftest"
            log_warning "No policies directory found for Conftest"
        fi
    else
        add_result "WARN" "conftest-install" "Conftest is not installed"
        log_warning "Conftest is not installed"
    fi
    
    return 0
}

# =============================================================================
# REPORT GENERATION
# =============================================================================

generate_report() {
    log_info "Generating validation report..."
    
    local report_file="${PROJECT_ROOT}/validation-report.json"
    local summary_file="${PROJECT_ROOT}/validation-summary.txt"
    
    # Generate JSON report
    {
        echo "{"
        echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
        echo "  \"summary\": {"
        echo "    \"total_checks\": $TOTAL_CHECKS,"
        echo "    \"passed_checks\": $PASSED_CHECKS,"
        echo "    \"failed_checks\": $FAILED_CHECKS,"
        echo "    \"warning_checks\": $WARNING_CHECKS"
        echo "  },"
        echo "  \"results\": ["
        
        local first=true
        for result in "${VALIDATION_RESULTS[@]}"; do
            IFS='|' read -r status check message <<< "$result"
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            echo "    {"
            echo "      \"status\": \"$status\","
            echo "      \"check\": \"$check\","
            echo "      \"message\": \"$message\""
            echo -n "    }"
        done
        
        echo ""
        echo "  ]"
        echo "}"
    } > "$report_file"
    
    # Generate summary report
    {
        echo "Git Collaboration Lab - Validation Summary"
        echo "=========================================="
        echo ""
        echo "Validation completed at: $(date)"
        echo ""
        echo "Summary:"
        echo "  Total checks: $TOTAL_CHECKS"
        echo "  Passed: $PASSED_CHECKS"
        echo "  Failed: $FAILED_CHECKS"
        echo "  Warnings: $WARNING_CHECKS"
        echo ""
        
        if [[ $FAILED_CHECKS -gt 0 ]]; then
            echo "Failed checks:"
            for result in "${VALIDATION_RESULTS[@]}"; do
                IFS='|' read -r status check message <<< "$result"
                if [[ "$status" == "FAIL" ]]; then
                    echo "  - $check: $message"
                fi
            done
            echo ""
        fi
        
        if [[ $WARNING_CHECKS -gt 0 ]]; then
            echo "Warnings:"
            for result in "${VALIDATION_RESULTS[@]}"; do
                IFS='|' read -r status check message <<< "$result"
                if [[ "$status" == "WARN" ]]; then
                    echo "  - $check: $message"
                fi
            done
            echo ""
        fi
        
        echo "Detailed results saved to: $report_file"
    } > "$summary_file"
    
    log_success "Validation report generated: $report_file"
    log_success "Validation summary generated: $summary_file"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    log_info "Starting Git Collaboration Lab validation"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --terraform)
                VALIDATE_TERRAFORM="true"
                shift
                ;;
            --no-terraform)
                VALIDATE_TERRAFORM="false"
                shift
                ;;
            --git)
                VALIDATE_GIT="true"
                shift
                ;;
            --no-git)
                VALIDATE_GIT="false"
                shift
                ;;
            --security)
                VALIDATE_SECURITY="true"
                shift
                ;;
            --no-security)
                VALIDATE_SECURITY="false"
                shift
                ;;
            --cost)
                VALIDATE_COST="true"
                shift
                ;;
            --no-cost)
                VALIDATE_COST="false"
                shift
                ;;
            --policy)
                VALIDATE_POLICY="true"
                shift
                ;;
            --no-policy)
                VALIDATE_POLICY="false"
                shift
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            --fail-fast)
                FAIL_FAST="true"
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
    
    # Run validations based on options
    if [[ "$VALIDATE_TERRAFORM" == "true" ]]; then
        validate_terraform_syntax
        validate_terraform_files
        validate_terraform_best_practices
    fi
    
    if [[ "$VALIDATE_GIT" == "true" ]]; then
        validate_git_repository
        validate_git_workflow
    fi
    
    if [[ "$VALIDATE_SECURITY" == "true" ]]; then
        validate_security_configuration
        run_security_tools
    fi
    
    if [[ "$VALIDATE_COST" == "true" ]]; then
        validate_cost_configuration
    fi
    
    if [[ "$VALIDATE_POLICY" == "true" ]]; then
        validate_policy_configuration
    fi
    
    # Generate report
    generate_report
    
    # Final summary
    log_info "Validation completed"
    log_info "Total checks: $TOTAL_CHECKS"
    log_info "Passed: $PASSED_CHECKS"
    log_info "Failed: $FAILED_CHECKS"
    log_info "Warnings: $WARNING_CHECKS"
    
    # Exit with appropriate code
    if [[ $FAILED_CHECKS -gt 0 ]]; then
        log_error "Validation failed with $FAILED_CHECKS failed checks"
        exit 1
    else
        log_success "All validations passed"
        exit 0
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
