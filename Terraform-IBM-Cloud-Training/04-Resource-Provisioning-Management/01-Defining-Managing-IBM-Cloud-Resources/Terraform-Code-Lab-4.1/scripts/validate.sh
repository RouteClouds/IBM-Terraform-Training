#!/bin/bash
# =============================================================================
# TERRAFORM VALIDATION SCRIPT
# Topic 4.1: Defining and Managing IBM Cloud Resources
# =============================================================================

set -e

echo "🔍 Terraform Lab 4.1 Validation Script"
echo "======================================="

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

# Function to check command availability
check_command() {
    if command -v $1 &> /dev/null; then
        print_status "SUCCESS" "$1 is installed"
        return 0
    else
        print_status "ERROR" "$1 is not installed"
        return 1
    fi
}

# =============================================================================
# PREREQUISITE CHECKS
# =============================================================================

echo ""
echo "📋 Checking Prerequisites..."
echo "----------------------------"

# Check required commands
COMMANDS_OK=true
for cmd in terraform jq curl; do
    if ! check_command $cmd; then
        COMMANDS_OK=false
    fi
done

if [ "$COMMANDS_OK" = false ]; then
    print_status "ERROR" "Missing required commands. Please install missing tools."
    exit 1
fi

# Check Terraform version
TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
print_status "INFO" "Terraform version: $TERRAFORM_VERSION"

# =============================================================================
# CONFIGURATION VALIDATION
# =============================================================================

echo ""
echo "🔧 Validating Terraform Configuration..."
echo "----------------------------------------"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_status "WARNING" "terraform.tfvars not found"
    print_status "INFO" "Copy terraform.tfvars.example to terraform.tfvars and update with your values"
else
    print_status "SUCCESS" "terraform.tfvars found"
fi

# Terraform format check
if terraform fmt -check=true -diff=true; then
    print_status "SUCCESS" "Terraform code is properly formatted"
else
    print_status "WARNING" "Terraform code formatting issues found"
    print_status "INFO" "Run 'terraform fmt' to fix formatting"
fi

# Terraform validation
if terraform validate; then
    print_status "SUCCESS" "Terraform configuration is valid"
else
    print_status "ERROR" "Terraform configuration validation failed"
    exit 1
fi

# =============================================================================
# ENVIRONMENT VALIDATION
# =============================================================================

echo ""
echo "🌍 Validating Environment..."
echo "----------------------------"

# Check for IBM Cloud API key
if [ -z "$IBMCLOUD_API_KEY" ] && [ -z "$TF_VAR_ibmcloud_api_key" ]; then
    if grep -q "YOUR_IBM_CLOUD_API_KEY_HERE" terraform.tfvars 2>/dev/null; then
        print_status "ERROR" "IBM Cloud API key not configured"
        print_status "INFO" "Set IBMCLOUD_API_KEY environment variable or update terraform.tfvars"
    else
        print_status "SUCCESS" "IBM Cloud API key configured in terraform.tfvars"
    fi
else
    print_status "SUCCESS" "IBM Cloud API key configured via environment variable"
fi

# =============================================================================
# TERRAFORM INITIALIZATION
# =============================================================================

echo ""
echo "🚀 Initializing Terraform..."
echo "----------------------------"

if terraform init; then
    print_status "SUCCESS" "Terraform initialization completed"
else
    print_status "ERROR" "Terraform initialization failed"
    exit 1
fi

# =============================================================================
# TERRAFORM PLAN VALIDATION
# =============================================================================

echo ""
echo "📋 Generating Terraform Plan..."
echo "-------------------------------"

if terraform plan -out=tfplan; then
    print_status "SUCCESS" "Terraform plan generated successfully"
    
    # Analyze plan
    PLAN_SUMMARY=$(terraform show -json tfplan | jq -r '.planned_values.root_module.resources | length')
    print_status "INFO" "Plan includes $PLAN_SUMMARY resources"
    
    # Check for specific resource types
    RESOURCE_TYPES=$(terraform show -json tfplan | jq -r '.planned_values.root_module.resources[].type' | sort | uniq -c)
    echo ""
    echo "📊 Resource Summary:"
    echo "$RESOURCE_TYPES"
    
