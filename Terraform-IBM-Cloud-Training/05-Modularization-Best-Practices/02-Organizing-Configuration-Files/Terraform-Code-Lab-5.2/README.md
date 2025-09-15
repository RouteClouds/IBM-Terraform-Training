# Configuration Organization Lab - Terraform Code Lab 5.2

## 📋 **Overview**

This comprehensive Terraform configuration demonstrates enterprise-grade organization patterns for scalable infrastructure management. The lab showcases best practices for structuring large Terraform projects with 50+ files, implementing consistent naming conventions, and establishing governance frameworks.

### **Learning Objectives**
- Implement enterprise directory structures and naming conventions
- Apply environment-specific configuration management patterns
- Establish validation and governance workflows
- Create maintainable and scalable Terraform configurations
- Integrate cost management and security compliance

### **Lab Components**
- **Foundation Infrastructure**: VPC, subnets, security groups, public gateways
- **Configuration Organization**: Hierarchical variable management and validation
- **Enterprise Patterns**: Naming conventions, tagging strategies, cost tracking
- **Automation Scripts**: Validation, deployment, and management utilities

---

## 🏗️ **Architecture Overview**

### **Infrastructure Components**
```
IBM Cloud VPC Infrastructure
├── VPC (Virtual Private Cloud)
├── Subnets (Multi-zone deployment)
├── Public Gateways (Internet connectivity)
├── Security Groups (Network security)
├── SSH Key Management (Secure access)
└── Activity Tracking (Audit and compliance)
```

### **Configuration Structure**
```
Terraform-Code-Lab-5.2/
├── providers.tf              # Provider configuration with multi-region support
├── variables.tf               # Comprehensive variable definitions (15+ variables)
├── main.tf                   # Main infrastructure configuration
├── outputs.tf                # Structured outputs (10+ outputs)
├── terraform.tfvars.example  # Example configuration with multiple environments
├── scripts/                  # Automation and utility scripts
│   ├── validate.sh          # Comprehensive validation script
│   └── deploy.sh            # Enterprise deployment automation
├── templates/               # Configuration templates
├── modules/                 # Local module development
└── generated/              # Generated files (SSH keys, reports)
```

---

## 🚀 **Quick Start**

### **Prerequisites**
- IBM Cloud account with VPC access
- Terraform CLI (v1.5.0 or later)
- IBM Cloud CLI (optional, for verification)
- Git (for version control)

### **Environment Setup**
```bash
# Set IBM Cloud API key
export TF_VAR_ibmcloud_api_key="your-ibm-cloud-api-key"

# Optional: Enable Terraform debugging
export TF_LOG=INFO
export TF_LOG_PATH="terraform.log"

# Clone or navigate to the lab directory
cd Terraform-Code-Lab-5.2
```

### **Configuration Setup**
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Customize configuration for your environment
# Edit terraform.tfvars with your specific settings:
# - Organization information
# - Regional preferences
# - Network configuration
# - Security settings
# - Cost management parameters
```

### **Validation and Deployment**
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run comprehensive validation
./scripts/validate.sh

# Deploy infrastructure (dry run first)
./scripts/deploy.sh --dry-run

# Deploy infrastructure
./scripts/deploy.sh

# Or deploy with auto-approval
./scripts/deploy.sh --auto-approve
```

---

## ⚙️ **Configuration Details**

### **Variable Organization**

#### **Organizational Configuration**
```hcl
organization_config = {
  name         = "ACME Corporation"
  division     = "Engineering"
  cost_center  = "CC-ENG-001"
  environment  = "development"
  project_name = "config-organization-lab"
  owner        = "platform-team"
  contact      = "platform-team@acme.com"
}
```

