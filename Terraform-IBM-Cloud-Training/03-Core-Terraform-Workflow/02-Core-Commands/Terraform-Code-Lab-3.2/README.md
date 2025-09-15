# Terraform Code Lab 3.2: Core Commands Practice

## 📋 **Lab Overview**

This Terraform configuration provides a comprehensive hands-on environment for practicing the five core Terraform commands: `init`, `validate`, `plan`, `apply`, and `destroy`. The lab creates a realistic IBM Cloud infrastructure while focusing on command workflow mastery and enterprise best practices.

### **Learning Objectives**

- Master all five core Terraform commands with practical application
- Understand command sequencing and dependencies in enterprise workflows
- Practice plan-based deployment processes for production readiness
- Implement proper error handling and troubleshooting techniques
- Develop automation skills for CI/CD integration

### **Lab Architecture**

The configuration deploys a multi-tier VPC infrastructure including:
- **VPC** with manual address prefix management
- **Multi-zone subnets** (web, app, data tiers)
- **Security groups** with configurable rules
- **Public gateway** (optional, for internet access)
- **Command logging** and validation resources

## 🏗️ **Infrastructure Components**

### **Core Resources**
- **1 VPC** with custom address prefix
- **3 Subnets** across different availability zones
- **1 Security Group** with 4 configurable rules
- **1 Public Gateway** (optional, $45/month)
- **Command validation** and logging resources

### **Utility Resources**
- **Random string** for unique resource naming
- **Time resources** for deployment tracking
- **Local files** for documentation generation
- **Null resources** for command validation

### **Generated Artifacts**
- `command-lab-deployment-summary.json` - Complete deployment information
- `terraform-commands-reference.md` - Command reference guide
- `command-lab-log.txt` - Deployment execution log

## 💰 **Cost Estimation**

### **Monthly Costs (USD)**
- **VPC**: $0.00 (Free)
- **Subnets**: $0.00 (Free)
- **Security Groups**: $0.00 (Free)
- **Public Gateway**: $45.00 (Optional)
- **Total**: $0.00 - $45.00/month

### **Cost Optimization**
- Set `enable_public_gateway = false` to eliminate all charges
- Use minimal subnet configurations for learning
- Clean up resources with `terraform destroy` after lab completion

## 🚀 **Quick Start Guide**

### **Prerequisites**
- Terraform >= 1.5.0
- IBM Cloud account with API key
- Appropriate IBM Cloud permissions (VPC, Subnets, Security Groups)

### **Setup Instructions**

1. **Clone and Navigate**:
   ```bash
   cd Terraform-Code-Lab-3.2
   ```

2. **Configure Variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your IBM Cloud API key and preferences
   ```

3. **Initialize Project**:
   ```bash
   terraform init
   ```

4. **Validate Configuration**:
   ```bash
   terraform validate
   ```

5. **Plan Deployment**:
   ```bash
   terraform plan -out=lab32.tfplan
   ```

6. **Deploy Infrastructure**:
   ```bash
   terraform apply lab32.tfplan
   ```

7. **Practice Commands** (see Command Reference section)

8. **Cleanup Resources**:
   ```bash
   terraform destroy
   ```

## 🔧 **Command Reference**

### **Core Command Sequence**

#### **1. terraform init**
```bash
# Basic initialization
terraform init

# Initialize with provider upgrades
terraform init -upgrade

# CI/CD friendly initialization
terraform init -no-color -input=false
```

#### **2. terraform validate**
```bash
# Validate configuration syntax
terraform validate

# Validate with JSON output for automation
terraform validate -json

# Validate for CI/CD pipelines
terraform validate -no-color
```

#### **3. terraform plan**
```bash
# Generate execution plan
terraform plan

# Save plan for later execution (recommended)
terraform plan -out=lab32.tfplan

# Plan with variable overrides
terraform plan -var="enable_public_gateway=false"

# Targeted planning
terraform plan -target=ibm_is_vpc.command_lab_vpc
```

#### **4. terraform apply**
```bash
# Apply with confirmation prompt
terraform apply

# Apply saved plan (recommended for production)
terraform apply lab32.tfplan

# Apply with auto-approval (use with caution)
terraform apply -auto-approve

# Targeted apply
terraform apply -target=ibm_is_vpc.command_lab_vpc
```

#### **5. terraform destroy**
```bash
# Plan destruction
terraform plan -destroy

# Destroy with confirmation
terraform destroy

# Destroy with auto-approval (use with caution)
terraform destroy -auto-approve

# Targeted destruction
terraform destroy -target=ibm_is_public_gateway.command_lab_gateway
```

### **State Management Commands**
```bash
# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show ibm_is_vpc.command_lab_vpc

# Refresh state from real infrastructure
terraform refresh
```

### **Troubleshooting Commands**
```bash
# Check Terraform version
terraform version

# List available providers
terraform providers

# Format configuration files
terraform fmt

