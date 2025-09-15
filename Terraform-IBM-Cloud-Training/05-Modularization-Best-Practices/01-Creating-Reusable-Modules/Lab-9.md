# Lab 9: Creating Reusable Terraform Modules

## 🎯 **Lab Overview**

This comprehensive hands-on laboratory provides practical experience in creating, testing, and publishing enterprise-grade Terraform modules for IBM Cloud infrastructure. You'll build production-ready modules with comprehensive validation, testing, and governance frameworks.

### **Learning Objectives**
- Create reusable VPC and compute modules with enterprise-grade interfaces
- Implement comprehensive testing and validation strategies
- Apply versioning and lifecycle management best practices
- Integrate modules with IBM Cloud Schematics for enterprise deployment
- Establish governance and distribution workflows

### **Lab Duration**: 90-120 minutes
### **Difficulty Level**: Intermediate to Advanced
### **Prerequisites**: Completion of Topics 1-4, IBM Cloud account with appropriate permissions

---

## 📋 **Lab Environment Setup**

### **Required Tools and Access**
- Terraform CLI (v1.5.0 or later)
- IBM Cloud CLI with VPC plugin
- Git for version control
- Go (v1.19+) for testing framework
- IBM Cloud account with VPC Infrastructure Services access

### **Cost Estimation**
- **VPC Resources**: $0.00 (VPC and subnets are free)
- **Public Gateway**: $45.00/month (if enabled)
- **Virtual Server Instances**: $24.00/month per instance (cx2-2x4 profile)
- **Estimated Lab Cost**: $5.00-10.00 for 2-hour session

### **Environment Variables**
```bash
export IBMCLOUD_API_KEY="your-api-key"
export TF_VAR_ibmcloud_api_key="your-api-key"
export TF_VAR_region="us-south"
export TF_VAR_resource_group_name="default"
```

---

## 🏗️ **Exercise 1: Basic VPC Module Creation (20 minutes)**

### **Objective**
Create a foundational VPC module with proper interface design and validation.

### **Step 1: Module Directory Structure**
```bash
# Create module directory structure
mkdir -p modules/vpc-basic/{examples/basic,tests/unit}
cd modules/vpc-basic

# Create core module files
touch {main.tf,variables.tf,outputs.tf,versions.tf,README.md}
```

### **Step 2: Module Interface Design**
Create the module interface with comprehensive variable validation:

```hcl
# variables.tf
variable "vpc_name" {
  description = "Name of the VPC to create"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.vpc_name))
    error_message = "VPC name must start with a letter, contain only lowercase letters, numbers, and hyphens."
  }
}

variable "resource_group_id" {
  description = "ID of the resource group for VPC resources"
  type        = string
}

variable "region" {
  description = "IBM Cloud region for VPC deployment"
  type        = string
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd"
    ], var.region)
    error_message = "Region must be a valid IBM Cloud VPC region."
  }
}

variable "address_prefix_management" {
  description = "Address prefix management for the VPC"
  type        = string
  default     = "auto"
  
  validation {
    condition     = contains(["auto", "manual"], var.address_prefix_management)
    error_message = "Address prefix management must be 'auto' or 'manual'."
  }
}

variable "enable_public_gateway" {
  description = "Enable public gateway for internet access"
  type        = bool
  default     = false
}

variable "tags" {
  description = "List of tags to apply to VPC resources"
  type        = list(string)
  default     = []
  
  validation {
    condition     = length(var.tags) <= 100
    error_message = "Cannot specify more than 100 tags."
  }
}
```

### **Step 3: Core Resource Implementation**
```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.45"
    }
  }
}

# Data source for availability zones
data "ibm_is_zones" "regional" {
  region = var.region
}

# VPC resource
resource "ibm_is_vpc" "main" {
  name                        = var.vpc_name
  resource_group              = var.resource_group_id
  address_prefix_management   = var.address_prefix_management
  default_network_acl_name    = "${var.vpc_name}-default-acl"
  default_routing_table_name  = "${var.vpc_name}-default-rt"
  default_security_group_name = "${var.vpc_name}-default-sg"
  
  tags = concat(var.tags, [
    "terraform:managed",
    "module:vpc-basic"
  ])
}

# Public gateway (conditional)
resource "ibm_is_public_gateway" "main" {
  count = var.enable_public_gateway ? length(data.ibm_is_zones.regional.zones) : 0
  
  name           = "${var.vpc_name}-gateway-${count.index + 1}"
  vpc            = ibm_is_vpc.main.id
  zone           = data.ibm_is_zones.regional.zones[count.index]
  resource_group = var.resource_group_id
  
  tags = concat(var.tags, [
    "terraform:managed",
    "module:vpc-basic",
    "component:public-gateway"
  ])
}
```

