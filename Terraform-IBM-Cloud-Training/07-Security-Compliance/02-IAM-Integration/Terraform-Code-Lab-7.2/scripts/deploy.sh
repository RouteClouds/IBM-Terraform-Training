#!/bin/bash

# IBM Cloud IAM Integration - Deployment Script
# Topic 7.2: Identity and Access Management (IAM) Integration
# Lab 7.2: Enterprise Identity and Access Management Implementation

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_DIR"

# Default values
ENVIRONMENT="dev"
AUTO_APPROVE=false
VALIDATE_ONLY=false
DESTROY=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy IBM Cloud IAM Integration infrastructure using Terraform.

OPTIONS:
    -e, --environment ENV    Environment to deploy (dev, staging, prod) [default: dev]
    -a, --auto-approve      Skip interactive approval of plan
    -v, --validate-only     Only validate configuration, don't deploy
    -d, --destroy           Destroy infrastructure instead of deploying
    -h, --help              Display this help message

EXAMPLES:
    $0                                    # Deploy to dev environment with interactive approval
    $0 -e prod -a                        # Deploy to prod with auto-approval
    $0 -v                                # Validate configuration only
    $0 -d -e dev                         # Destroy dev environment

PREREQUISITES:
    - IBM Cloud CLI installed and authenticated
    - Terraform >= 1.3.0 installed
    - Completion of Topic 7.1 (Managing Secrets and Credentials)
    - terraform.tfvars file configured with your values

INTEGRATION WITH TOPIC 7.1:
    This deployment builds upon the security foundation from Topic 7.1:
    - Extends service IDs to enterprise service accounts
    - Advances access groups to federated access control
    - Expands trusted profiles to external identity providers
    - Enhances compliance controls with automated governance

EOF
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if IBM Cloud CLI is installed
    if ! command -v ibmcloud &> /dev/null; then
        print_error "IBM Cloud CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check Terraform version
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
    REQUIRED_VERSION="1.3.0"
    if ! printf '%s\n%s\n' "$REQUIRED_VERSION" "$TERRAFORM_VERSION" | sort -V -C; then
        print_error "Terraform version $TERRAFORM_VERSION is too old. Required: >= $REQUIRED_VERSION"
        exit 1
    fi
    
    # Check if authenticated with IBM Cloud
    if ! ibmcloud account show &> /dev/null; then
        print_error "Not authenticated with IBM Cloud. Please run 'ibmcloud login' first."
        exit 1
    fi
    
    # Check if terraform.tfvars exists
    if [[ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]]; then
        print_warning "terraform.tfvars not found. Using terraform.tfvars.example as reference."
        if [[ -f "$TERRAFORM_DIR/terraform.tfvars.example" ]]; then
            print_status "Please copy terraform.tfvars.example to terraform.tfvars and customize:"
            echo "cp terraform.tfvars.example terraform.tfvars"
            exit 1
        fi
    fi
    
    print_success "Prerequisites check completed"
}

# Function to validate Topic 7.1 completion
validate_topic_71_completion() {
    print_status "Validating Topic 7.1 completion..."
    
    # Check if Topic 7.1 resources exist (optional validation)
    TOPIC_71_DIR="../../01-Managing-Secrets-Credentials/Terraform-Code-Lab-7.1"
    if [[ -d "$TOPIC_71_DIR" ]]; then
        print_status "Topic 7.1 directory found. Checking for completion indicators..."
        
        # Check if Topic 7.1 state file exists (indicates previous deployment)
        if [[ -f "$TOPIC_71_DIR/terraform.tfstate" ]] || [[ -f "$TOPIC_71_DIR/.terraform/terraform.tfstate" ]]; then
            print_success "Topic 7.1 appears to be completed (state file found)"
        else
            print_warning "Topic 7.1 state file not found. Ensure you've completed Lab 14 first."
            print_warning "Topic 7.2 builds upon the security foundation from Topic 7.1."
        fi
    else
        print_warning "Topic 7.1 directory not found. Ensure you've completed the prerequisites."
    fi
}

# Function to initialize Terraform
terraform_init() {
    print_status "Initializing Terraform..."
    cd "$TERRAFORM_DIR"
    
    terraform init
    
    if [[ $? -eq 0 ]]; then
        print_success "Terraform initialization completed"
    else
        print_error "Terraform initialization failed"
        exit 1
    fi
}

