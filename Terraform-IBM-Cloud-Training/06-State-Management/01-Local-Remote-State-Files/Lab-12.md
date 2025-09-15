# Lab 12: Local and Remote State Files Implementation

## 🎯 **Lab Overview**

**Duration**: 90-120 minutes  
**Difficulty**: Intermediate  
**Prerequisites**: Topics 1-5.3 completion, IBM Cloud account with appropriate permissions

### **Learning Objectives**
By completing this lab, you will:
1. **Analyze local state structure** and understand its limitations for team collaboration
2. **Configure IBM Cloud Object Storage** as a remote state backend with enterprise security
3. **Perform zero-downtime state migration** from local to remote backend
4. **Implement team collaboration workflows** with shared state access and coordination
5. **Establish monitoring and backup procedures** for enterprise state management

### **Lab Architecture**
This lab implements a complete state management solution using IBM Cloud Object Storage as the backend, with encryption, versioning, and team collaboration features.

**Estimated Costs**:
- IBM Cloud Object Storage: $5-10 for lab duration
- Activity Tracker: $2-5 for lab duration
- Key Protect: $1-3 for lab duration
- **Total Lab Cost**: $8-18 (can be minimized with lite plans)

---

## 🛠️ **Lab Setup and Prerequisites**

### **Required Tools and Access**
```bash
# Verify required tools
terraform --version  # Should be 1.5.0 or later
ibmcloud --version   # IBM Cloud CLI
git --version        # Git for version control

# Verify IBM Cloud authentication
ibmcloud auth
ibmcloud target --cf
```

### **Environment Variables Setup**
```bash
# Set required environment variables
export IBMCLOUD_API_KEY="your-api-key"
export TF_VAR_ibm_region="us-south"
export TF_VAR_resource_group_name="default"
export TF_VAR_project_name="terraform-state-lab"

# Verify environment setup
echo "API Key: ${IBMCLOUD_API_KEY:0:10}..."
echo "Region: $TF_VAR_ibm_region"
echo "Project: $TF_VAR_project_name"
```

### **Lab Directory Structure**
```bash
# Create lab directory structure
mkdir -p ~/terraform-state-lab/{local-state,remote-state,scripts,backups}
cd ~/terraform-state-lab

# Initialize Git repository for version control
git init
echo "*.tfstate*" >> .gitignore
echo ".terraform/" >> .gitignore
echo "terraform.tfvars" >> .gitignore
git add .gitignore
git commit -m "Initial commit with proper .gitignore"
```

---

## 📋 **Exercise 1: Local State Analysis and Management (15 minutes)**

### **Objective**
Understand local state structure, benefits, and limitations through hands-on analysis.

### **Step 1.1: Create Simple Infrastructure with Local State**

Building on the IBM Cloud provider knowledge from **Topic 2.2**, create a basic infrastructure configuration:

```bash
cd local-state
cat > main.tf << 'EOF'
# Local state demonstration configuration
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }
  }
}

# IBM Cloud provider configuration
provider "ibm" {
  ibmcloud_api_key = var.ibm_api_key
  region           = var.ibm_region
}

# Variables for configuration
variable "ibm_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "ibm_region" {
  description = "IBM Cloud region"
  type        = string
  default     = "us-south"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "state-lab"
}

# Data sources for existing resources
data "ibm_resource_group" "default" {
  name = "default"
}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Simple VPC for state demonstration
resource "ibm_is_vpc" "lab_vpc" {
  name           = "${var.project_name}-vpc-${random_string.suffix.result}"
  resource_group = data.ibm_resource_group.default.id
  
  tags = [
    "lab:state-management",
    "environment:development",
    "terraform:managed"
  ]
}

# Output for state analysis
output "vpc_info" {
  description = "VPC information for state analysis"
  value = {
    id   = ibm_is_vpc.lab_vpc.id
    name = ibm_is_vpc.lab_vpc.name
    crn  = ibm_is_vpc.lab_vpc.crn
  }
}
EOF
```

