#!/bin/bash

# IBM Cloud Schematics & Terraform Cloud Integration - Validation Script
# Topic 8.2: Advanced Integration Lab Environment
# Version: 1.0.0

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_DIR/validation.log"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get Terraform output
get_terraform_output() {
    local output_name="$1"
    cd "$PROJECT_DIR"
    terraform output -raw "$output_name" 2>/dev/null || echo ""
}

# Function to validate Schematics workspace
validate_schematics_workspace() {
    print_status "Validating Schematics workspace..."
    
    local workspace_id
    workspace_id=$(get_terraform_output "schematics_workspace_id")
    
    if [ -z "$workspace_id" ]; then
        print_error "Schematics workspace ID not found in Terraform outputs"
        return 1
    fi
    
    print_status "Checking workspace: $workspace_id"
    
    # Check workspace status using IBM Cloud CLI
    if command_exists ibmcloud; then
        local workspace_status
        workspace_status=$(ibmcloud schematics workspace get --id "$workspace_id" --output json 2>/dev/null | jq -r '.status // "unknown"')
        
        case "$workspace_status" in
            "ACTIVE")
                print_success "Schematics workspace is active"
                ;;
            "INACTIVE")
                print_warning "Schematics workspace is inactive"
                ;;
            "FAILED")
                print_error "Schematics workspace is in failed state"
                return 1
                ;;
            *)
                print_warning "Schematics workspace status: $workspace_status"
                ;;
        esac
    else
        print_warning "IBM Cloud CLI not available for workspace validation"
    fi
}

# Function to validate network workspace
validate_network_workspace() {
    print_status "Validating network dependency workspace..."
    
    local network_workspace_id
    network_workspace_id=$(get_terraform_output "network_workspace_id")
    
    if [ -z "$network_workspace_id" ]; then
        print_error "Network workspace ID not found in Terraform outputs"
        return 1
    fi
    
    print_success "Network workspace found: $network_workspace_id"
}

# Function to validate Terraform Cloud integration
validate_terraform_cloud() {
    print_status "Validating Terraform Cloud integration..."
    
    local tf_cloud_workspace_id
    tf_cloud_workspace_id=$(get_terraform_output "terraform_cloud_workspace_id")
    
    if [ -z "$tf_cloud_workspace_id" ]; then
        print_warning "Terraform Cloud workspace not configured or integration disabled"
        return 0
    fi
    
    local tf_cloud_workspace_name
    tf_cloud_workspace_name=$(get_terraform_output "terraform_cloud_workspace_name")
    
    print_success "Terraform Cloud workspace: $tf_cloud_workspace_name"
    
    # Validate workspace URL accessibility
    local tf_cloud_url
    tf_cloud_url=$(get_terraform_output "terraform_cloud_workspace_url")
    
    if [ -n "$tf_cloud_url" ]; then
        print_status "Terraform Cloud workspace URL: $tf_cloud_url"
    fi
}

# Function to validate IAM access group
validate_iam_access_group() {
    print_status "Validating IAM access group..."
    
    local access_group_id
    access_group_id=$(get_terraform_output "iam_access_group_id")
    
    if [ -z "$access_group_id" ]; then
        print_error "IAM access group ID not found in Terraform outputs"
        return 1
    fi
    
    local access_group_name
    access_group_name=$(get_terraform_output "iam_access_group_name")
    
    print_success "IAM access group: $access_group_name ($access_group_id)"
    
    local team_members_count
    team_members_count=$(get_terraform_output "team_members_count")
    
    print_status "Team members configured: $team_members_count"
}

# Function to validate monitoring services
validate_monitoring() {
    print_status "Validating monitoring and logging services..."
    
    local activity_tracker_id
    activity_tracker_id=$(get_terraform_output "activity_tracker_id")
    
    if [ -n "$activity_tracker_id" ]; then
        print_success "Activity Tracker configured: $activity_tracker_id"
    else
        print_warning "Activity Tracker not configured"
    fi
    
    local log_analysis_id
    log_analysis_id=$(get_terraform_output "log_analysis_id")
    
    if [ -n "$log_analysis_id" ]; then
        print_success "Log Analysis configured: $log_analysis_id"
    else
        print_warning "Log Analysis not configured"
    fi
}

# Function to validate cost tracking
validate_cost_tracking() {
    print_status "Validating cost tracking configuration..."
    
    local budget_config
    budget_config=$(get_terraform_output "budget_configuration")
    
    if [ -n "$budget_config" ]; then
        print_success "Budget configuration found"
        
        # Parse budget configuration
        local budget_limit
        budget_limit=$(echo "$budget_config" | jq -r '.budget_limit // "unknown"')
        
        local alert_threshold
        alert_threshold=$(echo "$budget_config" | jq -r '.alert_threshold // "unknown"')
        
        print_status "Budget limit: \$${budget_limit}, Alert threshold: ${alert_threshold}%"
    else
        print_warning "Budget configuration not found"
    fi
}

# Function to validate resource accessibility
validate_resource_access() {
    print_status "Validating resource accessibility..."
    
    local quick_access_urls
    quick_access_urls=$(get_terraform_output "quick_access_urls")
    
    if [ -n "$quick_access_urls" ]; then
        print_success "Quick access URLs configured"
        
        # Extract and display key URLs
        local schematics_console
        schematics_console=$(echo "$quick_access_urls" | jq -r '.schematics_console // ""')
        
        if [ -n "$schematics_console" ]; then
            print_status "Schematics Console: $schematics_console"
        fi
        
        local main_workspace_url
        main_workspace_url=$(echo "$quick_access_urls" | jq -r '.main_workspace // ""')
        
        if [ -n "$main_workspace_url" ]; then
            print_status "Main Workspace: $main_workspace_url"
        fi
    fi
}