# Function to validate Terraform configuration
terraform_validate() {
    print_status "Validating Terraform configuration..."
    cd "$TERRAFORM_DIR"
    
    terraform validate
    
    if [[ $? -eq 0 ]]; then
        print_success "Terraform configuration is valid"
    else
        print_error "Terraform configuration validation failed"
        exit 1
    fi
    
    # Format check
    terraform fmt -check=true -diff=true
    if [[ $? -ne 0 ]]; then
        print_warning "Terraform formatting issues detected. Run 'terraform fmt' to fix."
    fi
}

# Function to plan Terraform deployment
terraform_plan() {
    print_status "Creating Terraform plan for environment: $ENVIRONMENT"
    cd "$TERRAFORM_DIR"
    
    terraform plan -var="environment=$ENVIRONMENT" -out="tfplan-$ENVIRONMENT"
    
    if [[ $? -eq 0 ]]; then
        print_success "Terraform plan created successfully"
        print_status "Plan saved as: tfplan-$ENVIRONMENT"
    else
        print_error "Terraform plan failed"
        exit 1
    fi
}

# Function to apply Terraform configuration
terraform_apply() {
    print_status "Applying Terraform configuration for environment: $ENVIRONMENT"
    cd "$TERRAFORM_DIR"
    
    if [[ "$AUTO_APPROVE" == "true" ]]; then
        terraform apply -auto-approve "tfplan-$ENVIRONMENT"
    else
        terraform apply "tfplan-$ENVIRONMENT"
    fi
    
    if [[ $? -eq 0 ]]; then
        print_success "Terraform deployment completed successfully"
        print_status "Generating deployment summary..."
        terraform output deployment_summary
    else
        print_error "Terraform deployment failed"
        exit 1
    fi
}

# Function to destroy Terraform infrastructure
terraform_destroy() {
    print_status "Destroying Terraform infrastructure for environment: $ENVIRONMENT"
    cd "$TERRAFORM_DIR"
    
    print_warning "This will destroy all IAM integration resources!"
    print_warning "This action cannot be undone."
    
    if [[ "$AUTO_APPROVE" == "true" ]]; then
        terraform destroy -var="environment=$ENVIRONMENT" -auto-approve
    else
        terraform destroy -var="environment=$ENVIRONMENT"
    fi
    
    if [[ $? -eq 0 ]]; then
        print_success "Infrastructure destroyed successfully"
    else
        print_error "Infrastructure destruction failed"
        exit 1
    fi
}

# Function to display post-deployment information
post_deployment_info() {
    print_success "Deployment completed successfully!"
    echo
    print_status "Next steps:"
    echo "1. Review the deployment outputs above"
    echo "2. Test SAML federation configuration"
    echo "3. Validate access group assignments"
    echo "4. Test JIT access workflows"
    echo "5. Review compliance dashboard"
    echo
    print_status "Integration with Topic 7.1:"
    echo "- Service IDs from Topic 7.1 are now enhanced with enterprise lifecycle management"
    echo "- Access groups from Topic 7.1 are extended with federated identity integration"
    echo "- Trusted profiles from Topic 7.1 now support external identity providers"
    echo "- Compliance controls from Topic 7.1 are automated with governance workflows"
    echo
    print_status "Preparation for Topic 8:"
    echo "- Identity automation functions are ready for advanced orchestration"
    echo "- Federated trust relationships prepare for cross-cloud integration"
    echo "- Governance workflows provide foundation for enterprise automation"
    echo
    print_status "Useful commands:"
    echo "terraform output                    # View all outputs"
    echo "terraform output app_id_instance_guid  # Get App ID instance GUID"
    echo "terraform state list               # List all managed resources"
    echo "./scripts/validate.sh             # Validate deployment"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -a|--auto-approve)
            AUTO_APPROVE=true
            shift
            ;;
        -v|--validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        -d|--destroy)
            DESTROY=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT. Must be dev, staging, or prod."
    exit 1
fi

# Main execution
main() {
    echo "============================================================"
    echo "IBM Cloud IAM Integration Deployment"
    echo "Topic 7.2: Identity and Access Management (IAM) Integration"
    echo "Environment: $ENVIRONMENT"
    echo "============================================================"
    echo
    
    check_prerequisites
    validate_topic_71_completion
    terraform_init
    terraform_validate
    
    if [[ "$VALIDATE_ONLY" == "true" ]]; then
        print_success "Validation completed successfully"
        exit 0
    fi
    
    if [[ "$DESTROY" == "true" ]]; then
        terraform_destroy
        exit 0
    fi
    
    terraform_plan
    terraform_apply
    post_deployment_info
}

# Run main function
main