### **Step 1.2: Initialize and Apply Configuration**
```bash
# Create terraform.tfvars file
cat > terraform.tfvars << EOF
ibm_api_key  = "$IBMCLOUD_API_KEY"
ibm_region   = "$TF_VAR_ibm_region"
project_name = "$TF_VAR_project_name"
EOF

# Initialize and apply
terraform init
terraform plan -out=local.tfplan
terraform apply local.tfplan
```

### **Step 1.3: Analyze Local State Structure**
```bash
# Examine state file structure
echo "=== State File Analysis ==="
ls -la terraform.tfstate*

# View state file contents (formatted)
terraform show -json | jq '.' > state_analysis.json

# Analyze key state components
echo "=== State Version and Metadata ==="
jq '.version, .terraform_version, .serial, .lineage' terraform.tfstate

echo "=== Resource Inventory ==="
terraform state list

echo "=== Detailed Resource Information ==="
terraform state show ibm_is_vpc.lab_vpc

# Document state file size and complexity
echo "=== State File Metrics ==="
wc -l terraform.tfstate
du -h terraform.tfstate
```

### **Step 1.4: Demonstrate Local State Limitations**
```bash
# Simulate team collaboration challenge
echo "=== Team Collaboration Simulation ==="

# Create backup to simulate another team member's state
cp terraform.tfstate terraform.tfstate.teammate

# Make a change to simulate concurrent modification
terraform plan -var="project_name=state-lab-modified"

echo "Local state limitations identified:"
echo "1. Single point of access - only one person can modify"
echo "2. No concurrent operations - team conflicts inevitable"
echo "3. No centralized backup - individual responsibility"
echo "4. No audit trail - changes not tracked"
echo "5. Security concerns - sensitive data in local files"
```

**Validation Checkpoint**: Verify local state creation and analysis completion
- [ ] Local state file created and analyzed
- [ ] Resource inventory documented
- [ ] State limitations identified and understood

---

## ☁️ **Exercise 2: IBM Cloud Object Storage Backend Configuration (25 minutes)**

### **Objective**
Configure IBM Cloud Object Storage as a remote state backend with enterprise security features.

### **Step 2.1: Create COS Instance and Bucket**

Following the procedure from **Lab 1.2** (COS configuration), create the state backend infrastructure:

```bash
cd ../remote-state
cat > backend-setup.tf << 'EOF'
# IBM Cloud Object Storage for state backend
resource "ibm_resource_instance" "terraform_state_cos" {
  name              = "${var.project_name}-terraform-state"
  resource_group_id = data.ibm_resource_group.default.id
  service           = "cloud-object-storage"
  plan              = "lite"  # Use lite for lab cost optimization
  location          = "global"
  
  tags = [
    "service:terraform-state",
    "lab:state-management",
    "purpose:backend-storage"
  ]
}

# State storage bucket with enterprise features
resource "ibm_cos_bucket" "terraform_state_bucket" {
  bucket_name          = "${var.project_name}-state-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.terraform_state_cos.id
  region_location      = var.ibm_region
  storage_class        = "standard"
  
  # Enable versioning for state history
  object_versioning {
    enable = true
  }
  
  # Activity tracking for audit compliance
  activity_tracking {
    read_data_events     = true
    write_data_events    = true
    management_events    = true
  }
  
  # Lifecycle management for cost optimization
  lifecycle_rule {
    id     = "state-lifecycle"
    status = "Enabled"
    
    # Archive old state versions after 30 days
    transition {
      days          = 30
      storage_class = "cold"
    }
    
    # Delete very old versions after 90 days
    expiration {
      days = 90
    }
  }
}

# Service credentials for backend access
resource "ibm_resource_key" "cos_credentials" {
  name                 = "${var.project_name}-state-credentials"
  resource_instance_id = ibm_resource_instance.terraform_state_cos.id
  role                 = "Writer"
  
  parameters = {
    HMAC = true
  }
}

# Output backend configuration details
output "backend_config" {
  description = "Backend configuration for terraform backend block"
  value = {
    bucket   = ibm_cos_bucket.terraform_state_bucket.bucket_name
    endpoint = ibm_cos_bucket.terraform_state_bucket.s3_endpoint_public
    region   = var.ibm_region
  }
}

output "cos_credentials" {
  description = "COS credentials for backend authentication"
  value = {
    access_key_id     = ibm_resource_key.cos_credentials.credentials["cos_hmac_keys.access_key_id"]
    secret_access_key = ibm_resource_key.cos_credentials.credentials["cos_hmac_keys.secret_access_key"]
  }
  sensitive = true
}
EOF
```