# Function to validate integration status
validate_integration_status() {
    print_status "Validating integration status..."
    
    local integration_status
    integration_status=$(get_terraform_output "integration_status")
    
    if [ -n "$integration_status" ]; then
        print_success "Integration status retrieved"
        
        # Parse integration status
        local tf_cloud_enabled
        tf_cloud_enabled=$(echo "$integration_status" | jq -r '.terraform_cloud_integration // false')
        
        local cost_tracking_enabled
        cost_tracking_enabled=$(echo "$integration_status" | jq -r '.cost_tracking_enabled // false')
        
        local audit_logging_enabled
        audit_logging_enabled=$(echo "$integration_status" | jq -r '.audit_logging_enabled // false')
        
        local monitoring_enabled
        monitoring_enabled=$(echo "$integration_status" | jq -r '.monitoring_enabled // false')
        
        print_status "Terraform Cloud Integration: $tf_cloud_enabled"
        print_status "Cost Tracking: $cost_tracking_enabled"
        print_status "Audit Logging: $audit_logging_enabled"
        print_status "Monitoring: $monitoring_enabled"
    fi
}

# Function to run connectivity tests
run_connectivity_tests() {
    print_status "Running connectivity tests..."
    
    # Test IBM Cloud API connectivity
    if command_exists ibmcloud; then
        if ibmcloud account show >/dev/null 2>&1; then
            print_success "IBM Cloud API connectivity: OK"
        else
            print_warning "IBM Cloud API connectivity: Failed (not logged in)"
        fi
    fi
    
    # Test Terraform Cloud connectivity (if configured)
    local tf_cloud_org
    tf_cloud_org=$(get_terraform_output "terraform_cloud_organization")
    
    if [ -n "$tf_cloud_org" ] && [ "$tf_cloud_org" != "null" ]; then
        print_status "Testing Terraform Cloud connectivity..."
        
        if command_exists curl; then
            if curl -s -f "https://app.terraform.io/api/v2/organizations/$tf_cloud_org" >/dev/null; then
                print_success "Terraform Cloud API connectivity: OK"
            else
                print_warning "Terraform Cloud API connectivity: Failed"
            fi
        fi
    fi
}

# Function to generate validation report
generate_validation_report() {
    print_status "Generating validation report..."
    
    local report_file="$PROJECT_DIR/validation-report.json"
    
    cd "$PROJECT_DIR"
    
    # Create comprehensive validation report
    cat > "$report_file" << EOF
{
  "validation_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "terraform_outputs": $(terraform output -json 2>/dev/null || echo "{}"),
  "validation_status": {
    "schematics_workspace": "$(validate_schematics_workspace >/dev/null 2>&1 && echo "PASS" || echo "FAIL")",
    "network_workspace": "$(validate_network_workspace >/dev/null 2>&1 && echo "PASS" || echo "FAIL")",
    "terraform_cloud": "$(validate_terraform_cloud >/dev/null 2>&1 && echo "PASS" || echo "FAIL")",
    "iam_access_group": "$(validate_iam_access_group >/dev/null 2>&1 && echo "PASS" || echo "FAIL")",
    "monitoring": "$(validate_monitoring >/dev/null 2>&1 && echo "PASS" || echo "FAIL")",
    "cost_tracking": "$(validate_cost_tracking >/dev/null 2>&1 && echo "PASS" || echo "FAIL")"
  }
}
EOF
    
    print_success "Validation report saved: $report_file"
}

# Function to display summary
show_validation_summary() {
    print_success "Validation completed!"
    echo ""
    print_status "Summary:"
    echo "- Schematics workspace validation completed"
    echo "- Network workspace dependency validated"
    echo "- Terraform Cloud integration checked"
    echo "- IAM access control validated"
    echo "- Monitoring and logging services checked"
    echo "- Cost tracking configuration verified"
    echo ""
    print_status "Next steps:"
    echo "1. Review validation report: validation-report.json"
    echo "2. Access workspaces using the provided URLs"
    echo "3. Test workspace functionality with sample deployments"
    echo "4. Configure team access and permissions as needed"
    echo ""
    print_status "Troubleshooting:"
    echo "- Check validation.log for detailed information"
    echo "- Run terraform output to see all available values"
    echo "- Use IBM Cloud console to verify resource status"
}

# Main execution
main() {
    echo "=================================================="
    echo "IBM Cloud Schematics & Terraform Cloud Validation"
    echo "Topic 8.2: Advanced Integration Lab"
    echo "=================================================="
    echo ""
    
    # Initialize log file
    echo "Validation started at $(date)" > "$LOG_FILE"
    
    # Check if Terraform state exists
    cd "$PROJECT_DIR"
    if [ ! -f "terraform.tfstate" ] && [ ! -f ".terraform/terraform.tfstate" ]; then
        print_error "No Terraform state found. Please run 'terraform apply' first."
        exit 1
    fi
    
    # Run validation steps
    validate_schematics_workspace
    validate_network_workspace
    validate_terraform_cloud
    validate_iam_access_group
    validate_monitoring
    validate_cost_tracking
    validate_resource_access
    validate_integration_status
    run_connectivity_tests
    generate_validation_report
    
    echo ""
    show_validation_summary
}

# Run main function
main "$@"
