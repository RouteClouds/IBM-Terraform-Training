# IBM Cloud Terraform Training Lab 1.1 - Complete Setup Guide

## Table of Contents
1. [Prerequisites and Initial Setup](#1-prerequisites-and-initial-setup)
2. [Git Repository Setup](#2-git-repository-setup)
3. [IBM Cloud Authentication](#3-ibm-cloud-authentication)
4. [Lab 1.1 Infrastructure Deployment](#4-lab-11-infrastructure-deployment)
5. [Infrastructure Verification](#5-infrastructure-verification)
6. [Cleanup Process](#6-cleanup-process)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Prerequisites and Initial Setup

### 1.1 IBM Cloud Account Requirements

**Required:**
- Active IBM Cloud account with billing enabled
- Appropriate IAM permissions for VPC infrastructure
- Access to the following services:
  - Virtual Private Cloud (VPC)
  - Virtual Server Instances (VSI)
  - Identity and Access Management (IAM)

**Recommended Resource Group:**
- Create or use existing resource group (e.g., `terraform-training`)

### 1.2 Local Development Environment Setup

#### 1.2.1 Required Tools and Versions

**Terraform Installation:**
```bash
# Download and install Terraform (version >= 1.5.0)
# For Ubuntu/Debian:
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

**Expected Output:**
```
Terraform v1.6.0
on linux_amd64
```

**IBM Cloud CLI Installation:**
```bash
# Install IBM Cloud CLI
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Install VPC infrastructure plugin
ibmcloud plugin install vpc-infrastructure

# Verify installation
ibmcloud version
ibmcloud plugin list
```

**Expected Output:**
```
ibmcloud version 2.20.0+...
Listing installed plug-ins...

Plugin Name                            Version   Status             Private endpoints supported   
vpc-infrastructure/vpc-infrastructure   3.0.1     Update Available   true   
```

#### 1.2.2 Additional Required Tools

**Git:**
```bash
# Install Git (if not already installed)
sudo apt-get update
sudo apt-get install git

# Verify installation
git --version
```

**SSH Client:**
```bash
# Usually pre-installed on Linux/macOS
ssh -V
```

**jq (JSON processor):**
```bash
# Install jq for JSON processing
sudo apt-get install jq

# Verify installation
jq --version
```

### 1.3 IBM Cloud API Key Generation

#### 1.3.1 Create API Key via IBM Cloud Console

1. **Navigate to IBM Cloud Console:**
   - Go to https://cloud.ibm.com
   - Log in to your account

2. **Access IAM Service:**
   - Click on "Manage" in the top menu
   - Select "Access (IAM)"

3. **Create API Key:**
   - Click on "API keys" in the left sidebar
   - Click "Create an IBM Cloud API key"
   - Enter a name: `terraform-training-key`
   - Add description: `API key for Terraform training labs`
   - Click "Create"

4. **Download and Secure API Key:**
   - **IMPORTANT:** Download the API key immediately
   - Store it securely (you cannot retrieve it later)
   - Never commit API keys to version control

#### 1.3.2 Alternative: Create API Key via CLI

```bash
# Login to IBM Cloud first
ibmcloud login

# Create API key
ibmcloud iam api-key-create terraform-training-key -d "API key for Terraform training"
```

---

## 2. Git Repository Setup

### 2.1 Repository Initialization

#### 2.1.1 Create Local Repository

```bash
# Create project directory
mkdir IBM-Terraform-Training
cd IBM-Terraform-Training

# Initialize Git repository
git init

# Configure Git (if not already configured)
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

#### 2.1.2 Create Comprehensive .gitignore

Create `.gitignore` file with Terraform-specific patterns:

```bash
cat > .gitignore << 'EOF'
# Terraform Files
**/.terraform/
**/.terraform.lock.hcl
**/terraform.tfstate
**/terraform.tfstate.*
**/terraform.tfvars
**/.terraform.tfstate.lock.info
**/crash.log
**/crash.*.log
**/override.tf
**/override.tf.json
**/*_override.tf
**/*_override.tf.json
**/.terraformrc
**/terraform.rc

# Python Virtual Environments
**/venv/
**/env/
**/.venv/
**/.env/
**/ENV/
**/env.bak/
**/venv.bak/
**/__pycache__/
**/*.pyc
**/*.pyo
**/*.pyd
**/.Python
**/build/
**/develop-eggs/
**/dist/
**/downloads/
**/eggs/
**/.eggs/
**/lib/
**/lib64/
**/parts/
**/sdist/
**/var/
**/wheels/
**/share/python-wheels/
**/*.egg-info/
**/.installed.cfg
**/*.egg
**/MANIFEST

# IDE and Editor Files
**/.vscode/
**/.idea/
**/*.swp
**/*.swo
**/*~
**/.DS_Store
**/Thumbs.db

# OS Generated Files
**/.DS_Store
**/.DS_Store?
**/._*
**/.Spotlight-V100
**/.Trashes
**/ehthumbs.db
**/Thumbs.db

# Logs and Temporary Files
**/*.log
**/logs/
**/tmp/
**/temp/

# Sensitive Files
**/*.pem
**/*.key
**/*.crt
**/*.p12
**/*.pfx
**/secrets.txt
**/credentials.json

# Backup Files
**/*.backup
**/*.bak
**/*.orig

# Node.js (if using)
**/node_modules/
**/npm-debug.log*
**/yarn-debug.log*
**/yarn-error.log*

# Specific to this project
deployment-info.json
EOF
```

### 2.2 Repository Structure Setup

#### 2.2.1 Create Directory Structure

```bash
# Create the lab directory structure
mkdir -p Terraform-IBM-Cloud-Training/01-IaC-Concepts-IBM-Cloud-Integration/01-Overview-of-IaC/Terraform-Code-Lab-1.1

# Navigate to the lab directory
cd Terraform-IBM-Cloud-Training/01-IaC-Concepts-IBM-Cloud-Integration/01-Overview-of-IaC/Terraform-Code-Lab-1.1
```

### 2.3 GitHub Repository Creation

#### 2.3.1 Create GitHub Repository

1. **Via GitHub Web Interface:**
   - Go to https://github.com
   - Click "New repository"
   - Repository name: `IBM-Terraform-Training`
   - Description: `IBM Cloud Terraform Training Labs and Exercises`
   - Set to Public or Private as desired
   - **DO NOT** initialize with README, .gitignore, or license
   - Click "Create repository"

#### 2.3.2 Connect Local Repository to GitHub

```bash
# Add remote origin (replace with your GitHub username)
git remote add origin git@github.com:YOUR_USERNAME/IBM-Terraform-Training.git

# Verify remote
git remote -v
```

**Expected Output:**
```
origin  git@github.com:YOUR_USERNAME/IBM-Terraform-Training.git (fetch)
origin  git@github.com:YOUR_USERNAME/IBM-Terraform-Training.git (push)
```

---

## 3. IBM Cloud Authentication

### 3.1 Environment Variable Setup

#### 3.1.1 Set API Key Environment Variable

```bash
# Set IBM Cloud API key as environment variable
export IBMCLOUD_API_KEY="your-api-key-here"

# Verify it's set (should show the key)
echo $IBMCLOUD_API_KEY

# Add to shell profile for persistence (optional)
echo 'export IBMCLOUD_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc
```

### 3.2 IBM Cloud CLI Authentication

#### 3.2.1 Login and Target Setup

```bash
# Login using API key
ibmcloud login --apikey $IBMCLOUD_API_KEY

# Target specific region and resource group
ibmcloud target -r us-south -g terraform-training

# Verify authentication and targeting
ibmcloud target
```

**Expected Output:**
```
API endpoint:      https://cloud.ibm.com
Region:            us-south
User:              your-email@example.com
Account:           Your Account Name (account-id)
Resource group:    terraform-training
CF API endpoint:   
Org:               
Space:             
```

#### 3.2.2 Verify VPC Access

```bash
# Test VPC access
ibmcloud is vpcs

# Test zones access
ibmcloud is zones us-south
```

**Expected Output:**
```
Listing VPCs in all resource groups and region us-south under account...
No VPCs found.

Listing zones in region us-south under account...
Name         Region     Status   
us-south-1   us-south   available   
us-south-2   us-south   available   
us-south-3   us-south   available   
```

---

## 4. Lab 1.1 Infrastructure Deployment

### 4.1 Terraform Configuration Setup

#### 4.1.1 Create terraform.tfvars File

```bash
# Navigate to lab directory
cd Terraform-IBM-Cloud-Training/01-IaC-Concepts-IBM-Cloud-Integration/01-Overview-of-IaC/Terraform-Code-Lab-1.1

# Create terraform.tfvars from example
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
cat > terraform.tfvars << EOF
# IBM Cloud Configuration
ibmcloud_api_key = "$IBMCLOUD_API_KEY"
ibm_region = "us-south"
resource_group_name = "terraform-training"

# Project Configuration
project_name = "iac-training"
environment = "lab"
owner = "terraform-training-user"

# VSI Configuration
vsi_image_name = "ibm-ubuntu-20-04-3-minimal-amd64-2"
vsi_profile = "bx2-2x8"

# Network Configuration
create_public_gateway = true
create_floating_ip = false

# Tagging
tags = ["iac-training", "terraform", "lab-1.1"]
EOF
```

### 4.2 Terraform Workflow Execution

#### 4.2.1 Initialize Terraform

```bash
# Initialize Terraform working directory
terraform init
```

**Expected Output:**
```
Initializing the backend...

Initializing provider plugins...
- Finding IBM-Cloud/ibm versions matching "~> 1.58.0"...
- Finding hashicorp/random versions matching "~> 3.5.0"...
- Finding hashicorp/time versions matching "~> 0.9.0"...
- Installing IBM-Cloud/ibm v1.58.1...
- Installed IBM-Cloud/ibm v1.58.1 (signed by a HashiCorp partner)
- Installing hashicorp/random v3.5.1...
- Installed hashicorp/random v3.5.1 (signed by HashiCorp)
- Installing hashicorp/time v0.9.1...
- Installed hashicorp/time v0.9.1 (signed by HashiCorp)

Terraform has been successfully initialized!
```

#### 4.2.2 Validate Configuration

```bash
# Validate Terraform configuration
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

#### 4.2.3 Plan Infrastructure

```bash
# Create execution plan
terraform plan -var="ibmcloud_api_key=$IBMCLOUD_API_KEY"
```

**Expected Output Summary:**
```
Plan: 11 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + applied_tags = [
      + "iac-training",
      + "terraform", 
      + "lab-1.1",
      + "project:iac-training",
      + "environment:lab",
      + "owner:terraform-training-user",
      + "created-by:terraform",
    ]
  + lab_summary = {
      + deployment = {
          + environment = "lab"
          + project     = "iac-training"
          + region      = "us-south"
          + timestamp   = (known after apply)
        }
      + security_group = (known after apply)
      + subnet         = (known after apply)
      + vpc            = (known after apply)
      + vsi            = (known after apply)
    }
  # ... additional outputs
```

#### 4.2.4 Apply Configuration

```bash
# Apply the configuration
terraform apply -var="ibmcloud_api_key=$IBMCLOUD_API_KEY"

# When prompted, type 'yes' to confirm
```

**Expected Output:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

# ... resource creation progress ...

Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

lab_summary = {
  "deployment" = {
    "environment" = "lab"
    "project" = "iac-training"
    "region" = "us-south"
    "timestamp" = "2025-09-15T10:02:41Z"
  }
  "security_group" = {
    "id" = "r006-56b365f8-3428-48c2-859f-59cc5ab3016c"
    "name" = "iac-training-lab-sg-vsyw2m"
  }
  "subnet" = {
    "cidr" = "10.240.0.0/24"
    "id" = "0717-989d14f0-9244-4636-958c-e09405212c00"
    "name" = "iac-training-lab-subnet-vsyw2m"
    "zone" = "us-south-1"
  }
  "vpc" = {
    "id" = "r006-af8e8dc9-005b-4c53-a8a3-c498a911f4fb"
    "name" = "iac-training-lab-vpc-vsyw2m"
  }
  "vsi" = {
    "id" = "0717_d223f3cd-fa9d-4204-848f-2961fa38ce77"
    "name" = "iac-training-lab-vsi-vsyw2m"
    "private_ip" = "10.240.0.5"
    "profile" = "bx2-2x8"
    "status" = "running"
  }
}
```

### 4.3 SSH Key Setup for VSI Access

#### 4.3.1 Generate SSH Key Pair

```bash
# Generate SSH key pair for lab access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ibm_lab_key -N "" -C "ibm-lab-training"

# Verify key creation
ls -la ~/.ssh/ibm_lab_key*
```

**Expected Output:**
```
-rw------- 1 user user 3381 Sep 15 10:05 /home/user/.ssh/ibm_lab_key
-rw-r--r-- 1 user user  743 Sep 15 10:05 /home/user/.ssh/ibm_lab_key.pub
```

#### 4.3.2 Upload SSH Key to IBM Cloud

```bash
# Upload public key to IBM Cloud
ibmcloud is key-create ibm-lab-training-key @~/.ssh/ibm_lab_key.pub

# Verify key upload
ibmcloud is keys
```

**Expected Output:**
```
Creating key ibm-lab-training-key under account...
OK
Key ibm-lab-training-key was created.

ID                                     Name                   Type   Length   FingerPrint                                      Created        Resource group   
r006-b9912c8f-a9eb-44b7-8a42-bae723cb3926   ibm-lab-training-key   rsa    4096     SHA256:abc123...                                2025-09-15T10:05:30+00:00   terraform-training   
```

#### 4.3.3 Update Terraform Configuration for SSH

```bash
# Update terraform.tfvars to include SSH key
echo 'vsi_ssh_key_name = "ibm-lab-training-key"' >> terraform.tfvars

# Apply the updated configuration
terraform apply -var="ibmcloud_api_key=$IBMCLOUD_API_KEY" -auto-approve
```

### 4.4 Floating IP Assignment

#### 4.4.1 Create and Assign Floating IP

```bash
# Get VSI network interface ID
VSI_NIC_ID=$(terraform output -raw vsi_primary_network_interface | jq -r '.id')

# Create floating IP and attach to VSI
ibmcloud is floating-ip-reserve lab-training-fip --nic $VSI_NIC_ID

# Get the assigned floating IP
FLOATING_IP=$(ibmcloud is floating-ips --output json | jq -r '.[] | select(.name == "lab-training-fip") | .address')
echo "Floating IP: $FLOATING_IP"
```

**Expected Output:**
```
Creating floating IP lab-training-fip under account...
OK
Floating IP lab-training-fip was created.

Floating IP: 52.116.132.54
```

---

## 5. Infrastructure Verification

### 5.1 IBM Cloud Console Verification

#### 5.1.1 Navigate to VPC Resources

1. **Access IBM Cloud Console:**
   - Go to https://cloud.ibm.com
   - Log in to your account

2. **Navigate to VPC Infrastructure:**
   - Click on the hamburger menu (☰)
   - Select "VPC Infrastructure"
   - Choose "Virtual server instances"

3. **Verify VSI Creation:**
   - Look for: `iac-training-lab-vsi-vsyw2m`
   - Status should be: "Running"
   - Profile: bx2-2x8
   - Zone: us-south-1

4. **Check VPC Resources:**
   - Navigate to "VPCs" → Find `iac-training-lab-vpc-vsyw2m`
   - Navigate to "Subnets" → Find `iac-training-lab-subnet-vsyw2m`
   - Navigate to "Security groups" → Find `iac-training-lab-sg-vsyw2m`

### 5.2 SSH Connectivity Testing

#### 5.2.1 Test SSH Connection

```bash
# Test SSH connection to VSI
ssh -i ~/.ssh/ibm_lab_key -o StrictHostKeyChecking=no root@$FLOATING_IP "echo 'SSH connection successful!' && hostname && whoami"
```

**Expected Output:**
```
SSH connection successful!
iac-training-lab-vsi-vsyw2m
root
```

#### 5.2.2 Verify User Data Script Completion

```bash
# Check if user data script completed
ssh -i ~/.ssh/ibm_lab_key root@$FLOATING_IP "ls -la /tmp/user-data-complete && tail -5 /var/log/user-data.log 2>/dev/null || echo 'User data still running...'"
```

#### 5.2.3 Test Web Server (if user data completed)

```bash
# Test nginx web server
ssh -i ~/.ssh/ibm_lab_key root@$FLOATING_IP "systemctl status nginx && curl -s localhost | head -5"

# Test from external access
curl -s http://$FLOATING_IP | head -10
```

### 5.3 Resource State Verification

#### 5.3.1 Check Terraform State

```bash
# List all resources in Terraform state
terraform state list

# Show detailed resource information
terraform show
```

#### 5.3.2 Verify Resource Tags

```bash
# Check applied tags
terraform output applied_tags

# Verify tags in IBM Cloud
ibmcloud is instance $(terraform output -raw vsi_id) --output json | jq '.tags'
```

---

## 6. Cleanup Process

### 6.1 Infrastructure Destruction

#### 6.1.1 Remove Floating IP

```bash
# Remove floating IP (created outside Terraform)
ibmcloud is floating-ip-release lab-training-fip --force
```

**Expected Output:**
```
Deleting floating IP lab-training-fip under account...
OK
Floating IP lab-training-fip is deleted.
```

#### 6.1.2 Plan Destruction

```bash
# Plan infrastructure destruction
terraform plan -destroy -var="ibmcloud_api_key=$IBMCLOUD_API_KEY"
```

**Expected Output:**
```
Plan: 0 to add, 0 to change, 11 to destroy.
```

#### 6.1.3 Execute Destruction

```bash
# Destroy all infrastructure
terraform destroy -var="ibmcloud_api_key=$IBMCLOUD_API_KEY" -auto-approve
```

**Expected Output:**
```
# ... destruction progress ...

Destroy complete! Resources: 11 destroyed.
```

#### 6.1.4 Clean Up SSH Key

```bash
# Remove SSH key from IBM Cloud
ibmcloud is key-delete ibm-lab-training-key --force

# Verify cleanup
terraform state list
```

**Expected Output:**
```
Deleting key ibm-lab-training-key under account...
OK
Key ibm-lab-training-key is deleted.

(empty output from state list)
```

### 6.2 Local Cleanup

#### 6.2.1 Remove State Files

```bash
# Remove Terraform state files (optional)
rm -f terraform.tfstate*
rm -f .terraform.lock.hcl
rm -rf .terraform/

# Remove deployment info
rm -f deployment-info.json
```

### 6.3 Cost Verification

#### 6.3.1 Check IBM Cloud Billing

1. **Access Billing Dashboard:**
   - Go to IBM Cloud Console
   - Navigate to "Manage" → "Billing and usage"
   - Check "Usage" for recent charges

2. **Verify Resource Deletion:**
   - Ensure no VPC resources remain
   - Confirm no ongoing charges

---

## 7. Troubleshooting

### 7.1 Common Issues and Solutions

#### 7.1.1 Authentication Issues

**Problem:** `Error: No valid (unexpired) auth token`

**Solution:**
```bash
# Re-authenticate
ibmcloud login --apikey $IBMCLOUD_API_KEY
ibmcloud target -r us-south -g terraform-training

# Verify API key is set
echo $IBMCLOUD_API_KEY
```

#### 7.1.2 Resource Group Issues

**Problem:** `Resource group not found`

**Solution:**
```bash
# List available resource groups
ibmcloud resource groups

# Create resource group if needed
ibmcloud resource group-create terraform-training

# Update terraform.tfvars with correct resource group name
```

#### 7.1.3 SSH Connection Issues

**Problem:** `Permission denied (publickey)`

**Solutions:**
```bash
# Check SSH key permissions
chmod 600 ~/.ssh/ibm_lab_key

# Verify key is uploaded to IBM Cloud
ibmcloud is keys

# Check VSI has the key assigned
ibmcloud is instance $(terraform output -raw vsi_id) --output json | jq '.keys'

# Test with verbose SSH
ssh -v -i ~/.ssh/ibm_lab_key root@$FLOATING_IP
```

#### 7.1.4 Terraform Provider Issues

**Problem:** `Provider registry.terraform.io/ibm-cloud/ibm not found`

**Solution:**
```bash
# Clean and reinitialize
rm -rf .terraform/
terraform init
```

#### 7.1.5 Large File Git Issues

**Problem:** `remote: error: File too large`

**Solution:**
```bash
# Remove .terraform directory before committing
rm -rf .terraform/
git rm --cached -r .terraform/ 2>/dev/null || true

# Ensure .gitignore is properly configured
git add .gitignore
git commit -m "Add comprehensive .gitignore"
```

### 7.2 Verification Commands

#### 7.2.1 Environment Verification

```bash
# Check all required tools
terraform version
ibmcloud version
git --version
ssh -V
jq --version

# Check IBM Cloud authentication
ibmcloud target

# Check API key
echo $IBMCLOUD_API_KEY | cut -c1-10
```

#### 7.2.2 Resource Verification

```bash
# Check VPC resources
ibmcloud is vpcs
ibmcloud is subnets
ibmcloud is instances

# Check Terraform state
terraform state list
terraform output
```

### 7.3 Getting Help

#### 7.3.1 IBM Cloud Support

- **Documentation:** https://cloud.ibm.com/docs
- **Support:** https://cloud.ibm.com/unifiedsupport/supportcenter
- **Community:** https://community.ibm.com/community/user/cloud

#### 7.3.2 Terraform Support

- **Documentation:** https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs
- **Community:** https://discuss.hashicorp.com/c/terraform-providers/

---

## Summary

This guide provides a complete walkthrough for setting up and executing IBM Cloud Terraform Training Lab 1.1. The lab demonstrates Infrastructure as Code fundamentals by creating a complete VPC environment with a Virtual Server Instance.

**Key Learning Outcomes:**
- ✅ Infrastructure as Code workflow (init → plan → apply → destroy)
- ✅ IBM Cloud VPC networking concepts
- ✅ Terraform state management
- ✅ SSH key management and VSI access
- ✅ Cost management and resource cleanup
- ✅ Git repository management for IaC projects

**Total Lab Duration:** Approximately 90-120 minutes

**Estimated Cost:** $0.10-0.15 per hour for VSI (remember to destroy resources after completion)

For questions or issues, refer to the troubleshooting section or consult the IBM Cloud documentation.
