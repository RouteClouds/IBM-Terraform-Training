# Lab 3: Hands-on Directory Setup and Configuration Files

## 📋 **Lab Overview**

**Duration**: 90-120 minutes  
**Difficulty**: Intermediate  
**Prerequisites**: Completion of Topics 1-2 (IaC Concepts and Terraform CLI Installation)

### **Learning Objectives**

By completing this lab, you will:
- Create a complete, enterprise-grade Terraform project structure from scratch
- Implement proper file separation and modular configuration approaches
- Configure IBM Cloud provider and basic resources following best practices
- Apply consistent naming conventions and comprehensive documentation standards
- Validate your implementation against enterprise quality criteria

### **Lab Scenario**

You are a DevOps engineer tasked with creating a standardized Terraform project structure for your organization's IBM Cloud infrastructure. The project must support multiple environments (dev, staging, production) and follow enterprise best practices for team collaboration and maintainability.

---

## 🎯 **Lab Environment Setup**

### **Prerequisites Verification**

Before starting, verify your environment:

```bash
# Verify Terraform installation
terraform version

# Verify IBM Cloud CLI (optional but recommended)
ibmcloud version

# Verify IBM Cloud API key is configured
echo $IC_API_KEY
```

**Expected Output**:
- Terraform v1.5.0 or higher
- IBM Cloud CLI v2.0.0 or higher (if installed)
- API key should be set (masked output)

### **Lab Directory Preparation**

```bash
# Create lab working directory
mkdir -p ~/terraform-labs/lab-3-directory-structure
cd ~/terraform-labs/lab-3-directory-structure

# Verify you're in the correct directory
pwd
```

---

## 📁 **Exercise 1: Create Basic Project Structure (20 minutes)**

![File Naming Conventions](DaC/generated_diagrams/naming_conventions.png)
*Figure 3.4: Reference guide for standardized naming patterns and file organization that you'll implement in this exercise*

### **Step 1: Create Directory Structure**

Create the foundational directory structure:

```bash
# Create main project directory
mkdir terraform-ibm-infrastructure

# Navigate to project directory
cd terraform-ibm-infrastructure

# Create core configuration files
touch providers.tf
touch variables.tf
touch main.tf
touch outputs.tf
touch terraform.tfvars.example
touch README.md

# Create supporting files
touch .gitignore
touch .terraform-version

# Verify structure
ls -la
```

**Expected Output**:
```
total 8
drwxr-xr-x  10 user  staff   320 Jan 20 10:00 .
drwxr-xr-x   3 user  staff    96 Jan 20 10:00 ..
-rw-r--r--   1 user  staff     0 Jan 20 10:00 .gitignore
-rw-r--r--   1 user  staff     0 Jan 20 10:00 .terraform-version
-rw-r--r--   1 user  staff     0 Jan 20 10:00 README.md
-rw-r--r--   1 user  staff     0 Jan 20 10:00 main.tf
-rw-r--r--   1 user  staff     0 Jan 20 10:00 outputs.tf
-rw-r--r--   1 user  staff     0 Jan 20 10:00 providers.tf
-rw-r--r--   1 user  staff     0 Jan 20 10:00 terraform.tfvars.example
-rw-r--r--   1 user  staff     0 Jan 20 10:00 variables.tf
```

### **Step 2: Configure Supporting Files**

Create `.terraform-version` file:
```bash
echo "1.5.0" > .terraform-version
```

Create `.gitignore` file:
```bash
cat > .gitignore << 'EOF'
# Terraform files
*.tfstate
*.tfstate.*
*.tfplan
*.tfplan.*
.terraform/
.terraform.lock.hcl

# Variable files
terraform.tfvars
*.auto.tfvars

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log
crash.log

# Backup files
*.backup
EOF
```

### **Validation Checkpoint 1**

Verify your basic structure:
```bash
# Check file count
ls -1 | wc -l

# Should output: 8

# Check .gitignore content
cat .gitignore | grep -c "terraform.tfvars"

# Should output: 1
```

---

## ⚙️ **Exercise 2: Configure Provider and Variables (25 minutes)**

### **Step 3: Create providers.tf**

Configure the IBM Cloud provider with enterprise standards:

