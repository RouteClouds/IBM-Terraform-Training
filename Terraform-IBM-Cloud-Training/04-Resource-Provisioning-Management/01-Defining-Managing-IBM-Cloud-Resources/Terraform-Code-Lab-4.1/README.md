# Terraform Code Lab 4.1: Defining and Managing IBM Cloud Resources

## 🎯 **Lab Overview**

This comprehensive Terraform configuration demonstrates enterprise-grade resource provisioning and management on IBM Cloud. The lab implements a complete 3-tier web application infrastructure with advanced security, monitoring, and cost optimization features.

### **Learning Objectives**
- Master IBM Cloud resource provisioning with Terraform
- Implement multi-tier architecture with proper security isolation
- Configure load balancing and high availability patterns
- Apply enterprise security and compliance frameworks
- Optimize costs and implement monitoring strategies

### **Architecture Overview**
```
┌─────────────────────────────────────────────────────────────┐
│                    IBM Cloud VPC                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Web Tier      │  │  Application    │  │   Database      │ │
│  │   (Public)      │  │     Tier        │  │     Tier        │ │
│  │                 │  │   (Private)     │  │   (Private)     │ │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ ┌─────────────┐ │ │
│  │ │ Web Server  │ │  │ │ App Server  │ │  │ │ DB Server   │ │ │
│  │ │   (nginx)   │ │  │ │  (Node.js)  │ │  │ │(PostgreSQL) │ │ │
│  │ └─────────────┘ │  │ └─────────────┘ │  │ └─────────────┘ │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│           │                     │                     │        │
│  ┌─────────────────┐            │                     │        │
│  │ Load Balancer   │            │                     │        │
│  │   (Public)      │            │                     │        │
│  └─────────────────┘            │                     │        │
└─────────────────────────────────────────────────────────────┘
```

## 📋 **Prerequisites**

### **Required Tools**
- **Terraform** >= 1.0.0
- **IBM Cloud CLI** >= 2.0.0
- **jq** (for JSON processing)
- **curl** (for testing)

### **IBM Cloud Requirements**
- Active IBM Cloud account
- IBM Cloud API key with appropriate permissions
- Resource group access
- VPC Infrastructure Services enabled

### **Permissions Required**
- VPC Infrastructure Services: Editor
- Resource Group: Viewer
- IAM Identity Services: Operator

## 🚀 **Quick Start**

### **1. Clone and Setup**
```bash
# Navigate to the lab directory
cd Terraform-Code-Lab-4.1

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your configuration
nano terraform.tfvars
```

### **2. Configure Authentication**
```bash
# Option 1: Environment variable (recommended)
export IBMCLOUD_API_KEY="your-api-key-here"

# Option 2: Update terraform.tfvars
# ibmcloud_api_key = "your-api-key-here"
```

### **3. Initialize and Deploy**
```bash
# Initialize Terraform
terraform init

# Validate configuration
./scripts/validate.sh

# Deploy infrastructure
terraform apply

# Test deployment
./scripts/test-deployment.sh
```

### **4. Access Your Application**
```bash
# Get access URL
terraform output access_information

# Open in browser
curl $(terraform output -raw access_information | jq -r '.web_application.url')
```

## 📁 **Project Structure**

```
Terraform-Code-Lab-4.1/
├── README.md                    # This comprehensive guide
├── providers.tf                 # Provider configurations
├── variables.tf                 # Variable definitions
├── main.tf                      # Main infrastructure resources
├── outputs.tf                   # Output definitions
├── terraform.tfvars.example     # Example variable values
├── .gitignore                   # Git ignore patterns
└── scripts/                     # Utility scripts
    ├── validate.sh              # Configuration validation
    ├── test-deployment.sh       # Deployment testing
    ├── cleanup.sh               # Resource cleanup
    ├── web-server-init.sh       # Web server initialization
    ├── app-server-init.sh       # App server initialization
    └── db-server-init.sh        # Database server initialization
```

## ⚙️ **Configuration Guide**

