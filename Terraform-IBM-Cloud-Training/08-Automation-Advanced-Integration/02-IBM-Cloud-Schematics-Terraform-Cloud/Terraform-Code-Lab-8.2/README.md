# IBM Cloud Schematics & Terraform Cloud Integration - Lab Environment

## 🎯 **Overview**

This lab environment provides a comprehensive, production-ready implementation of IBM Cloud Schematics integrated with Terraform Cloud for enterprise-grade infrastructure automation. The lab demonstrates advanced patterns for team collaboration, cost optimization, and hybrid cloud management.

### **Learning Objectives**

By completing this lab, you will:

1. **Deploy Enterprise Schematics Workspaces** - Create and configure production-ready Schematics workspaces with advanced settings
2. **Implement Terraform Cloud Integration** - Establish seamless integration between IBM Cloud Schematics and Terraform Cloud
3. **Configure Team Collaboration** - Set up IAM access groups, policies, and team-based workflow management
4. **Enable Cost Optimization** - Implement budget tracking, cost alerts, and automated resource lifecycle management
5. **Establish Monitoring and Governance** - Deploy comprehensive audit logging, monitoring, and compliance frameworks

---

## 🏗️ **Architecture Overview**

This lab creates the following infrastructure:

### **Core Components**
- **Primary Schematics Workspace** - Main infrastructure automation workspace
- **Network Dependency Workspace** - Demonstrates workspace orchestration and dependencies
- **Terraform Cloud Workspace** - Hybrid cloud automation integration
- **IAM Access Group** - Team collaboration and role-based access control
- **Activity Tracker** - Comprehensive audit logging and compliance
- **Log Analysis** - Centralized logging and monitoring

### **Integration Features**
- **Cross-Platform Workflows** - Unified automation across IBM Cloud and Terraform Cloud
- **Workspace Dependencies** - Sophisticated orchestration and dependency management
- **Cost Tracking** - Automated budget monitoring and optimization
- **Security Framework** - Enterprise-grade security and compliance controls

---

## 📋 **Prerequisites**