```bash
cat > providers.tf << 'EOF'
# =============================================================================
# TERRAFORM AND PROVIDER CONFIGURATION
# =============================================================================

terraform {
  # Specify minimum Terraform version required
  required_version = ">= 1.5.0"
  
  # Define required providers with version constraints
  required_providers {
    # IBM Cloud Provider for managing IBM Cloud resources
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }
    
    # Random provider for generating unique resource names
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    
    # Time provider for managing time-based resources
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}

# =============================================================================
# IBM CLOUD PROVIDER CONFIGURATION
# =============================================================================

# Default IBM Cloud provider configuration
provider "ibm" {
  # IBM Cloud API Key - provided via environment variable or terraform.tfvars
  # ibmcloud_api_key = var.ibmcloud_api_key
  
  # Default region for resource provisioning
  region = var.ibm_region
  
  # Use VPC Gen 2 for better performance and features
  generation = 2
}

# Random provider configuration
provider "random" {
  # No specific configuration required
}

# Time provider configuration
provider "time" {
  # No specific configuration required
}
EOF
```

### **Step 4: Create variables.tf**

Define comprehensive input variables:

```bash
cat > variables.tf << 'EOF'
# =============================================================================
# IBM CLOUD AUTHENTICATION AND CONFIGURATION
# =============================================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
}

variable "ibm_region" {
  description = "IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", 
      "jp-tok", "au-syd", "jp-osa", "br-sao", "ca-tor"
    ], var.ibm_region)
    error_message = "IBM region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "default"
}

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "owner" {
  description = "Owner of the infrastructure (email or team name)"
  type        = string
}

# =============================================================================
# RESOURCE CONFIGURATION
# =============================================================================

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.240.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR."
  }
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.240.1.0/24"
  
  validation {
    condition     = can(cidrhost(var.subnet_cidr_block, 0))
    error_message = "Subnet CIDR block must be a valid IPv4 CIDR."
  }
}

variable "enable_public_gateway" {
  description = "Enable public gateway for internet access"
  type        = bool
  default     = true
}

# =============================================================================
# TAGGING AND METADATA
# =============================================================================

variable "resource_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    "managed-by" = "terraform"
    "project"    = "infrastructure-automation"
  }
}

variable "enable_monitoring" {
  description = "Enable monitoring and logging for resources"
  type        = bool
  default     = false
}
EOF
```

### **Validation Checkpoint 2**

Validate your provider and variable configuration:
```bash
# Initialize Terraform to download providers
terraform init

# Validate configuration syntax
terraform validate

# Check for formatting issues
terraform fmt -check
```

**Expected Output**:
- `terraform init`: Should download IBM, random, and time providers
- `terraform validate`: Should output "Success! The configuration is valid."
- `terraform fmt -check`: Should show no formatting issues

---

## 🏗️ **Exercise 3: Create Main Configuration and Outputs (30 minutes)**

### **Step 5: Create main.tf**

Implement the main resource configuration:

