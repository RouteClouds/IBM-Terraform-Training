#!/bin/bash

# IBM Cloud Schematics & Terraform Cloud Integration - Setup Script
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
LOG_FILE="$PROJECT_DIR/setup.log"

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

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check for required tools
    if ! command_exists terraform; then
        missing_tools+=("terraform")
    fi
    
    if ! command_exists ibmcloud; then
        missing_tools+=("ibmcloud")
    fi
    
    if ! command_exists jq; then
        missing_tools+=("jq")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_status "Please install the missing tools and run this script again."
        print_status "Installation guides:"
        print_status "- Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli"
        print_status "- IBM Cloud CLI: https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli"
        print_status "- jq: https://stedolan.github.io/jq/download/"
        exit 1
    fi
    
    print_success "All required tools are installed"
}

# Function to validate Terraform version
validate_terraform_version() {
    print_status "Validating Terraform version..."
    
    local tf_version
    tf_version=$(terraform version -json | jq -r '.terraform_version')
    
    if [[ ! "$tf_version" =~ ^1\.[5-9]\. ]]; then
        print_warning "Terraform version $tf_version detected. Recommended version is 1.5.0 or higher."
    else
        print_success "Terraform version $tf_version is compatible"
    fi
}

# Function to check IBM Cloud CLI login
check_ibmcloud_login() {
    print_status "Checking IBM Cloud CLI authentication..."
    
    if ! ibmcloud account show >/dev/null 2>&1; then
        print_warning "IBM Cloud CLI is not logged in"
        print_status "Please run: ibmcloud login"
        return 1
    fi
    
    local account_name
    account_name=$(ibmcloud account show --output json | jq -r '.name')
    print_success "Logged into IBM Cloud account: $account_name"
}

# Function to validate environment variables
validate_environment() {
    print_status "Validating environment variables..."
    
    local missing_vars=()
    
    # Check for required environment variables
    if [ -z "$IBMCLOUD_API_KEY" ]; then
        missing_vars+=("IBMCLOUD_API_KEY")
    fi
    
    if [ -z "$TFE_TOKEN" ]; then
        missing_vars+=("TFE_TOKEN")
    fi
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_warning "Missing environment variables: ${missing_vars[*]}"
        print_status "You can either:"
        print_status "1. Set environment variables: export IBMCLOUD_API_KEY=your-key"
        print_status "2. Configure them in terraform.tfvars file"
    else
        print_success "Required environment variables are set"
    fi
}

# Function to initialize Terraform
initialize_terraform() {
    print_status "Initializing Terraform..."
    
    cd "$PROJECT_DIR"
    
    if terraform init; then
        print_success "Terraform initialized successfully"
    else
        print_error "Terraform initialization failed"
        exit 1
    fi
}

# Function to validate Terraform configuration
validate_terraform_config() {
    print_status "Validating Terraform configuration..."
    
    cd "$PROJECT_DIR"
    
    if terraform validate; then
        print_success "Terraform configuration is valid"
    else
        print_error "Terraform configuration validation failed"
        exit 1
    fi
}

# Function to create terraform.tfvars if it doesn't exist
setup_tfvars() {
    print_status "Setting up terraform.tfvars..."
    
    cd "$PROJECT_DIR"
    
    if [ ! -f "terraform.tfvars" ]; then
        if [ -f "terraform.tfvars.example" ]; then
            cp terraform.tfvars.example terraform.tfvars
            print_success "Created terraform.tfvars from example file"
            print_warning "Please edit terraform.tfvars with your specific values before running terraform apply"
        else
            print_error "terraform.tfvars.example not found"
            exit 1
        fi
    else
        print_success "terraform.tfvars already exists"
    fi
}

# Function to plan Terraform deployment
plan_deployment() {
    print_status "Creating Terraform plan..."
    
    cd "$PROJECT_DIR"
    
    if terraform plan -out=tfplan; then
        print_success "Terraform plan created successfully"
        print_status "Plan saved as 'tfplan'"
        print_status "Review the plan and run 'terraform apply tfplan' to deploy"
    else
        print_error "Terraform plan failed"
        exit 1
    fi
}

# Function to display next steps
show_next_steps() {
    print_success "Setup completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. Review and edit terraform.tfvars with your specific values"
    echo "2. Run 'terraform plan' to review the deployment plan"
    echo "3. Run 'terraform apply' to deploy the infrastructure"
    echo "4. Use the output values to access your workspaces"
    echo ""
    print_status "Useful commands:"
    echo "- terraform plan                 # Review deployment plan"
    echo "- terraform apply               # Deploy infrastructure"
    echo "- terraform destroy             # Clean up resources"
    echo "- terraform output              # Show output values"
    echo "- ./scripts/validate.sh         # Validate deployment"
    echo "- ./scripts/cleanup.sh          # Clean up resources"
    echo ""
    print_status "Documentation:"
    echo "- README.md                     # Comprehensive setup guide"
    echo "- Lab-16.md                     # Hands-on lab exercises"
    echo "- Concept.md                    # Theoretical background"
}

# Main execution
main() {
    echo "=============================================="
    echo "IBM Cloud Schematics & Terraform Cloud Setup"
    echo "Topic 8.2: Advanced Integration Lab"
    echo "=============================================="
    echo ""
    
    # Initialize log file
    echo "Setup started at $(date)" > "$LOG_FILE"
    
    # Run setup steps
    check_prerequisites
    validate_terraform_version
    check_ibmcloud_login || true  # Don't exit if not logged in
    validate_environment
    setup_tfvars
    initialize_terraform
    validate_terraform_config
    plan_deployment
    
    echo ""
    show_next_steps
}

# Run main function
main "$@"
