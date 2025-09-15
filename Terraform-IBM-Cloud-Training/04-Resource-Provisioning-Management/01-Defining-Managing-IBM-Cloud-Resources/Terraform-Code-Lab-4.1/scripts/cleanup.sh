#!/bin/bash
# =============================================================================
# CLEANUP SCRIPT
# Topic 4.1: Defining and Managing IBM Cloud Resources
# =============================================================================

set -e

echo "🧹 Terraform Lab 4.1 Cleanup Script"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Function to confirm action
confirm_action() {
    local message=$1
    echo ""
    print_status "WARNING" "$message"
    read -p "Are you sure you want to continue? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_status "INFO" "Operation cancelled"
        exit 0
    fi
}

# =============================================================================
# CLEANUP OPTIONS
# =============================================================================

echo ""
echo "🗂️ Cleanup Options:"
echo "1. Destroy infrastructure only (keep Terraform files)"
echo "2. Full cleanup (destroy infrastructure + remove Terraform files)"
echo "3. Clean temporary files only"
echo "4. Cancel"
echo ""

read -p "Select option (1-4): " -r CLEANUP_OPTION

case $CLEANUP_OPTION in
    1)
        CLEANUP_TYPE="infrastructure"
        ;;
    2)
        CLEANUP_TYPE="full"
        ;;
    3)
        CLEANUP_TYPE="temp"
        ;;
    4)
        print_status "INFO" "Cleanup cancelled"
        exit 0
        ;;
    *)
        print_status "ERROR" "Invalid option selected"
        exit 1
        ;;
esac

# =============================================================================
# INFRASTRUCTURE CLEANUP
# =============================================================================

if [ "$CLEANUP_TYPE" = "infrastructure" ] || [ "$CLEANUP_TYPE" = "full" ]; then
    echo ""
    echo "🏗️ Infrastructure Cleanup..."
    echo "----------------------------"
    
    # Check if Terraform state exists
    if [ ! -f "terraform.tfstate" ]; then
        print_status "WARNING" "No Terraform state file found"
        print_status "INFO" "Infrastructure may already be destroyed or never deployed"
    else
        # Show current infrastructure
        echo ""
        print_status "INFO" "Current infrastructure:"
        terraform state list 2>/dev/null || print_status "WARNING" "Unable to list current state"
        
        # Get estimated cost before destruction
        if command -v jq &> /dev/null && [ -f "terraform.tfstate" ]; then
            RESOURCE_COUNT=$(terraform state list | wc -l)
            print_status "INFO" "Found $RESOURCE_COUNT resources to destroy"
        fi
        
        confirm_action "This will DESTROY all infrastructure resources in IBM Cloud"
        
        echo ""
        print_status "INFO" "Generating destruction plan..."
        
        # Generate destroy plan
        if terraform plan -destroy -out=destroy.tfplan; then
            print_status "SUCCESS" "Destruction plan generated"
            
            echo ""
            print_status "INFO" "Destruction plan summary:"
            terraform show destroy.tfplan | grep -E "^  # " | head -20
            
            confirm_action "Execute the destruction plan"
            
            # Execute destruction
            echo ""
            print_status "INFO" "Destroying infrastructure..."
            
            if terraform apply destroy.tfplan; then
                print_status "SUCCESS" "Infrastructure destroyed successfully"
                
                # Clean up plan file
                rm -f destroy.tfplan
                
                # Verify destruction
                REMAINING_RESOURCES=$(terraform state list 2>/dev/null | wc -l)
                if [ "$REMAINING_RESOURCES" -eq 0 ]; then
                    print_status "SUCCESS" "All resources destroyed"
                else
                    print_status "WARNING" "$REMAINING_RESOURCES resources may still exist"
                fi
                
            else
                print_status "ERROR" "Infrastructure destruction failed"
                print_status "INFO" "Check the error messages above and retry"
                exit 1
            fi
            
        else
            print_status "ERROR" "Failed to generate destruction plan"
            exit 1
        fi
    fi
fi

# =============================================================================
# TERRAFORM FILES CLEANUP
# =============================================================================

