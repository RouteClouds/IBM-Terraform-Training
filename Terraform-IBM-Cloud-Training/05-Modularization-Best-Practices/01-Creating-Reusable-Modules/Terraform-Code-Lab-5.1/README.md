# Terraform Code Lab 5.1: Creating Reusable Modules

## 🎯 **Overview**

This comprehensive Terraform configuration demonstrates enterprise-grade module creation patterns for IBM Cloud infrastructure. The lab provides hands-on experience with module design, testing, validation, and deployment using real IBM Cloud services.

### **Learning Objectives**
- Create reusable VPC and compute modules with enterprise-grade interfaces
- Implement comprehensive variable validation and output design
- Apply testing and validation strategies for module quality assurance
- Integrate with IBM Cloud services using best practices
- Establish governance and distribution workflows

### **Lab Duration**: 90-120 minutes
### **Difficulty Level**: Intermediate to Advanced

---

## 📋 **Prerequisites**

### **Required Tools**
- Terraform CLI (v1.5.0 or later)
- IBM Cloud CLI with VPC plugin
- Git for version control
- jq for JSON processing
- curl and wget for downloads

### **Required Access**
- IBM Cloud account with VPC Infrastructure Services access
- Resource group with appropriate permissions
- IBM Cloud API key with sufficient privileges

### **Optional Tools** (for enhanced experience)
- TFLint for configuration linting
- TFSec for security scanning
- Infracost for cost estimation
- Go (v1.19+) for testing framework

---

## 🚀 **Quick Start**

### **1. Environment Setup**
```bash
# Clone or navigate to the lab directory
cd Terraform-Code-Lab-5.1

# Set up environment variables
export IBMCLOUD_API_KEY="your-api-key-here"
export TF_VAR_ibmcloud_api_key="your-api-key-here"

# Copy and customize configuration
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
```

### **2. Validation and Planning**
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run comprehensive validation
./scripts/validate.sh

# Plan deployment (dry run)
./scripts/deploy.sh --dry-run
```

### **3. Deployment**
```bash
# Deploy infrastructure
./scripts/deploy.sh

# Or deploy with auto-approval
./scripts/deploy.sh --auto-approve
```

### **4. Cleanup**
```bash
# Destroy infrastructure when done
./scripts/deploy.sh --destroy
```

---

## 📁 **Project Structure**

```
Terraform-Code-Lab-5.1/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions with validation
├── outputs.tf                 # Comprehensive output definitions
├── providers.tf               # Provider configuration and validation
├── terraform.tfvars.example   # Example variable values
├── README.md                  # This documentation
├── scripts/
│   ├── validate.sh           # Validation and linting script
│   └── deploy.sh             # Deployment automation script
├── templates/
│   └── user-data.sh          # Instance initialization script
└── generated/                # Auto-generated files (gitignored)
    ├── ssh-private-key.pem   # Generated SSH key (debug mode)
    └── module-config.json    # Module configuration export
```

---

## 🔧 **Configuration Guide**

### **Core Variables**

#### **Authentication**
```hcl
# Set via environment variable (recommended)
export IBMCLOUD_API_KEY="your-api-key"

# Or in terraform.tfvars
ibmcloud_api_key = "your-api-key"
```

#### **Regional Configuration**
```hcl
primary_region = "us-south"
secondary_region = "us-east"
enable_multi_region = false
```

#### **Organization Settings**
```hcl
organization_config = {
  name        = "IBM Cloud Training"
  division    = "Education"
  cost_center = "CC-EDU-001"
  environment = "development"
  project     = "terraform-training"
  owner       = "platform-team"
  contact     = "platform-team@company.com"
}
```

#### **VPC Configuration**
```hcl
vpc_configuration = {
  name                  = "lab-vpc"
  enable_public_gateway = true
  
  subnets = [
    {
      name       = "subnet-1"
      zone       = "us-south-1"
      cidr_block = "10.240.0.0/24"
    },
    {
      name       = "subnet-2"
      zone       = "us-south-2"
      cidr_block = "10.240.1.0/24"
    }
  ]
}
```

#### **Compute Configuration**
```hcl
compute_configuration = {
  instance_count   = 2
  instance_profile = "cx2-2x4"
  base_image_name  = "ibm-ubuntu-22-04-1-minimal-amd64-1"
}
```

### **Feature Flags**
```hcl
enable_enterprise_features = true
enable_monitoring_services = true
enable_security_services   = true
enable_audit_logging       = true
```

---

## 🧪 **Testing and Validation**

### **Automated Validation**
The `validate.sh` script performs comprehensive checks:

```bash
./scripts/validate.sh
```

**Validation Checks:**
- ✅ Terraform syntax and formatting
- ✅ TFLint analysis for best practices
- ✅ TFSec security scanning
- ✅ Variable and output validation
- ✅ Provider configuration checks
- ✅ File structure validation
- ✅ Example file completeness

### **Manual Testing**
```bash
# Initialize and validate
terraform init
terraform validate
terraform fmt -check

# Plan with different configurations
terraform plan -var="compute_configuration.instance_count=1"
terraform plan -var="enable_multi_region=true"

# Security scan
tfsec .

