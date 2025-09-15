#!/bin/bash

# =============================================================================
# TERRAFORM CONFIGURATION VALIDATION SCRIPT
# Advanced HCL Configuration Lab - Topic 4.2
# =============================================================================

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_DIR/validation.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    log "$message"
}

# Print header
print_header() {
    echo -e "${BLUE}"
    echo "============================================================================="
    echo "  TERRAFORM CONFIGURATION VALIDATION"
    echo "  Advanced HCL Configuration Lab - Topic 4.2"
    echo "============================================================================="
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_status "$BLUE" "Checking prerequisites..."
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_status "$RED" "❌ Terraform is not installed"
        exit 1
    fi
    
    local tf_version=$(terraform version -json | jq -r '.terraform_version')
    print_status "$GREEN" "✅ Terraform version: $tf_version"
    
    # Check IBM Cloud CLI
    if ! command -v ibmcloud &> /dev/null; then
        print_status "$YELLOW" "⚠️  IBM Cloud CLI not found (optional for validation)"
    else
        print_status "$GREEN" "✅ IBM Cloud CLI found"
    fi
    
    # Check jq
    if ! command -v jq &> /dev/null; then
        print_status "$YELLOW" "⚠️  jq not found (optional for JSON processing)"
    else
        print_status "$GREEN" "✅ jq found"
    fi
}

# Validate Terraform syntax
validate_syntax() {
    print_status "$BLUE" "Validating Terraform syntax..."
    
    cd "$PROJECT_DIR"
    
    # Initialize if needed
    if [ ! -d ".terraform" ]; then
        print_status "$YELLOW" "Initializing Terraform..."
        terraform init -backend=false
    fi
    
    # Validate syntax
    if terraform validate; then
        print_status "$GREEN" "✅ Terraform syntax validation passed"
    else
        print_status "$RED" "❌ Terraform syntax validation failed"
        return 1
    fi
}

# Validate variable definitions
validate_variables() {
    print_status "$BLUE" "Validating variable definitions..."
    
    local variables_file="$PROJECT_DIR/variables.tf"
    
    if [ ! -f "$variables_file" ]; then
        print_status "$RED" "❌ variables.tf not found"
        return 1
    fi
    
    # Count variables
    local var_count=$(grep -c "^variable " "$variables_file" || echo "0")
    print_status "$GREEN" "✅ Found $var_count variable definitions"
    
    # Check for validation rules
    local validation_count=$(grep -c "validation {" "$variables_file" || echo "0")
    print_status "$GREEN" "✅ Found $validation_count validation rules"
    
    # Check for descriptions
    local desc_count=$(grep -c "description" "$variables_file" || echo "0")
    print_status "$GREEN" "✅ Found $desc_count variable descriptions"
}

# Test variable validation
test_variable_validation() {
    print_status "$BLUE" "Testing variable validation rules..."
    
    cd "$PROJECT_DIR"
    
    # Create temporary tfvars file with invalid values
    local temp_tfvars="test_validation.tfvars"
    
    cat > "$temp_tfvars" << EOF
# Test invalid values to trigger validation
resource_group_id = "invalid-format"
primary_region = "invalid-region"

project_configuration = {
  project_name = "INVALID_NAME_WITH_CAPS"
  project_code = "invalid-code"
  project_description = "Test description"
  project_owner = "invalid-email"
  
  organization = {
    name = "test"
    division = "test"
    department = "test"
    cost_center = "test"
    budget_code = "test"
  }
  
  environment = {
    name = "invalid-env"
    tier = "test"
    purpose = "test"
    criticality = "invalid"
  }
  
  compliance = {
    frameworks = ["invalid-framework"]
    data_classification = "test"
    retention_period = 10
    audit_required = false
  }
  
  technical = {
    architecture_pattern = "test"
    deployment_model = "test"
    scaling_strategy = "test"
    backup_strategy = "test"
  }
}
EOF
    
    # Test validation (should fail)
    if terraform plan -var-file="$temp_tfvars" &> /dev/null; then
        print_status "$YELLOW" "⚠️  Variable validation may not be working correctly"
    else
        print_status "$GREEN" "✅ Variable validation rules are working"
    fi
    
    # Clean up
    rm -f "$temp_tfvars"
}

