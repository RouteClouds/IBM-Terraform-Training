# Environment Validation Checklist - IBM Cloud Terraform Training

## 🎯 **Purpose**

This comprehensive checklist ensures all students have properly configured environments before training begins, preventing delays and ensuring smooth laboratory exercises.

**Validation Time**: 15-20 minutes  
**When to Use**: Before training starts and after any environment changes  
**Support**: Instructors available for assistance with failed validations

## 📋 **Pre-Validation Requirements**

### **Student Information**
- [ ] Student Name: ________________________
- [ ] Email Address: ______________________
- [ ] Training Session: ___________________
- [ ] Validation Date: ____________________
- [ ] Instructor: _________________________

### **System Information**
- [ ] Operating System: ___________________
- [ ] RAM Available: ______________________
- [ ] Disk Space Free: ____________________
- [ ] Internet Speed: _____________________

## ✅ **Section 1: Account and Authentication**

### **1.1 IBM Cloud Account Validation**

#### **Test 1: Account Access**
```bash
# Command to run:
ibmcloud login --apikey @ibm-cloud-api-key.txt

# Expected output:
# Authenticating...
# OK
# Targeted account [Account Name] ([Account ID])
```
- [ ] **PASS**: Successfully logged in to IBM Cloud
- [ ] **FAIL**: Login failed - check API key and account status

#### **Test 2: Account Information**
```bash
# Command to run:
ibmcloud account show

# Expected output should include:
# Account ID, Name, Type, State (ACTIVE)
```
- [ ] **PASS**: Account information displayed correctly
- [ ] **FAIL**: Account information missing or incorrect

#### **Test 3: API Key Validation**
```bash
# Command to run:
ibmcloud iam api-keys

# Expected output:
# List of API keys including training key
```
- [ ] **PASS**: API key listed and active
- [ ] **FAIL**: API key missing or inactive

### **1.2 Resource Access Validation**

#### **Test 4: Resource Groups**
```bash
# Command to run:
ibmcloud resource groups

# Expected output:
# List of accessible resource groups
```
- [ ] **PASS**: Can view resource groups
- [ ] **FAIL**: No resource groups visible or access denied

#### **Test 5: Service Access**
```bash
# Command to run:
ibmcloud resource service-instances

# Expected output:
# List of service instances (may be empty for new accounts)
```
- [ ] **PASS**: Command executes without errors
- [ ] **FAIL**: Access denied or command fails

## 🔧 **Section 2: CLI Tools Validation**

### **2.1 IBM Cloud CLI**

#### **Test 6: CLI Version**
```bash
# Command to run:
ibmcloud version

# Expected output:
# ibmcloud version 2.20.0+
```
- [ ] **PASS**: Version 2.20.0 or higher
- [ ] **FAIL**: Older version or command not found

#### **Test 7: Required Plugins**
```bash
# Command to run:
ibmcloud plugin list

# Expected plugins:
# vpc-infrastructure, cloud-object-storage, key-protect, schematics
```
- [ ] **PASS**: All required plugins installed
- [ ] **FAIL**: Missing plugins - install with: `ibmcloud plugin install [plugin-name]`

#### **Test 8: Target Configuration**
```bash
# Command to run:
ibmcloud target

# Expected output should show:
# API endpoint, Region, Account, Resource group
```
- [ ] **PASS**: All target settings configured
- [ ] **FAIL**: Missing target configuration

### **2.2 Terraform CLI**

#### **Test 9: Terraform Version**
```bash
# Command to run:
terraform version

# Expected output:
# Terraform v1.5.0+ and provider versions
```
- [ ] **PASS**: Version 1.5.0 or higher
- [ ] **FAIL**: Older version or command not found

#### **Test 10: Terraform Initialization**
```bash
# Commands to run:
cd terraform-training
terraform init

# Expected output:
# Terraform has been successfully initialized!
```
- [ ] **PASS**: Initialization successful
- [ ] **FAIL**: Initialization failed - check provider configuration

## 🌐 **Section 3: Connectivity and Permissions**

### **3.1 Network Connectivity**

#### **Test 11: IBM Cloud API Connectivity**
```bash
# Command to run:
curl -s -o /dev/null -w "%{http_code}" https://cloud.ibm.com/api

# Expected output:
# 200 (or similar success code)
```
- [ ] **PASS**: Can reach IBM Cloud APIs
- [ ] **FAIL**: Network connectivity issues

#### **Test 12: Terraform Registry Access**
```bash
# Command to run:
curl -s -o /dev/null -w "%{http_code}" https://registry.terraform.io/providers/IBM-Cloud/ibm/latest

# Expected output:
# 200
```
- [ ] **PASS**: Can access Terraform Registry
- [ ] **FAIL**: Registry access blocked

### **3.2 Resource Creation Permissions**

