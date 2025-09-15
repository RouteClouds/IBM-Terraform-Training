# Terraform Code Lab 6.2: State Locking and Drift Detection

## 📋 **Lab Overview**

This comprehensive Terraform configuration demonstrates **advanced state management** with distributed state locking and automated drift detection using IBM Cloud services. The lab provides hands-on experience with enterprise-grade state consistency, conflict prevention, and automated monitoring patterns.

### **Learning Objectives**
- Implement distributed state locking with IBM Cloudant
- Configure automated drift detection using IBM Cloud Functions
- Deploy monitoring and alerting for state management operations
- Establish conflict resolution and remediation workflows
- Integrate enterprise compliance and audit logging

### **Architecture Overview**
- **State Backend**: IBM Cloud Object Storage with S3 compatibility
- **State Locking**: IBM Cloudant with DynamoDB compatibility
- **Drift Detection**: IBM Cloud Functions with scheduled triggers
- **Monitoring**: IBM Monitoring and Activity Tracker integration
- **Alerting**: Multi-channel notifications (Slack, Email, Webhooks)

---

## 🏗️ **Infrastructure Components**

### **Core Services**
- **IBM Cloudant**: NoSQL database for distributed state locking
- **IBM Cloud Object Storage**: S3-compatible backend for state storage
- **IBM Cloud Functions**: Serverless automation for drift detection
- **IBM VPC**: Isolated network environment for demonstration
- **IBM Virtual Server Instance**: Compute resource for testing

### **Monitoring and Compliance**
- **IBM Monitoring**: Infrastructure metrics and alerting
- **IBM Activity Tracker**: Audit logging and compliance tracking
- **Custom Dashboards**: Real-time operational visibility
- **Alert Channels**: Slack, Email, and Webhook integrations

### **Security Features**
- **Encryption**: End-to-end encryption for state and data
- **Access Control**: IAM-based permissions and role management
- **Audit Logging**: Comprehensive activity tracking
- **Network Security**: VPC isolation and security groups

---

## 🚀 **Quick Start Guide**

### **Prerequisites**
```bash
# Required tools
terraform >= 1.5.0
ibmcloud CLI with plugins
jq
curl

# IBM Cloud authentication
ibmcloud login
ibmcloud target -r us-south -g default
```

### **Initial Setup**
```bash
# Clone and navigate to lab directory
cd Terraform-Code-Lab-6.2

# Copy and customize configuration
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Deploy infrastructure
terraform apply
```

### **Automated Setup**
```bash
# Use the automated setup script
chmod +x scripts/setup-environment.sh
./scripts/setup-environment.sh
```

---

## 📁 **File Structure**

```
Terraform-Code-Lab-6.2/
├── providers.tf              # Provider and backend configuration
├── variables.tf               # Variable definitions (25+ variables)
├── main.tf                   # Main infrastructure configuration
├── outputs.tf                # Output definitions (15+ outputs)
├── terraform.tfvars.example  # Example configuration file
├── README.md                 # This comprehensive guide
├── scripts/
│   └── setup-environment.sh  # Automated setup script
├── templates/
│   ├── user-data.sh          # VSI initialization script
│   ├── backend-with-locking.tf.tpl  # Backend configuration template
│   └── drift-detection.js    # Cloud Functions drift detection
└── modules/                  # Reusable Terraform modules (if any)
```

---

## ⚙️ **Configuration Guide**

### **Core Configuration Variables**

#### **Authentication and Region**
```hcl
# IBM Cloud API key (required)
ibm_api_key = "your-ibm-cloud-api-key"

# Primary deployment region
primary_region = "us-south"

# Resource group for organization
resource_group_name = "default"
```

#### **Project Settings**
```hcl
# Project identification
project_name = "state-locking-lab"
environment = "development"

# Cost tracking
cost_center = "training"
budget_alert_threshold = 100
```

### **State Locking Configuration**

#### **Basic Locking Setup**
```hcl
# Enable distributed state locking
enable_state_locking = true

# Lock table configuration
lock_table_name = "terraform-locks"
lock_timeout_minutes = 10
lock_retry_attempts = 3
lock_retry_delay_seconds = 5
```

#### **Cloudant Configuration**
```hcl
# Cloudant service plan
cloudant_plan = "lite"  # or "standard" for production

# For standard plan only
cloudant_capacity_throughput = 1
```

### **Drift Detection Configuration**

#### **Detection Settings**
```hcl
# Enable automated drift detection
enable_drift_detection = true

# Schedule (cron format)
drift_check_schedule = "0 */6 * * *"  # Every 6 hours

# Severity and thresholds
drift_severity_threshold = 3
enable_auto_remediation = false
auto_remediation_threshold = 3
```

