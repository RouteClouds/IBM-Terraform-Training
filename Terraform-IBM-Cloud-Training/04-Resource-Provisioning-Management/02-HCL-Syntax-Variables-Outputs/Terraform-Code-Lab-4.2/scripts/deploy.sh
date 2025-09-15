#!/bin/bash

# =============================================================================
# TERRAFORM DEPLOYMENT AUTOMATION SCRIPT
# Advanced HCL Configuration Lab - Topic 4.2
# =============================================================================

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_DIR/deployment.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
DRY_RUN=false
AUTO_APPROVE=false
ENVIRONMENT="development"
BACKUP_STATE=true

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
    echo "  TERRAFORM DEPLOYMENT AUTOMATION"
    echo "  Advanced HCL Configuration Lab - Topic 4.2"
    echo "============================================================================="
    echo -e "${NC}"
}

# Show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --dry-run          Perform a dry run (plan only)"
    echo "  -a, --auto-approve     Auto-approve the deployment"
    echo "  -e, --environment ENV  Set environment (development|staging|production)"
    echo "  -n, --no-backup        Skip state backup"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --dry-run                    # Plan only"
    echo "  $0 --environment production     # Deploy to production"
    echo "  $0 --auto-approve --no-backup   # Auto-deploy without backup"
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -a|--auto-approve)
                AUTO_APPROVE=true
                shift
                ;;
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -n|--no-backup)
                BACKUP_STATE=false
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Check prerequisites
check_prerequisites() {
    print_status "$BLUE" "🔍 Checking prerequisites..."
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_status "$RED" "❌ Terraform is not installed"
        exit 1
    fi
    
    local tf_version=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n1 | cut -d' ' -f2)
    print_status "$GREEN" "✅ Terraform version: $tf_version"
    
    # Check IBM Cloud CLI
    if ! command -v ibmcloud &> /dev/null; then
        print_status "$YELLOW" "⚠️  IBM Cloud CLI not found"
    else
        print_status "$GREEN" "✅ IBM Cloud CLI found"
    fi
    
    # Check authentication
    if [ -z "${IBMCLOUD_API_KEY:-}" ] && [ -z "${IC_API_KEY:-}" ]; then
        print_status "$YELLOW" "⚠️  IBM Cloud API key not found in environment variables"
        print_status "$YELLOW" "    Set IBMCLOUD_API_KEY or IC_API_KEY before deployment"
    else
        print_status "$GREEN" "✅ IBM Cloud API key found"
    fi
}

# Validate configuration
validate_configuration() {
    print_status "$BLUE" "🔧 Validating configuration..."
    
    cd "$PROJECT_DIR"
    
    # Check for required files
    local required_files=("providers.tf" "variables.tf" "main.tf" "outputs.tf")
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            print_status "$RED" "❌ Required file missing: $file"
            exit 1
        fi
    done
    
    # Check for terraform.tfvars
    if [ ! -f "terraform.tfvars" ]; then
        print_status "$YELLOW" "⚠️  terraform.tfvars not found"
        if [ -f "terraform.tfvars.example" ]; then
            print_status "$BLUE" "📋 Copy terraform.tfvars.example to terraform.tfvars and configure"
            print_status "$BLUE" "    cp terraform.tfvars.example terraform.tfvars"
        fi
        exit 1
    fi
    
    # Validate Terraform syntax
    if terraform validate; then
        print_status "$GREEN" "✅ Configuration validation passed"
    else
        print_status "$RED" "❌ Configuration validation failed"
        exit 1
    fi
}

# Backup state file
backup_state() {
    if [ "$BACKUP_STATE" = true ]; then
        print_status "$BLUE" "💾 Backing up Terraform state..."
        
        if [ -f "terraform.tfstate" ]; then
            local backup_file="terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)"
            cp terraform.tfstate "$backup_file"
            print_status "$GREEN" "✅ State backed up to: $backup_file"
        else
            print_status "$YELLOW" "⚠️  No existing state file to backup"
        fi
    fi
}

# Initialize Terraform
initialize_terraform() {
    print_status "$BLUE" "🚀 Initializing Terraform..."
    
    cd "$PROJECT_DIR"
    
    if terraform init; then
        print_status "$GREEN" "✅ Terraform initialization completed"
    else
        print_status "$RED" "❌ Terraform initialization failed"
        exit 1
    fi
}

# Plan deployment
plan_deployment() {
    print_status "$BLUE" "📋 Planning deployment..."
    
    cd "$PROJECT_DIR"
    
    local plan_file="terraform.plan"
    local plan_args="-out=$plan_file"
    
    # Add environment-specific variables if available
    if [ -f "environments/${ENVIRONMENT}.tfvars" ]; then
        plan_args="$plan_args -var-file=environments/${ENVIRONMENT}.tfvars"
        print_status "$BLUE" "📁 Using environment file: environments/${ENVIRONMENT}.tfvars"
    fi
    
    if terraform plan $plan_args; then
        print_status "$GREEN" "✅ Planning completed successfully"
        
        # Show plan summary
        print_status "$CYAN" "📊 Plan Summary:"
        terraform show -no-color "$plan_file" | grep -E "Plan:|No changes" || true
        
        return 0
    else
        print_status "$RED" "❌ Planning failed"
        exit 1
    fi
}