if [ "$CLEANUP_TYPE" = "full" ]; then
    echo ""
    echo "📁 Terraform Files Cleanup..."
    echo "-----------------------------"
    
    confirm_action "This will remove ALL Terraform files and state"
    
    # Remove Terraform state files
    if [ -f "terraform.tfstate" ]; then
        rm -f terraform.tfstate
        print_status "SUCCESS" "Removed terraform.tfstate"
    fi
    
    if [ -f "terraform.tfstate.backup" ]; then
        rm -f terraform.tfstate.backup
        print_status "SUCCESS" "Removed terraform.tfstate.backup"
    fi
    
    # Remove Terraform directory
    if [ -d ".terraform" ]; then
        rm -rf .terraform
        print_status "SUCCESS" "Removed .terraform directory"
    fi
    
    # Remove lock file
    if [ -f ".terraform.lock.hcl" ]; then
        rm -f .terraform.lock.hcl
        print_status "SUCCESS" "Removed .terraform.lock.hcl"
    fi
    
    # Remove variable files (keep examples)
    if [ -f "terraform.tfvars" ]; then
        rm -f terraform.tfvars
        print_status "SUCCESS" "Removed terraform.tfvars"
    fi
fi

# =============================================================================
# TEMPORARY FILES CLEANUP
# =============================================================================

echo ""
echo "🗑️ Temporary Files Cleanup..."
echo "-----------------------------"

# Remove plan files
for plan_file in *.tfplan destroy.tfplan; do
    if [ -f "$plan_file" ]; then
        rm -f "$plan_file"
        print_status "SUCCESS" "Removed $plan_file"
    fi
done

# Remove log files
for log_file in *.log terraform.log crash.log; do
    if [ -f "$log_file" ]; then
        rm -f "$log_file"
        print_status "SUCCESS" "Removed $log_file"
    fi
done

# Remove temporary directories
for temp_dir in tmp temp .tmp; do
    if [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
        print_status "SUCCESS" "Removed $temp_dir directory"
    fi
done

# Remove backup files
for backup_file in *.backup *.bak *~; do
    if [ -f "$backup_file" ]; then
        rm -f "$backup_file"
        print_status "SUCCESS" "Removed $backup_file"
    fi
done

# =============================================================================
# VERIFICATION
# =============================================================================

echo ""
echo "🔍 Cleanup Verification..."
echo "-------------------------"

# Check for remaining Terraform files
TERRAFORM_FILES=$(find . -name "*.tfstate*" -o -name "*.tfplan*" -o -name ".terraform" 2>/dev/null | wc -l)
if [ "$TERRAFORM_FILES" -eq 0 ]; then
    print_status "SUCCESS" "No Terraform state or plan files remaining"
else
    print_status "WARNING" "Some Terraform files may still exist"
fi

# Check for remaining log files
LOG_FILES=$(find . -name "*.log" 2>/dev/null | wc -l)
if [ "$LOG_FILES" -eq 0 ]; then
    print_status "SUCCESS" "No log files remaining"
else
    print_status "INFO" "$LOG_FILES log files found (may be intentional)"
fi

# =============================================================================
# CLEANUP SUMMARY
# =============================================================================

echo ""
echo "📋 Cleanup Summary"
echo "=================="

case $CLEANUP_TYPE in
    "infrastructure")
        print_status "SUCCESS" "Infrastructure cleanup completed"
        print_status "INFO" "Terraform configuration files preserved"
        ;;
    "full")
        print_status "SUCCESS" "Full cleanup completed"
        print_status "INFO" "All infrastructure and Terraform files removed"
        ;;
    "temp")
        print_status "SUCCESS" "Temporary files cleanup completed"
        print_status "INFO" "Infrastructure and configuration files preserved"
        ;;
esac

echo ""
echo "🎯 Next Steps:"

if [ "$CLEANUP_TYPE" = "full" ]; then
    echo "1. Re-initialize if you want to deploy again: terraform init"
    echo "2. Copy terraform.tfvars.example to terraform.tfvars"
    echo "3. Update terraform.tfvars with your configuration"
    echo "4. Deploy: terraform apply"
elif [ "$CLEANUP_TYPE" = "infrastructure" ]; then
    echo "1. Re-deploy if needed: terraform apply"
    echo "2. Review and update configuration as needed"
    echo "3. Consider implementing remote state for team collaboration"
else
    echo "1. Continue working with your Terraform configuration"
    echo "2. Deploy infrastructure: terraform apply"
fi

echo ""
echo "📚 Additional Resources:"
echo "- IBM Cloud Console: https://cloud.ibm.com"
echo "- Terraform Documentation: https://terraform.io/docs"
echo "- IBM Provider Documentation: https://registry.terraform.io/providers/IBM-Cloud/ibm"

print_status "SUCCESS" "Cleanup script completed successfully"
