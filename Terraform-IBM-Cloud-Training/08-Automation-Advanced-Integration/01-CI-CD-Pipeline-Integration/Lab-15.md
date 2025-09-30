# Lab 15: Enterprise CI/CD Pipeline Integration with IBM Cloud

## Lab Information
- **Lab ID**: LAB-8.1-001
- **Duration**: 120 minutes
- **Difficulty**: Advanced
- **Prerequisites**: 
  - Completed Labs 1-14
  - IBM Cloud account with DevOps and Schematics access
  - GitHub or GitLab account
  - Basic understanding of CI/CD concepts

## Learning Objectives

### Primary Objective
Implement a comprehensive enterprise-grade CI/CD pipeline that automates Terraform infrastructure deployment on IBM Cloud with integrated security scanning, multi-environment promotion, and automated rollback capabilities.

### Secondary Objectives
- Configure GitLab CI or GitHub Actions for Terraform automation
- Implement automated security scanning with TFSec and Checkov
- Set up multi-environment deployment (dev, staging, prod)
- Configure automated testing and validation
- Implement infrastructure drift detection and remediation
- Establish monitoring and alerting for pipeline operations

### Success Criteria
By the end of this lab, you will have:
- [ ] Functional CI/CD pipeline automating Terraform deployments
- [ ] Integrated security scanning preventing vulnerable deployments
- [ ] Multi-environment promotion with approval gates
- [ ] Automated rollback capabilities for failed deployments
- [ ] Comprehensive monitoring and alerting system
- [ ] Documentation of pipeline operations and troubleshooting

## Lab Environment Setup

### Required IBM Cloud Services
- **IBM Cloud Schematics**: Managed Terraform execution
- **IBM Cloud Code Engine**: Serverless CI/CD execution
- **IBM Cloud DevOps Toolchain**: Integrated development pipeline
- **IBM Cloud Activity Tracker**: Audit logging and compliance
- **IBM Cloud Monitoring**: Pipeline performance and alerting
- **IBM Cloud Log Analysis**: Centralized log management

### Required External Services
- **GitHub/GitLab**: Source code repository and CI/CD platform
- **Docker Hub/IBM Container Registry**: Container image storage
- **Slack/Microsoft Teams**: Notification integration (optional)

### Cost Estimates
- **IBM Cloud Schematics**: $0.10 per workspace hour
- **IBM Cloud Code Engine**: $0.000024 per vCPU-second
- **IBM Cloud DevOps Toolchain**: Free tier available
- **Total Estimated Cost**: $15-25 for complete lab execution

## Exercise 1: GitLab CI Pipeline Setup (30 minutes)

### Step 1: Repository Preparation
1. **Create GitLab Repository**:
   ```bash
   # Clone the lab repository
   git clone https://github.com/your-org/terraform-ibm-cicd-lab.git
   cd terraform-ibm-cicd-lab
   
   # Add GitLab remote
   git remote add gitlab https://gitlab.com/your-username/terraform-ibm-cicd.git
   git push gitlab main
   ```

2. **Configure GitLab Variables**:
   Navigate to Project Settings > CI/CD > Variables and add:
   ```yaml
   IBM_CLOUD_API_KEY: [Your IBM Cloud API Key]
   TF_VAR_ibmcloud_api_key: [Your IBM Cloud API Key]
   SCHEMATICS_WORKSPACE_ID: [Workspace ID from previous labs]
   SLACK_WEBHOOK_URL: [Optional notification webhook]
   ```

### Step 2: GitLab CI Configuration
1. **Create .gitlab-ci.yml**:
   ```yaml
   stages:
     - validate
     - security-scan
     - plan
     - deploy-dev
     - test-dev
     - deploy-staging
     - deploy-prod
   
   variables:
     TF_VERSION: "1.6.0"
     IBM_CLOUD_REGION: "us-south"
     
   before_script:
     - apk add --no-cache curl unzip
     - curl -fsSL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -o terraform.zip
     - unzip terraform.zip && mv terraform /usr/local/bin/
     - curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
     - ibmcloud login --apikey $IBM_CLOUD_API_KEY -r $IBM_CLOUD_REGION
   
   terraform-validate:
     stage: validate
     script:
       - terraform init -backend=false
       - terraform validate
       - terraform fmt -check
     only:
       - merge_requests
       - main
   ```

