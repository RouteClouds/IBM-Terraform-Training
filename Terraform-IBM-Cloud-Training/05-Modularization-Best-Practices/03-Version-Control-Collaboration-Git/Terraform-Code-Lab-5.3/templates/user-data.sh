#!/bin/bash

# Git Collaboration Lab - User Data Script
# Instance initialization script for development environments

set -euo pipefail

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================

ENVIRONMENT="${environment}"
WORKFLOW_PATTERN="${workflow_pattern}"
TEAM_COUNT="${team_count}"
INSTANCE_NUMBER="${instance_number}"

LOG_FILE="/var/log/user-data.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log() {
    echo "$TIMESTAMP - $1" | tee -a "$LOG_FILE"
}

log_info() {
    log "[INFO] $1"
}

log_success() {
    log "[SUCCESS] $1"
}

log_error() {
    log "[ERROR] $1"
}

# =============================================================================
# SYSTEM INITIALIZATION
# =============================================================================

initialize_system() {
    log_info "Starting system initialization for Git Collaboration Lab"
    log_info "Environment: $ENVIRONMENT"
    log_info "Workflow Pattern: $WORKFLOW_PATTERN"
    log_info "Team Count: $TEAM_COUNT"
    log_info "Instance Number: $INSTANCE_NUMBER"
    
    # Update system packages
    log_info "Updating system packages..."
    apt-get update -y
    apt-get upgrade -y
    
    # Install essential packages
    log_info "Installing essential packages..."
    apt-get install -y \
        curl \
        wget \
        git \
        jq \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        vim \
        htop \
        tree \
        build-essential
    
    log_success "System packages updated and essential tools installed"
}

# =============================================================================
# DEVELOPMENT TOOLS INSTALLATION
# =============================================================================

install_terraform() {
    log_info "Installing Terraform..."
    
    # Add HashiCorp GPG key
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    
    # Add HashiCorp repository
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    
    # Update and install Terraform
    apt-get update -y
    apt-get install -y terraform
    
    # Verify installation
    terraform version
    
    log_success "Terraform installed successfully"
}

install_ibm_cloud_cli() {
    log_info "Installing IBM Cloud CLI..."
    
    # Download and install IBM Cloud CLI
    curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
    
    # Install VPC infrastructure plugin
    ibmcloud plugin install vpc-infrastructure
    
    # Install container registry plugin
    ibmcloud plugin install container-registry
    
    # Install cloud object storage plugin
    ibmcloud plugin install cloud-object-storage
    
    # Verify installation
    ibmcloud version
    ibmcloud plugin list
    
    log_success "IBM Cloud CLI installed successfully"
}

install_git_tools() {
    log_info "Installing Git and related tools..."
    
    # Git is already installed, configure it
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor vim
    
    # Install GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list
    apt-get update -y
    apt-get install -y gh
    
    # Install git-flow
    apt-get install -y git-flow
    
    # Install pre-commit
    pip3 install pre-commit
    
    log_success "Git tools installed successfully"
}

install_security_tools() {
    log_info "Installing security scanning tools..."
    
    # Install tfsec
    curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
    mv tfsec /usr/local/bin/
    
    # Install Checkov
    pip3 install checkov
    
    # Install Terrascan
    curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz
    tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz
    mv terrascan /usr/local/bin/
    
    log_success "Security tools installed successfully"
}

install_cost_tools() {
    log_info "Installing cost analysis tools..."
    
    # Install Infracost
    curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
    
    log_success "Cost analysis tools installed successfully"
}

install_policy_tools() {
    log_info "Installing policy validation tools..."
    
    # Install Open Policy Agent (OPA)
    curl -L -o opa https://openpolicyagent.org/downloads/v0.57.0/opa_linux_amd64_static
    chmod 755 ./opa
    mv opa /usr/local/bin/
    
    # Install Conftest
    wget https://github.com/open-policy-agent/conftest/releases/download/v0.46.0/conftest_0.46.0_Linux_x86_64.tar.gz
    tar xzf conftest_0.46.0_Linux_x86_64.tar.gz
    mv conftest /usr/local/bin/
    rm conftest_0.46.0_Linux_x86_64.tar.gz
    
    log_success "Policy validation tools installed successfully"
}