#### **Alert Configuration**
```hcl
# Alert channels
drift_alert_channels = ["email", "slack"]

# Notification endpoints
slack_webhook_url = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
email_recipients = ["team@company.com"]
webhook_endpoints = ["https://your-system.com/webhook"]
```

### **Infrastructure Configuration**

#### **Network Settings**
```hcl
# VPC and subnet configuration
vpc_address_prefix = "10.241.0.0/16"
subnet_address_prefix = "10.241.1.0/24"

# Internet access
enable_public_gateway = true
enable_floating_ip = false
```

#### **Compute Configuration**
```hcl
# VSI settings
vsi_profile = "bx2-2x8"
vsi_image_name = "ibm-ubuntu-22-04-1-minimal-amd64-1"
ssh_key_name = "your-ssh-key-name"
```

### **Monitoring and Compliance**

#### **Service Configuration**
```hcl
# Monitoring services
enable_activity_tracker = true
enable_monitoring = true
enable_key_protect = false

# Service plans
activity_tracker_plan = "7-day"
monitoring_plan = "graduated-tier"
```

#### **Cloud Functions**
```hcl
# Automation configuration
enable_cloud_functions = true
functions_namespace = "terraform-automation"
function_memory_limit = 256
function_timeout = 300
```

---

## 🔧 **Advanced Configuration**

### **Environment-Specific Settings**

#### **Development Environment**
```hcl
environment = "development"
enable_state_locking = true
enable_drift_detection = true
enable_auto_remediation = false
cloudant_plan = "lite"
activity_tracker_plan = "lite"
monitoring_plan = "lite"
enable_testing_mode = true
simulate_drift = true
```

#### **Production Environment**
```hcl
environment = "production"
enable_state_locking = true
enable_drift_detection = true
enable_auto_remediation = true
auto_remediation_threshold = 1
cloudant_plan = "standard"
cloudant_capacity_throughput = 5
activity_tracker_plan = "30-day"
monitoring_plan = "graduated-tier"
enable_key_protect = true
drift_check_schedule = "0 */2 * * *"  # Every 2 hours
budget_alert_threshold = 500
```

### **Security Hardening**

#### **Encryption Configuration**
```hcl
# Enable encryption services
enable_key_protect = true

# Backend encryption (always enabled)
# State files are encrypted at rest and in transit
```

#### **Access Control**
```hcl
# Network security
# Security groups configured with minimal required access
# VPC isolation for network-level security

# IAM integration
# Service credentials with least privilege access
# Role-based access control for all services
```

### **Cost Optimization**

#### **Service Plan Selection**
```hcl
# Development/Testing
cloudant_plan = "lite"              # Free tier
activity_tracker_plan = "lite"     # Free tier
monitoring_plan = "lite"            # Free tier

# Production
cloudant_plan = "standard"          # Paid tier with SLA
activity_tracker_plan = "30-day"   # Extended retention
monitoring_plan = "graduated-tier" # Advanced features
```

#### **Resource Optimization**
```hcl
# Compute optimization
vsi_profile = "bx2-2x8"  # Balanced performance/cost

# Storage optimization
# Lifecycle policies for state history
# Automatic archiving of old state versions

# Function optimization
function_memory_limit = 256  # Optimal for drift detection
function_timeout = 300       # Sufficient for most operations
```

---

## 📊 **Monitoring and Observability**

### **Key Metrics**

#### **State Management Metrics**
- **Lock Duration**: Average time locks are held
- **Lock Conflicts**: Number of concurrent access attempts
- **State Operations**: Frequency of state modifications
- **Drift Events**: Number of drift detections per period

#### **Infrastructure Metrics**
- **Resource Health**: Status of all managed resources
- **Performance**: Response times and throughput
- **Availability**: Service uptime and reliability
- **Cost**: Resource utilization and spending

### **Alerting Configuration**

#### **Critical Alerts**
- State corruption detected
- Lock timeout exceeded
- High-severity drift detected
- Service availability issues

#### **Warning Alerts**
- Moderate drift detected
- Lock conflicts occurring
- Performance degradation
- Budget threshold approaching

#### **Informational Alerts**
- Successful drift remediation
- Scheduled maintenance
- Configuration changes
- Cost optimization opportunities

### **Dashboard Integration**

#### **Real-time Monitoring**
- Live infrastructure status
- Active locks and operations
- Drift detection results
- Alert status and history

