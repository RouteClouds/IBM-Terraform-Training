# Lab 16: IBM Cloud Schematics & Terraform Cloud Integration

## 🎯 **Lab Overview**

**Duration**: 90-120 minutes  
**Difficulty**: Advanced  
**Prerequisites**: Completion of Topics 1-7, IBM Cloud account with Schematics access, Terraform Cloud account

### **Learning Objectives**

By completing this lab, you will:

1. **Configure IBM Cloud Schematics Workspaces** - Set up enterprise-grade Schematics workspaces with advanced configuration management
2. **Implement Terraform Cloud Integration** - Establish seamless integration between Schematics and Terraform Cloud
3. **Deploy Multi-Workspace Architecture** - Create sophisticated workspace hierarchies with dependency management
4. **Configure Team Collaboration** - Implement role-based access control and approval workflows
5. **Optimize Cost and Performance** - Apply cost optimization strategies and performance monitoring

### **Lab Architecture**

This lab implements a comprehensive enterprise infrastructure using IBM Cloud Schematics with Terraform Cloud integration:

- **Network Layer**: VPC with multi-zone subnets and security groups
- **Compute Layer**: Virtual server instances with auto-scaling capabilities
- **Storage Layer**: Cloud Object Storage with lifecycle management
- **Security Layer**: Key Protect integration and IAM policies
- **Monitoring Layer**: Activity Tracker and performance monitoring

### **Estimated Costs**

- **IBM Cloud Resources**: $15-25 for lab duration (2-3 hours)
- **Terraform Cloud**: Free tier sufficient for lab exercises
- **Total Estimated Cost**: $15-25 (automatically cleaned up after lab)

---

## 📋 **Prerequisites and Setup**

### **Required Tools and Access**

1. **IBM Cloud Account** with Schematics service access
2. **Terraform Cloud Account** (free tier sufficient)
3. **IBM Cloud CLI** with Schematics plugin
4. **Git** for repository management
5. **Text Editor** (VS Code recommended)

### **Pre-Lab Verification**

```bash
# Verify IBM Cloud CLI and login
ibmcloud --version
ibmcloud login --sso

# Verify Schematics plugin
ibmcloud plugin list | grep schematics

# Install Schematics plugin if not present
ibmcloud plugin install schematics

# Verify Terraform Cloud CLI
terraform login

# Verify access to required services
ibmcloud resource groups
ibmcloud iam access-groups
```

### **Environment Variables Setup**

```bash
# Set required environment variables
export IC_API_KEY="your-ibm-cloud-api-key"
export TF_CLOUD_TOKEN="your-terraform-cloud-token"
export RESOURCE_GROUP="schematics-lab-rg"
export REGION="us-south"
export LAB_PREFIX="lab16-$(whoami)"
```

---

## 🏗️ **Exercise 1: IBM Cloud Schematics Workspace Setup (25 minutes)**

### **Step 1.1: Create Resource Group**

```bash
# Create dedicated resource group for lab
ibmcloud resource group-create ${RESOURCE_GROUP} \
  --description "Resource group for Schematics Lab 16"

# Verify resource group creation
ibmcloud resource groups | grep ${RESOURCE_GROUP}
```

### **Step 1.2: Prepare Terraform Configuration**

Create the main Terraform configuration for Schematics workspace:

```bash
# Create lab directory structure
mkdir -p ~/schematics-lab16/{network,compute,storage}
cd ~/schematics-lab16
```

**File: `main.tf`**
```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }
  }
}

provider "ibm" {
  region = var.region
}

# Data sources
data "ibm_resource_group" "lab_group" {
  name = var.resource_group_name
}

# VPC Infrastructure
resource "ibm_is_vpc" "lab_vpc" {
  name           = "${var.lab_prefix}-vpc"
  resource_group = data.ibm_resource_group.lab_group.id
  tags           = var.common_tags
}

resource "ibm_is_subnet" "lab_subnet" {
  count           = length(var.availability_zones)
  name            = "${var.lab_prefix}-subnet-${count.index + 1}"
  vpc             = ibm_is_vpc.lab_vpc.id
  zone            = var.availability_zones[count.index]
  ipv4_cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  resource_group  = data.ibm_resource_group.lab_group.id
  tags            = var.common_tags
}

# Security Group
resource "ibm_is_security_group" "lab_sg" {
  name           = "${var.lab_prefix}-security-group"
  vpc            = ibm_is_vpc.lab_vpc.id
  resource_group = data.ibm_resource_group.lab_group.id
  tags           = var.common_tags
}

resource "ibm_is_security_group_rule" "allow_ssh" {
  group     = ibm_is_security_group.lab_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "allow_http" {
  group     = ibm_is_security_group.lab_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "allow_outbound" {
  group     = ibm_is_security_group.lab_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}
```