# =============================================================================
# DEVELOPMENT ENVIRONMENT SETUP
# =============================================================================

setup_development_environment() {
    log_info "Setting up development environment..."
    
    # Create development user
    useradd -m -s /bin/bash developer
    usermod -aG sudo developer
    
    # Create development directories
    mkdir -p /home/developer/{projects,scripts,tools}
    mkdir -p /home/developer/.ssh
    
    # Set up Git workflow directories based on pattern
    case "$WORKFLOW_PATTERN" in
        "gitflow")
            mkdir -p /home/developer/projects/{main,develop,feature,release,hotfix}
            ;;
        "github-flow")
            mkdir -p /home/developer/projects/{main,feature}
            ;;
        "gitlab-flow")
            mkdir -p /home/developer/projects/{main,staging,production,feature}
            ;;
        "trunk-based")
            mkdir -p /home/developer/projects/{main,short-lived-feature}
            ;;
    esac
    
    # Set ownership
    chown -R developer:developer /home/developer/
    
    log_success "Development environment setup completed"
}

setup_git_workflow_templates() {
    log_info "Setting up Git workflow templates..."
    
    # Create Git templates directory
    mkdir -p /home/developer/.git-templates/hooks
    
    # Create pre-commit hook template
    cat > /home/developer/.git-templates/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for Terraform validation

set -e

echo "Running pre-commit validations..."

# Check if Terraform files are being committed
if git diff --cached --name-only | grep -q '\.tf$'; then
    echo "Terraform files detected, running validations..."
    
    # Format check
    terraform fmt -check=true -diff=true
    
    # Validation
    terraform validate
    
    # Security scan (if tfsec is available)
    if command -v tfsec &> /dev/null; then
        tfsec .
    fi
fi

echo "Pre-commit validations passed!"
EOF
    
    chmod +x /home/developer/.git-templates/hooks/pre-commit
    
    # Configure Git to use templates
    sudo -u developer git config --global init.templateDir /home/developer/.git-templates
    
    log_success "Git workflow templates setup completed"
}

setup_ci_cd_templates() {
    log_info "Setting up CI/CD templates..."
    
    # Create GitHub Actions workflow template
    mkdir -p /home/developer/.github-templates/workflows
    
    cat > /home/developer/.github-templates/workflows/terraform-ci.yml << 'EOF'
name: Terraform CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  TF_VERSION: 1.5.0

jobs:
  validate:
    name: Validate Terraform
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ${{ env.TF_VERSION }}
    
    - name: Terraform Format Check
      run: terraform fmt -check=true -diff=true
    
    - name: Terraform Init
      run: terraform init -backend=false
    
    - name: Terraform Validate
      run: terraform validate
    
    - name: Security Scan with tfsec
      uses: aquasecurity/tfsec-action@v1.0.0
      with:
        soft_fail: true
    
    - name: Cost Analysis with Infracost
      uses: infracost/actions/setup@v2
      with:
        api-key: ${{ secrets.INFRACOST_API_KEY }}
    
    - name: Generate Infracost diff
      run: |
        infracost breakdown --path . \
          --format json \
          --out-file infracost-base.json
    
  plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    needs: validate
    if: github.event_name == 'pull_request'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ${{ env.TF_VERSION }}
    
    - name: Terraform Init
      run: terraform init
      env:
        IBMCLOUD_API_KEY: ${{ secrets.IBMCLOUD_API_KEY }}
    
    - name: Terraform Plan
      run: terraform plan -no-color
      env:
        IBMCLOUD_API_KEY: ${{ secrets.IBMCLOUD_API_KEY }}
    
  apply:
    name: Terraform Apply
    runs-on: ubuntu-latest
    needs: validate
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ${{ env.TF_VERSION }}
    
    - name: Terraform Init
      run: terraform init
      env:
        IBMCLOUD_API_KEY: ${{ secrets.IBMCLOUD_API_KEY }}
    
    - name: Terraform Apply
      run: terraform apply -auto-approve
      env:
        IBMCLOUD_API_KEY: ${{ secrets.IBMCLOUD_API_KEY }}
EOF
    
    # Create CODEOWNERS template
    cat > /home/developer/.github-templates/CODEOWNERS << 'EOF'
# Git Collaboration Lab - Code Owners

# Global owners
* @platform-team

# Terraform configurations
*.tf @platform-team @security-team
*.tfvars @platform-team
terraform.tfstate* @platform-team

# CI/CD workflows
.github/workflows/ @platform-team @devops-team

# Security policies
policies/ @security-team
*.rego @security-team

# Documentation
*.md @platform-team @documentation-team
docs/ @documentation-team

# Scripts
scripts/ @platform-team @devops-team
EOF
    
    # Set ownership
    chown -R developer:developer /home/developer/.github-templates/
    
    log_success "CI/CD templates setup completed"
}