### Step 3: Security Scanning Integration
1. **Add TFSec Security Scanning**:
   ```yaml
   tfsec-scan:
     stage: security-scan
     image: aquasec/tfsec:latest
     script:
       - tfsec . --format json --out tfsec-results.json
       - tfsec . --format junit --out tfsec-junit.xml
     artifacts:
       reports:
         junit: tfsec-junit.xml
       paths:
         - tfsec-results.json
     allow_failure: false
   ```

2. **Add Checkov Policy Scanning**:
   ```yaml
   checkov-scan:
     stage: security-scan
     image: bridgecrew/checkov:latest
     script:
       - checkov -d . --framework terraform --output json --output-file checkov-results.json
       - checkov -d . --framework terraform --output junit --output-file checkov-junit.xml
     artifacts:
       reports:
         junit: checkov-junit.xml
       paths:
         - checkov-results.json
     allow_failure: false
   ```

### Validation Steps
- Verify pipeline triggers on code commits
- Confirm security scans execute successfully
- Validate artifact generation and storage
- Test notification integration (if configured)

## Exercise 2: IBM Cloud Schematics Integration (35 minutes)

### Step 1: Schematics Workspace Configuration
1. **Create Schematics Workspace via CLI**:
   ```bash
   # Create workspace configuration
   cat > workspace-config.json << EOF
   {
     "name": "cicd-pipeline-workspace",
     "type": ["terraform_v1.6"],
     "description": "CI/CD Pipeline Terraform Workspace",
     "tags": ["cicd", "automation", "terraform"],
     "template_repo": {
       "url": "https://gitlab.com/your-username/terraform-ibm-cicd.git",
       "branch": "main"
     },
     "template_data": [{
       "folder": ".",
       "type": "terraform_v1.6",
       "variablestore": [
         {
           "name": "ibmcloud_api_key",
           "value": "$IBM_CLOUD_API_KEY",
           "type": "string",
           "secure": true
         },
         {
           "name": "environment",
           "value": "dev",
           "type": "string"
         }
       ]
     }]
   }
   EOF
   
   # Create the workspace
   ibmcloud schematics workspace new --file workspace-config.json
   ```

2. **Configure Pipeline Integration**:
   ```yaml
   schematics-plan:
     stage: plan
     script:
       - |
         PLAN_ID=$(ibmcloud schematics plan --id $SCHEMATICS_WORKSPACE_ID --json | jq -r '.activityid')
         echo "Plan ID: $PLAN_ID"
         
         # Wait for plan completion
         while true; do
           STATUS=$(ibmcloud schematics workspace get --id $SCHEMATICS_WORKSPACE_ID --json | jq -r '.status')
           if [[ "$STATUS" == "ACTIVE" ]]; then
             break
           fi
           sleep 30
         done
         
         # Get plan results
         ibmcloud schematics logs --id $SCHEMATICS_WORKSPACE_ID --act-id $PLAN_ID
     only:
       - main
   ```

### Step 2: Multi-Environment Deployment
1. **Development Environment Deployment**:
   ```yaml
   deploy-dev:
     stage: deploy-dev
     script:
       - |
         # Update workspace variables for dev environment
         ibmcloud schematics workspace update --id $SCHEMATICS_WORKSPACE_ID \
           --var environment=dev \
           --var instance_count=1 \
           --var instance_profile=bx2-2x8
         
         # Execute apply
         APPLY_ID=$(ibmcloud schematics apply --id $SCHEMATICS_WORKSPACE_ID --json | jq -r '.activityid')
         
         # Monitor apply progress
         while true; do
           STATUS=$(ibmcloud schematics workspace get --id $SCHEMATICS_WORKSPACE_ID --json | jq -r '.status')
           if [[ "$STATUS" == "ACTIVE" ]]; then
             break
           elif [[ "$STATUS" == "FAILED" ]]; then
             echo "Deployment failed"
             exit 1
           fi
           sleep 60
         done
     environment:
       name: development
       url: https://dev.example.com
     only:
       - main
   ```