```bash
cat > main.tf << 'EOF'
# =============================================================================
# DATA SOURCES
# =============================================================================

# Get information about the specified resource group
data "ibm_resource_group" "project_rg" {
  name = var.resource_group_name
}

# =============================================================================
# LOCAL VALUES
# =============================================================================

locals {
  # Naming convention: {project}-{environment}-{resource-type}
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = merge(var.resource_tags, {
    environment = var.environment
    region      = var.ibm_region
    owner       = var.owner
    created_by  = "terraform"
    created_at  = timestamp()
  })
  
  # Availability zone for resources
  availability_zone = "${var.ibm_region}-1"
}

# =============================================================================
# RANDOM RESOURCES
# =============================================================================

# Generate random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# NETWORKING RESOURCES
# =============================================================================

# VPC for network isolation
resource "ibm_is_vpc" "project_vpc" {
  name           = "${local.name_prefix}-vpc-${random_string.suffix.result}"
  resource_group = data.ibm_resource_group.project_rg.id
  tags           = local.common_tags
  
  # Enable classic access if needed for hybrid connectivity
  classic_access = false
}

# Public gateway for internet access (optional)
resource "ibm_is_public_gateway" "project_gateway" {
  count = var.enable_public_gateway ? 1 : 0
  
  name           = "${local.name_prefix}-gateway-${random_string.suffix.result}"
  vpc            = ibm_is_vpc.project_vpc.id
  zone           = local.availability_zone
  resource_group = data.ibm_resource_group.project_rg.id
  tags           = local.common_tags
}

# Subnet for compute resources
resource "ibm_is_subnet" "project_subnet" {
  name            = "${local.name_prefix}-subnet-${random_string.suffix.result}"
  vpc             = ibm_is_vpc.project_vpc.id
  zone            = local.availability_zone
  ipv4_cidr_block = var.subnet_cidr_block
  resource_group  = data.ibm_resource_group.project_rg.id
  
  # Attach public gateway if enabled
  public_gateway = var.enable_public_gateway ? ibm_is_public_gateway.project_gateway[0].id : null
  
  tags = local.common_tags
}

# =============================================================================
# SECURITY RESOURCES
# =============================================================================

# Security group for network access control
resource "ibm_is_security_group" "project_sg" {
  name           = "${local.name_prefix}-sg-${random_string.suffix.result}"
  vpc            = ibm_is_vpc.project_vpc.id
  resource_group = data.ibm_resource_group.project_rg.id
  tags           = local.common_tags
}

# Allow outbound internet access
resource "ibm_is_security_group_rule" "outbound_all" {
  group     = ibm_is_security_group.project_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Allow inbound SSH access (port 22)
resource "ibm_is_security_group_rule" "inbound_ssh" {
  group     = ibm_is_security_group.project_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Allow inbound HTTP access (port 80)
resource "ibm_is_security_group_rule" "inbound_http" {
  group     = ibm_is_security_group.project_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 80
    port_max = 80
  }
}
EOF
```

### **Step 6: Create outputs.tf**

Define comprehensive output values:

```bash
cat > outputs.tf << 'EOF'
# =============================================================================
# NETWORKING OUTPUTS
# =============================================================================

output "vpc_id" {
  description = "ID of the created VPC"
  value       = ibm_is_vpc.project_vpc.id
}

output "vpc_name" {
  description = "Name of the created VPC"
  value       = ibm_is_vpc.project_vpc.name
}

output "vpc_crn" {
  description = "CRN of the created VPC"
  value       = ibm_is_vpc.project_vpc.crn
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = ibm_is_subnet.project_subnet.id
}

output "subnet_name" {
  description = "Name of the created subnet"
  value       = ibm_is_subnet.project_subnet.name
}

output "public_gateway_id" {
  description = "ID of the public gateway (if enabled)"
  value       = var.enable_public_gateway ? ibm_is_public_gateway.project_gateway[0].id : null
}

# =============================================================================
# SECURITY OUTPUTS
# =============================================================================

output "security_group_id" {
  description = "ID of the created security group"
  value       = ibm_is_security_group.project_sg.id
}

output "security_group_name" {
  description = "Name of the created security group"
  value       = ibm_is_security_group.project_sg.name
}

# =============================================================================
# PROJECT INFORMATION OUTPUTS
# =============================================================================

output "project_info" {
  description = "Comprehensive project deployment information"
  value = {
    project_name  = var.project_name
    environment   = var.environment
    region        = var.ibm_region
    owner         = var.owner
    name_prefix   = local.name_prefix
    random_suffix = random_string.suffix.result
  }
}

output "resource_summary" {
  description = "Summary of created resources"
  value = {
    vpc_count             = 1
    subnet_count          = 1
    security_group_count  = 1
    public_gateway_count  = var.enable_public_gateway ? 1 : 0
    total_resources       = var.enable_public_gateway ? 4 : 3
    estimated_monthly_cost = "$10-25 USD"
  }
}

output "connection_info" {
  description = "Information for connecting to the infrastructure"
  value = {
    vpc_cidr        = var.vpc_cidr_block
    subnet_cidr     = var.subnet_cidr_block
    availability_zone = local.availability_zone
    internet_access = var.enable_public_gateway
  }
}
EOF
```

### **Validation Checkpoint 3**

