#!/bin/bash

# IBM Cloud Schematics & Terraform Cloud Integration - Cleanup Script
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
LOG_FILE="$PROJECT_DIR/cleanup.log"

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

# Function to confirm cleanup
confirm_cleanup() {
    echo "=============================================="
    echo "IBM Cloud Schematics & Terraform Cloud Cleanup"
    echo "Topic 8.2: Advanced Integration Lab"
    echo "=============================================="
    echo ""
    print_warning "This script will destroy ALL resources created by this lab."
    print_warning "This action is IRREVERSIBLE!"
    echo ""
    print_status "Resources that will be destroyed:"
    echo "- IBM Cloud Schematics workspaces"
    echo "- Terraform Cloud workspaces (if configured)"
    echo "- IAM access groups and policies"
    echo "- Activity Tracker instances"
    echo "- Log Analysis instances"
    echo "- All associated tags and configurations"
    echo ""
    
    read -p "Are you sure you want to proceed? (type 'yes' to confirm): " confirmation
    
    if [ "$confirmation" != "yes" ]; then
        print_status "Cleanup cancelled by user"
        exit 0
    fi
    
    echo ""
    print_status "Proceeding with cleanup..."
}

# Function to backup current state
backup_state() {
    print_status "Creating backup of current state..."
    
    cd "$PROJECT_DIR"
    
    local backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup Terraform state
    if [ -f "terraform.tfstate" ]; then
        cp terraform.tfstate "$backup_dir/"
        print_success "Terraform state backed up"
    fi
    
    # Backup Terraform outputs
    if terraform output -json > "$backup_dir/outputs.json" 2>/dev/null; then
        print_success "Terraform outputs backed up"
    fi
    
    # Backup configuration files
    cp terraform.tfvars "$backup_dir/" 2>/dev/null || true
    cp *.tf "$backup_dir/" 2>/dev/null || true
    
    print_success "Backup created in: $backup_dir"
}

# Function to destroy Terraform resources
destroy_terraform_resources() {
    print_status "Destroying Terraform-managed resources..."
    
    cd "$PROJECT_DIR"
    
    # Check if state file exists
    if [ ! -f "terraform.tfstate" ] && [ ! -f ".terraform/terraform.tfstate" ]; then
        print_warning "No Terraform state found. Nothing to destroy."
        return 0
    fi
    
    # Create destroy plan
    print_status "Creating destroy plan..."
    if terraform plan -destroy -out=destroy.tfplan; then
        print_success "Destroy plan created"
    else
        print_error "Failed to create destroy plan"
        return 1
    fi
    
    # Apply destroy plan
    print_status "Applying destroy plan..."
    if terraform apply destroy.tfplan; then
        print_success "Terraform resources destroyed successfully"
    else
        print_error "Failed to destroy Terraform resources"
        return 1
    fi
    
    # Clean up plan file
    rm -f destroy.tfplan
}

# Function to clean up local files
cleanup_local_files() {
    print_status "Cleaning up local files..."
    
    cd "$PROJECT_DIR"
    
    # Remove Terraform state files
    rm -f terraform.tfstate*
    rm -f .terraform.lock.hcl
    
    # Remove Terraform plan files
    rm -f tfplan
    rm -f destroy.tfplan
    
    # Remove log files
    rm -f setup.log
    rm -f validation.log
    rm -f validation-report.json
    
    # Remove .terraform directory
    rm -rf .terraform/
    
    print_success "Local files cleaned up"
}

# Function to verify cleanup
verify_cleanup() {
    print_status "Verifying cleanup completion..."
    
    cd "$PROJECT_DIR"
    
    # Check if any state files remain
    if [ -f "terraform.tfstate" ] || [ -f ".terraform/terraform.tfstate" ]; then
        print_warning "Some Terraform state files still exist"
    else
        print_success "All Terraform state files removed"
    fi
    
    # Check if .terraform directory exists
    if [ -d ".terraform" ]; then
        print_warning ".terraform directory still exists"
    else
        print_success ".terraform directory removed"
    fi
    
    print_success "Cleanup verification completed"
}

# Function to display manual cleanup steps
show_manual_cleanup_steps() {
    print_status "Manual cleanup steps (if needed):"
    echo ""
    echo "If some resources were not destroyed automatically, you may need to:"
    echo ""
    echo "1. IBM Cloud Console cleanup:"
    echo "   - Go to https://cloud.ibm.com/schematics"
    echo "   - Delete any remaining workspaces manually"
    echo "   - Check IAM > Access groups for any remaining groups"
    echo "   - Review Observability services for Activity Tracker/Log Analysis instances"
    echo ""
    echo "2. Terraform Cloud cleanup:"
    echo "   - Go to https://app.terraform.io"
    echo "   - Delete any remaining workspaces in your organization"
    echo "   - Remove any workspace variables that were created"
    echo ""
    echo "3. Cost tracking cleanup:"
    echo "   - Review billing and usage for any unexpected charges"
    echo "   - Remove any budget alerts that were configured"
    echo ""
    echo "4. Local environment cleanup:"
    echo "   - Remove any environment variables that were set"
    echo "   - Clear any cached credentials"
    echo ""
}

# Function to display cleanup summary
show_cleanup_summary() {
    print_success "Cleanup completed successfully!"
    echo ""
    print_status "Summary of actions performed:"
    echo "- Terraform-managed resources destroyed"
    echo "- Local state and configuration files removed"
    echo "- Backup created for recovery if needed"
    echo ""
    print_status "What was cleaned up:"
    echo "- IBM Cloud Schematics workspaces"
    echo "- IAM access groups and policies"
    echo "- Monitoring and logging services"
    echo "- Terraform Cloud workspaces (if configured)"
    echo "- Local Terraform state and cache"
    echo ""
    print_status "Recovery options:"
    echo "- Backups are available in the 'backups/' directory"
    echo "- Configuration files can be reused for redeployment"
    echo "- Run './scripts/setup.sh' to redeploy the lab environment"
    echo ""
    print_warning "Important notes:"
    echo "- Some IBM Cloud resources may take time to be fully removed"
    echo "- Check your IBM Cloud billing to ensure no unexpected charges"
    echo "- Terraform Cloud workspaces may need manual deletion"
}

# Function to handle cleanup errors
handle_cleanup_errors() {
    print_error "Cleanup encountered errors!"
    echo ""
    print_status "Troubleshooting steps:"
    echo "1. Check the cleanup log: $LOG_FILE"
    echo "2. Verify IBM Cloud CLI authentication: ibmcloud account show"
    echo "3. Check Terraform Cloud authentication if applicable"
    echo "4. Try running specific cleanup commands manually:"
    echo "   - terraform destroy (for remaining resources)"
    echo "   - ibmcloud schematics workspace delete --id <workspace-id>"
    echo ""
    print_status "If problems persist:"
    echo "- Review the manual cleanup steps above"
    echo "- Contact your IBM Cloud administrator"
    echo "- Check IBM Cloud support documentation"
}

# Main execution
main() {
    # Initialize log file
    echo "Cleanup started at $(date)" > "$LOG_FILE"
    
    # Confirm cleanup with user
    confirm_cleanup
    
    # Perform cleanup steps
    if backup_state && destroy_terraform_resources; then
        cleanup_local_files
        verify_cleanup
        echo ""
        show_cleanup_summary
        show_manual_cleanup_steps
    else
        handle_cleanup_errors
        exit 1
    fi
}

# Handle script interruption
trap 'print_error "Cleanup interrupted! Some resources may not have been destroyed."; exit 1' INT TERM

# Run main function
main "$@"