### **Step 4: Comprehensive Outputs**
```hcl
# outputs.tf
output "vpc_id" {
  description = "ID of the created VPC"
  value       = ibm_is_vpc.main.id
}

output "vpc_crn" {
  description = "CRN of the created VPC"
  value       = ibm_is_vpc.main.crn
}

output "vpc_status" {
  description = "Status of the VPC"
  value       = ibm_is_vpc.main.status
}

output "default_network_acl_id" {
  description = "ID of the default network ACL"
  value       = ibm_is_vpc.main.default_network_acl
}

output "default_security_group_id" {
  description = "ID of the default security group"
  value       = ibm_is_vpc.main.default_security_group
}

output "public_gateway_ids" {
  description = "IDs of the public gateways"
  value       = ibm_is_public_gateway.main[*].id
}

output "availability_zones" {
  description = "Available zones in the region"
  value       = data.ibm_is_zones.regional.zones
}

output "module_metadata" {
  description = "Module metadata and configuration"
  value = {
    module_name    = "vpc-basic"
    module_version = "1.0.0"
    vpc_name       = var.vpc_name
    region         = var.region
    created_at     = timestamp()
  }
}
```

### **Step 5: Example Implementation**
```hcl
# examples/basic/main.tf
module "vpc" {
  source = "../../"
  
  vpc_name                  = "example-vpc"
  resource_group_id         = data.ibm_resource_group.default.id
  region                    = "us-south"
  address_prefix_management = "auto"
  enable_public_gateway     = true
  
  tags = [
    "environment:development",
    "project:module-testing",
    "owner:platform-team"
  ]
}

data "ibm_resource_group" "default" {
  name = "default"
}

output "vpc_details" {
  value = module.vpc
}
```

### **Validation Steps**
```bash
# Initialize and validate the module
cd examples/basic
terraform init
terraform validate
terraform plan

# Check formatting
terraform fmt -check -recursive ../../
```

---

## 🧪 **Exercise 2: Advanced Module with Comprehensive Validation (25 minutes)**

### **Objective**
Enhance the VPC module with advanced features, comprehensive validation, and enterprise patterns.

### **Step 1: Enhanced Variable Design**
```hcl
# variables.tf (enhanced)
variable "vpc_configuration" {
  description = "Comprehensive VPC configuration object"
  type = object({
    name                      = string
    address_prefix_management = optional(string, "auto")
    enable_public_gateway     = optional(bool, false)
    
    # Advanced networking configuration
    classic_access            = optional(bool, false)
    default_network_acl_name  = optional(string, null)
    default_routing_table_name = optional(string, null)
    default_security_group_name = optional(string, null)
    
    # Subnet configuration
    subnets = optional(list(object({
      name                    = string
      zone                    = string
      cidr_block             = string
      public_gateway_enabled = optional(bool, false)
    })), [])
  })
  
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.vpc_configuration.name))
    error_message = "VPC name must start with a letter, contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition = length(var.vpc_configuration.name) >= 3 && length(var.vpc_configuration.name) <= 63
    error_message = "VPC name must be between 3 and 63 characters."
  }
  
  validation {
    condition = length(var.vpc_configuration.subnets) <= 15
    error_message = "Cannot create more than 15 subnets per VPC."
  }
  
  validation {
    condition = alltrue([
      for subnet in var.vpc_configuration.subnets :
      can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "All subnet CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "enterprise_settings" {
  description = "Enterprise governance and compliance settings"
  type = object({
    cost_center     = string
    environment     = string
    project_code    = string
    compliance_tags = optional(list(string), [])
    
    monitoring = optional(object({
      enable_flow_logs    = optional(bool, false)
      enable_activity_tracker = optional(bool, false)
      log_retention_days  = optional(number, 30)
    }), {})
    
    security = optional(object({
      enable_encryption   = optional(bool, true)
      kms_key_id         = optional(string, null)
      allowed_ip_ranges  = optional(list(string), [])
    }), {})
  })
  
  validation {
    condition = contains(["development", "staging", "production"], var.enterprise_settings.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
  
  validation {
    condition = can(regex("^[A-Z]{2,4}-[0-9]{3,6}$", var.enterprise_settings.project_code))
    error_message = "Project code must follow format: ABC-123 (2-4 letters, dash, 3-6 numbers)."
  }
}
```