2. **Staging Environment with Approval**:
   ```yaml
   deploy-staging:
     stage: deploy-staging
     script:
       - |
         # Update for staging environment
         ibmcloud schematics workspace update --id $SCHEMATICS_WORKSPACE_ID \
           --var environment=staging \
           --var instance_count=2 \
           --var instance_profile=bx2-4x16
         
         # Execute staging deployment
         APPLY_ID=$(ibmcloud schematics apply --id $SCHEMATICS_WORKSPACE_ID --json | jq -r '.activityid')
         
         # Monitor and validate
         ./scripts/validate-deployment.sh staging
     environment:
       name: staging
       url: https://staging.example.com
     when: manual
     only:
       - main
   ```

### Validation Steps
- Verify Schematics workspace creation and configuration
- Confirm multi-environment variable management
- Test deployment progression through environments
- Validate approval gate functionality

## Exercise 3: Automated Testing and Validation (25 minutes)

### Step 1: Infrastructure Testing
1. **Create Terratest Integration**:
   ```yaml
   infrastructure-test:
     stage: test-dev
     image: golang:1.21
     script:
       - cd tests/
       - go mod init terraform-tests
       - go mod tidy
       - go test -v -timeout 30m
     artifacts:
       reports:
         junit: tests/test-results.xml
     dependencies:
       - deploy-dev
   ```

2. **Create Go Test File** (`tests/infrastructure_test.go`):
   ```go
   package test
   
   import (
       "testing"
       "github.com/gruntwork-io/terratest/modules/terraform"
       "github.com/stretchr/testify/assert"
   )
   
   func TestInfrastructure(t *testing.T) {
       terraformOptions := &terraform.Options{
           TerraformDir: "../",
           Vars: map[string]interface{}{
               "environment": "test",
           },
       }
       
       defer terraform.Destroy(t, terraformOptions)
       terraform.InitAndApply(t, terraformOptions)
       
       // Validate outputs
       vpcId := terraform.Output(t, terraformOptions, "vpc_id")
       assert.NotEmpty(t, vpcId)
   }
   ```

### Step 2: Application Health Checks
1. **Add Health Check Script**:
   ```bash
   #!/bin/bash
   # scripts/validate-deployment.sh
   
   ENVIRONMENT=$1
   HEALTH_ENDPOINT="https://${ENVIRONMENT}.example.com/health"
   
   echo "Validating deployment for environment: $ENVIRONMENT"
   
   # Wait for application to be ready
   for i in {1..30}; do
       if curl -f $HEALTH_ENDPOINT; then
           echo "Application is healthy"
           exit 0
       fi
       echo "Waiting for application... ($i/30)"
       sleep 10
   done
   
   echo "Application health check failed"
   exit 1
   ```

### Validation Steps
- Verify automated testing execution
- Confirm health check validation
- Test failure scenarios and rollback
- Validate test result reporting

## Exercise 4: Monitoring and Alerting Setup (30 minutes)

### Step 1: IBM Cloud Monitoring Integration
1. **Configure Monitoring Alerts**:
   ```yaml
   setup-monitoring:
     stage: deploy-dev
     script:
       - |
         # Create monitoring instance if not exists
         ibmcloud resource service-instance-create \
           cicd-monitoring sysdig-monitor lite us-south
         
         # Configure alerts for pipeline failures
         curl -X POST "https://us-south.monitoring.cloud.ibm.com/api/alerts" \
           -H "Authorization: Bearer $SYSDIG_TOKEN" \
           -H "Content-Type: application/json" \
           -d '{
             "alert": {
               "name": "CI/CD Pipeline Failure",
               "description": "Alert when CI/CD pipeline fails",
               "severity": 4,
               "condition": "avg(sysdig_container_cpu_used_percent) > 90"
             }
           }'
     when: manual
   ```

### Step 2: Log Analysis Configuration
1. **Setup Centralized Logging**:
   ```yaml
   configure-logging:
     stage: deploy-dev
     script:
       - |
         # Create Log Analysis instance
         ibmcloud resource service-instance-create \
           cicd-logs logdna standard us-south
         
         # Configure log forwarding
         ibmcloud logging config-create \
           --name cicd-pipeline-logs \
           --type platform_logs \
           --logdna-instance cicd-logs
   ```