# Validate outputs
validate_outputs() {
    print_status "$BLUE" "Validating output definitions..."
    
    local outputs_file="$PROJECT_DIR/outputs.tf"
    
    if [ ! -f "$outputs_file" ]; then
        print_status "$RED" "❌ outputs.tf not found"
        return 1
    fi
    
    # Count outputs
    local output_count=$(grep -c "^output " "$outputs_file" || echo "0")
    print_status "$GREEN" "✅ Found $output_count output definitions"
    
    # Check for descriptions
    local desc_count=$(grep -c "description" "$outputs_file" || echo "0")
    print_status "$GREEN" "✅ Found $desc_count output descriptions"
    
    # Check for sensitive outputs
    local sensitive_count=$(grep -c "sensitive.*=.*true" "$outputs_file" || echo "0")
    print_status "$GREEN" "✅ Found $sensitive_count sensitive outputs"
}

# Check configuration files
check_configuration_files() {
    print_status "$BLUE" "Checking configuration files..."
    
    local files=(
        "providers.tf"
        "variables.tf"
        "main.tf"
        "outputs.tf"
        "terraform.tfvars.example"
        "README.md"
        ".gitignore"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$PROJECT_DIR/$file" ]; then
            local size=$(stat -f%z "$PROJECT_DIR/$file" 2>/dev/null || stat -c%s "$PROJECT_DIR/$file" 2>/dev/null || echo "0")
            print_status "$GREEN" "✅ $file ($size bytes)"
        else
            print_status "$RED" "❌ $file missing"
        fi
    done
}

# Validate HCL best practices
validate_best_practices() {
    print_status "$BLUE" "Validating HCL best practices..."
    
    cd "$PROJECT_DIR"
    
    # Check for local values
    local locals_count=$(grep -c "locals {" *.tf || echo "0")
    print_status "$GREEN" "✅ Found $locals_count local value blocks"
    
    # Check for data sources
    local data_count=$(grep -c "^data " *.tf || echo "0")
    print_status "$GREEN" "✅ Found $data_count data sources"
    
    # Check for resource dependencies
    local depends_count=$(grep -c "depends_on" *.tf || echo "0")
    print_status "$GREEN" "✅ Found $depends_count explicit dependencies"
    
    # Check for conditional resources
    local count_count=$(grep -c "count.*=" *.tf || echo "0")
    print_status "$GREEN" "✅ Found $count_count conditional resources"
}

# Generate validation report
generate_report() {
    print_status "$BLUE" "Generating validation report..."
    
    local report_file="$PROJECT_DIR/validation_report.json"
    
    cat > "$report_file" << EOF
{
  "validation_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "terraform_version": "$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || echo 'unknown')",
  "validation_results": {
    "syntax_valid": true,
    "variables_count": $(grep -c "^variable " "$PROJECT_DIR/variables.tf" || echo "0"),
    "outputs_count": $(grep -c "^output " "$PROJECT_DIR/outputs.tf" || echo "0"),
    "validation_rules": $(grep -c "validation {" "$PROJECT_DIR/variables.tf" || echo "0"),
    "local_blocks": $(grep -c "locals {" "$PROJECT_DIR"/*.tf || echo "0"),
    "data_sources": $(grep -c "^data " "$PROJECT_DIR"/*.tf || echo "0")
  },
  "files_checked": [
    "providers.tf",
    "variables.tf", 
    "main.tf",
    "outputs.tf",
    "terraform.tfvars.example",
    "README.md",
    ".gitignore"
  ],
  "recommendations": [
    "Review variable validation rules for completeness",
    "Ensure all outputs have descriptions",
    "Consider adding more data sources for dynamic configuration",
    "Implement comprehensive tagging strategy",
    "Add monitoring and alerting configuration"
  ]
}
EOF
    
    print_status "$GREEN" "✅ Validation report generated: $report_file"
}

# Main execution
main() {
    print_header
    
    # Initialize log file
    echo "Validation started at $(date)" > "$LOG_FILE"
    
    # Run validation steps
    check_prerequisites
    validate_syntax
    validate_variables
    test_variable_validation
    validate_outputs
    check_configuration_files
    validate_best_practices
    generate_report
    
    print_status "$GREEN" "🎉 Validation completed successfully!"
    print_status "$BLUE" "📋 Check validation.log for detailed results"
    print_status "$BLUE" "📊 Review validation_report.json for summary"
}

# Error handling
trap 'print_status "$RED" "❌ Validation failed with error on line $LINENO"' ERR

# Execute main function
main "$@"