### **Step 2: Advanced Resource Implementation**
```hcl
# main.tf (enhanced)
locals {
  # Generate comprehensive tags
  base_tags = [
    "terraform:managed",
    "module:vpc-advanced",
    "cost-center:${var.enterprise_settings.cost_center}",
    "environment:${var.enterprise_settings.environment}",
    "project:${var.enterprise_settings.project_code}"
  ]
  
  all_tags = concat(
    local.base_tags,
    var.enterprise_settings.compliance_tags,
    var.tags
  )
  
  # Subnet configuration with defaults
  subnet_configs = [
    for subnet in var.vpc_configuration.subnets : {
      name                    = subnet.name
      zone                    = subnet.zone
      cidr_block             = subnet.cidr_block
      public_gateway_enabled = subnet.public_gateway_enabled
      public_gateway_id      = subnet.public_gateway_enabled ? ibm_is_public_gateway.main[index(data.ibm_is_zones.regional.zones, subnet.zone)].id : null
    }
  ]
}

# Enhanced VPC with enterprise features
resource "ibm_is_vpc" "main" {
  name                        = var.vpc_configuration.name
  resource_group              = var.resource_group_id
  address_prefix_management   = var.vpc_configuration.address_prefix_management
  classic_access              = var.vpc_configuration.classic_access
  default_network_acl_name    = coalesce(var.vpc_configuration.default_network_acl_name, "${var.vpc_configuration.name}-default-acl")
  default_routing_table_name  = coalesce(var.vpc_configuration.default_routing_table_name, "${var.vpc_configuration.name}-default-rt")
  default_security_group_name = coalesce(var.vpc_configuration.default_security_group_name, "${var.vpc_configuration.name}-default-sg")
  
  tags = local.all_tags
}

# Subnets with advanced configuration
resource "ibm_is_subnet" "subnets" {
  count = length(local.subnet_configs)
  
  name                     = local.subnet_configs[count.index].name
  vpc                      = ibm_is_vpc.main.id
  zone                     = local.subnet_configs[count.index].zone
  ipv4_cidr_block         = local.subnet_configs[count.index].cidr_block
  public_gateway          = local.subnet_configs[count.index].public_gateway_id
  resource_group          = var.resource_group_id
  
  tags = concat(local.all_tags, [
    "component:subnet",
    "zone:${local.subnet_configs[count.index].zone}"
  ])
}

# Flow logs (conditional)
resource "ibm_is_flow_log" "vpc_flow_logs" {
  count = var.enterprise_settings.monitoring.enable_flow_logs ? 1 : 0
  
  name           = "${var.vpc_configuration.name}-flow-logs"
  target         = ibm_is_vpc.main.id
  active         = true
  storage_bucket = var.flow_logs_bucket_name
  resource_group = var.resource_group_id
  
  tags = concat(local.all_tags, [
    "component:flow-logs",
    "monitoring:enabled"
  ])
}
```

### **Step 3: Testing Framework Setup**
```go
// tests/unit/vpc_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVPCModuleBasicConfiguration(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../../examples/basic",
        Vars: map[string]interface{}{
            "vpc_name": "test-vpc-basic",
            "region":   "us-south",
        },
        NoColor: true,
    }
    
    defer terraform.Destroy(t, terraformOptions)
    
    terraform.InitAndApply(t, terraformOptions)
    
    // Validate outputs
    vpcID := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcID)
    
    vpcStatus := terraform.Output(t, terraformOptions, "vpc_status")
    assert.Equal(t, "available", vpcStatus)
}

func TestVPCModuleValidation(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../../examples/basic",
        Vars: map[string]interface{}{
            "vpc_name": "Invalid-VPC-Name",  // Should fail validation
            "region":   "us-south",
        },
        NoColor: true,
    }
    
    _, err := terraform.InitAndPlanE(t, terraformOptions)
    assert.Error(t, err, "Expected validation error for invalid VPC name")
}
```