# Linting
tflint
```

---

## 💰 **Cost Estimation**

### **Estimated Monthly Costs (USD)**

| Resource Type | Quantity | Unit Cost | Total |
|---------------|----------|-----------|-------|
| VPC | 1 | $0.00 | $0.00 |
| Subnets | 3 | $0.00 | $0.00 |
| Public Gateway | 1 | $45.00 | $45.00 |
| Virtual Servers (cx2-2x4) | 2 | $24.00 | $48.00 |
| Boot Volumes (100GB) | 2 | $10.00 | $20.00 |
| **Total Estimated** | | | **$113.00** |

### **Cost Optimization Tips**
- Use smaller instance profiles for development
- Disable public gateways if not needed
- Reduce boot volume sizes
- Use spot instances for non-critical workloads

---

## 🔒 **Security Features**

### **Built-in Security**
- ✅ Variable validation for input sanitization
- ✅ Sensitive data protection with `sensitive = true`
- ✅ Security group rules with least privilege
- ✅ Encrypted storage by default
- ✅ SSH key management with proper permissions
- ✅ Network ACLs for additional security

### **Security Best Practices**
- API keys stored as environment variables
- No hardcoded credentials in configuration
- Proper resource tagging for governance
- Audit logging enabled for compliance
- Regular security scanning with TFSec

---

## 📊 **Monitoring and Observability**

### **Built-in Monitoring**
- Activity Tracker integration (production environments)
- VPC Flow Logs for network monitoring
- Comprehensive resource tagging
- Cost tracking and allocation
- Performance metrics collection

### **Monitoring Outputs**
```bash
# View monitoring configuration
terraform output monitoring_observability

# Check cost tracking
terraform output cost_tracking

# Review security compliance
terraform output security_compliance
```

---

## 🔧 **Troubleshooting**

### **Common Issues**

#### **Authentication Errors**
```bash
# Verify API key
ibmcloud login --apikey $IBMCLOUD_API_KEY

# Check permissions
ibmcloud iam user-policies $USER_EMAIL
```

#### **Resource Conflicts**
```bash
# Check existing resources
ibmcloud is vpcs
ibmcloud is subnets

# Import existing resources if needed
terraform import ibm_is_vpc.main <vpc-id>
```

#### **Validation Failures**
```bash
# Run detailed validation
./scripts/validate.sh

# Check specific issues
terraform validate
tflint
tfsec .
```

#### **Deployment Failures**
```bash
# Enable debug logging
export TF_LOG=DEBUG

# Check deployment logs
tail -f deployment.log

# Retry with verbose output
./scripts/deploy.sh --dry-run
```

### **Debug Mode**
Enable debug mode for additional troubleshooting information:

```hcl
module_config = {
  development = {
    enable_debug_mode = true
    enable_verbose_logs = true
  }
}
```

---

## 📚 **Advanced Usage**

### **Multi-Region Deployment**
```hcl
enable_multi_region = true
enable_cross_region_networking = true
secondary_region = "eu-gb"
```

### **Enterprise Features**
```hcl
security_configuration = {
  compliance = {
    frameworks = ["SOC2", "ISO27001", "GDPR"]
    data_classification = "confidential"
    audit_required = true
  }
}
```

### **Custom Module Development**
Use this lab as a template for creating your own modules:

1. Copy the structure to a new directory
2. Modify variables and resources for your use case
3. Update validation rules and outputs
4. Test thoroughly with the validation script
5. Document and publish to your module registry

---

## 🔗 **Integration Examples**

### **With IBM Cloud Schematics**
```bash
# Create Schematics workspace
ibmcloud schematics workspace new --file workspace-config.json

# Apply via Schematics
ibmcloud schematics apply --id <workspace-id>
```

### **With CI/CD Pipelines**
```yaml
# GitHub Actions example
- name: Terraform Validate
  run: ./scripts/validate.sh

- name: Terraform Plan
  run: ./scripts/deploy.sh --dry-run

- name: Terraform Apply
  run: ./scripts/deploy.sh --auto-approve
  if: github.ref == 'refs/heads/main'
```

---

## 📖 **Additional Resources**

### **Documentation**
- [IBM Cloud Terraform Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm)
- [Terraform Module Development](https://www.terraform.io/docs/modules/)
- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)

### **Tools and Utilities**
- [TFLint](https://github.com/terraform-linters/tflint) - Terraform linter
- [TFSec](https://github.com/aquasecurity/tfsec) - Security scanner
- [Infracost](https://www.infracost.io/) - Cost estimation
- [Terratest](https://terratest.gruntwork.io/) - Testing framework

### **IBM Cloud Resources**
- [IBM Cloud Architecture Center](https://www.ibm.com/cloud/architecture)
- [IBM Cloud Schematics](https://cloud.ibm.com/docs/schematics)
- [IBM Cloud Cost Estimator](https://cloud.ibm.com/estimator)

---

## 🎯 **Success Criteria**

### **Completion Checklist**
- [ ] All validation checks pass
- [ ] Infrastructure deploys successfully
- [ ] Outputs provide comprehensive information
- [ ] Cost estimates are within acceptable limits
- [ ] Security scans show no critical issues
- [ ] Documentation is complete and accurate

### **Learning Outcomes Achieved**
- [ ] Created reusable module with proper interface design
- [ ] Implemented comprehensive validation and testing
- [ ] Applied enterprise governance and security practices
- [ ] Integrated with IBM Cloud services effectively
- [ ] Established deployment and maintenance workflows

**Next Steps**: Apply these module creation principles to build your organization's module library and establish enterprise governance frameworks for infrastructure as code.

---

## 📞 **Support**

For questions or issues with this lab:
1. Review the troubleshooting section above
2. Check the validation and deployment logs
3. Consult the IBM Cloud documentation
4. Contact the training team for assistance

**Happy Module Building! 🚀**