### **Essential Variables**
```hcl
# Authentication
ibmcloud_api_key = "your-api-key"
ibm_region = "us-south"
resource_group_name = "default"

# Project Configuration
project_name = "terraform-lab-41"
environment = "development"
owner = "your-name"

# Network Configuration
vpc_address_prefix = "10.240.0.0/16"

# Instance Configuration
instance_configurations = {
  "web-servers" = {
    count = 2
    profile = "bx2-2x8"
  }
  "app-servers" = {
    count = 2
    profile = "bx2-4x16"
  }
  "db-servers" = {
    count = 1
    profile = "bx2-8x32"
  }
}
```

### **Security Configuration**
```hcl
security_configurations = {
  allowed_ssh_cidr_blocks = ["your.ip.address/32"]
  allowed_web_cidr_blocks = ["0.0.0.0/0"]
  enable_network_acls = true
  compliance_framework = "general"
}
```

## 🏗️ **Infrastructure Components**

### **Networking**
- **VPC**: Isolated virtual private cloud
- **Subnets**: 6 subnets across 2 availability zones
- **Public Gateways**: Internet access for public subnets
- **Security Groups**: Tier-based network security

### **Compute**
- **Web Servers**: 2x bx2-2x8 instances with nginx
- **App Servers**: 2x bx2-4x16 instances with Node.js
- **DB Servers**: 1x bx2-8x32 instance with PostgreSQL

### **Storage**
- **Boot Volumes**: Encrypted root storage for all instances
- **Data Volumes**: Dedicated storage for application and database data
- **Shared Storage**: Common storage for shared resources

### **Load Balancing**
- **Application Load Balancer**: Public-facing load balancer
- **Backend Pool**: Health-checked web server pool
- **Health Monitoring**: Automated health checks

## 🔒 **Security Features**

### **Network Security**
- **Defense in Depth**: Multi-layer security architecture
- **Network Isolation**: Private subnets for app and database tiers
- **Security Groups**: Granular traffic control
- **Network ACLs**: Additional subnet-level protection

### **Data Protection**
- **Encryption at Rest**: All storage volumes encrypted
- **Encryption in Transit**: HTTPS/TLS for web traffic
- **Access Control**: Role-based access management
- **Audit Logging**: Comprehensive activity tracking

### **Compliance**
- **Framework Support**: General, HIPAA, SOX, PCI-DSS
- **Security Monitoring**: Real-time threat detection
- **Vulnerability Management**: Regular security assessments
- **Incident Response**: Automated alerting and response

## 💰 **Cost Optimization**

### **Estimated Monthly Costs (USD)**
| Component | Count | Unit Cost | Total |
|-----------|-------|-----------|-------|
| Web Servers (bx2-2x8) | 2 | $73 | $146 |
| App Servers (bx2-4x16) | 2 | $146 | $292 |
| DB Servers (bx2-8x32) | 1 | $292 | $292 |
| Storage Volumes | 850GB | ~$0.15/GB | $128 |
| Load Balancer | 1 | $25 | $25 |
| **Total Estimated** | | | **~$883** |

### **Cost Optimization Strategies**
- **Right-sizing**: Monitor and adjust instance profiles
- **Scheduled Scaling**: Auto-scale based on demand
- **Reserved Instances**: Long-term commitments for savings
- **Storage Optimization**: Use appropriate storage tiers
- **Resource Tagging**: Track and allocate costs effectively

## 📊 **Monitoring and Observability**

### **Built-in Monitoring**
- **Platform Metrics**: CPU, memory, disk, network
- **Application Metrics**: Response time, error rates
- **Infrastructure Health**: Resource availability
- **Cost Tracking**: Real-time cost monitoring

### **Recommended Monitoring Stack**
- **IBM Cloud Monitoring**: Infrastructure metrics with Sysdig
- **IBM Log Analysis**: Centralized logging with LogDNA
- **Activity Tracker**: Audit and compliance logging
- **Custom Dashboards**: Application-specific monitoring

## 🧪 **Testing and Validation**

