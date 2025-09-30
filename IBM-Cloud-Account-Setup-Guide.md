# IBM Cloud Account Setup Guide - Terraform Training

## 🎯 **Overview**

This comprehensive guide provides step-by-step instructions for setting up IBM Cloud accounts, configuring authentication, and preparing development environments for the Terraform training program.

**Estimated Time**: 45-60 minutes  
**Prerequisites**: Valid email address and computer with internet access  
**Support**: Training instructors available for assistance

## 📋 **Pre-Training Checklist**

### **Required Information**
- [ ] Valid email address (preferably corporate email)
- [ ] Phone number for SMS verification
- [ ] Credit card for account verification (no charges during training)
- [ ] Preferred username and password

### **System Requirements**
- [ ] Windows 10+, macOS 10.15+, or Linux (Ubuntu 18.04+)
- [ ] 8GB RAM minimum, 16GB recommended
- [ ] 10GB free disk space
- [ ] Stable internet connection (minimum 10 Mbps)
- [ ] Administrative privileges for software installation

## 🚀 **Step 1: IBM Cloud Account Creation**

### **1.1 Account Registration**

1. **Navigate to IBM Cloud**
   - Open browser and go to: https://cloud.ibm.com
   - Click "Create an IBM Cloud account"

2. **Enter Account Information**
   ```
   Email: [your-email@company.com]
   First Name: [Your First Name]
   Last Name: [Your Last Name]
   Country/Region: [Select your location]
   ```

3. **Verify Email Address**
   - Check your email for verification message
   - Click verification link within 24 hours
   - Return to IBM Cloud login page

4. **Complete Profile Setup**
   - Set strong password (minimum 8 characters, mixed case, numbers, symbols)
   - Add phone number for SMS verification
   - Accept terms and conditions

### **1.2 Account Verification**

1. **Phone Verification**
   - Enter phone number in international format
   - Receive and enter SMS verification code
   - Confirm phone number is verified

2. **Identity Verification**
   - Provide credit card information for verification
   - **Note**: No charges will be incurred during training
   - Card is used only for identity verification

3. **Account Activation**
   - Wait for account activation (usually 5-10 minutes)
   - Receive welcome email with account details
   - Log in to IBM Cloud console to confirm access

## 🔑 **Step 2: API Key Generation**

### **2.1 Create Service ID**

1. **Access IAM Console**
   - Log in to IBM Cloud console
   - Navigate to "Manage" → "Access (IAM)"
   - Click "Service IDs" in left navigation

2. **Create New Service ID**
   ```
   Name: terraform-training-service-id
   Description: Service ID for Terraform training exercises
   ```
   - Click "Create"
   - Note the Service ID for future reference

### **2.2 Generate API Key**

1. **Create API Key**
   - In Service ID details, click "API keys" tab
   - Click "Create" button
   - Enter API key details:
   ```
   Name: terraform-training-api-key
   Description: API key for Terraform training labs
   ```

2. **Download and Secure API Key**
   - **CRITICAL**: Download API key immediately
   - Save to secure location (password manager recommended)
   - **WARNING**: API key cannot be retrieved after this step
   - Store in file named: `ibm-cloud-api-key.txt`

### **2.3 Assign Permissions**

1. **Create Access Policy**
   - Go to "Access policies" tab in Service ID
   - Click "Assign access"
   - Select "IAM services"

2. **Configure Resource Access**
   ```
   Service: All Identity and Access enabled services
   Resource group: Default (or training-specific group)
   Service access: Manager, Editor, Operator, Viewer
   Platform access: Administrator, Editor, Operator, Viewer
   ```

3. **Validate Permissions**
   - Review assigned policies
   - Ensure sufficient permissions for resource creation
   - Test API key functionality

## 💻 **Step 3: CLI Installation**

### **3.1 Install IBM Cloud CLI**

#### **Windows Installation**
```powershell
# Download and run installer
Invoke-WebRequest -Uri "https://download.clis.cloud.ibm.com/ibm-cloud-cli/2.20.0/IBM_Cloud_CLI_2.20.0_windows_amd64.exe" -OutFile "ibm-cloud-cli.exe"
.\ibm-cloud-cli.exe

# Verify installation
ibmcloud version
```

#### **macOS Installation**
```bash
# Using Homebrew (recommended)
brew install ibmcloud-cli

# Or download installer
curl -fsSL https://clis.cloud.ibm.com/install/osx | sh

# Verify installation
ibmcloud version
```