#### **Test 13: VPC Creation Test (Dry Run)**
```bash
# Create test configuration:
cat > test-vpc.tf << EOF
resource "ibm_is_vpc" "test_vpc" {
  name = "validation-test-vpc"
  tags = ["validation", "test"]
}
EOF

# Command to run:
terraform plan

# Expected output:
# Plan shows VPC will be created
```
- [ ] **PASS**: Plan shows resource creation
- [ ] **FAIL**: Permission denied or plan fails

#### **Test 14: Resource Group Access**
```bash
# Command to run:
ibmcloud resource groups --output json | jq '.[0].id'

# Expected output:
# Resource group ID string
```
- [ ] **PASS**: Can access resource group details
- [ ] **FAIL**: Access denied or command fails

## 🔍 **Section 4: Development Environment**

### **4.1 File System and Permissions**

#### **Test 15: Directory Creation**
```bash
# Commands to run:
mkdir -p ~/terraform-training/test
cd ~/terraform-training/test
touch test-file.tf
ls -la test-file.tf

# Expected output:
# File created successfully with proper permissions
```
- [ ] **PASS**: Can create directories and files
- [ ] **FAIL**: Permission issues or disk space problems

#### **Test 16: Environment Variables**
```bash
# Command to run:
echo $PATH | grep -E "(terraform|ibmcloud)"

# Expected output:
# PATH contains terraform and ibmcloud directories
```
- [ ] **PASS**: CLI tools in PATH
- [ ] **FAIL**: PATH configuration issues

### **4.2 Configuration Files**

#### **Test 17: Provider Configuration**
```bash
# Command to run:
terraform providers

# Expected output:
# provider[registry.terraform.io/ibm-cloud/ibm]
```
- [ ] **PASS**: IBM provider configured correctly
- [ ] **FAIL**: Provider configuration issues

#### **Test 18: Variables Configuration**
```bash
# Command to run:
terraform validate

# Expected output:
# Success! The configuration is valid.
```
- [ ] **PASS**: Configuration validates successfully
- [ ] **FAIL**: Configuration errors found

## 🧪 **Section 5: End-to-End Validation**

### **5.1 Complete Workflow Test**

#### **Test 19: Resource Lifecycle Test**
```bash
# Create minimal test resource:
cat > validation-test.tf << EOF
resource "ibm_resource_group" "validation_test" {
  name = "terraform-validation-test-$(date +%s)"
  tags = ["validation", "temporary"]
}

output "resource_group_id" {
  value = ibm_resource_group.validation_test.id
}
EOF

# Commands to run:
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve

# Expected behavior:
# Resource created and destroyed successfully
```
- [ ] **PASS**: Complete lifecycle successful
- [ ] **FAIL**: Errors during creation or destruction

#### **Test 20: Cost Tracking Validation**
```bash
# Command to run:
ibmcloud billing account-usage --output json

# Expected output:
# Account usage information (may be minimal for new accounts)
```
- [ ] **PASS**: Can access billing information
- [ ] **FAIL**: Billing access denied

## 📊 **Validation Summary**

### **Results Overview**
- **Total Tests**: 20
- **Passed**: _____ / 20
- **Failed**: _____ / 20
- **Success Rate**: _____%

### **Critical Failures (Must Fix Before Training)**
- [ ] Account access issues (Tests 1-5)
- [ ] CLI installation problems (Tests 6-10)
- [ ] Network connectivity issues (Tests 11-12)
- [ ] Permission problems (Tests 13-14)

### **Minor Issues (Can Be Addressed During Training)**
- [ ] Configuration optimization (Tests 15-18)
- [ ] Advanced feature access (Tests 19-20)

## 🚨 **Troubleshooting Guide**

### **Common Issues and Solutions**

#### **API Key Problems**
```bash
# Regenerate API key if validation fails
ibmcloud iam service-api-key-create terraform-training-new [SERVICE-ID]
```

#### **Permission Issues**
```bash
# Check and update service policies
ibmcloud iam service-policies [SERVICE-ID]
```

#### **Network Connectivity**
```bash
# Test basic connectivity
ping cloud.ibm.com
nslookup registry.terraform.io
```

#### **CLI Installation Issues**
```bash
# Reinstall IBM Cloud CLI
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Reinstall Terraform
# Follow platform-specific installation instructions
```

## ✅ **Validation Completion**

### **Student Certification**
I certify that I have completed all validation tests and my environment is ready for training.

**Student Signature**: ________________________  
**Date**: ____________________

### **Instructor Verification**
I have reviewed the validation results and confirm the student environment meets training requirements.

**Instructor Signature**: ________________________  
**Date**: ____________________

### **Next Steps**
- [ ] Environment ready for training
- [ ] Issues identified and resolved
- [ ] Student prepared for Day 1 activities
- [ ] Backup environment configured (if needed)

---

**Support**: Contact training instructors immediately if any critical validations fail.