### **Step 2.2: Deploy Backend Infrastructure**
```bash
# Copy configuration from local-state exercise
cp ../local-state/main.tf .
cp ../local-state/terraform.tfvars .

# Add backend setup to main configuration
cat backend-setup.tf >> main.tf

# Initialize and deploy backend infrastructure
terraform init
terraform plan -out=backend.tfplan
terraform apply backend.tfplan

# Capture backend configuration for migration
terraform output -json backend_config > backend_config.json
terraform output -json cos_credentials > cos_credentials.json
```

### **Step 2.3: Configure Backend Block**
```bash
# Extract backend configuration values
BUCKET_NAME=$(jq -r '.bucket' backend_config.json)
ENDPOINT=$(jq -r '.endpoint' backend_config.json)
REGION=$(jq -r '.region' backend_config.json)

# Create backend configuration file
cat > backend.tf << EOF
terraform {
  backend "s3" {
    bucket                      = "$BUCKET_NAME"
    key                        = "infrastructure/terraform.tfstate"
    region                     = "$REGION"
    endpoint                   = "$ENDPOINT"
    skip_credentials_validation = true
    skip_region_validation     = true
    skip_metadata_api_check    = true
    force_path_style           = true
    encrypt                    = true
  }
}
EOF

echo "Backend configuration created:"
cat backend.tf
```

**Validation Checkpoint**: Verify backend infrastructure deployment
- [ ] COS instance and bucket created successfully
- [ ] Service credentials generated and secured
- [ ] Backend configuration file created
- [ ] All outputs captured for migration

---

## 🔄 **Exercise 3: State Migration Implementation (30 minutes)**

### **Objective**
Perform zero-downtime migration from local to remote state with comprehensive validation.

### **Step 3.1: Pre-Migration Preparation**

Following the workflow patterns from **Topic 3.1**, prepare for state migration:

```bash
# Create comprehensive backup strategy
mkdir -p ../backups/$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="../backups/$(date +%Y%m%d_%H%M%S)"

# Backup current state and configuration
cp terraform.tfstate* $BACKUP_DIR/
cp *.tf $BACKUP_DIR/
cp terraform.tfvars $BACKUP_DIR/

# Document current state for validation
terraform state list > $BACKUP_DIR/resource_inventory.txt
terraform show > $BACKUP_DIR/state_details.txt

echo "Pre-migration backup completed in: $BACKUP_DIR"
ls -la $BACKUP_DIR
```

### **Step 3.2: Configure Remote Backend Authentication**
```bash
# Set up authentication for remote backend
export AWS_ACCESS_KEY_ID=$(jq -r '.access_key_id' cos_credentials.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.secret_access_key' cos_credentials.json)

# Verify authentication
echo "Backend authentication configured"
echo "Access Key: ${AWS_ACCESS_KEY_ID:0:10}..."
```