# =============================================================================
# MONITORING AND LOGGING SETUP
# =============================================================================

setup_monitoring() {
    log_info "Setting up monitoring and logging..."
    
    # Install and configure rsyslog for centralized logging
    apt-get install -y rsyslog
    
    # Configure log rotation
    cat > /etc/logrotate.d/git-lab << 'EOF'
/var/log/git-lab/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF
    
    # Create log directory
    mkdir -p /var/log/git-lab
    
    # Install monitoring agent (example with basic monitoring)
    apt-get install -y htop iotop nethogs
    
    log_success "Monitoring and logging setup completed"
}

# =============================================================================
# FINALIZATION
# =============================================================================

finalize_setup() {
    log_info "Finalizing instance setup..."
    
    # Create instance information file
    cat > /home/developer/instance-info.txt << EOF
Git Collaboration Lab Instance Information
==========================================

Instance Number: $INSTANCE_NUMBER
Environment: $ENVIRONMENT
Workflow Pattern: $WORKFLOW_PATTERN
Team Count: $TEAM_COUNT
Setup Date: $(date)

Installed Tools:
- Terraform: $(terraform version | head -n1)
- IBM Cloud CLI: $(ibmcloud version | head -n1)
- Git: $(git --version)
- GitHub CLI: $(gh --version | head -n1)
- tfsec: $(tfsec --version)
- Checkov: $(checkov --version)
- Infracost: $(infracost --version)
- OPA: $(opa version | head -n1)

Development Directories:
$(tree /home/developer/projects/ || echo "Projects directory structure created")

Next Steps:
1. Configure IBM Cloud CLI: ibmcloud login
2. Set up Git credentials: git config --global user.name "Your Name"
3. Clone your repository: git clone <repository-url>
4. Initialize workflow: Follow the $WORKFLOW_PATTERN workflow pattern
5. Run validation: ./scripts/validate.sh
6. Deploy infrastructure: ./scripts/deploy.sh

For more information, see the README.md file in your project directory.
EOF
    
    chown developer:developer /home/developer/instance-info.txt
    
    # Set up welcome message
    cat > /etc/motd << EOF

Welcome to Git Collaboration Lab Instance $INSTANCE_NUMBER
Environment: $ENVIRONMENT | Workflow: $WORKFLOW_PATTERN

Instance setup completed successfully!
Check /home/developer/instance-info.txt for details.

Happy coding! 🚀

EOF
    
    # Clean up
    apt-get autoremove -y
    apt-get autoclean
    
    log_success "Instance setup finalized"
    log_success "Git Collaboration Lab instance $INSTANCE_NUMBER is ready!"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    log_info "Starting Git Collaboration Lab instance initialization"
    
    # Execute setup steps
    initialize_system
    install_terraform
    install_ibm_cloud_cli
    install_git_tools
    install_security_tools
    install_cost_tools
    install_policy_tools
    setup_development_environment
    setup_git_workflow_templates
    setup_ci_cd_templates
    setup_monitoring
    finalize_setup
    
    log_success "Git Collaboration Lab instance initialization completed successfully"
}

# Execute main function
main "$@"