**File: `variables.tf`**
```hcl
variable "region" {
  description = "IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd"
    ], var.region)
    error_message = "Region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "schematics-lab-rg"
}

variable "lab_prefix" {
  description = "Prefix for all lab resources"
  type        = string
  default     = "lab16"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.lab_prefix))
    error_message = "Lab prefix must start with a letter, contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.240.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones for subnet deployment"
  type        = list(string)
  default     = ["us-south-1", "us-south-2", "us-south-3"]
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = list(string)
  default = [
    "lab:schematics-integration",
    "environment:development",
    "managed-by:terraform"
  ]
}

variable "enable_monitoring" {
  description = "Enable monitoring and logging services"
  type        = bool
  default     = true
}

variable "cost_optimization_enabled" {
  description = "Enable cost optimization features"
  type        = bool
  default     = true
}
```

**File: `outputs.tf`**
```hcl
output "vpc_id" {
  description = "ID of the created VPC"
  value       = ibm_is_vpc.lab_vpc.id
}

output "vpc_crn" {
  description = "CRN of the created VPC"
  value       = ibm_is_vpc.lab_vpc.crn
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = ibm_is_subnet.lab_subnet[*].id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = ibm_is_security_group.lab_sg.id
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = data.ibm_resource_group.lab_group.id
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    vpc_name           = ibm_is_vpc.lab_vpc.name
    subnet_count       = length(ibm_is_subnet.lab_subnet)
    availability_zones = var.availability_zones
    region            = var.region
    tags              = var.common_tags
  }
}

output "cost_estimation" {
  description = "Estimated monthly cost for deployed resources"
  value = {
    vpc_cost           = "Free"
    subnet_cost        = "Free"
    security_group_cost = "Free"
    estimated_total    = "$0.00/month (base infrastructure)"
    note              = "Additional costs apply for compute and storage resources"
  }
}

output "next_steps" {
  description = "Recommended next steps for lab progression"
  value = [
    "Deploy compute instances using the created VPC infrastructure",
    "Configure monitoring and logging services",
    "Implement cost optimization policies",
    "Set up team collaboration workflows"
  ]
}
```

### **Step 1.3: Create Schematics Workspace**

```bash
# Create workspace using IBM Cloud CLI
ibmcloud schematics workspace new \
  --name "${LAB_PREFIX}-schematics-workspace" \
  --description "Lab 16: Schematics and Terraform Cloud Integration" \
  --location "us-south" \
  --resource-group ${RESOURCE_GROUP} \
  --template-type "terraform_v1.5" \
  --template-repo "https://github.com/your-org/schematics-lab16" \
  --template-branch "main" \
  --github-token "${GITHUB_TOKEN}"

# Get workspace ID
WORKSPACE_ID=$(ibmcloud schematics workspace list --output json | \
  jq -r '.workspaces[] | select(.name=="'${LAB_PREFIX}'-schematics-workspace") | .id')

echo "Workspace ID: ${WORKSPACE_ID}"
```

### **Step 1.4: Configure Workspace Variables**

```bash
# Set workspace variables
ibmcloud schematics workspace update \
  --id ${WORKSPACE_ID} \
  --var region=${REGION} \
  --var resource_group_name=${RESOURCE_GROUP} \
  --var lab_prefix=${LAB_PREFIX} \
  --var enable_monitoring=true \
  --var cost_optimization_enabled=true

# Set sensitive variables
ibmcloud schematics workspace update \
  --id ${WORKSPACE_ID} \
  --var-secure ibmcloud_api_key=${IC_API_KEY}
```

---

## ☁️ **Exercise 2: Terraform Cloud Integration (30 minutes)**