#### **Network Configuration**
```hcl
network_configuration = {
  vpc_name                   = "main-vpc"
  address_prefix_management = "auto"
  enable_public_gateway     = true
  
  subnets = [
    {
      name                    = "subnet-1"
      zone                    = "us-south-1"
      cidr_block             = "10.240.0.0/24"
      public_gateway_enabled = true
    }
  ]
  
  security_groups = [
    {
      name        = "web-sg"
      description = "Security group for web servers"
      rules = [
        {
          direction   = "inbound"
          protocol    = "tcp"
          port_min    = 80
          port_max    = 80
          source_type = "cidr_block"
          source      = "0.0.0.0/0"
        }
      ]
    }
  ]
}
```

#### **Environment-Specific Configuration**
```hcl
environment_specific_config = {
  development = {
    instance_count        = 1
    enable_monitoring     = false
    backup_retention_days = 7
  }
  
  production = {
    instance_count           = 3
    enable_monitoring        = true
    backup_retention_days    = 30
    enable_high_availability = true
    enable_disaster_recovery = true
  }
}
```

### **Naming Convention Implementation**

The configuration implements enterprise naming conventions:

**Pattern**: `{organization}-{environment}-{service}-{purpose}-{instance}`

**Example**: `acme-prod-vpc-main-001`

**Validation Rules**:
- Lowercase only
- Start with letter
- Alphanumeric + hyphens
- Maximum 63 characters
- No consecutive hyphens

### **Cost Management Integration**

```hcl
cost_configuration = {
  monthly_budget_limit = 500.00
  cost_center         = "CC-ENG-001"
  
  cost_allocation_tags = {
    "Department"   = "Engineering"
    "Team"        = "Platform"
    "Environment" = "Development"
  }
  
  enable_cost_alerts    = true
  cost_alert_thresholds = [50.0, 75.0, 90.0]
}
```

---

## 🔧 **Advanced Usage**

### **Multi-Environment Deployment**

#### **Development Environment**
```bash
# Use development configuration
cp terraform.tfvars.example terraform.tfvars
# Edit: set environment = "development"

./scripts/deploy.sh
```

#### **Production Environment**
```bash
# Use production configuration
# Edit terraform.tfvars:
# - Set environment = "production"
# - Enable security features
# - Configure high availability
# - Set appropriate instance counts

./scripts/deploy.sh --auto-approve
```

### **Custom Validation Rules**

Add custom validation to `variables.tf`:

```hcl
variable "custom_validation_example" {
  description = "Example of custom validation"
  type        = string
  
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.custom_validation_example))
    error_message = "Must follow naming convention pattern."
  }
}
```

### **Security Configuration**

Enable comprehensive security features:

```hcl
security_configuration = {
  enable_flow_logs         = true
  enable_activity_tracker = true
  enable_key_management   = true
  encryption_at_rest      = true
  encryption_in_transit   = true
  compliance_framework    = "SOC2"
  data_classification     = "confidential"
}
```

### **Cost Optimization**

Implement cost optimization strategies:

```hcl
cost_configuration = {
  enable_auto_scaling       = true
  enable_scheduled_shutdown = true
  
  shutdown_schedule = {
    weekdays = {
      start_time = "18:00"
      end_time   = "08:00"
    }
    weekends = {
      enabled = true
    }
  }
}
```

---

## 📊 **Outputs and Integration**

### **Key Outputs**

#### **Infrastructure Summary**
- Complete VPC and networking information
- Resource inventory and status
- Configuration metadata

#### **Integration Endpoints**
- VPC ID and CRN for module integration
- Subnet IDs mapped by availability zone
- Security group IDs for application deployment

#### **Cost Analysis**
- Estimated monthly costs by component
- Budget utilization and recommendations
- Cost allocation and tracking information

#### **Security Compliance**
- Security configuration status
- Compliance framework validation
- Security recommendations

### **Output Usage Examples**

```bash
# Get VPC ID for other modules
terraform output -raw integration_endpoints | jq -r '.vpc_id'

# Get cost analysis
terraform output cost_analysis

# Get security compliance status
terraform output security_compliance

# Get all outputs in JSON format
terraform output -json > infrastructure-outputs.json
```

---

## 🔍 **Validation and Testing**

### **Automated Validation**

The `validate.sh` script performs comprehensive checks:

- **Terraform Syntax**: `terraform validate`
- **Configuration Structure**: Required files and directories
- **Naming Conventions**: File and resource naming patterns
- **Variable Definitions**: Descriptions and validation rules
- **Output Definitions**: Comprehensive output coverage
- **Security Scanning**: TFSec security analysis (if available)
- **Linting**: TFLint code quality checks (if available)

### **Manual Testing**

```bash
# Test configuration without deployment
terraform plan -var-file=terraform.tfvars

# Validate specific components
terraform plan -target=ibm_is_vpc.main

# Check formatting
terraform fmt -check -recursive

# Validate with different variable files
terraform plan -var-file=environments/production.tfvars
```

### **Integration Testing**

```bash
# Test with different environments
for env in development staging production; do
    echo "Testing $env environment..."
    terraform plan -var="organization_config.environment=$env"
done
```

---

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **Authentication Errors**
```bash
# Verify IBM Cloud API key
export TF_VAR_ibmcloud_api_key="your-api-key"

# Test IBM Cloud CLI authentication
ibmcloud login --apikey $TF_VAR_ibmcloud_api_key
```

#### **Resource Limits**
```bash
# Check VPC quotas
ibmcloud is vpcs

# Check subnet limits (max 15 per VPC)
ibmcloud is subnets
```

#### **Naming Convention Violations**
```bash
# Check for naming issues
./scripts/validate.sh

# Fix formatting issues
terraform fmt -recursive
```

#### **Cost Budget Exceeded**
```bash
# Review cost configuration
terraform plan | grep "estimated_monthly_cost"

# Adjust instance counts or profiles
# Edit terraform.tfvars and reduce:
# - compute_configuration.instance_count
# - compute_configuration.instance_profile
```

### **Debug Mode**

```bash
# Enable detailed logging
export TF_LOG=DEBUG
export TF_LOG_PATH="debug.log"

# Run with debug output
./scripts/deploy.sh --dry-run

# Review debug log
tail -f debug.log
```

### **State Management Issues**

```bash
# Check state file
terraform show

# Refresh state
terraform refresh

# Import existing resources (if needed)
terraform import ibm_is_vpc.main <vpc-id>
```

---

## 🧹 **Cleanup**

### **Destroy Infrastructure**
```bash
# Destroy all resources
./scripts/deploy.sh --destroy

# Or destroy specific resources
terraform destroy -target=ibm_is_vpc.main

# Force destroy (use with caution)
terraform destroy -auto-approve
```

### **Clean Generated Files**
```bash
# Remove generated files
rm -rf generated/
rm -f *.log *.json terraform.plan

# Reset to clean state
git clean -fd
```

---

## 📚 **Additional Resources**

### **Documentation**
- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)
- [Terraform IBM Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [IBM Cloud Terraform Examples](https://github.com/IBM-Cloud/terraform-provider-ibm/tree/master/examples)

### **Best Practices**
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [IBM Cloud Architecture Center](https://www.ibm.com/cloud/architecture)
- [Infrastructure as Code Patterns](https://docs.aws.amazon.com/whitepapers/latest/introduction-devops-aws/infrastructure-as-code.html)

### **Training Resources**
- [IBM Cloud Terraform Training](https://cloud.ibm.com/docs/terraform)
- [HashiCorp Learn Terraform](https://learn.hashicorp.com/terraform)
- [IBM Cloud Architecture Patterns](https://www.ibm.com/cloud/architecture/architectures)

---

## 🎯 **Next Steps**

1. **Deploy Compute Resources**: Use the VPC infrastructure to deploy virtual server instances
2. **Implement Load Balancing**: Add load balancers for high availability
3. **Set Up Monitoring**: Configure IBM Cloud Monitoring and logging
4. **Establish CI/CD**: Integrate with GitLab CI or GitHub Actions
5. **Implement Backup**: Set up automated backup and disaster recovery
6. **Security Hardening**: Implement additional security controls and compliance measures

**Continue to Topic 5.3**: Version control and collaboration with Git to learn advanced Git workflows for Terraform projects.