### **Required Tools**
- **Terraform** >= 1.5.0 ([Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli))
- **IBM Cloud CLI** ([Installation Guide](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli))
- **jq** - JSON processor ([Installation Guide](https://stedolan.github.io/jq/download/))
- **Git** - Version control system

### **Required Accounts and Access**
- **IBM Cloud Account** with appropriate permissions:
  - Schematics service access
  - IAM policy management
  - Resource group access
  - Billing and cost management
- **Terraform Cloud Account** (optional, for hybrid integration)
- **GitHub Account** (for template repositories)

### **Required Permissions**
- **IBM Cloud IAM Roles**:
  - Manager role for Schematics service
  - Editor role for target resource group
  - Administrator role for IAM (for access group management)
  - Editor role for Activity Tracker and Log Analysis services

---

## 🚀 **Quick Start**

### **1. Clone and Setup**

```bash
# Clone the repository (if not already done)
git clone <repository-url>
cd Terraform-Code-Lab-8.2

# Run automated setup
./scripts/setup.sh
```

### **2. Configure Variables**

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your specific values
nano terraform.tfvars
```

### **3. Deploy Infrastructure**

```bash
# Initialize Terraform
terraform init

# Review deployment plan
terraform plan

# Deploy infrastructure
terraform apply
```

### **4. Validate Deployment**

```bash
# Run validation script
./scripts/validate.sh

# View outputs
terraform output
```

---

## ⚙️ **Configuration Guide**

### **Essential Variables**

Edit `terraform.tfvars` with your specific values:

```hcl
# Authentication
ibmcloud_api_key = "your-ibm-cloud-api-key"
terraform_cloud_token = "your-terraform-cloud-token"

# Project Configuration
project_name = "your-project-name"
environment = "dev"
owner_email = "your-email@company.com"

# IBM Cloud Settings
ibm_region = "us-south"
resource_group_name = "your-resource-group"

# Team Collaboration
team_members = [
  "team-member-1@company.com",
  "team-member-2@company.com"
]

# Cost Management
budget_limit = 500
budget_alert_threshold = 80
```

### **Advanced Configuration Options**

#### **Terraform Cloud Integration**
```hcl
# Enable/disable Terraform Cloud integration
enable_terraform_cloud_integration = true
terraform_cloud_organization = "your-org"
terraform_cloud_hostname = "app.terraform.io"
```

#### **Security and Compliance**
```hcl
# Compliance level (standard, high, critical)
compliance_level = "high"

# Access control
workspace_access_level = "operator"  # viewer, operator, manager

# Audit logging
enable_audit_logging = true
log_retention_days = 90
```

#### **Cost Optimization**
```hcl
# Budget management
budget_limit = 1000
budget_alert_threshold = 85

# Automated cleanup (cron format)
auto_destroy_schedule = "0 18 * * 5"  # Every Friday at 6 PM

# Cost tracking
enable_cost_tracking = true
```

---

## 📊 **Monitoring and Management**

### **Accessing Your Resources**

After deployment, use these commands to access your resources:

```bash
# Get all output values
terraform output

# Get specific workspace URLs
terraform output schematics_workspace_url
terraform output terraform_cloud_workspace_url

# Get monitoring dashboard URLs
terraform output activity_tracker_dashboard_url
terraform output log_analysis_dashboard_url
```

### **Workspace Management**

#### **Schematics Workspace Operations**
```bash
# List workspaces
ibmcloud schematics workspace list

# Get workspace details
ibmcloud schematics workspace get --id $(terraform output -raw schematics_workspace_id)

# Apply workspace (run Terraform)
ibmcloud schematics apply --id $(terraform output -raw schematics_workspace_id)

# View workspace logs
ibmcloud schematics logs --id $(terraform output -raw schematics_workspace_id)
```

#### **Team Collaboration**
```bash
# View access group members
ibmcloud iam access-group-users $(terraform output -raw iam_access_group_name)

# Add team member to access group
ibmcloud iam access-group-user-add $(terraform output -raw iam_access_group_name) user@company.com
```

### **Cost Monitoring**

#### **Budget Tracking**
```bash
# View current usage
ibmcloud billing account-usage

# View resource group usage
ibmcloud billing resource-group-usage $(terraform output -raw resource_group_name)

# View cost breakdown by service
ibmcloud billing org-usage --output json | jq '.resources[]'
```

---

## 🔧 **Troubleshooting**

### **Common Issues and Solutions**

#### **Authentication Errors**
```bash
# Verify IBM Cloud authentication
ibmcloud account show

# Re-authenticate if needed
ibmcloud login --apikey your-api-key

# Verify Terraform Cloud token
export TFE_TOKEN="your-terraform-cloud-token"
```

#### **Permission Errors**
```bash
# Check IAM permissions
ibmcloud iam user-policies your-email@company.com

# Verify resource group access
ibmcloud resource groups

# Check Schematics service access
ibmcloud iam user-policy your-email@company.com --service-name schematics
```

#### **Resource Conflicts**
```bash
# Check for existing resources
ibmcloud schematics workspace list | grep your-project-name

# View resource group contents
ibmcloud resource service-instances --resource-group-name your-resource-group

# Clean up conflicting resources
terraform destroy
```

#### **Terraform State Issues**
```bash
# Refresh state
terraform refresh

# Import existing resources (if needed)
terraform import ibm_schematics_workspace.main_workspace workspace-id

# Reset state (use with caution)
rm terraform.tfstate*
terraform init
```

### **Validation and Testing**

#### **Run Comprehensive Validation**
```bash
# Automated validation
./scripts/validate.sh

# Manual validation steps
terraform plan -detailed-exitcode
ibmcloud schematics workspace get --id $(terraform output -raw schematics_workspace_id)
```

#### **Test Workspace Functionality**
```bash
# Test workspace execution
ibmcloud schematics plan --id $(terraform output -raw schematics_workspace_id)

# Monitor execution
ibmcloud schematics logs --id $(terraform output -raw schematics_workspace_id) --follow
```

---

## 🧹 **Cleanup**

### **Automated Cleanup**

```bash
# Run cleanup script
./scripts/cleanup.sh
```

### **Manual Cleanup Steps**

If automated cleanup fails:

```bash
# Destroy Terraform resources
terraform destroy

# Remove local files
rm -rf .terraform/
rm terraform.tfstate*

# Manual IBM Cloud cleanup
ibmcloud schematics workspace delete --id workspace-id
ibmcloud iam access-group-delete access-group-name
```

---

## 📚 **Additional Resources**

### **Documentation**
- [IBM Cloud Schematics Documentation](https://cloud.ibm.com/docs/schematics)
- [Terraform Cloud Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
- [IBM Cloud Terraform Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)

### **Best Practices**
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [IBM Cloud Security Best Practices](https://cloud.ibm.com/docs/security)
- [Cost Optimization Strategies](https://cloud.ibm.com/docs/billing-usage)

### **Support and Community**
- [IBM Cloud Support](https://cloud.ibm.com/unifiedsupport/supportcenter)
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core)
- [IBM Cloud Slack Community](https://ibm.biz/BdqgNz)

---

## 🎓 **Learning Path**

### **Beginner Level**
1. Complete basic Terraform tutorials
2. Familiarize yourself with IBM Cloud console
3. Practice with simple Schematics workspaces

### **Intermediate Level**
1. Deploy this lab environment
2. Experiment with workspace dependencies
3. Configure team collaboration features

### **Advanced Level**
1. Implement custom governance policies
2. Integrate with CI/CD pipelines
3. Develop custom Terraform modules

---

## 📝 **Lab Exercises**

### **Exercise 1: Basic Deployment**
- Deploy the lab environment with default settings
- Explore the created resources in IBM Cloud console
- Review Terraform outputs and understand resource relationships

### **Exercise 2: Team Collaboration**
- Add team members to the access group
- Test different access levels (viewer, operator, manager)
- Practice workspace sharing and collaboration workflows

### **Exercise 3: Cost Optimization**
- Configure budget alerts and thresholds
- Implement automated cleanup schedules
- Monitor cost trends and optimization opportunities

### **Exercise 4: Advanced Integration**
- Set up Terraform Cloud workspace integration
- Configure cross-platform workflows
- Implement policy as code governance

---

## 🔒 **Security Considerations**

### **Credential Management**
- Never commit API keys or tokens to version control
- Use environment variables for sensitive values
- Implement proper secret rotation policies

### **Access Control**
- Follow principle of least privilege
- Regularly review and audit access permissions
- Implement multi-factor authentication where possible

### **Compliance**
- Enable comprehensive audit logging
- Implement policy as code governance
- Regular compliance validation and reporting

---

*This lab environment provides a comprehensive foundation for learning IBM Cloud Schematics and Terraform Cloud integration. For additional support or questions, refer to the documentation links above or contact your training instructor.*