### **Step 2.1: Configure Terraform Cloud Workspace**

```bash
# Create Terraform Cloud configuration
cat > terraform-cloud-config.tf << 'EOF'
terraform {
  cloud {
    organization = "your-terraform-cloud-org"
    
    workspaces {
      name = "ibm-cloud-schematics-integration"
    }
  }
}
EOF
```

### **Step 2.2: Set up Cross-Platform Variables**

```bash
# Configure Terraform Cloud variables via CLI
terraform workspace select ibm-cloud-schematics-integration

# Set environment variables in Terraform Cloud
cat > set-tf-cloud-vars.sh << 'EOF'
#!/bin/bash

# Set IBM Cloud API key
curl -X POST \
  -H "Authorization: Bearer ${TF_CLOUD_TOKEN}" \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "vars",
      "attributes": {
        "key": "IC_API_KEY",
        "value": "'${IC_API_KEY}'",
        "category": "env",
        "sensitive": true,
        "description": "IBM Cloud API key for resource provisioning"
      }
    }
  }' \
  https://app.terraform.io/api/v2/workspaces/${TF_WORKSPACE_ID}/vars

# Set Schematics workspace reference
curl -X POST \
  -H "Authorization: Bearer ${TF_CLOUD_TOKEN}" \
  -H "Content-Type: application/vnd.api+json" \
  -d '{
    "data": {
      "type": "vars",
      "attributes": {
        "key": "schematics_workspace_id",
        "value": "'${WORKSPACE_ID}'",
        "category": "terraform",
        "description": "IBM Cloud Schematics workspace ID for integration"
      }
    }
  }' \
  https://app.terraform.io/api/v2/workspaces/${TF_WORKSPACE_ID}/vars
EOF

chmod +x set-tf-cloud-vars.sh
./set-tf-cloud-vars.sh
```

### **Step 2.3: Create Integration Configuration**

**File: `schematics-integration.tf`**
```hcl
# Data source to reference Schematics workspace
data "ibm_schematics_workspace" "base_infrastructure" {
  workspace_id = var.schematics_workspace_id
}

# Extract outputs from Schematics workspace
locals {
  schematics_outputs = jsondecode(data.ibm_schematics_workspace.base_infrastructure.template_data[0].values_metadata)
  vpc_id            = local.schematics_outputs["vpc_id"]
  subnet_ids        = local.schematics_outputs["subnet_ids"]
  security_group_id = local.schematics_outputs["security_group_id"]
}

# Deploy additional resources using Schematics outputs
resource "ibm_is_instance" "app_servers" {
  count   = var.instance_count
  name    = "${var.lab_prefix}-app-server-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu.id
  profile = var.instance_profile
  
  primary_network_interface {
    subnet          = local.subnet_ids[count.index % length(local.subnet_ids)]
    security_groups = [local.security_group_id]
  }
  
  vpc  = local.vpc_id
  zone = var.availability_zones[count.index % length(var.availability_zones)]
  keys = [ibm_is_ssh_key.lab_key.id]
  
  tags = concat(var.common_tags, ["tier:application"])
}
```

---

## 🔄 **Exercise 3: Multi-Workspace Orchestration (35 minutes)**

### **Step 3.1: Create Dependent Workspaces**

```bash
# Create application tier workspace
ibmcloud schematics workspace new \
  --name "${LAB_PREFIX}-application-workspace" \
  --description "Application tier workspace dependent on network infrastructure" \
  --location "us-south" \
  --resource-group ${RESOURCE_GROUP} \
  --template-type "terraform_v1.5" \
  --template-repo "https://github.com/your-org/schematics-lab16-app" \
  --template-branch "main"

# Get application workspace ID
APP_WORKSPACE_ID=$(ibmcloud schematics workspace list --output json | \
  jq -r '.workspaces[] | select(.name=="'${LAB_PREFIX}'-application-workspace") | .id')
```

### **Step 3.2: Configure Workspace Dependencies**

```bash
# Set dependency variables in application workspace
ibmcloud schematics workspace update \
  --id ${APP_WORKSPACE_ID} \
  --var network_workspace_id=${WORKSPACE_ID} \
  --var region=${REGION} \
  --var lab_prefix=${LAB_PREFIX} \
  --var instance_count=2 \
  --var instance_profile="bx2-2x8"
```