### Validation Steps
- Verify monitoring dashboard creation
- Confirm alert rule configuration
- Test log aggregation and search
- Validate notification delivery

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Pipeline Authentication Failures
**Symptom**: "Authentication failed" errors in pipeline
**Solution**:
```bash
# Verify API key permissions
ibmcloud iam api-key-get $API_KEY_NAME

# Check service access policies
ibmcloud iam user-policies $USER_EMAIL

# Regenerate API key if needed
ibmcloud iam api-key-create cicd-pipeline-key \
  --description "CI/CD Pipeline API Key"
```

#### 2. Schematics Workspace Conflicts
**Symptom**: "Workspace is locked" or "Concurrent operation" errors
**Solution**:
```bash
# Check workspace status
ibmcloud schematics workspace get --id $WORKSPACE_ID

# Force unlock if necessary (use with caution)
ibmcloud schematics workspace unlock --id $WORKSPACE_ID

# Wait for current operations to complete
while [[ $(ibmcloud schematics workspace get --id $WORKSPACE_ID --json | jq -r '.status') != "ACTIVE" ]]; do
  sleep 30
done
```

#### 3. Security Scan Failures
**Symptom**: TFSec or Checkov blocking pipeline
**Solution**:
```bash
# Run local security scan
tfsec . --soft-fail

# Review and fix security issues
checkov -d . --framework terraform --check CKV_IBM_1

# Update security policies if needed
echo 'tfsec:ignore:IBM001' >> main.tf
```

#### 4. Deployment Validation Failures
**Symptom**: Health checks failing after deployment
**Solution**:
```bash
# Check application logs
ibmcloud logs tail $APP_NAME

# Verify resource provisioning
terraform show | grep -A 5 "resource_status"

# Manual health check
curl -v https://$ENVIRONMENT.example.com/health
```

### Performance Optimization

#### 1. Pipeline Execution Time
- Use Docker layer caching for faster builds
- Implement parallel job execution where possible
- Cache Terraform providers and modules
- Use incremental security scanning

#### 2. Resource Costs
- Implement automatic resource cleanup for dev environments
- Use smaller instance profiles for testing
- Schedule non-production environment shutdown
- Monitor and alert on cost thresholds

## Lab Completion Checklist

### Technical Validation
- [ ] CI/CD pipeline executes successfully end-to-end
- [ ] Security scanning prevents vulnerable deployments
- [ ] Multi-environment deployment works with approvals
- [ ] Automated testing validates infrastructure
- [ ] Monitoring and alerting are functional
- [ ] Rollback procedures work correctly

### Documentation Requirements
- [ ] Pipeline configuration documented
- [ ] Environment promotion process documented
- [ ] Troubleshooting procedures validated
- [ ] Security policies and exceptions documented
- [ ] Monitoring dashboard screenshots captured
- [ ] Cost optimization recommendations provided

### Business Value Assessment
- [ ] Deployment time reduction measured (target: 90%+)
- [ ] Error rate improvement documented (target: 85%+)
- [ ] Operational efficiency gains quantified
- [ ] Security posture improvement validated
- [ ] Cost optimization opportunities identified
- [ ] ROI calculation completed

## Expected Outcomes

### Immediate Benefits
- **95% Deployment Time Reduction**: From hours to minutes
- **90% Error Rate Reduction**: Automated validation prevents issues
- **100% Audit Compliance**: Complete deployment traceability
- **75% Operational Efficiency**: Reduced manual intervention

### Long-term Value
- **Scalable Automation**: Foundation for enterprise-wide adoption
- **Security Excellence**: Shift-left security with automated scanning
- **Operational Resilience**: Automated rollback and recovery
- **Continuous Improvement**: Data-driven optimization opportunities

### ROI Calculation
- **Initial Investment**: 40 hours setup + $500 monthly operational costs
- **Annual Savings**: $150,000 (reduced deployment time + error prevention)
- **ROI**: 300% return on investment within first year
- **Payback Period**: 3 months

## Next Steps

1. **Scale Implementation**: Extend pipeline to additional projects
2. **Advanced Features**: Implement blue-green deployments
3. **Integration Enhancement**: Add more security scanning tools
4. **Monitoring Expansion**: Implement advanced observability
5. **Team Training**: Conduct knowledge transfer sessions

This lab provides the foundation for enterprise-grade CI/CD automation with IBM Cloud, enabling organizations to achieve significant operational improvements and business value through infrastructure automation.