### **Step 3.3: Perform State Migration**
```bash
echo "=== Starting State Migration ==="

# Initialize with backend migration
terraform init -migrate-state

# Respond 'yes' when prompted to migrate state
# The migration process will:
# 1. Copy local state to remote backend
# 2. Verify state integrity
# 3. Update local configuration

echo "=== Migration Validation ==="

# Verify migration success
terraform plan -detailed-exitcode
PLAN_EXIT_CODE=$?

if [ $PLAN_EXIT_CODE -eq 0 ]; then
    echo "✅ Migration successful - no changes detected"
elif [ $PLAN_EXIT_CODE -eq 2 ]; then
    echo "⚠️  Migration completed but changes detected - review required"
else
    echo "❌ Migration failed - investigate before proceeding"
    exit 1
fi

# Verify all resources present in remote state
echo "=== Resource Verification ==="
terraform state list > post_migration_resources.txt
diff $BACKUP_DIR/resource_inventory.txt post_migration_resources.txt

if [ $? -eq 0 ]; then
    echo "✅ All resources successfully migrated"
else
    echo "⚠️  Resource differences detected - review required"
fi
```

### **Step 3.4: Post-Migration Validation and Cleanup**
```bash
echo "=== Post-Migration Validation ==="

# Test remote state operations
terraform refresh
terraform plan

# Verify state is stored remotely
if [ ! -f terraform.tfstate ]; then
    echo "✅ Local state file removed - using remote backend"
else
    echo "⚠️  Local state file still present - cleanup required"
fi

# Test state locking (will be expanded in Lab 13)
echo "Testing basic state operations..."
terraform plan -lock-timeout=30s

# Document migration success
cat > migration_report.md << EOF
# State Migration Report

**Migration Date**: $(date)
**Source**: Local state file
**Destination**: IBM Cloud Object Storage
**Bucket**: $BUCKET_NAME
**Status**: ✅ Successful

## Pre-Migration State
- Resources: $(wc -l < $BACKUP_DIR/resource_inventory.txt)
- State Size: $(du -h $BACKUP_DIR/terraform.tfstate | cut -f1)

## Post-Migration Validation
- All resources migrated: ✅
- No configuration drift: ✅
- Remote backend operational: ✅

## Next Steps
- Configure team access controls
- Implement state locking (Lab 13)
- Set up monitoring and alerting
EOF

echo "Migration completed successfully!"
cat migration_report.md
```

**Validation Checkpoint**: Verify successful state migration
- [ ] State successfully migrated to remote backend
- [ ] All resources present in remote state
- [ ] No configuration drift detected
- [ ] Local state files cleaned up
- [ ] Migration report generated

---

## 👥 **Exercise 4: Team Collaboration Setup (20 minutes)**

### **Objective**
Establish team collaboration workflows with shared state access and coordination.

### **Step 4.1: Configure Team Access Controls**

Building on the collaboration patterns from **Topic 5.3**, implement team access:

```bash
# Create team access configuration
cat > team-access.tf << 'EOF'
# Additional service credentials for team members
resource "ibm_resource_key" "team_developer_credentials" {
  name                 = "${var.project_name}-developer-access"
  resource_instance_id = ibm_resource_instance.terraform_state_cos.id
  role                 = "Reader"  # Read-only for developers
  
  parameters = {
    HMAC = true
  }
}

resource "ibm_resource_key" "team_operator_credentials" {
  name                 = "${var.project_name}-operator-access"
  resource_instance_id = ibm_resource_instance.terraform_state_cos.id
  role                 = "Writer"  # Full access for operators
  
  parameters = {
    HMAC = true
  }
}

# Output team credentials
output "team_access" {
  description = "Team access credentials for different roles"
  value = {
    developer = {
      access_key_id     = ibm_resource_key.team_developer_credentials.credentials["cos_hmac_keys.access_key_id"]
      secret_access_key = ibm_resource_key.team_developer_credentials.credentials["cos_hmac_keys.secret_access_key"]
      role             = "Reader"
    }
    operator = {
      access_key_id     = ibm_resource_key.team_operator_credentials.credentials["cos_hmac_keys.access_key_id"]
      secret_access_key = ibm_resource_key.team_operator_credentials.credentials["cos_hmac_keys.secret_access_key"]
      role             = "Writer"
    }
  }
  sensitive = true
}
EOF

# Apply team access configuration
terraform apply -auto-approve
```