### **Validation Steps**
```bash
# Run comprehensive validation
terraform fmt -check -recursive
terraform validate

# Run unit tests
cd tests
go mod init vpc-module-tests
go mod tidy
go test -v ./unit/...

# Security scan
tfsec .
```

---

## 📦 **Exercise 3: Module Composition and Dependencies (20 minutes)**

### **Objective**
Create a composite module that combines VPC and compute resources with proper dependency management.

### **Step 1: Composite Module Structure**
```bash
mkdir -p modules/web-application/{modules/{vpc,compute},examples/complete}
```

### **Step 2: Compute Sub-module**
```hcl
# modules/compute/main.tf
resource "ibm_is_instance" "web_servers" {
  count = var.instance_count
  
  name           = "${var.name_prefix}-web-${count.index + 1}"
  image          = data.ibm_is_image.base.id
  profile        = var.instance_profile
  vpc            = var.vpc_id
  zone           = var.subnets[count.index % length(var.subnets)].zone
  keys           = var.ssh_key_ids
  resource_group = var.resource_group_id
  
  primary_network_interface {
    subnet          = var.subnets[count.index % length(var.subnets)].id
    security_groups = var.security_group_ids
  }
  
  user_data = base64encode(templatefile("${path.module}/templates/web-server-init.sh", {
    hostname = "${var.name_prefix}-web-${count.index + 1}"
  }))
  
  tags = concat(var.tags, [
    "component:web-server",
    "instance:${count.index + 1}"
  ])
}

data "ibm_is_image" "base" {
  name = var.base_image_name
}
```

### **Step 3: Composite Module Integration**
```hcl
# modules/web-application/main.tf
module "vpc" {
  source = "./modules/vpc"
  
  vpc_configuration = var.vpc_configuration
  enterprise_settings = var.enterprise_settings
  resource_group_id = var.resource_group_id
  region = var.region
  tags = var.tags
}

module "compute" {
  source = "./modules/compute"
  
  name_prefix        = var.application_name
  instance_count     = var.compute_configuration.instance_count
  instance_profile   = var.compute_configuration.instance_profile
  base_image_name    = var.compute_configuration.base_image_name
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.subnet_details
  security_group_ids = [module.vpc.default_security_group_id]
  ssh_key_ids       = var.ssh_key_ids
  resource_group_id = var.resource_group_id
  tags = var.tags
  
  depends_on = [module.vpc]
}
```

### **Validation Steps**
```bash
# Test module composition
cd examples/complete
terraform init
terraform plan
terraform apply -auto-approve

# Validate dependencies
terraform graph | dot -Tpng > dependency-graph.png
```

---

## 🚀 **Exercise 4: Testing and Validation Strategies (15 minutes)**

### **Objective**
Implement comprehensive testing strategies including unit, integration, and end-to-end testing.

### **Step 1: Automated Testing Pipeline**
```yaml
# .github/workflows/module-ci.yml
name: Module CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Terraform Format Check
      run: terraform fmt -check -recursive
    
    - name: Terraform Validate
      run: |
        find . -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do
          echo "Validating $dir"
          (cd "$dir" && terraform init -backend=false && terraform validate)
        done
    
    - name: Security Scan
      uses: aquasecurity/tfsec-action@v1.0.0
    
    - name: Cost Estimation
      uses: infracost/infracost-gh-action@v0.16
      with:
        api_key: ${{ secrets.INFRACOST_API_KEY }}
        path: examples/complete
        terraform_plan_flags: -var-file=terraform.tfvars.example
```

