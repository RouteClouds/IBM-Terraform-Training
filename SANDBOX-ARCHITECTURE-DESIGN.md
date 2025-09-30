# IBM Cloud Terraform Training - Sandbox Environment Architecture

## 🏗️ **Executive Summary**

This document defines the comprehensive technical architecture for the IBM Cloud Terraform Training sandbox environment, ensuring safe, cost-controlled, and educationally effective learning experiences.

## 🎯 **Design Principles**

### **1. Safety First**
- **Complete Isolation**: No access to production environments
- **Resource Boundaries**: Strict limits on resource creation and costs
- **Automatic Cleanup**: Scheduled resource removal to prevent cost accumulation

### **2. Educational Effectiveness**
- **Real-World Scenarios**: Actual IBM Cloud resource provisioning
- **Progressive Complexity**: Environment scales with learning progression
- **Validation Checkpoints**: Built-in verification and troubleshooting support

### **3. Cost Control**
- **Predictable Costs**: Fixed budget allocation per student
- **Automated Monitoring**: Real-time cost tracking and alerts
- **Resource Quotas**: Prevent accidental over-provisioning

## 🏛️ **Technical Architecture**

### **Account Structure**

#### **Training Master Account**
- **Purpose**: Central management and billing consolidation
- **Access**: Training administrators and instructors only
- **Features**: Cost tracking, resource monitoring, policy enforcement

#### **Student Sub-Accounts**
- **Purpose**: Individual student learning environments
- **Isolation**: Complete separation between students
- **Lifecycle**: Created before training, destroyed after completion

### **Resource Organization**

#### **Resource Groups**
```
Training-Master-RG/
├── Student-Environment-Templates/
├── Shared-Training-Resources/
├── Monitoring-and-Logging/
└── Cost-Management-Tools/

Student-{ID}-RG/
├── Lab-1-Resources/
├── Lab-2-Resources/
├── ...
└── Lab-8-Resources/
```

#### **Naming Conventions**
- **Students**: `terraform-training-student-{ID}`
- **Resources**: `{lab-number}-{resource-type}-{student-id}`
- **Tags**: `training`, `student-{id}`, `lab-{number}`, `auto-cleanup`

### **Security Architecture**

#### **Identity and Access Management (IAM)**
- **Student Policies**: Restricted to training resource groups only
- **Service IDs**: Dedicated service accounts for Terraform operations
- **API Keys**: Temporary keys with automatic expiration
- **MFA Requirements**: Multi-factor authentication for all accounts

#### **Network Security**
- **VPC Isolation**: Dedicated VPC per student environment
- **Security Groups**: Restrictive rules allowing only necessary traffic
- **Network ACLs**: Additional layer of network protection
- **Private Endpoints**: Secure communication with IBM Cloud services

### **Cost Control Framework**

#### **Budget Allocation**
- **Per Student**: $50 maximum for 4-day training
- **Per Lab**: $5-10 estimated cost per laboratory exercise
- **Buffer**: 20% contingency for extended learning time

#### **Automated Controls**
- **Spending Alerts**: Notifications at 50%, 75%, 90% of budget
- **Resource Quotas**: Maximum instances, storage, and network resources
- **Auto-Shutdown**: Scheduled shutdown of compute resources during breaks
- **Cleanup Automation**: Daily cleanup of unused resources

### **Monitoring and Logging**

#### **Activity Tracking**
- **IBM Cloud Activity Tracker**: Complete audit log of all actions
- **Resource Lifecycle**: Track creation, modification, and deletion
- **Cost Attribution**: Detailed cost breakdown per student and lab
- **Performance Metrics**: Resource utilization and optimization opportunities

#### **Student Progress Monitoring**
- **Lab Completion**: Automated detection of successful lab completion
- **Error Tracking**: Common issues and troubleshooting guidance
- **Performance Analytics**: Time to completion and success rates

## 🔧 **Implementation Components**

### **Infrastructure as Code Templates**

