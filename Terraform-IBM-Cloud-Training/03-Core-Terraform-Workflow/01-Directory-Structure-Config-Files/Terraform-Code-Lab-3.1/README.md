# Terraform Code Lab 3.1: Directory Structure and Configuration Files

## 📋 **Lab Overview**

This Terraform configuration demonstrates enterprise-grade project organization and file structure best practices for IBM Cloud infrastructure. It creates a complete VPC environment with subnets, security groups, and optional public gateways while showcasing proper separation of concerns across configuration files.

## 🏗️ **Architecture**

This lab creates the following IBM Cloud resources:

- **VPC**: Isolated network environment with configurable CIDR block
- **Subnets**: Multiple subnets distributed across availability zones
- **Public Gateways**: Optional internet access for private subnets
- **Security Group**: Network access control with configurable rules
- **Documentation**: Automated deployment summary generation

## 📁 **File Structure and Organization**

```
Terraform-Code-Lab-3.1/
├── providers.tf              # Provider and Terraform configuration
├── variables.tf              # Input variable definitions (20+ variables)
├── main.tf                   # Resource definitions and logic
├── outputs.tf                # Output value definitions (15+ outputs)
├── terraform.tfvars.example  # Example variable values with documentation
├── README.md                 # This comprehensive documentation
└── deployment-summary.json   # Generated deployment summary (created after apply)
```

### **File Responsibilities**

#### **providers.tf**
- Terraform version constraints (>= 1.5.0)
- Provider version specifications (IBM Cloud, Random, Time, Local)
- Provider configuration and authentication setup
- Multi-provider coordination

#### **variables.tf**
- 20+ comprehensive input variables with validation
- IBM Cloud authentication and configuration
- Project and environment settings
- Network and security configuration
- Advanced options and feature flags

#### **main.tf**
- Data sources for existing resources
- Local value computations and naming conventions
- Resource definitions with proper dependencies
- Security group rules and network configuration
- Documentation generation

#### **outputs.tf**
- 15+ detailed output values for integration
- Networking information (VPC, subnets, gateways)
- Security configuration details
- Project metadata and deployment tracking
- Cost estimation and next steps guidance

## 🚀 **Prerequisites**

### **Required Software**
- Terraform >= 1.5.0
- IBM Cloud CLI (optional but recommended)
- Git (for version control)

### **IBM Cloud Requirements**
- Active IBM Cloud account
- Valid API key with VPC permissions
- Resource group (default or custom)
- Appropriate IAM permissions for VPC resources

### **Permissions Required**
- VPC Infrastructure Services: Editor or Administrator
- Resource Group: Viewer (minimum)
- IAM Identity Services: Viewer (for service IDs)

## ⚙️ **Configuration**

### **Step 1: Clone and Setup**

```bash
# Navigate to the lab directory
cd Terraform-Code-Lab-3.1

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your specific values
nano terraform.tfvars  # or use your preferred editor
```

### **Step 2: Configure Variables**

Edit `terraform.tfvars` with your specific values:

```hcl
# Required variables
ibmcloud_api_key = "your-api-key-here"  # Or set IC_API_KEY environment variable
project_name     = "your-project-name"
owner           = "your-email@company.com"

# Optional customizations
ibm_region      = "us-south"
environment     = "dev"
vpc_cidr_block  = "10.240.0.0/16"
```

### **Step 3: Environment Variables (Alternative)**

Instead of setting `ibmcloud_api_key` in terraform.tfvars, you can use environment variables:

```bash
export IC_API_KEY="your-ibm-cloud-api-key"
export TF_VAR_project_name="your-project-name"
export TF_VAR_owner="your-email@company.com"
```

## 🔧 **Deployment**

### **Step 1: Initialize Terraform**

```bash
# Download providers and initialize backend
terraform init

# Expected output: Successful provider downloads
```

### **Step 2: Validate Configuration**

```bash
# Check configuration syntax and logic
terraform validate

# Format code for consistency
terraform fmt

# Expected output: "Success! The configuration is valid."
```

### **Step 3: Plan Deployment**

```bash
# Generate and review execution plan
terraform plan

# Save plan for consistent apply
terraform plan -out=deployment.tfplan
```

**Expected Plan Output:**
- 1 VPC
- 3 Subnets (default configuration)
- 3 Public Gateways (if enabled)
- 1 Security Group
- Multiple Security Group Rules
- 1 Local File (deployment summary)

### **Step 4: Apply Configuration**

```bash
# Apply the saved plan
terraform apply deployment.tfplan

# Or apply with auto-approval (use with caution)
terraform apply -auto-approve
```

### **Step 5: Verify Deployment**

```bash
# View all outputs
terraform output

# View specific output
terraform output project_info

# Check generated documentation
cat deployment-summary.json
```

## 📊 **Outputs and Information**

### **Key Outputs**

#### **Networking Information**
- `vpc_id`: VPC identifier for resource references
- `subnet_ids`: List of subnet IDs for compute deployment
- `public_gateway_ids`: Gateway IDs for internet access configuration
- `security_group_id`: Security group for instance assignment

#### **Project Information**
- `project_info`: Comprehensive deployment metadata
- `resource_summary`: Resource count and cost estimation
- `network_configuration`: Complete network setup details
- `connection_info`: Information for infrastructure usage