#### **Historical Analysis**
- Trend analysis for drift patterns
- Performance metrics over time
- Cost analysis and optimization
- Compliance reporting

---

## 🧪 **Testing and Validation**

### **State Locking Tests**

#### **Concurrent Access Testing**
```bash
# Terminal 1: Start long-running operation
terraform apply -auto-approve &

# Terminal 2: Attempt concurrent operation
terraform plan
# Expected: Lock conflict error
```

#### **Lock Timeout Testing**
```bash
# Simulate stuck lock scenario
terraform apply -auto-approve &
APPLY_PID=$!

# Kill process to simulate crash
kill -9 $APPLY_PID

# Attempt new operation (should timeout)
terraform apply -auto-approve
```

#### **Emergency Lock Breaking**
```bash
# Check lock status
terraform force-unlock -help

# Break lock if necessary (emergency only)
terraform force-unlock LOCK_ID

# Verify lock removal
terraform plan
```

### **Drift Detection Tests**

#### **Manual Drift Simulation**
```bash
# Modify resource outside Terraform
ibmcloud is security-group-rule-add SECURITY_GROUP_ID \
  --direction inbound \
  --protocol tcp \
  --port-min 9090 \
  --port-max 9090

# Trigger drift detection
ibmcloud fn action invoke drift-detection --result

# Verify drift detection and alerts
```

#### **Automated Drift Testing**
```bash
# Enable drift simulation in configuration
simulate_drift = true

# Deploy with simulation enabled
terraform apply

# Monitor drift detection logs
ibmcloud fn activation logs --last
```

### **Remediation Testing**

#### **Low-Severity Auto-Remediation**
```bash
# Configure auto-remediation
enable_auto_remediation = true
auto_remediation_threshold = 3

# Create low-severity drift
# Verify automatic remediation

# Check remediation logs
ibmcloud fn activation logs --last
```

#### **High-Severity Manual Approval**
```bash
# Create high-severity drift
# Verify approval request generation
# Test manual approval workflow
```

---

## 🔍 **Troubleshooting Guide**

### **Common Issues and Solutions**

#### **State Locking Issues**

**Problem**: Lock acquisition fails
```bash
# Check Cloudant service status
ibmcloud resource service-instance terraform-locks

# Verify credentials
ibmcloud resource service-key terraform-locks-key

# Test connectivity
curl -X GET https://your-cloudant-instance.cloudantnosqldb.appdomain.cloud/terraform-locks
```

**Problem**: Lock timeout occurs
```bash
# Increase timeout in configuration
lock_timeout_minutes = 15

# Check for stuck processes
ps aux | grep terraform

# Force unlock if necessary
terraform force-unlock LOCK_ID
```

#### **Drift Detection Issues**

**Problem**: Drift detection not triggering
```bash
# Check Cloud Functions status
ibmcloud fn namespace list
ibmcloud fn action list

# Verify trigger configuration
ibmcloud fn trigger list

# Test function manually
ibmcloud fn action invoke drift-detection --result
```

**Problem**: False positive drift alerts
```bash
# Adjust severity threshold
drift_severity_threshold = 5

# Review detection algorithm
# Check for expected infrastructure changes
```

#### **Backend Configuration Issues**

**Problem**: Backend migration fails
```bash
# Verify COS bucket access
ibmcloud cos bucket-head --bucket BUCKET_NAME

# Check credentials
ibmcloud resource service-key state-credentials

# Validate backend configuration
terraform init -backend-config="bucket=BUCKET_NAME"
```

**Problem**: State corruption
```bash
# Check state file integrity
terraform show

# Restore from backup if needed
# Verify state consistency
terraform plan
```

### **Performance Optimization**

#### **Lock Performance**
```bash
# Monitor lock duration
# Optimize operation frequency
# Use workspace isolation for parallel work
```

#### **Drift Detection Performance**
```bash
# Adjust detection frequency
drift_check_schedule = "0 */12 * * *"  # Every 12 hours

# Optimize function memory
function_memory_limit = 512

# Implement incremental detection
```

#### **Cost Optimization**
```bash
# Monitor service usage
ibmcloud billing account-usage

# Optimize service plans
# Implement lifecycle policies
# Use resource tagging for cost allocation
```

---

## 📚 **Best Practices**

### **State Management**

#### **Locking Strategy**
- Always enable state locking for team environments
- Use appropriate timeout values for your operations
- Implement emergency unlock procedures
- Monitor lock duration and conflicts

#### **Backend Security**
- Enable encryption for state storage
- Use IAM for access control
- Implement audit logging
- Regular backup and disaster recovery testing