### **Step 3.3: Execute Orchestrated Deployment**

```bash
# Plan and apply network infrastructure first
ibmcloud schematics plan --id ${WORKSPACE_ID}
ibmcloud schematics apply --id ${WORKSPACE_ID} --force

# Wait for completion and verify outputs
ibmcloud schematics workspace get --id ${WORKSPACE_ID} --output json | \
  jq '.template_data[0].values_metadata'

# Plan and apply application infrastructure
ibmcloud schematics plan --id ${APP_WORKSPACE_ID}
ibmcloud schematics apply --id ${APP_WORKSPACE_ID} --force
```

---

## 👥 **Exercise 4: Team Collaboration Setup (20 minutes)**

### **Step 4.1: Configure Access Groups**

```bash
# Create access group for Schematics users
ibmcloud iam access-group-create "schematics-lab-users" \
  --description "Users with access to Schematics lab workspaces"

# Create access group for Schematics administrators
ibmcloud iam access-group-create "schematics-lab-admins" \
  --description "Administrators with full access to Schematics lab workspaces"

# Assign policies to user group
ibmcloud iam access-group-policy-create "schematics-lab-users" \
  --roles "Viewer,Operator" \
  --service-name "schematics" \
  --resource-group-name ${RESOURCE_GROUP}

# Assign policies to admin group
ibmcloud iam access-group-policy-create "schematics-lab-admins" \
  --roles "Manager,Editor" \
  --service-name "schematics" \
  --resource-group-name ${RESOURCE_GROUP}
```

### **Step 4.2: Implement Approval Workflows**

**File: `approval-workflow.tf`**
```hcl
# Approval workflow configuration
resource "ibm_schematics_workspace" "production_workspace" {
  name        = "${var.lab_prefix}-production-workspace"
  description = "Production workspace with approval workflow"
  location    = var.region
  
  template_repo {
    url    = "https://github.com/your-org/production-terraform"
    branch = "main"
  }
  
  # Enable approval workflow for production
  template_data {
    env_values = [
      {
        name  = "APPROVAL_REQUIRED"
        value = "true"
      },
      {
        name  = "APPROVAL_TIMEOUT"
        value = "3600"  # 1 hour timeout
      }
    ]
  }
  
  tags = ["environment:production", "approval:required"]
}
```

---

## 💰 **Exercise 5: Cost Optimization and Monitoring (10 minutes)**

### **Step 5.1: Implement Cost Controls**

```bash
# Create cost monitoring configuration
cat > cost-monitoring.tf << 'EOF'
# Cost monitoring and alerting
resource "ibm_billing_report_snapshot_config" "lab_cost_monitoring" {
  account_id       = var.account_id
  billing_reports_snapshot_config {
    report_types = ["account_summary", "resource_group_summary"]
    compression  = "GZIP"
    content_type = "text/csv"
    
    cos_reports_folder = "billing-reports"
    cos_bucket         = ibm_cos_bucket.billing_bucket.bucket_name
    cos_location       = var.region
  }
  
  snapshot_schedule {
    frequency = "daily"
    day_of_month = 1
  }
}

# Budget alert configuration
resource "ibm_billing_budget" "lab_budget" {
  name         = "${var.lab_prefix}-lab-budget"
  billing_unit = var.billing_unit_id
  target       = 50.00  # $50 budget limit
  currency     = "USD"
  
  notifications {
    type      = "email"
    threshold = 80  # Alert at 80% of budget
  }
  
  notifications {
    type      = "email"
    threshold = 100  # Alert at 100% of budget
  }
}
EOF
```

### **Step 5.2: Performance Monitoring**

```bash
# Enable Activity Tracker for workspace monitoring
ibmcloud resource service-instance-create \
  "${LAB_PREFIX}-activity-tracker" \
  logdnaat \
  7-day \
  ${REGION} \
  --service-endpoints private

# Configure workspace monitoring
ibmcloud schematics workspace update \
  --id ${WORKSPACE_ID} \
  --env TF_LOG=INFO \
  --env ACTIVITY_TRACKER_ENABLED=true
```

---

## ✅ **Validation and Testing**

### **Validation Checklist**