#### **Student Environment Template**
```hcl
# Student environment provisioning template
resource "ibm_resource_group" "student_rg" {
  name = "terraform-training-student-${var.student_id}"
  tags = ["training", "student-${var.student_id}", "auto-cleanup"]
}

resource "ibm_is_vpc" "student_vpc" {
  name           = "training-vpc-${var.student_id}"
  resource_group = ibm_resource_group.student_rg.id
  tags           = ["training", "student-${var.student_id}"]
}

# Cost control policy
resource "ibm_iam_access_group_policy" "student_policy" {
  access_group_id = ibm_iam_access_group.students.id
  roles           = ["Editor"]
  
  resources {
    resource_group_id = ibm_resource_group.student_rg.id
  }
}
```

#### **Cleanup Automation**
```bash
#!/bin/bash
# Automated cleanup script for training resources
# Runs daily to remove unused resources and control costs

# Remove resources older than 5 days
ibmcloud resource search "tags:auto-cleanup AND created_at:<$(date -d '5 days ago' -I)"

# Shutdown compute instances during non-training hours
ibmcloud is instances --resource-group-name "terraform-training-*" --output json | \
  jq -r '.[] | select(.status=="running") | .id' | \
  xargs -I {} ibmcloud is instance-stop {}
```

### **Student Onboarding Automation**

#### **Pre-Training Setup**
1. **Account Creation**: Automated student account provisioning
2. **Access Configuration**: IAM policies and API key generation
3. **Environment Validation**: Connectivity and permission testing
4. **Tool Installation**: Terraform CLI and IBM Cloud CLI setup

#### **During Training Support**
1. **Real-Time Monitoring**: Cost and resource usage tracking
2. **Automated Assistance**: Common issue detection and resolution
3. **Progress Tracking**: Lab completion and milestone achievement
4. **Instructor Dashboard**: Student progress and environment status

#### **Post-Training Cleanup**
1. **Resource Inventory**: Complete resource audit and documentation
2. **Cost Reporting**: Final cost breakdown and optimization recommendations
3. **Account Deactivation**: Secure removal of student access
4. **Knowledge Transfer**: Export of student configurations for reference

## 📊 **Cost Estimation**

### **Per-Student Costs (4-Day Training)**
- **Compute Resources**: $15-20 (VSI instances for labs)
- **Storage**: $5-8 (Block storage and Object storage)
- **Networking**: $3-5 (VPC, Load Balancers, Public IPs)
- **Services**: $5-10 (Key Protect, Activity Tracker, etc.)
- **Buffer**: $10-15 (Extended learning time, troubleshooting)
- **Total**: $38-58 per student

### **Scaling Considerations**
- **20 Students**: $760-1,160 total cost
- **50 Students**: $1,900-2,900 total cost
- **100 Students**: $3,800-5,800 total cost

## 🚀 **Deployment Strategy**

### **Phase 1: Infrastructure Setup (1 day)**
- Deploy master account infrastructure
- Configure monitoring and cost controls
- Test automation scripts and cleanup procedures

### **Phase 2: Student Environment Templates (1 day)**
- Create and validate student environment templates
- Test account provisioning and access controls
- Validate lab resource provisioning

### **Phase 3: Validation and Testing (1 day)**
- End-to-end testing with sample student accounts
- Validate cost controls and cleanup automation
- Performance testing and optimization

## ✅ **Success Criteria**

### **Technical Validation**
- [ ] Student environments provision in under 5 minutes
- [ ] All lab exercises complete successfully in sandbox
- [ ] Cost controls prevent budget overruns
- [ ] Cleanup automation removes 100% of resources

### **Educational Effectiveness**
- [ ] Students can complete all labs without environment issues
- [ ] Real IBM Cloud resources are provisioned and managed
- [ ] Troubleshooting guidance resolves 90% of common issues
- [ ] Environment supports all 8 training topics effectively

### **Operational Excellence**
- [ ] Instructor dashboard provides real-time student status
- [ ] Automated monitoring detects and resolves issues
- [ ] Cost reporting provides accurate per-student breakdown
- [ ] Security controls prevent unauthorized access

**Next Steps**: Proceed with detailed implementation documentation and student onboarding workflow creation.