### **Step 4.2: Create Team Workflow Documentation**
```bash
cat > ../scripts/team-workflow.md << 'EOF'
# Team Collaboration Workflow

## Team Roles and Permissions

### Developer Role (Read-Only)
- Can run `terraform plan` to review changes
- Cannot apply changes to infrastructure
- Can access state for troubleshooting and analysis

### Operator Role (Read-Write)
- Can run all Terraform commands
- Can apply infrastructure changes
- Responsible for production deployments

## Workflow Process

### 1. Development Workflow
```bash
# Developer workflow
git pull origin main
terraform init
terraform plan  # Review changes only
# Create pull request for review
```

### 2. Deployment Workflow
```bash
# Operator workflow (after PR approval)
git pull origin main
terraform init
terraform plan -out=deployment.tfplan
terraform apply deployment.tfplan
```

### 3. Emergency Procedures
```bash
# Emergency state access
terraform force-unlock <LOCK_ID>  # Use with extreme caution
terraform import <resource> <id>   # Import existing resources
```

## Best Practices
1. Always run `terraform plan` before `apply`
2. Use pull requests for all infrastructure changes
3. Coordinate with team before major changes
4. Keep state backend credentials secure
5. Monitor state operations through Activity Tracker
EOF
```

### **Step 4.3: Test Team Collaboration**
```bash
# Simulate team member access
echo "=== Testing Team Collaboration ==="

# Test developer (read-only) access
export AWS_ACCESS_KEY_ID=$(terraform output -json team_access | jq -r '.developer.access_key_id')
export AWS_SECRET_ACCESS_KEY=$(terraform output -json team_access | jq -r '.developer.secret_access_key')

# Developer can plan but not apply
terraform plan
echo "Developer access tested - plan successful"

# Test operator (read-write) access
export AWS_ACCESS_KEY_ID=$(terraform output -json team_access | jq -r '.operator.access_key_id')
export AWS_SECRET_ACCESS_KEY=$(terraform output -json team_access | jq -r '.operator.secret_access_key')

# Operator can plan and apply
terraform plan
echo "Operator access tested - full access confirmed"

# Reset to original credentials
export AWS_ACCESS_KEY_ID=$(jq -r '.access_key_id' cos_credentials.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.secret_access_key' cos_credentials.json)
```

**Validation Checkpoint**: Verify team collaboration setup
- [ ] Team access credentials created for different roles
- [ ] Workflow documentation created
- [ ] Role-based access tested and verified
- [ ] Team coordination procedures established

---

## 📊 **Exercise 5: Monitoring and Backup Procedures (10 minutes)**

### **Objective**
Establish monitoring and automated backup procedures for enterprise state management.

### **Step 5.1: Configure State Monitoring**
```bash
# Create monitoring script
cat > ../scripts/state-monitor.sh << 'EOF'
#!/bin/bash
# State monitoring and health check script

echo "=== Terraform State Health Check ==="
echo "Timestamp: $(date)"

# Check backend connectivity
echo "Testing backend connectivity..."
terraform init -backend=true

# Check state integrity
echo "Checking state integrity..."
terraform plan -detailed-exitcode
PLAN_EXIT=$?

if [ $PLAN_EXIT -eq 0 ]; then
    echo "✅ State is consistent - no drift detected"
elif [ $PLAN_EXIT -eq 2 ]; then
    echo "⚠️  Configuration drift detected - review required"
    terraform plan > drift_report_$(date +%Y%m%d_%H%M%S).txt
else
    echo "❌ State check failed - investigation required"
fi

# Check state file metrics
echo "State file metrics:"
terraform state list | wc -l | xargs echo "Resources:"
terraform show -json | jq '.values.root_module.resources | length' | xargs echo "Managed resources:"

echo "Health check completed"
EOF

chmod +x ../scripts/state-monitor.sh
```

