# IBM Cloud Schematics Setup Guide for Terraform Training Labs

## 🎯 **Overview**

This comprehensive guide provides step-by-step instructions for setting up and running IBM Cloud Terraform training labs using IBM Cloud Schematics. The guide is designed for complete beginners to IBM Cloud and covers everything from account creation to lab execution.

**What You'll Learn:**
- Complete IBM Cloud account setup and configuration
- IBM Cloud CLI installation and authentication
- IBM Cloud Schematics workspace creation and management
- GitOps pipeline configuration for automated deployments
- Cost management and security best practices

**Target Lab:** Lab 1.1 - Infrastructure as Code Fundamentals
**Location:** `/Terraform-IBM-Cloud-Training/01-IaC-Concepts-IBM-Cloud-Integration/01-Overview-of-IaC/Terraform-Code-Lab-1.1`

---

## 📋 **Prerequisites and Account Setup**

### **1. IBM Cloud Account Creation and Verification**

#### **Step 1: Create Your IBM Cloud Account**
1. **Visit IBM Cloud Registration**: Navigate to [https://cloud.ibm.com/registration](https://cloud.ibm.com/registration)
2. **Complete Registration Form**:
   - Enter your email address (use a professional email if possible)
   - Create a strong password (minimum 8 characters with mixed case, numbers, symbols)
   - Select your country/region
   - Accept the terms and conditions
3. **Email Verification**:
   - Check your email for verification message from IBM Cloud
   - Click the verification link to activate your account
   - Complete any additional verification steps if prompted

#### **Step 2: Account Verification and Setup**
1. **Login to IBM Cloud Console**: [https://cloud.ibm.com](https://cloud.ibm.com)
2. **Complete Profile Setup**:
   - Add your full name and contact information
   - Set up two-factor authentication (highly recommended)
   - Configure notification preferences
3. **Account Type Verification**:
   - **Lite Account**: Free tier with limited resources (sufficient for basic labs)
   - **Pay-As-You-Go**: Recommended for comprehensive training (requires credit card)
   - **Subscription**: Enterprise accounts with committed usage

### **2. Required IBM Cloud Services and Pricing Considerations**

#### **Services Required for Lab 1.1**
| Service | Purpose | Estimated Cost (USD/hour) | Free Tier Available |
|---------|---------|---------------------------|-------------------|
| **VPC Infrastructure** | Virtual Private Cloud, Subnets | $0.00 | ✅ Yes |
| **Virtual Server Instance** | Compute (bx2-2x8 profile) | $0.10-0.15 | ❌ No |
| **Block Storage** | Boot volume (25GB) | $0.0005 | ❌ No |
| **Public Gateway** | Internet access | $0.045 | ❌ No |
| **Floating IP** | Public IP address | $0.0065 | ❌ No |
| **IBM Cloud Schematics** | Terraform management | $0.00 | ✅ Yes |

**Total Estimated Cost**: $0.15-0.20 per hour for complete lab environment

#### **Cost Management Strategies**
- **Lab Duration**: Plan for 2-4 hours per lab session
- **Resource Cleanup**: Always destroy resources after lab completion
- **Billing Alerts**: Set up spending notifications at $5, $10, $25 thresholds
- **Resource Tagging**: Use consistent tags for cost tracking and management

### **3. Initial Account Configuration and Billing Setup**

#### **Billing Configuration**
1. **Navigate to Billing**: Go to "Manage > Billing and usage" in IBM Cloud console
2. **Add Payment Method**:
   - Click "Payment methods" in the left sidebar
   - Add credit card or PayPal account
   - Verify payment method with small authorization charge
3. **Set Spending Notifications**:
   - Go to "Spending notifications"
   - Create alerts at $5, $10, $25, $50 thresholds
   - Configure email notifications for budget overruns

#### **Account Organization**
1. **Create Resource Groups**:
   - Navigate to "Manage > Account > Resource groups"
   - Create "terraform-training" resource group
   - Set appropriate access policies
2. **Configure Access Management**:
   - Go to "Manage > Access (IAM)"
   - Review default policies
   - Create service IDs for automation (covered in authentication section)

---

## 🔐 **Authentication and Access Configuration**

### **1. IBM Cloud API Key Creation Process**

#### **Method 1: Using IBM Cloud Console (Recommended for Beginners)**

**Step 1: Navigate to API Key Management**
1. Login to [IBM Cloud Console](https://cloud.ibm.com)
2. Click on "Manage" in the top navigation bar
3. Select "Access (IAM)" from the dropdown menu
4. Click "API keys" in the left sidebar

**Step 2: Create User API Key**
1. Click the "Create an IBM Cloud API key" button
2. **API Key Configuration**:
   - **Name**: `terraform-training-key` (descriptive naming)
   - **Description**: `API key for Terraform training labs and Schematics`
   - **Restrict by IP**: Leave blank for training (can restrict later for security)
3. Click "Create" button
4. **IMPORTANT**: Copy and save the API key immediately - it will only be shown once
5. Store the key securely (password manager, secure notes, etc.)

**Step 3: Verify API Key Permissions**
1. Go to "Access policies" tab
2. Verify your user has the following permissions:
   - **VPC Infrastructure Services**: Editor or Administrator
   - **Resource Group**: Viewer (minimum)
   - **IBM Cloud Schematics**: Editor
   - **Identity and Access Management**: Viewer

#### **Method 2: Using IBM Cloud CLI (Advanced Users)**

```bash
# Login to IBM Cloud CLI
ibmcloud login

# Create API key
ibmcloud iam api-key-create terraform-training-key -d "API key for Terraform training labs"

# Example output:
# API key terraform-training-key was created
# Please preserve the API key! It cannot be retrieved after it's created.
# ID            ApiKey-12345678-1234-1234-1234-123456789012
# Name          terraform-training-key
# Description   API key for Terraform training labs
# Created At    2024-01-15T10:30:00Z
# API Key       abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGH
```

### **2. Secure API Key Storage and Management**

#### **Security Best Practices**
1. **Never Store in Code**: Never commit API keys to version control systems
2. **Use Environment Variables**: Store keys as environment variables for local development
3. **Rotate Regularly**: Change API keys every 90 days minimum
4. **Limit Scope**: Use Service IDs with minimal required permissions for automation
5. **Monitor Usage**: Review API key usage in Activity Tracker

#### **Storage Options**
- **Local Development**: Environment variables or secure configuration files
- **Password Managers**: 1Password, LastPass, Bitwarden for personal use
- **Enterprise**: HashiCorp Vault, IBM Key Protect, or similar secrets management
- **CI/CD Pipelines**: Secure environment variables in GitHub Actions, Jenkins, etc.

### **3. Environment Variable Configuration**

#### **Windows (PowerShell)**
```powershell
# Set environment variable for current session
$env:IBMCLOUD_API_KEY = "your-api-key-here"

# Set permanently (requires restart)
[Environment]::SetEnvironmentVariable("IBMCLOUD_API_KEY", "your-api-key-here", "User")

# Verify setting
echo $env:IBMCLOUD_API_KEY
```

#### **macOS/Linux (Bash/Zsh)**
```bash
# Set environment variable for current session
export IBMCLOUD_API_KEY="your-api-key-here"

# Add to shell profile for persistence
echo 'export IBMCLOUD_API_KEY="your-api-key-here"' >> ~/.bashrc
# or for zsh
echo 'export IBMCLOUD_API_KEY="your-api-key-here"' >> ~/.zshrc

# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc

# Verify setting
echo $IBMCLOUD_API_KEY
```

---

## 💻 **IBM Cloud CLI Installation and Configuration**

### **1. Platform-Specific Installation Instructions**

#### **Windows Installation**
```powershell
# Method 1: Using PowerShell (Recommended)
# Download and run installer
Invoke-WebRequest -Uri "https://download.clis.cloud.ibm.com/ibm-cloud-cli/2.23.0/IBM_Cloud_CLI_2.23.0_windows_amd64.exe" -OutFile "IBM_Cloud_CLI.exe"
.\IBM_Cloud_CLI.exe

# Method 2: Using Chocolatey
choco install ibmcloud-cli

# Method 3: Using Winget
winget install IBM.CloudCLI
```

#### **macOS Installation**
```bash
# Method 1: Using Homebrew (Recommended)
brew install ibmcloud-cli

# Method 2: Using curl
curl -fsSL https://clis.cloud.ibm.com/install/osx | sh

# Method 3: Download installer
# Visit: https://github.com/IBM-Cloud/ibm-cloud-cli-release/releases
# Download .pkg file and run installer
```

#### **Linux Installation**
```bash
# Method 1: Using curl (Recommended)
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Method 2: Using package managers
# Ubuntu/Debian
curl -sL https://ibm.biz/idt-installer | bash

# RHEL/CentOS/Fedora
curl -sL https://ibm.biz/idt-installer | bash

# Method 3: Manual download
wget https://download.clis.cloud.ibm.com/ibm-cloud-cli/2.23.0/IBM_Cloud_CLI_2.23.0_linux_amd64.tar.gz
tar -xzf IBM_Cloud_CLI_2.23.0_linux_amd64.tar.gz
sudo ./Bluemix_CLI/install
```

### **2. CLI Plugin Installation for Required Services**

```bash
# Install VPC Infrastructure plugin
ibmcloud plugin install vpc-infrastructure

# Install Schematics plugin
ibmcloud plugin install schematics

# Install Container Registry plugin (if needed for advanced labs)
ibmcloud plugin install container-registry

# Install Key Protect plugin (for security labs)
ibmcloud plugin install key-protect

# Verify installed plugins
ibmcloud plugin list

# Update all plugins
ibmcloud plugin update --all
```

### **3. Authentication Setup and Verification**

#### **Initial Authentication**
```bash
# Login with API key
ibmcloud login --apikey $IBMCLOUD_API_KEY

# Alternative: Interactive login
ibmcloud login

# Set target resource group
ibmcloud target -g terraform-training

# Set target region
ibmcloud target -r us-south

# Verify authentication and settings
ibmcloud target
```

#### **Verification Commands**
```bash
# Check account information
ibmcloud account show

# List resource groups
ibmcloud resource groups

# Test VPC access
ibmcloud is vpcs

# Test Schematics access
ibmcloud schematics workspace list

# Check current user permissions
ibmcloud iam user-policies $(ibmcloud iam users --output json | jq -r '.[] | select(.email=="your-email@domain.com") | .id')
```

### **4. Basic CLI Usage and Troubleshooting**

#### **Common CLI Commands**
```bash
# Get help for any command
ibmcloud help
ibmcloud is help
ibmcloud schematics help

# Check CLI version
ibmcloud version

# Update CLI
ibmcloud update

# Clear CLI cache (if experiencing issues)
ibmcloud config --check-version false
ibmcloud logout
ibmcloud login --apikey $IBMCLOUD_API_KEY
```

#### **Troubleshooting Common Issues**

**Issue 1: Authentication Failures**
```bash
# Clear existing authentication
ibmcloud logout

# Re-authenticate with verbose output
ibmcloud login --apikey $IBMCLOUD_API_KEY -v

# Check API key validity
ibmcloud iam api-keys
```

**Issue 2: Permission Denied Errors**
```bash
# Check current target settings
ibmcloud target

# Verify resource group access
ibmcloud resource groups

# Check IAM policies
ibmcloud iam user-policies $USER_ID
```

**Issue 3: Plugin Issues**
```bash
# Reinstall problematic plugins
ibmcloud plugin uninstall vpc-infrastructure
ibmcloud plugin install vpc-infrastructure

# Clear plugin cache
rm -rf ~/.bluemix/plugins
ibmcloud plugin install vpc-infrastructure schematics
```

---

## 🏗️ **IBM Cloud Resource Management**

### **1. Understanding and Creating IBM Cloud Resource Groups**

#### **What are Resource Groups?**
Resource groups are logical containers that help organize and manage IBM Cloud resources. They enable:
- **Cost Tracking**: Monitor spending by project or team
- **Access Control**: Apply IAM policies to groups of resources
- **Resource Organization**: Logical grouping for easier management
- **Billing Allocation**: Separate billing for different projects

#### **Creating Resource Groups**

**Method 1: Using IBM Cloud Console**
1. Navigate to "Manage > Account > Resource groups"
2. Click "Create" button
3. **Resource Group Configuration**:
   - **Name**: `terraform-training`
   - **Description**: `Resource group for Terraform training labs`
   - **Tags**: `training`, `terraform`, `education`
4. Click "Create" to finish

**Method 2: Using IBM Cloud CLI**
```bash
# Create resource group
ibmcloud resource group-create terraform-training

# List all resource groups
ibmcloud resource groups

# Set as default target
ibmcloud target -g terraform-training

# Verify current target
ibmcloud target
```

### **2. Resource Organization for Training Labs**

#### **Recommended Resource Group Structure**
```
Account Root
├── default (IBM Cloud default)
├── terraform-training (Main training group)
│   ├── Lab 1.1 resources (VPC, VSI, etc.)
│   ├── Lab 1.2 resources
│   └── Shared resources (SSH keys, etc.)
└── production (Future real projects)
```

#### **Resource Naming Conventions**
```bash
# Format: {project}-{environment}-{resource-type}-{identifier}
# Examples:
iac-training-lab-vpc-main
iac-training-lab-subnet-web
iac-training-lab-vsi-web01
iac-training-lab-sg-web
```

### **3. Setting Up Proper IAM Permissions and Policies**

#### **Required Permissions for Training Labs**
| Service | Role | Purpose |
|---------|------|---------|
| **VPC Infrastructure** | Editor | Create/modify VPC resources |
| **Resource Groups** | Viewer | Access resource groups |
| **IBM Cloud Schematics** | Editor | Manage Schematics workspaces |
| **Identity and Access Management** | Viewer | View SSH keys and policies |

#### **Creating Service ID for Automation**
```bash
# Create service ID for Schematics automation
ibmcloud iam service-id-create terraform-schematics-automation \
  --description "Service ID for Terraform Schematics automation"

# Assign VPC Infrastructure permissions
ibmcloud iam service-policy-create terraform-schematics-automation \
  --roles Editor \
  --service-name is

# Assign Resource Group permissions
ibmcloud iam service-policy-create terraform-schematics-automation \
  --roles Viewer \
  --resource-type resource-group \
  --resource terraform-training

# Create API key for service ID
ibmcloud iam service-api-key-create terraform-schematics-key terraform-schematics-automation
```

### **4. Cost Management and Resource Tagging Strategies**

#### **Cost Management Best Practices**
1. **Set Spending Alerts**: Configure notifications at multiple thresholds
2. **Regular Monitoring**: Check billing dashboard daily during training
3. **Resource Lifecycle**: Destroy resources immediately after lab completion
4. **Right-sizing**: Use appropriate instance sizes for training purposes

#### **Resource Tagging Strategy**
```bash
# Standard tags for all training resources
tags = [
  "training",
  "terraform",
  "iac",
  "lab-1.1",
  "temporary"
]

# Additional metadata tags
additional_tags = {
  "cost-center"    = "training"
  "department"     = "it"
  "purpose"        = "learning"
  "auto-delete"    = "true"
  "created-by"     = "terraform"
  "lab-session"    = "2024-01-15"
}
```

---

## 🚀 **IBM Cloud Schematics Setup**

### **1. Introduction to IBM Cloud Schematics and Benefits**

#### **What is IBM Cloud Schematics?**
IBM Cloud Schematics is IBM's managed Terraform service that provides:
- **Managed Terraform**: No need to install or maintain Terraform infrastructure
- **State Management**: Automatic state file storage and locking
- **GitOps Integration**: Direct integration with Git repositories
- **Audit Logging**: Complete audit trail of all infrastructure changes
- **Team Collaboration**: Shared workspaces with role-based access control
- **Cost Estimation**: Built-in cost estimation for planned changes

#### **Benefits Over Local Terraform**
| Feature | Local Terraform | IBM Cloud Schematics |
|---------|----------------|---------------------|
| **Infrastructure** | Self-managed | Fully managed |
| **State Storage** | Manual setup required | Automatic |
| **Team Collaboration** | Complex setup | Built-in |
| **Audit Logging** | Manual implementation | Automatic |
| **Cost Estimation** | Third-party tools | Built-in |
| **Security** | Self-managed | Enterprise-grade |
| **Scalability** | Limited by local resources | Cloud-scale |

### **2. Creating a Schematics Workspace for the Lab**

#### **Method 1: Using IBM Cloud Console (Recommended)**

**Step 1: Navigate to Schematics**
1. Login to [IBM Cloud Console](https://cloud.ibm.com)
2. Search for "Schematics" in the top search bar
3. Click on "Schematics" service
4. Click "Create workspace" button

**Step 2: Workspace Configuration**
```yaml
# Workspace Settings
Name: iac-training-lab-1-1
Description: Infrastructure as Code Training - Lab 1.1
Resource Group: terraform-training
Location: North America (us-south)
Tags: training, terraform, lab-1.1

# Repository Settings
Repository URL: https://github.com/RouteClouds/Terraform-IBM-Cloud-Training
Branch: main
Folder: 01-IaC-Concepts-IBM-Cloud-Integration/01-Overview-of-IaC/Terraform-Code-Lab-1.1
Personal Access Token: (if private repository)
```

**Step 3: Variable Configuration**
```hcl
# Required Variables
ibmcloud_api_key = "your-api-key-here" (mark as sensitive)
ibm_region = "us-south"
resource_group_name = "terraform-training"
project_name = "iac-training"
environment = "lab"
owner = "your-name-or-email"

# Optional Variables
vsi_profile = "bx2-2x8"
create_public_gateway = true
create_floating_ip = false
auto_delete_volume = true
```

#### **Method 2: Using IBM Cloud CLI**
```bash
# Create workspace using CLI
ibmcloud schematics workspace new \
  --name "iac-training-lab-1-1" \
  --description "Infrastructure as Code Training - Lab 1.1" \
  --resource-group "terraform-training" \
  --location "us-south" \
  --template-repo "https://github.com/RouteClouds/Terraform-IBM-Cloud-Training" \
  --template-folder "01-IaC-Concepts-IBM-Cloud-Integration/01-Overview-of-IaC/Terraform-Code-Lab-1.1" \
  --template-branch "main"

# Set workspace variables
ibmcloud schematics workspace update \
  --id WORKSPACE_ID \
  --var ibmcloud_api_key=YOUR_API_KEY \
  --var ibm_region=us-south \
  --var resource_group_name=terraform-training
```

### **3. Connecting Schematics to GitHub Repository**

#### **Repository Setup Requirements**
1. **Repository Access**: Ensure the repository is accessible (public or with proper credentials)
2. **Folder Structure**: Verify the Terraform code is in the correct folder path
3. **File Validation**: Ensure all required files are present (main.tf, variables.tf, etc.)

#### **Private Repository Configuration**
If using a private repository, you'll need to configure authentication:

**GitHub Personal Access Token Setup**
1. Go to GitHub Settings > Developer settings > Personal access tokens
2. Generate new token with `repo` scope
3. Copy the token and store securely
4. In Schematics workspace, add the token in repository settings

**SSH Key Configuration (Alternative)**
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "schematics@ibmcloud.com"

# Add public key to GitHub account
# Add private key to Schematics workspace settings
```

---

## 🔄 **GitOps Pipeline Configuration**

### **1. Setting Up GitHub Repository Under RouteClouds Account**

#### **Repository Structure for Schematics Integration**
```
Terraform-IBM-Cloud-Training/
├── .github/
│   └── workflows/
│       ├── schematics-plan.yml
│       ├── schematics-apply.yml
│       └── schematics-destroy.yml
├── 01-IaC-Concepts-IBM-Cloud-Integration/
│   └── 01-Overview-of-IaC/
│       └── Terraform-Code-Lab-1.1/
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           ├── providers.tf
│           ├── terraform.tfvars.example
│           └── README.md
├── docs/
│   ├── setup-guide.md
│   └── troubleshooting.md
└── README.md
```

#### **Repository Configuration**
```yaml
# .github/workflows/schematics-plan.yml
name: Schematics Plan
on:
  pull_request:
    paths:
      - '01-IaC-Concepts-IBM-Cloud-Integration/**'
      - '.github/workflows/**'

jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup IBM Cloud CLI
        run: |
          curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
          ibmcloud plugin install schematics

      - name: Authenticate to IBM Cloud
        run: |
          ibmcloud login --apikey ${{ secrets.IBMCLOUD_API_KEY }}
          ibmcloud target -g terraform-training

      - name: Generate Terraform Plan
        run: |
          ibmcloud schematics plan --id ${{ secrets.WORKSPACE_ID }}
          ibmcloud schematics logs --id ${{ secrets.WORKSPACE_ID }}
```

### **2. Automated Deployment Workflows**

#### **GitHub Actions for Schematics Integration**
```yaml
# .github/workflows/schematics-apply.yml
name: Schematics Apply
on:
  push:
    branches: [main]
    paths:
      - '01-IaC-Concepts-IBM-Cloud-Integration/**'

jobs:
  apply:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup IBM Cloud CLI
        run: |
          curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
          ibmcloud plugin install schematics

      - name: Authenticate to IBM Cloud
        run: |
          ibmcloud login --apikey ${{ secrets.IBMCLOUD_API_KEY }}
          ibmcloud target -g terraform-training

      - name: Apply Terraform Changes
        run: |
          ibmcloud schematics apply --id ${{ secrets.WORKSPACE_ID }}
          ibmcloud schematics logs --id ${{ secrets.WORKSPACE_ID }}

      - name: Get Outputs
        run: |
          ibmcloud schematics output --id ${{ secrets.WORKSPACE_ID }}
```

### **3. Branch Protection and Approval Processes**

#### **Branch Protection Rules**
```yaml
# Repository Settings > Branches > Add rule
Branch name pattern: main
Protection rules:
  ✅ Require a pull request before merging
  ✅ Require approvals (1 reviewer minimum)
  ✅ Dismiss stale PR approvals when new commits are pushed
  ✅ Require review from code owners
  ✅ Require status checks to pass before merging
  ✅ Require branches to be up to date before merging
  ✅ Require conversation resolution before merging
  ✅ Include administrators
```

#### **CODEOWNERS File**
```bash
# .github/CODEOWNERS
# Global owners
* @RouteClouds/terraform-admins

# Terraform code owners
*.tf @RouteClouds/terraform-reviewers
*.tfvars @RouteClouds/terraform-reviewers

# Lab-specific owners
01-IaC-Concepts-IBM-Cloud-Integration/ @RouteClouds/lab-maintainers
```

### **4. Monitoring and Notifications**

#### **Slack Integration for Pipeline Notifications**
```yaml
# Add to workflow files
- name: Notify Slack on Success
  if: success()
  uses: 8398a7/action-slack@v3
  with:
    status: success
    channel: '#terraform-training'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}

- name: Notify Slack on Failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    channel: '#terraform-training'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 🎯 **Lab Execution Guide**

### **1. Step-by-Step Instructions to Run Lab 1.1 Through Schematics**

#### **Pre-Execution Checklist**
- [ ] IBM Cloud account set up and verified
- [ ] API key created and stored securely
- [ ] Resource group "terraform-training" created
- [ ] Schematics workspace configured
- [ ] Repository connected and variables set
- [ ] Billing alerts configured

#### **Step 1: Workspace Preparation**
```bash
# Verify workspace status
ibmcloud schematics workspace get --id WORKSPACE_ID

# Check workspace variables
ibmcloud schematics workspace get --id WORKSPACE_ID --output json | jq '.template_data[0].variablestore'

# Update variables if needed
ibmcloud schematics workspace update --id WORKSPACE_ID \
  --var ibmcloud_api_key=YOUR_API_KEY \
  --var project_name=iac-training \
  --var environment=lab
```

#### **Step 2: Generate and Review Plan**
```bash
# Generate Terraform plan
ibmcloud schematics plan --id WORKSPACE_ID

# Monitor plan generation
ibmcloud schematics logs --id WORKSPACE_ID

# Review planned changes
ibmcloud schematics workspace get --id WORKSPACE_ID --output json | jq '.last_health_check_at'
```

#### **Step 3: Apply Infrastructure Changes**
```bash
# Apply the Terraform configuration
ibmcloud schematics apply --id WORKSPACE_ID

# Monitor apply progress
ibmcloud schematics logs --id WORKSPACE_ID --follow

# Check apply status
ibmcloud schematics workspace get --id WORKSPACE_ID | grep "last_action_name\|last_action_status"
```

#### **Step 4: Verify Deployment**
```bash
# Get workspace outputs
ibmcloud schematics output --id WORKSPACE_ID

# Verify VPC creation
ibmcloud is vpcs --resource-group-name terraform-training

# Check VSI status
ibmcloud is instances --resource-group-name terraform-training

# Test connectivity (if floating IP created)
ping FLOATING_IP_ADDRESS
ssh root@FLOATING_IP_ADDRESS
```

### **2. Monitoring Deployment Progress and Troubleshooting**

#### **Real-time Monitoring**
```bash
# Follow logs in real-time
ibmcloud schematics logs --id WORKSPACE_ID --follow

# Check workspace health
ibmcloud schematics workspace get --id WORKSPACE_ID | grep health

# Monitor resource creation in IBM Cloud console
# Navigate to: VPC Infrastructure > Virtual server instances
```

#### **Common Issues and Solutions**

**Issue 1: Authentication Failures**
```bash
# Symptoms: "Authentication failed" or "Invalid API key"
# Solution:
ibmcloud schematics workspace update --id WORKSPACE_ID \
  --var ibmcloud_api_key=NEW_API_KEY

# Verify API key permissions
ibmcloud iam user-policies USER_ID
```

**Issue 2: Resource Quota Exceeded**
```bash
# Symptoms: "Quota exceeded" errors
# Solution: Check and request quota increases
ibmcloud is instance-profiles
ibmcloud is volumes --resource-group-name terraform-training

# Request quota increase through IBM Cloud support
```

**Issue 3: Resource Group Access**
```bash
# Symptoms: "Resource group not found" or "Access denied"
# Solution: Verify resource group exists and permissions
ibmcloud resource groups
ibmcloud iam user-policies USER_ID | grep terraform-training
```

### **3. Validation Steps for Successful Lab Completion**

#### **Infrastructure Validation Checklist**
```bash
# 1. Verify VPC creation
VPC_ID=$(ibmcloud is vpcs --resource-group-name terraform-training --output json | jq -r '.[0].id')
echo "VPC ID: $VPC_ID"

# 2. Verify subnet creation
SUBNET_ID=$(ibmcloud is subnets --resource-group-name terraform-training --output json | jq -r '.[0].id')
echo "Subnet ID: $SUBNET_ID"

# 3. Verify security group
SG_ID=$(ibmcloud is security-groups --resource-group-name terraform-training --output json | jq -r '.[0].id')
echo "Security Group ID: $SG_ID"

# 4. Verify VSI creation and status
VSI_ID=$(ibmcloud is instances --resource-group-name terraform-training --output json | jq -r '.[0].id')
VSI_STATUS=$(ibmcloud is instance $VSI_ID --output json | jq -r '.status')
echo "VSI ID: $VSI_ID, Status: $VSI_STATUS"

# 5. Check resource tags
ibmcloud is instance $VSI_ID --output json | jq '.user_tags'
```

#### **Functional Testing**
```bash
# Test network connectivity (if public gateway enabled)
FLOATING_IP=$(ibmcloud schematics output --id WORKSPACE_ID | grep floating_ip | awk '{print $2}')
if [ ! -z "$FLOATING_IP" ]; then
  ping -c 4 $FLOATING_IP
  echo "Floating IP connectivity: PASS"
else
  echo "No floating IP configured"
fi

# Test SSH access (if SSH key configured)
if [ ! -z "$FLOATING_IP" ]; then
  ssh -o ConnectTimeout=10 root@$FLOATING_IP 'echo "SSH access: PASS"'
fi
```

### **4. Cleanup Procedures and Cost Management**

#### **Immediate Cleanup After Lab Completion**
```bash
# Destroy all resources through Schematics
ibmcloud schematics destroy --id WORKSPACE_ID

# Monitor destruction progress
ibmcloud schematics logs --id WORKSPACE_ID --follow

# Verify all resources are destroyed
ibmcloud is instances --resource-group-name terraform-training
ibmcloud is vpcs --resource-group-name terraform-training

# Check for any remaining billable resources
ibmcloud resource service-instances --resource-group-name terraform-training
```

#### **Cost Verification**
```bash
# Check current billing
ibmcloud billing account-usage --output json

# Review resource usage
ibmcloud billing resource-instances-usage --resource-group-name terraform-training

# Set up cost alerts (if not already configured)
ibmcloud billing spending-notifications-create \
  --type account \
  --threshold 10 \
  --unit USD \
  --emails your-email@domain.com
```

---

## 🔧 **Troubleshooting and Best Practices**

### **1. Common Issues and Solutions**

#### **Authentication and Access Issues**

**Problem**: "Invalid API key" or "Authentication failed"
```bash
# Solution Steps:
1. Verify API key is correct and not expired
   ibmcloud iam api-keys

2. Check API key permissions
   ibmcloud iam user-policies USER_ID

3. Regenerate API key if necessary
   ibmcloud iam api-key-create new-terraform-key

4. Update Schematics workspace with new key
   ibmcloud schematics workspace update --id WORKSPACE_ID --var ibmcloud_api_key=NEW_KEY
```

**Problem**: "Resource group not found"
```bash
# Solution Steps:
1. Verify resource group exists
   ibmcloud resource groups

2. Create resource group if missing
   ibmcloud resource group-create terraform-training

3. Verify access to resource group
   ibmcloud target -g terraform-training
```

#### **Resource Creation Issues**

**Problem**: "Quota exceeded" errors
```bash
# Solution Steps:
1. Check current quotas
   ibmcloud is instance-profiles
   ibmcloud is volumes --resource-group-name terraform-training

2. Clean up unused resources
   ibmcloud is instances --resource-group-name terraform-training
   ibmcloud is vpcs --resource-group-name terraform-training

3. Request quota increase through IBM Cloud support
   # Navigate to: Support > Create a case > Account & Billing
```

**Problem**: "Zone not available" or "Profile not supported"
```bash
# Solution Steps:
1. Check available zones in region
   ibmcloud is zones us-south

2. Verify profile availability in zone
   ibmcloud is instance-profiles --zone us-south-1

3. Update variables with supported values
   ibmcloud schematics workspace update --id WORKSPACE_ID \
     --var subnet_zone=us-south-2 \
     --var vsi_profile=bx2-2x8
```

#### **Schematics-Specific Issues**

**Problem**: "Workspace locked" or "Another operation in progress"
```bash
# Solution Steps:
1. Check workspace status
   ibmcloud schematics workspace get --id WORKSPACE_ID

2. Wait for current operation to complete
   ibmcloud schematics logs --id WORKSPACE_ID --follow

3. Force unlock if operation is stuck (use with caution)
   ibmcloud schematics workspace unlock --id WORKSPACE_ID
```

**Problem**: "Template validation failed"
```bash
# Solution Steps:
1. Check Terraform syntax locally
   terraform validate

2. Verify all required variables are set
   ibmcloud schematics workspace get --id WORKSPACE_ID | grep variablestore

3. Update repository with fixes
   git add . && git commit -m "Fix validation issues" && git push

4. Refresh workspace template
   ibmcloud schematics workspace update --id WORKSPACE_ID --pull-latest
```

### **2. Security Best Practices**

#### **API Key Management**
- **Rotation**: Rotate API keys every 90 days
- **Scope**: Use Service IDs with minimal required permissions
- **Storage**: Never store API keys in code or version control
- **Monitoring**: Monitor API key usage through Activity Tracker

#### **Network Security**
```hcl
# Secure security group rules
security_group_rules = [
  {
    direction   = "inbound"
    ip_version  = "ipv4"
    protocol    = "tcp"
    port_min    = 22
    port_max    = 22
    remote      = "YOUR_IP_ADDRESS/32"  # Restrict SSH to your IP
    description = "SSH access from trusted IP"
  }
]
```

#### **Resource Protection**
```hcl
# Enable deletion protection for critical resources
lifecycle {
  prevent_destroy = true
}

# Use encryption for storage volumes
volume_encryption_key = data.ibm_kms_key.training_key.crn
```

### **3. Cost Optimization Tips**

#### **Resource Sizing**
- **Development**: Use `bx2-2x8` (2 vCPU, 8GB RAM) for basic labs
- **Testing**: Use `bx2-4x16` (4 vCPU, 16GB RAM) for performance testing
- **Production**: Right-size based on actual requirements

#### **Scheduling and Automation**
```bash
# Schedule automatic cleanup using cron jobs
# Add to crontab: 0 18 * * * /path/to/cleanup-script.sh

#!/bin/bash
# cleanup-script.sh
WORKSPACE_ID="your-workspace-id"

# Destroy resources at end of business day
ibmcloud login --apikey $IBMCLOUD_API_KEY
ibmcloud schematics destroy --id $WORKSPACE_ID --force
```

#### **Cost Monitoring**
```bash
# Set up multiple spending alerts
ibmcloud billing spending-notifications-create --type account --threshold 5 --unit USD
ibmcloud billing spending-notifications-create --type account --threshold 15 --unit USD
ibmcloud billing spending-notifications-create --type account --threshold 25 --unit USD

# Regular cost reviews
ibmcloud billing account-usage --output json | jq '.resources[] | select(.resource_group_name=="terraform-training")'
```

### **4. Next Steps for Continuing with Additional Labs**

#### **Lab Progression Path**
1. **Lab 1.1**: Basic VPC and VSI creation ✅
2. **Lab 1.2**: Multi-tier architecture with load balancer
3. **Lab 2.1**: Terraform modules and reusability
4. **Lab 2.2**: State management and remote backends
5. **Lab 3.1**: Security groups and network ACLs
6. **Lab 3.2**: Database integration and data persistence

#### **Workspace Organization for Multiple Labs**
```bash
# Create separate workspaces for each lab
ibmcloud schematics workspace new --name "iac-training-lab-1-2" \
  --template-folder "01-IaC-Concepts-IBM-Cloud-Integration/02-Benefits-and-Use-Cases/Terraform-Code-Lab-1.2"

ibmcloud schematics workspace new --name "iac-training-lab-2-1" \
  --template-folder "02-Terraform-CLI-Provider-Installation/01-Installing-Terraform-CLI/Terraform-Code-Lab-2.1"
```

#### **Advanced Schematics Features**
- **Workspace Templates**: Create reusable workspace configurations
- **Job Scheduling**: Automate apply/destroy operations
- **Drift Detection**: Monitor infrastructure changes outside Terraform
- **Cost Estimation**: Review costs before applying changes
- **Team Collaboration**: Share workspaces with team members

#### **Integration with CI/CD**
```yaml
# Advanced GitHub Actions workflow
name: Multi-Lab Deployment
on:
  workflow_dispatch:
    inputs:
      lab_number:
        description: 'Lab number to deploy (1.1, 1.2, etc.)'
        required: true
        type: choice
        options:
          - '1.1'
          - '1.2'
          - '2.1'
          - '2.2'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Lab ${{ github.event.inputs.lab_number }}
        run: |
          WORKSPACE_ID=$(echo "${{ secrets.WORKSPACE_IDS }}" | jq -r '.["${{ github.event.inputs.lab_number }}"]')
          ibmcloud schematics apply --id $WORKSPACE_ID
```

---

## 📚 **Additional Resources and Documentation**

### **Official IBM Cloud Documentation**
- [IBM Cloud Schematics Documentation](https://cloud.ibm.com/docs/schematics)
- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)
- [IBM Cloud CLI Reference](https://cloud.ibm.com/docs/cli)
- [Terraform IBM Cloud Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)

### **Training Resources**
- [IBM Cloud Architecture Center](https://www.ibm.com/cloud/architecture)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [IBM Cloud Cost Optimization](https://cloud.ibm.com/docs/billing-usage)

### **Community and Support**
- [IBM Cloud Community](https://community.ibm.com/community/user/cloud/home)
- [Terraform IBM Cloud Provider GitHub](https://github.com/IBM-Cloud/terraform-provider-ibm)
- [IBM Cloud Support](https://cloud.ibm.com/unifiedsupport/supportcenter)

---

## 🎉 **Conclusion**

This comprehensive guide provides everything needed to successfully set up and run IBM Cloud Terraform training labs using IBM Cloud Schematics. By following these step-by-step instructions, you'll have:

- ✅ Complete IBM Cloud account setup with proper billing and security
- ✅ IBM Cloud CLI installed and configured for all platforms
- ✅ IBM Cloud Schematics workspace ready for lab execution
- ✅ GitOps pipeline configured for automated deployments
- ✅ Cost management and security best practices implemented
- ✅ Troubleshooting knowledge for common issues

**Remember**: Always clean up resources after lab completion to avoid unnecessary charges. The training environment is designed for learning, and proper resource management is part of the educational experience.

**Happy Learning!** 🚀