else
    print_status "ERROR" "Terraform plan generation failed"
    exit 1
fi

# =============================================================================
# COST ESTIMATION
# =============================================================================

echo ""
echo "💰 Cost Estimation..."
echo "--------------------"

# Extract instance counts and profiles from plan
WEB_INSTANCES=$(terraform show -json tfplan | jq -r '.planned_values.root_module.resources[] | select(.type=="ibm_is_instance" and (.name | contains("web"))) | .values.profile' | wc -l)
APP_INSTANCES=$(terraform show -json tfplan | jq -r '.planned_values.root_module.resources[] | select(.type=="ibm_is_instance" and (.name | contains("app"))) | .values.profile' | wc -l)
DB_INSTANCES=$(terraform show -json tfplan | jq -r '.planned_values.root_module.resources[] | select(.type=="ibm_is_instance" and (.name | contains("db"))) | .values.profile' | wc -l)

print_status "INFO" "Web servers: $WEB_INSTANCES instances"
print_status "INFO" "App servers: $APP_INSTANCES instances"
print_status "INFO" "DB servers: $DB_INSTANCES instances"

# Rough cost calculation (USD/month)
WEB_COST=$((WEB_INSTANCES * 73))
APP_COST=$((APP_INSTANCES * 146))
DB_COST=$((DB_INSTANCES * 292))
TOTAL_COMPUTE_COST=$((WEB_COST + APP_COST + DB_COST))

print_status "INFO" "Estimated monthly compute cost: \$${TOTAL_COMPUTE_COST}"
print_status "WARNING" "Add storage, network, and data transfer costs for total"

# =============================================================================
# SECURITY VALIDATION
# =============================================================================

echo ""
echo "🔒 Security Validation..."
echo "------------------------"

# Check for overly permissive CIDR blocks
if terraform show -json tfplan | jq -r '.planned_values.root_module.resources[] | select(.type=="ibm_is_security_group_rule") | .values.remote' | grep -q "0.0.0.0/0"; then
    print_status "WARNING" "Found security group rules allowing access from 0.0.0.0/0"
    print_status "INFO" "Consider restricting access to specific IP ranges in production"
else
    print_status "SUCCESS" "No overly permissive security group rules found"
fi

# =============================================================================
# BEST PRACTICES CHECK
# =============================================================================

echo ""
echo "📝 Best Practices Check..."
echo "-------------------------"

# Check for resource tagging
if terraform show -json tfplan | jq -r '.planned_values.root_module.resources[].values.tags' | grep -q "managed-by"; then
    print_status "SUCCESS" "Resources include proper tagging"
else
    print_status "WARNING" "Consider adding comprehensive resource tags"
fi

# Check for encryption
if terraform show -json tfplan | jq -r '.planned_values.root_module.resources[] | select(.type=="ibm_is_volume") | .values' | grep -q "encryption"; then
    print_status "SUCCESS" "Storage volumes configured with encryption"
else
    print_status "WARNING" "Consider enabling encryption for storage volumes"
fi

# =============================================================================
# VALIDATION SUMMARY
# =============================================================================

echo ""
echo "📊 Validation Summary"
echo "===================="

print_status "SUCCESS" "Configuration validation completed"
print_status "INFO" "Ready for deployment with 'terraform apply'"

echo ""
echo "🚀 Next Steps:"
echo "1. Review the generated plan: terraform show tfplan"
echo "2. Deploy infrastructure: terraform apply tfplan"
echo "3. Validate deployment: ./scripts/test-deployment.sh"
echo "4. Clean up when done: terraform destroy"

echo ""
echo "📚 Additional Resources:"
echo "- IBM Cloud Console: https://cloud.ibm.com"
echo "- Terraform Documentation: https://terraform.io/docs"
echo "- IBM Provider Documentation: https://registry.terraform.io/providers/IBM-Cloud/ibm"

# Clean up plan file
rm -f tfplan

print_status "SUCCESS" "Validation script completed successfully"