Validate your complete configuration:
```bash
# Validate the complete configuration
terraform validate

# Format all files
terraform fmt

# Generate and review the execution plan
terraform plan
```

**Expected Output**:
- `terraform validate`: Should confirm valid configuration
- `terraform fmt`: Should format all files consistently
- `terraform plan`: Should show plan to create 4-5 resources (depending on public gateway setting)

---

## 📝 **Exercise 4: Create Documentation and Example Files (20 minutes)**

### **Step 7: Create terraform.tfvars.example**

Provide example variable values:

```bash
cat > terraform.tfvars.example << 'EOF'
# =============================================================================
# IBM CLOUD AUTHENTICATION AND CONFIGURATION
# =============================================================================

# IBM Cloud API Key (Required)
# Obtain from: https://cloud.ibm.com/iam/apikeys
ibmcloud_api_key = "your-ibm-cloud-api-key-here"

# IBM Cloud Region (Required)
# Available regions: us-south, us-east, eu-gb, eu-de, jp-tok, au-syd, etc.
ibm_region = "us-south"

# Resource Group (Required)
# Must exist in your IBM Cloud account
resource_group_name = "default"

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

# Project name for resource naming and tagging
project_name = "terraform-lab"

# Environment designation
environment = "dev"

# Owner information for resource tagging
owner = "your-email@company.com"

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================

# VPC CIDR block (adjust if conflicts with existing networks)
vpc_cidr_block = "10.240.0.0/16"

# Subnet CIDR block (must be within VPC CIDR)
subnet_cidr_block = "10.240.1.0/24"

# Enable public gateway for internet access
enable_public_gateway = true

# =============================================================================
# OPTIONAL CONFIGURATION
# =============================================================================

# Additional resource tags
resource_tags = {
  "managed-by" = "terraform"
  "project"    = "infrastructure-automation"
  "cost-center" = "engineering"
  "team"       = "devops"
}

# Enable monitoring and logging
enable_monitoring = false
EOF
```

### **Step 8: Create comprehensive README.md**

Document your project:

```bash
cat > README.md << 'EOF'
# Terraform IBM Cloud Infrastructure Project

## Overview

This Terraform project creates a basic IBM Cloud infrastructure including VPC, subnet, security group, and optional public gateway. It demonstrates enterprise-grade project organization and best practices for team collaboration.

## Architecture

- **VPC**: Isolated network environment
- **Subnet**: Network segment for compute resources
- **Security Group**: Network access control
- **Public Gateway**: Internet access (optional)

## Prerequisites

- Terraform >= 1.5.0
- IBM Cloud account with API key
- Appropriate IBM Cloud permissions for VPC resources

## Quick Start

1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd terraform-ibm-infrastructure
   ```

2. **Configure Variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Clean Up**
   ```bash
   terraform destroy
   ```

## Configuration

### Required Variables

- `ibmcloud_api_key`: Your IBM Cloud API key
- `project_name`: Name for resource identification
- `owner`: Owner email or team name

### Optional Variables

- `ibm_region`: IBM Cloud region (default: us-south)
- `environment`: Environment name (default: dev)
- `vpc_cidr_block`: VPC CIDR (default: 10.240.0.0/16)
- `enable_public_gateway`: Enable internet access (default: true)

## File Structure

```
├── providers.tf              # Provider configuration
├── variables.tf              # Input variable definitions
├── main.tf                   # Resource definitions
├── outputs.tf                # Output value definitions
├── terraform.tfvars.example  # Example variable values
├── README.md                 # This documentation
├── .gitignore                # Git ignore patterns
└── .terraform-version        # Terraform version specification
```

## Outputs

After successful deployment, the following information will be displayed:

- VPC ID and name
- Subnet ID and name
- Security group information
- Project summary and connection details

## Cost Estimation

Estimated monthly cost: $10-25 USD (varies by region and usage)

## Support

For questions or issues, contact the infrastructure team or refer to the IBM Cloud Terraform documentation.
EOF
```

### **Validation Checkpoint 4**

Verify your documentation and examples:
```bash
# Check README length
wc -l README.md

# Should be approximately 80+ lines

# Verify terraform.tfvars.example
grep -c "=" terraform.tfvars.example