### **Step 5.2: Implement Backup Automation**
```bash
# Create backup script
cat > ../scripts/backup-state.sh << 'EOF'
#!/bin/bash
# Automated state backup script

BACKUP_DIR="../backups/automated/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "=== Automated State Backup ==="
echo "Backup directory: $BACKUP_DIR"

# Export current state
terraform show -json > "$BACKUP_DIR/terraform.tfstate.json"
terraform state pull > "$BACKUP_DIR/terraform.tfstate"

# Backup configuration files
cp *.tf "$BACKUP_DIR/"
cp terraform.tfvars "$BACKUP_DIR/" 2>/dev/null || true

# Create backup manifest
cat > "$BACKUP_DIR/backup_manifest.json" << EOL
{
  "backup_timestamp": "$(date -Iseconds)",
  "terraform_version": "$(terraform version -json | jq -r '.terraform_version')",
  "resource_count": $(terraform state list | wc -l),
  "backup_type": "automated",
  "backend_type": "s3",
  "bucket": "$BUCKET_NAME"
}
EOL

echo "✅ Backup completed: $BACKUP_DIR"
ls -la "$BACKUP_DIR"
EOF

chmod +x ../scripts/backup-state.sh
```

### **Step 5.3: Test Monitoring and Backup**
```bash
# Test monitoring script
echo "=== Testing State Monitoring ==="
../scripts/state-monitor.sh

# Test backup script
echo "=== Testing Automated Backup ==="
../scripts/backup-state.sh

# Verify backup integrity
LATEST_BACKUP=$(ls -t ../backups/automated/ | head -1)
echo "Verifying backup: $LATEST_BACKUP"
jq '.' "../backups/automated/$LATEST_BACKUP/backup_manifest.json"
```

**Validation Checkpoint**: Verify monitoring and backup procedures
- [ ] State monitoring script created and tested
- [ ] Automated backup script implemented
- [ ] Backup integrity verified
- [ ] Monitoring procedures documented

---

## 🎯 **Lab Summary and Validation**

### **Lab Completion Checklist**
- [ ] **Exercise 1**: Local state analyzed and limitations identified
- [ ] **Exercise 2**: IBM COS backend configured with enterprise features
- [ ] **Exercise 3**: State migration completed successfully with validation
- [ ] **Exercise 4**: Team collaboration workflows established
- [ ] **Exercise 5**: Monitoring and backup procedures implemented

### **Key Achievements**
1. **State Management Mastery**: Complete understanding of local vs remote state
2. **Enterprise Backend**: IBM COS configured with security and compliance features
3. **Zero-Downtime Migration**: Successful state migration with comprehensive validation
4. **Team Collaboration**: Role-based access and workflow coordination
5. **Operational Excellence**: Monitoring and backup automation

### **Cost Summary**
```bash
echo "=== Lab Cost Summary ==="
echo "IBM Cloud Object Storage: ~$5-10"
echo "Activity Tracker: ~$2-5"
echo "Service Credentials: $0"
echo "Total Estimated Cost: $7-15"
echo ""
echo "Cost optimization achieved through:"
echo "- Lite plan usage where available"
echo "- Lifecycle policies for storage optimization"
echo "- Efficient resource cleanup procedures"
```

### **Next Steps**
This lab establishes the foundation for **Lab 13: State Locking and Drift Detection**, where you will:
- Implement state locking mechanisms
- Configure automated drift detection
- Establish enterprise governance frameworks
- Deploy comprehensive monitoring and alerting

### **Cleanup Instructions**
```bash
# Optional: Clean up lab resources to minimize costs
# WARNING: This will destroy all lab infrastructure

# Backup final state before cleanup
../scripts/backup-state.sh

# Destroy infrastructure
terraform destroy -auto-approve

# Clean up local files
cd ~/terraform-state-lab
rm -rf local-state remote-state
```

**🎉 Congratulations!** You have successfully implemented enterprise-grade state management with IBM Cloud Object Storage, establishing the foundation for advanced state management capabilities in the next lab.