### **Drift Detection**

#### **Detection Strategy**
- Set appropriate detection frequency
- Configure severity thresholds based on risk
- Implement graduated response procedures
- Maintain alert fatigue prevention

#### **Remediation Strategy**
- Use auto-remediation for low-risk changes only
- Implement approval workflows for high-risk changes
- Maintain rollback procedures
- Document all remediation actions

### **Monitoring and Alerting**

#### **Alert Management**
- Configure multiple notification channels
- Implement alert escalation procedures
- Use severity-based routing
- Maintain alert acknowledgment workflows

#### **Compliance and Audit**
- Enable comprehensive activity tracking
- Implement retention policies
- Regular compliance reporting
- Maintain audit trail integrity

---

## 🎯 **Success Criteria**

### **Technical Validation**
- [ ] State locking prevents concurrent modifications
- [ ] Drift detection identifies changes within configured timeframe
- [ ] Automated remediation handles low-risk drift appropriately
- [ ] Manual approval workflows function for high-risk changes
- [ ] All monitoring and alerting channels operational

### **Operational Validation**
- [ ] Team can collaborate without state conflicts
- [ ] Infrastructure changes are detected and reported
- [ ] Incident response procedures are effective
- [ ] Compliance requirements are met
- [ ] Cost optimization targets achieved

### **Business Validation**
- [ ] Reduced risk of state corruption
- [ ] Improved team productivity
- [ ] Enhanced operational visibility
- [ ] Compliance with audit requirements
- [ ] Optimized infrastructure costs

---

## 📖 **Additional Resources**

### **Documentation**
- [Lab 13: State Locking and Drift Detection](../Lab-13.md)
- [Concept: Advanced State Management](../Concept.md)
- [IBM Cloudant Documentation](https://cloud.ibm.com/docs/Cloudant)
- [IBM Cloud Functions Documentation](https://cloud.ibm.com/docs/openwhisk)

### **Related Labs**
- [Lab 12: Local and Remote State Files](../../01-Local-Remote-State-Files/Lab-12.md)
- [Topic 5: Resource Dependencies](../../../05-Resource-Dependencies/)
- [Topic 7: Security and Compliance](../../../07-Security-Compliance/)

### **Community Resources**
- [Terraform State Management Best Practices](https://terraform.io/docs/language/state/)
- [IBM Cloud Terraform Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/)
- [Infrastructure as Code Patterns](https://patterns.terraform.io/)

---

## 💡 **Cost Estimation**

### **Monthly Cost Breakdown (USD)**

#### **Development Environment**
| Service | Plan | Estimated Cost |
|---------|------|----------------|
| IBM Cloudant | Lite | Free |
| IBM Cloud Object Storage | Lite | Free |
| IBM Cloud Functions | Pay-per-use | $5-10 |
| IBM Activity Tracker | Lite | Free |
| IBM Monitoring | Lite | Free |
| VPC Infrastructure | Standard | $20-30 |
| **Total Development** | | **$25-40** |

#### **Production Environment**
| Service | Plan | Estimated Cost |
|---------|------|----------------|
| IBM Cloudant | Standard (5 units) | $375 |
| IBM Cloud Object Storage | Standard | $10-25 |
| IBM Cloud Functions | Pay-per-use | $15-30 |
| IBM Activity Tracker | 30-day | $150-200 |
| IBM Monitoring | Graduated Tier | $50-100 |
| VPC Infrastructure | Standard | $40-80 |
| **Total Production** | | **$640-810** |

### **Cost Optimization Tips**
- Use Lite plans for development and testing
- Implement efficient drift detection schedules
- Optimize function execution frequency
- Monitor usage and adjust plans accordingly
- Use lifecycle policies for state storage
- Implement resource tagging for cost allocation

---

## 🔐 **Security Considerations**

### **Data Protection**
- All state files encrypted at rest and in transit
- Service credentials use least privilege access
- Network isolation through VPC and security groups
- Regular security audits and compliance checks

### **Access Control**
- IAM-based authentication and authorization
- Role-based access control for all services
- Service-to-service authentication
- Regular credential rotation

### **Audit and Compliance**
- Comprehensive activity logging
- Audit trail for all state operations
- Compliance reporting capabilities
- Data retention policies

### **Incident Response**
- Emergency unlock procedures
- Incident escalation workflows
- Disaster recovery procedures
- Security incident response plan

This comprehensive Terraform Code Lab provides enterprise-grade state management capabilities with distributed locking, automated drift detection, and comprehensive monitoring for production-ready infrastructure automation.