# Apply deployment
apply_deployment() {
    print_status "$BLUE" "🚀 Applying deployment..."
    
    cd "$PROJECT_DIR"
    
    local plan_file="terraform.plan"
    
    if [ ! -f "$plan_file" ]; then
        print_status "$RED" "❌ Plan file not found. Run planning first."
        exit 1
    fi
    
    local apply_args="$plan_file"
    
    if [ "$AUTO_APPROVE" = true ]; then
        print_status "$YELLOW" "⚠️  Auto-approve enabled - applying without confirmation"
        if terraform apply "$apply_args"; then
            print_status "$GREEN" "✅ Deployment completed successfully"
        else
            print_status "$RED" "❌ Deployment failed"
            exit 1
        fi
    else
        print_status "$BLUE" "🤔 Review the plan above and confirm deployment"
        echo -e "${YELLOW}Do you want to apply this deployment? (yes/no): ${NC}"
        read -r confirmation
        
        case $confirmation in
            yes|y|Y|YES)
                if terraform apply "$apply_args"; then
                    print_status "$GREEN" "✅ Deployment completed successfully"
                else
                    print_status "$RED" "❌ Deployment failed"
                    exit 1
                fi
                ;;
            *)
                print_status "$YELLOW" "⏹️  Deployment cancelled by user"
                exit 0
                ;;
        esac
    fi
}

# Show outputs
show_outputs() {
    print_status "$BLUE" "📤 Deployment Outputs:"
    
    cd "$PROJECT_DIR"
    
    if terraform output -json > outputs.json 2>/dev/null; then
        # Show key outputs
        if command -v jq &> /dev/null; then
            echo ""
            print_status "$CYAN" "🏗️  Deployment Summary:"
            terraform output deployment_summary 2>/dev/null || echo "  Deployment summary not available"
            
            echo ""
            print_status "$CYAN" "💰 Cost Analysis:"
            terraform output cost_analysis 2>/dev/null || echo "  Cost analysis not available"
            
            echo ""
            print_status "$CYAN" "🔧 Configuration Status:"
            terraform output configuration_status 2>/dev/null || echo "  Configuration status not available"
        else
            terraform output
        fi
        
        print_status "$GREEN" "✅ Outputs saved to: outputs.json"
    else
        print_status "$YELLOW" "⚠️  No outputs available or deployment not completed"
    fi
}

# Generate deployment report
generate_deployment_report() {
    print_status "$BLUE" "📊 Generating deployment report..."
    
    local report_file="$PROJECT_DIR/deployment_report.json"
    
    cat > "$report_file" << EOF
{
  "deployment": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "environment": "$ENVIRONMENT",
    "dry_run": $DRY_RUN,
    "auto_approve": $AUTO_APPROVE,
    "backup_created": $BACKUP_STATE,
    "terraform_version": "$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || echo 'unknown')",
    "status": "completed"
  },
  "configuration": {
    "project_directory": "$PROJECT_DIR",
    "log_file": "$LOG_FILE",
    "plan_file": "terraform.plan",
    "outputs_file": "outputs.json"
  },
  "next_steps": [
    "Review deployment outputs for configuration details",
    "Monitor resource utilization and costs",
    "Implement monitoring and alerting",
    "Schedule regular backups and maintenance",
    "Review security configurations and compliance"
  ]
}
EOF
    
    print_status "$GREEN" "✅ Deployment report saved to: $report_file"
}

# Cleanup temporary files
cleanup() {
    print_status "$BLUE" "🧹 Cleaning up temporary files..."
    
    cd "$PROJECT_DIR"
    
    # Remove plan file if not needed
    if [ -f "terraform.plan" ] && [ "$DRY_RUN" = false ]; then
        rm -f terraform.plan
        print_status "$GREEN" "✅ Removed plan file"
    fi
    
    # Clean up old backup files (keep last 5)
    if ls terraform.tfstate.backup.* 1> /dev/null 2>&1; then
        ls -t terraform.tfstate.backup.* | tail -n +6 | xargs rm -f 2>/dev/null || true
        print_status "$GREEN" "✅ Cleaned up old backup files"
    fi
}

# Main execution
main() {
    print_header
    
    # Parse arguments
    parse_arguments "$@"
    
    # Initialize log file
    echo "Deployment started at $(date)" > "$LOG_FILE"
    log "Environment: $ENVIRONMENT"
    log "Dry run: $DRY_RUN"
    log "Auto approve: $AUTO_APPROVE"
    log "Backup state: $BACKUP_STATE"
    
    # Run deployment steps
    check_prerequisites
    validate_configuration
    backup_state
    initialize_terraform
    plan_deployment
    
    if [ "$DRY_RUN" = true ]; then
        print_status "$YELLOW" "🔍 Dry run completed - no resources were created"
        print_status "$BLUE" "📋 Review the plan above and run without --dry-run to apply"
    else
        apply_deployment
        show_outputs
        generate_deployment_report
        cleanup
        
        print_status "$GREEN" "🎉 Deployment completed successfully!"
        print_status "$BLUE" "📋 Check deployment.log for detailed results"
        print_status "$BLUE" "📊 Review deployment_report.json for summary"
    fi
}

# Error handling
trap 'print_status "$RED" "❌ Deployment failed with error on line $LINENO"' ERR

# Execute main function
main "$@"