#### **Linux Installation**
```bash
# Ubuntu/Debian
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# CentOS/RHEL
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Verify installation
ibmcloud version
```

### **3.2 Install Required Plugins**

```bash
# Install essential plugins for training
ibmcloud plugin install vpc-infrastructure
ibmcloud plugin install cloud-object-storage
ibmcloud plugin install key-protect
ibmcloud plugin install schematics

# Verify plugin installation
ibmcloud plugin list
```

### **3.3 Install Terraform CLI**

#### **Windows Installation**
```powershell
# Using Chocolatey
choco install terraform

# Or manual installation
$terraformVersion = "1.5.7"
Invoke-WebRequest -Uri "https://releases.hashicorp.com/terraform/${terraformVersion}/terraform_${terraformVersion}_windows_amd64.zip" -OutFile "terraform.zip"
Expand-Archive terraform.zip -DestinationPath "C:\terraform"
# Add C:\terraform to PATH environment variable
```

#### **macOS Installation**
```bash
# Using Homebrew
brew install terraform

# Verify installation
terraform version
```

#### **Linux Installation**
```bash
# Download and install
TERRAFORM_VERSION="1.5.7"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

## ⚙️ **Step 4: Environment Configuration**

### **4.1 Configure IBM Cloud CLI**

```bash
# Login to IBM Cloud
ibmcloud login --apikey @ibm-cloud-api-key.txt

# Set target region (use training region)
ibmcloud target -r us-south

# Set resource group
ibmcloud target -g Default

# Verify configuration
ibmcloud target
```

### **4.2 Configure Terraform Provider**

1. **Create Provider Configuration**
   ```bash
   # Create training directory
   mkdir terraform-training
   cd terraform-training
   
   # Create provider configuration file
   cat > providers.tf << EOF
   terraform {
     required_providers {
       ibm = {
         source  = "IBM-Cloud/ibm"
         version = "~> 1.57.0"
       }
     }
     required_version = ">= 1.5.0"
   }
   
   provider "ibm" {
     ibmcloud_api_key = var.ibmcloud_api_key
     region           = var.region
   }
   EOF
   ```

2. **Create Variables File**
   ```bash
   cat > variables.tf << EOF
   variable "ibmcloud_api_key" {
     description = "IBM Cloud API key"
     type        = string
     sensitive   = true
   }
   
   variable "region" {
     description = "IBM Cloud region"
     type        = string
     default     = "us-south"
   }
   EOF
   ```

3. **Create terraform.tfvars File**
   ```bash
   cat > terraform.tfvars << EOF
   ibmcloud_api_key = "YOUR_API_KEY_HERE"
   region           = "us-south"
   EOF
   ```

### **4.3 Validate Configuration**

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Test provider connectivity
terraform plan
```

## ✅ **Step 5: Environment Validation**

### **5.1 Connectivity Tests**

```bash
# Test IBM Cloud CLI connectivity
ibmcloud resource groups

# Test Terraform provider
terraform providers

# Test resource creation (dry run)
terraform plan -var-file="terraform.tfvars"
```

### **5.2 Validation Checklist**

- [ ] IBM Cloud account created and verified
- [ ] API key generated and securely stored
- [ ] IBM Cloud CLI installed and configured
- [ ] Terraform CLI installed and working
- [ ] Provider configuration validated
- [ ] Connectivity to IBM Cloud confirmed
- [ ] Resource group access verified
- [ ] Training directory structure created

## 🆘 **Troubleshooting**

### **Common Issues and Solutions**

#### **API Key Issues**
```bash
# Error: Invalid API key
# Solution: Regenerate API key and update configuration
ibmcloud iam service-api-key-create terraform-training-api-key-new [SERVICE-ID]
```

#### **Permission Errors**
```bash
# Error: Insufficient permissions
# Solution: Verify and update IAM policies
ibmcloud iam service-policies [SERVICE-ID]
```

#### **CLI Installation Issues**
```bash
# Error: Command not found
# Solution: Verify PATH environment variable
echo $PATH
which ibmcloud
which terraform
```

### **Getting Help**
- **Training Support**: Contact instructors during training hours
- **IBM Cloud Support**: https://cloud.ibm.com/docs
- **Terraform Documentation**: https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs

## 📞 **Support Contacts**

**Training Team**:
- Email: terraform-training-support@company.com
- Slack: #terraform-training-help
- Phone: Available during training hours

**Emergency Support**:
- Critical issues preventing training participation
- Available 24/7 during training week

---

**Next Steps**: Complete this setup guide before training begins. Bring any issues to the first training session for immediate resolution.