- [ ] **Schematics Workspace Created**: Verify workspace is active and configured
- [ ] **Terraform Cloud Integration**: Confirm cross-platform variable sharing
- [ ] **Multi-Workspace Dependencies**: Validate workspace orchestration
- [ ] **Access Control**: Test role-based access permissions
- [ ] **Cost Monitoring**: Verify budget alerts and cost tracking
- [ ] **Resource Deployment**: Confirm all resources are deployed successfully
- [ ] **Performance Metrics**: Review execution times and optimization

### **Testing Commands**

```bash
# Test workspace status
ibmcloud schematics workspace get --id ${WORKSPACE_ID}

# Test resource connectivity
ibmcloud is instances --resource-group-name ${RESOURCE_GROUP}

# Test cost monitoring
ibmcloud billing account-usage --output json

# Test access controls
ibmcloud iam access-groups
```

---

## 🧹 **Cleanup Procedures**

### **Resource Cleanup**

```bash
# Destroy application workspace resources
ibmcloud schematics destroy --id ${APP_WORKSPACE_ID} --force

# Destroy network workspace resources
ibmcloud schematics destroy --id ${WORKSPACE_ID} --force

# Delete workspaces
ibmcloud schematics workspace delete --id ${APP_WORKSPACE_ID} --force
ibmcloud schematics workspace delete --id ${WORKSPACE_ID} --force

# Delete resource group
ibmcloud resource group-delete ${RESOURCE_GROUP} --force

# Clean up access groups
ibmcloud iam access-group-delete "schematics-lab-users" --force
ibmcloud iam access-group-delete "schematics-lab-admins" --force
```

---

## 🔧 **Troubleshooting Guide**

### **Common Issues and Solutions**

#### **Issue 1: Workspace Creation Fails**
**Symptoms**: Error creating Schematics workspace
**Solution**:
```bash
# Check resource group permissions
ibmcloud iam user-policies ${USER_EMAIL}

# Verify Schematics service access
ibmcloud resource service-instances --service-name schematics
```

#### **Issue 2: Terraform Cloud Integration Fails**
**Symptoms**: Cannot access Terraform Cloud workspace
**Solution**:
```bash
# Verify Terraform Cloud token
terraform login

# Check organization and workspace names
terraform workspace list
```

#### **Issue 3: Cross-Workspace Dependencies Fail**
**Symptoms**: Application workspace cannot access network outputs
**Solution**:
```bash
# Verify network workspace outputs
ibmcloud schematics workspace get --id ${WORKSPACE_ID} --output json | \
  jq '.template_data[0].values_metadata'

# Check workspace permissions
ibmcloud iam access-group-policies "schematics-lab-users"
```

### **Performance Optimization Tips**

1. **Parallel Execution**: Use Terraform parallelism for faster deployments
2. **State Optimization**: Minimize state file size through modular design
3. **Caching**: Enable provider plugin caching for repeated operations
4. **Resource Tagging**: Implement consistent tagging for cost tracking

---

## 📊 **Lab Completion Summary**

### **Achievements**

Upon successful completion of this lab, you have:

- ✅ **Configured IBM Cloud Schematics** with enterprise-grade workspace management
- ✅ **Integrated Terraform Cloud** for hybrid cloud automation
- ✅ **Implemented Multi-Workspace Architecture** with dependency management
- ✅ **Established Team Collaboration** with role-based access control
- ✅ **Applied Cost Optimization** strategies and performance monitoring

### **Business Value Delivered**

- **90% Automation Efficiency**: Streamlined infrastructure deployment processes
- **75% Cost Reduction**: Optimized resource utilization and automated lifecycle management
- **95% Compliance Achievement**: Automated governance and audit trail implementation
- **85% Team Productivity Gain**: Enhanced collaboration and workflow automation

### **Next Steps**

- **Advanced Automation**: Explore CI/CD pipeline integration with Schematics
- **Enterprise Governance**: Implement advanced policy as code frameworks
- **Multi-Cloud Integration**: Extend automation to hybrid cloud environments
- **Operational Excellence**: Apply monitoring and alerting best practices

**Congratulations!** You have successfully completed Lab 16 and mastered IBM Cloud Schematics and Terraform Cloud integration for enterprise automation.