### **Automated Testing**
```bash
# Validate configuration
./scripts/validate.sh

# Test deployment
./scripts/test-deployment.sh

# Performance testing
curl -w "@curl-format.txt" -s -o /dev/null http://your-lb-hostname
```

### **Manual Testing**
1. **Web Application**: Access via load balancer URL
2. **Health Checks**: Verify `/health` endpoints
3. **Security**: Test network isolation
4. **Scaling**: Modify instance counts
5. **Monitoring**: Review metrics and logs

## 🔧 **Troubleshooting**

### **Common Issues**

#### **Authentication Errors**
```bash
# Verify API key
ibmcloud iam api-key-get your-key-name

# Check permissions
ibmcloud iam user-policies your-email
```

#### **Resource Limits**
```bash
# Check quotas
ibmcloud is quotas

# View current usage
ibmcloud resource service-instances
```

#### **Network Connectivity**
```bash
# Test load balancer
curl -I http://your-lb-hostname

# Check security groups
terraform state show ibm_is_security_group.web_tier_sg
```

### **Debugging Commands**
```bash
# Terraform debugging
export TF_LOG=DEBUG
terraform apply

# State inspection
terraform state list
terraform state show resource_name

# Plan analysis
terraform plan -out=debug.tfplan
terraform show debug.tfplan
```

## 🚀 **Advanced Usage**

### **Scaling Operations**
```bash
# Scale web servers
terraform apply -var='instance_configurations.web-servers.count=4'

# Scale app servers
terraform apply -var='instance_configurations.app-servers.count=3'
```

### **Environment Promotion**
```bash
# Development to staging
terraform workspace new staging
terraform apply -var-file=staging.tfvars

# Staging to production
terraform workspace new production
terraform apply -var-file=production.tfvars
```

### **Disaster Recovery**
```bash
# Deploy to secondary region
terraform apply -var='ibm_region=us-east'

# Cross-region replication
terraform apply -var='enable_cross_region_backup=true'
```

## 🧹 **Cleanup**

### **Destroy Infrastructure**
```bash
# Interactive cleanup
./scripts/cleanup.sh

# Direct destruction
terraform destroy

# Force cleanup (if needed)
terraform destroy -auto-approve
```

### **Cleanup Verification**
```bash
# Verify no resources remain
ibmcloud is instances
ibmcloud is vpcs
ibmcloud is load-balancers
```

## 📚 **Learning Resources**

### **Documentation**
- [IBM Cloud Terraform Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm)
- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)
- [Terraform Best Practices](https://terraform.io/docs/cloud/guides/recommended-practices)

### **Next Steps**
1. **Topic 4.2**: HCL Syntax, Variables, and Outputs
2. **Topic 4.3**: Resource Dependencies and Attributes
3. **Topic 5**: Modularization Best Practices
4. **Topic 6**: State Management and Collaboration

### **Community Resources**
- [IBM Cloud Community](https://community.ibm.com/community/user/cloud)
- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core)
- [GitHub Examples](https://github.com/IBM-Cloud/terraform-provider-ibm)

## 🎓 **Assessment Criteria**

### **Technical Competency**
- [ ] Successfully deploy 3-tier architecture
- [ ] Configure proper network security
- [ ] Implement load balancing and health checks
- [ ] Enable monitoring and logging
- [ ] Optimize costs and resource utilization

### **Best Practices**
- [ ] Use proper resource naming conventions
- [ ] Implement comprehensive tagging strategy
- [ ] Follow security best practices
- [ ] Document configuration decisions
- [ ] Test deployment thoroughly

### **Business Value**
- [ ] Demonstrate cost optimization (30-50% savings)
- [ ] Achieve high availability (99.9% uptime)
- [ ] Implement security compliance
- [ ] Enable operational efficiency
- [ ] Support scalability requirements

---

## 📞 **Support**

For questions or issues with this lab:
1. Review the troubleshooting section
2. Check the IBM Cloud documentation
3. Consult the Terraform provider documentation
4. Reach out to the training team

**Happy Learning! 🚀**