### **Step 2: Integration Testing**
```go
// tests/integration/vpc_integration_test.go
func TestVPCModuleIntegration(t *testing.T) {
    t.Parallel()
    
    uniqueID := random.UniqueId()
    vpcName := fmt.Sprintf("test-vpc-%s", strings.ToLower(uniqueID))
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../../examples/complete",
        Vars: map[string]interface{}{
            "vpc_name":           vpcName,
            "region":            "us-south",
            "resource_group_id": os.Getenv("IBM_RESOURCE_GROUP_ID"),
        },
        EnvVars: map[string]string{
            "IBMCLOUD_API_KEY": os.Getenv("IBMCLOUD_API_KEY"),
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    
    terraform.InitAndApply(t, terraformOptions)
    
    // Validate VPC creation
    vpcID := terraform.Output(t, terraformOptions, "vpc_id")
    validateVPCExists(t, vpcID)
    
    // Validate subnets
    subnetIDs := terraform.OutputList(t, terraformOptions, "subnet_ids")
    assert.True(t, len(subnetIDs) > 0, "At least one subnet should be created")
    
    // Validate instances
    instanceIDs := terraform.OutputList(t, terraformOptions, "instance_ids")
    for _, instanceID := range instanceIDs {
        validateInstanceRunning(t, instanceID)
    }
}
```

---

## 📚 **Exercise 5: Publishing to Module Registry (10 minutes)**

### **Objective**
Publish the module to a registry with proper versioning and documentation.

### **Step 1: Module Documentation**
```markdown
# VPC Module

## Usage

```hcl
module "vpc" {
  source  = "terraform-ibm-modules/vpc/ibm"
  version = "~> 1.0"
  
  vpc_configuration = {
    name                      = "my-vpc"
    address_prefix_management = "auto"
    enable_public_gateway     = true
    
    subnets = [
      {
        name       = "subnet-1"
        zone       = "us-south-1"
        cidr_block = "10.240.0.0/24"
      }
    ]
  }
  
  enterprise_settings = {
    cost_center  = "CC-001"
    environment  = "development"
    project_code = "PRJ-123"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| ibm | ~> 1.45 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_configuration | VPC configuration object | `object` | n/a | yes |
| enterprise_settings | Enterprise settings | `object` | n/a | yes |
```

### **Step 2: Version Tagging**
```bash
# Tag and release
git tag -a v1.0.0 -m "Initial release of VPC module"
git push origin v1.0.0

# Create release notes
gh release create v1.0.0 --title "VPC Module v1.0.0" --notes "Initial release with enterprise features"
```

---

## 🔧 **Exercise 6: IBM Cloud Schematics Integration (10 minutes)**

### **Objective**
Deploy the module using IBM Cloud Schematics with enterprise governance.

### **Step 1: Schematics Workspace Configuration**
```json
{
  "name": "vpc-module-deployment",
  "type": ["terraform_v1.0"],
  "description": "VPC module deployment via Schematics",
  "template_repo": {
    "url": "https://github.com/your-org/terraform-ibm-vpc-module",
    "branch": "main",
    "folder": "examples/complete"
  },
  "template_data": [{
    "folder": ".",
    "type": "terraform_v1.0",
    "variablestore": [
      {
        "name": "vpc_configuration",
        "value": "{\"name\":\"schematics-vpc\",\"enable_public_gateway\":true}",
        "type": "object"
      }
    ]
  }]
}
```

### **Step 2: Automated Deployment**
```bash
# Create Schematics workspace
ibmcloud schematics workspace new --file workspace-config.json

# Apply the configuration
ibmcloud schematics apply --id <workspace-id>

# Monitor deployment
ibmcloud schematics logs --id <workspace-id>
```

---

## ✅ **Lab Validation and Cleanup**

### **Validation Checklist**
- [ ] VPC module creates resources successfully
- [ ] All validation rules work correctly
- [ ] Tests pass (unit and integration)
- [ ] Module is properly documented
- [ ] Version is tagged and released
- [ ] Schematics deployment works

### **Cleanup Steps**
```bash
# Destroy test resources
terraform destroy -auto-approve

# Clean up Schematics workspace
ibmcloud schematics workspace delete --id <workspace-id>

# Remove local test files
rm -rf .terraform terraform.tfstate*
```

---

## 🎯 **Key Takeaways**

1. **Module Design**: Proper interface design with validation is crucial for reusability
2. **Testing Strategy**: Multi-level testing ensures module quality and reliability
3. **Enterprise Integration**: Governance and compliance features are essential for enterprise adoption
4. **Documentation**: Comprehensive documentation enables effective module adoption
5. **Automation**: CI/CD pipelines ensure consistent quality and deployment processes

**Next Steps**: Apply these module creation principles to build your organization's module library and establish enterprise governance frameworks for infrastructure as code.