#### **Validation and Tracking**
- `deployment_metadata`: Deployment tracking and auditing
- `validation_results`: Configuration verification results
- `cost_estimation`: Detailed cost breakdown and optimization tips
- `next_steps`: Recommended actions and learning progression

### **Generated Documentation**

The configuration automatically generates `deployment-summary.json` with:
- Deployment information and timestamps
- Resource counts and configurations
- Network setup details
- Cost estimation and factors

## 💰 **Cost Estimation**

### **Resource Costs (Monthly)**

| Resource | Quantity | Cost per Unit | Total Cost |
|----------|----------|---------------|------------|
| VPC | 1 | Free | $0 |
| Subnets | 3 | Free | $0 |
| Security Groups | 1 | Free | $0 |
| Public Gateways | 0-3 | $45/month | $0-135 |

**Total Estimated Cost**: $0-135 USD/month (depending on public gateway configuration)

### **Cost Optimization**

- **Disable public gateways** if internet access is not required
- **Use private endpoints** for IBM Cloud services
- **Monitor usage** with IBM Cloud Cost and Resource Tracking
- **Consider reserved capacity** for predictable workloads

## 🔒 **Security Considerations**

### **Default Security Configuration**

- **Outbound**: All traffic allowed (standard practice)
- **Inbound SSH**: Configurable CIDR blocks (default: 0.0.0.0/0)
- **Inbound HTTP/HTTPS**: Configurable CIDR blocks (default: 0.0.0.0/0)

### **Production Security Recommendations**

1. **Restrict SSH access** to specific IP ranges
2. **Use bastion hosts** for secure access
3. **Enable flow logs** for network monitoring
4. **Implement security group logging** for compliance
5. **Regular security reviews** and updates

### **Security Best Practices**

```hcl
# Example production security configuration
allowed_ssh_cidr_blocks = ["203.0.113.0/24"]  # Your office network
allowed_http_cidr_blocks = ["0.0.0.0/0"]      # Public web access
enable_flow_logs = true
enable_security_group_logging = true
```

## 🧪 **Testing and Validation**

### **Automated Validation**

The configuration includes built-in validation:

```bash
# Check validation results
terraform output validation_results
```

### **Manual Testing**

1. **VPC Creation**: Verify VPC exists in IBM Cloud console
2. **Subnet Distribution**: Confirm subnets span multiple zones
3. **Security Groups**: Review rules in IBM Cloud console
4. **Connectivity**: Test network connectivity (if instances deployed)

### **Troubleshooting**

#### **Common Issues**

**Issue**: `terraform init` fails
- **Solution**: Check internet connectivity and provider URLs
- **Command**: `terraform init -upgrade`

**Issue**: Authentication errors
- **Solution**: Verify API key and permissions
- **Check**: `ibmcloud iam api-keys` and `ibmcloud target`

**Issue**: Resource quota exceeded
- **Solution**: Check IBM Cloud quotas and limits
- **Command**: `ibmcloud is quotas`

**Issue**: CIDR conflicts
- **Solution**: Adjust VPC and subnet CIDR blocks
- **Tool**: Use IBM Cloud VPC planning tools

## 🧹 **Cleanup**

### **Destroy Resources**

```bash
# Destroy all created resources
terraform destroy

# Confirm destruction when prompted
# Type: yes
```

### **Verify Cleanup**

```bash
# Check for remaining resources
ibmcloud is vpcs
ibmcloud is subnets
ibmcloud is public-gateways
```

### **Clean Local Files**

```bash
# Remove generated files
rm -f deployment-summary.json
rm -f terraform.tfstate*
rm -f deployment.tfplan
rm -rf .terraform/
```

## 📚 **Learning Objectives Achieved**

After completing this lab, you have:

✅ **Created enterprise-grade Terraform project structure**  
✅ **Implemented proper file separation and organization**  
✅ **Configured IBM Cloud provider with best practices**  
✅ **Applied consistent naming conventions and documentation**  
✅ **Validated implementation against quality criteria**  
✅ **Demonstrated real-world infrastructure deployment**  

## 🎯 **Next Steps**

### **Immediate Actions**
1. **Review deployment summary** in generated JSON file
2. **Explore IBM Cloud console** to see created resources
3. **Experiment with variable modifications** and redeployment
4. **Practice cleanup and redeployment** procedures

### **Learning Progression**
1. **Topic 3.2**: Core Commands (init, validate, plan, apply, destroy)
2. **Topic 3.3**: Provider Configuration and Authentication
3. **Topic 4**: Resource Provisioning & Management
4. **Topic 5**: Modularization & Best Practices

### **Advanced Exercises**
1. **Multi-environment setup** (dev, staging, production)
2. **Module creation** for reusable components
3. **CI/CD integration** with automated deployment
4. **Monitoring and alerting** implementation

## 🤝 **Support and Resources**

### **Documentation**
- [IBM Cloud Terraform Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [Terraform Configuration Language](https://www.terraform.io/language)
- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)

### **Community**
- [IBM Cloud Community](https://community.ibm.com/community/user/cloud)
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core)
- [IBM Cloud Slack](https://ibm-cloud-tech.slack.com)

### **Training Resources**
- IBM Cloud Terraform Training Program
- HashiCorp Terraform Certification
- IBM Cloud Architecture Center

---

**🎉 Congratulations!** You have successfully completed Terraform Code Lab 3.1 and demonstrated mastery of directory structure and configuration file organization for enterprise-grade IBM Cloud infrastructure automation.