# Validate with detailed output
TF_LOG=DEBUG terraform validate
```

## 📊 **Configuration Variables**

### **Required Variables**
- `ibm_api_key` - IBM Cloud API key for authentication
- `owner` - Owner email for resource tagging

### **Key Configuration Options**
- `project_name` - Project identifier (default: "lab32-core-commands")
- `environment` - Environment designation (default: "lab")
- `ibm_region` - IBM Cloud region (default: "us-south")
- `enable_public_gateway` - Enable internet access (default: true)
- `enable_command_logging` - Enable detailed logging (default: true)

### **Advanced Options**
- `command_timeout` - Command execution timeout (default: 300s)
- `enable_resource_validation` - Enable post-deployment validation
- `auto_approve_destroy` - Auto-approve destroy operations (default: false)

## 🎯 **Lab Exercises**

### **Exercise 1: Basic Command Workflow**
1. Initialize the project with `terraform init`
2. Validate configuration with `terraform validate`
3. Generate plan with `terraform plan`
4. Deploy infrastructure with `terraform apply`
5. Verify deployment with outputs

### **Exercise 2: Plan-Based Deployment**
1. Generate and save plan: `terraform plan -out=production.tfplan`
2. Review plan contents: `terraform show production.tfplan`
3. Apply saved plan: `terraform apply production.tfplan`
4. Verify no additional changes: `terraform plan`

### **Exercise 3: Configuration Changes**
1. Modify variables in `terraform.tfvars`
2. Plan changes: `terraform plan`
3. Apply updates: `terraform apply`
4. Verify changes in outputs

### **Exercise 4: Targeted Operations**
1. Target specific resource: `terraform plan -target=ibm_is_vpc.command_lab_vpc`
2. Apply targeted change: `terraform apply -target=ibm_is_vpc.command_lab_vpc`
3. Plan remaining changes: `terraform plan`

### **Exercise 5: State Management**
1. List all resources: `terraform state list`
2. Show specific resource: `terraform state show ibm_is_vpc.command_lab_vpc`
3. Refresh state: `terraform refresh`
4. Compare with plan: `terraform plan`

### **Exercise 6: Cleanup and Destruction**
1. Plan destruction: `terraform plan -destroy`
2. Review destruction plan carefully
3. Execute cleanup: `terraform destroy`
4. Verify complete cleanup: `terraform state list`

## 🔍 **Validation and Testing**

### **Automated Validation**
The configuration includes built-in validation:
- Resource creation verification
- Command execution logging
- Cost estimation calculations
- Output generation validation

### **Manual Verification**
1. **Check IBM Cloud Console**: Verify resources in VPC dashboard
2. **Review Generated Files**: Examine deployment summary and logs
3. **Test Connectivity**: Validate network configuration
4. **Verify Outputs**: Confirm all expected outputs are generated

### **Success Criteria**
- ✅ All commands execute without errors
- ✅ Infrastructure deploys successfully
- ✅ Outputs provide complete information
- ✅ Generated files contain expected data
- ✅ Cleanup removes all resources

## 🛠️ **Troubleshooting Guide**

### **Common Issues and Solutions**

#### **terraform init Failures**
- **Issue**: Provider download errors
- **Solution**: Check internet connectivity, configure proxy if needed
- **Command**: `terraform init -plugin-dir=/path/to/cached/providers`

#### **terraform validate Errors**
- **Issue**: Syntax or configuration errors
- **Solution**: Review error messages, check variable definitions
- **Command**: `terraform validate -json` for detailed error information

#### **terraform plan Failures**
- **Issue**: Authentication or permission errors
- **Solution**: Verify API key and IBM Cloud permissions
- **Check**: `echo $IC_API_KEY` and IBM Cloud console access

#### **terraform apply Errors**
- **Issue**: Resource quota or limit exceeded
- **Solution**: Check IBM Cloud quotas and adjust configuration
- **Command**: Review IBM Cloud console for quota information

#### **terraform destroy Issues**
- **Issue**: Dependency errors during destruction
- **Solution**: Use targeted destruction or manual cleanup
- **Command**: `terraform destroy -target=specific_resource`

### **Debug Commands**
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform plan

# Check provider configuration
terraform providers

# Validate state consistency
terraform plan -detailed-exitcode

# Force state refresh
terraform refresh
```

## 📚 **Additional Resources**

### **Documentation**
- [Terraform IBM Cloud Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)
- [Terraform Core Commands](https://www.terraform.io/docs/cli/commands/index.html)

### **Best Practices**
- Always validate before planning
- Save plans for production deployments
- Use meaningful resource names and tags
- Implement proper error handling
- Regular state backup and management

### **Next Steps**
- Practice advanced command options and flags
- Experiment with different configuration patterns
- Integrate commands into automation scripts
- Explore state management techniques
- Learn about remote state and collaboration

## 🎉 **Lab Completion**

Upon successful completion of this lab, you will have:
- ✅ Mastered all five core Terraform commands
- ✅ Implemented enterprise-grade command workflows
- ✅ Practiced plan-based deployment processes
- ✅ Developed troubleshooting and error resolution skills
- ✅ Created automation-ready command sequences

**Congratulations!** You are now ready to proceed to advanced Terraform topics and real-world infrastructure automation challenges.

---

**Lab Version**: 3.2  
**Last Updated**: 2024-01-20  
**Terraform Version**: >= 1.5.0  
**IBM Provider Version**: ~> 1.58.0