# Should show multiple variable assignments

# Final validation
terraform validate && echo "✅ Configuration is valid!"
```

---

## 🧪 **Exercise 5: Test and Validate Implementation (15-25 minutes)**

### **Step 9: Create Test Configuration**

Create your actual terraform.tfvars file for testing:

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your actual values (use your preferred editor)
# nano terraform.tfvars
# or
# code terraform.tfvars
```

**Required edits**:
- Replace `your-ibm-cloud-api-key-here` with your actual API key
- Update `owner` with your email
- Adjust `project_name` if desired
- Modify other values as needed

### **Step 10: Execute Deployment Test**

**⚠️ Note**: This step will create actual IBM Cloud resources and incur costs. Proceed only if you have appropriate permissions and budget.

```bash
# Initialize Terraform
terraform init

# Create execution plan
terraform plan -out=deployment.tfplan

# Review the plan carefully
# Apply only if the plan looks correct
terraform apply deployment.tfplan

# View outputs
terraform output
```

### **Step 11: Validation and Cleanup**

Validate your deployment:

```bash
# Check resource creation
terraform show

# Verify outputs
terraform output project_info
terraform output resource_summary

# Clean up resources (IMPORTANT!)
terraform destroy
```

**Expected Validation Results**:
- All resources created successfully
- Outputs display correct information
- Resources destroyed without errors

---

## 📊 **Lab Assessment and Deliverables**

### **Deliverable Checklist**

Verify you have created all required files:

```bash
# Check file structure
ls -la

# Verify file content
wc -l *.tf *.md

# Expected output:
# providers.tf: ~50 lines
# variables.tf: ~100 lines  
# main.tf: ~120 lines
# outputs.tf: ~80 lines
# README.md: ~80 lines
```

### **Quality Validation**

Run comprehensive validation:

```bash
# Syntax validation
terraform validate

# Format check
terraform fmt -check

# Security scan (if available)
# tfsec .

# Documentation check
grep -c "description" variables.tf outputs.tf
# Should show multiple descriptions
```

### **Assessment Criteria**

Your implementation will be evaluated on:

1. **✅ File Organization**: Proper separation of concerns
2. **✅ Naming Conventions**: Consistent and descriptive names
3. **✅ Documentation**: Comprehensive comments and README
4. **✅ Validation**: All validation checks pass
5. **✅ Best Practices**: Enterprise-grade patterns implemented

### **Troubleshooting Common Issues**

**Issue**: `terraform init` fails
- **Solution**: Check internet connectivity and provider source URLs

**Issue**: `terraform validate` shows errors
- **Solution**: Review syntax, check variable references and resource dependencies

**Issue**: `terraform plan` fails with authentication errors
- **Solution**: Verify API key is correct and has appropriate permissions

**Issue**: Resource creation fails
- **Solution**: Check IBM Cloud quotas and regional availability

---

## 🎯 **Lab Summary and Next Steps**

### **What You Accomplished**

✅ Created enterprise-grade Terraform project structure  
✅ Implemented proper file separation and organization  
✅ Configured IBM Cloud provider with best practices  
✅ Applied consistent naming conventions and documentation  
✅ Validated implementation against quality criteria  

### **Key Learning Outcomes**

- **Project Organization**: Understanding of proper Terraform file structure
- **Configuration Management**: Skills in variables, providers, and outputs
- **IBM Cloud Integration**: Practical experience with IBM Cloud resources
- **Enterprise Patterns**: Application of professional development practices
- **Quality Assurance**: Validation and testing methodologies

### **Preparation for Next Topics**

This lab prepares you for:
- **Topic 3.2**: Core commands that will operate on your organized files
- **Topic 3.3**: Advanced provider configuration building on your setup
- **Topic 4**: Resource provisioning using your project structure
- **Topic 5**: Modularization that scales your organizational patterns

### **Additional Practice**

To reinforce your learning:
1. Create additional environments (staging, production)
2. Implement different resource configurations
3. Practice with different IBM Cloud regions
4. Experiment with advanced tagging strategies

**🎉 Congratulations!** You have successfully completed Lab 3 and mastered Terraform directory structure and configuration files for IBM Cloud.
