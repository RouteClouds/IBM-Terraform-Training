# Git Collaboration Lab 5.3 - Version Control and Collaboration with Git

## 🎯 **Overview**

This comprehensive Terraform configuration demonstrates enterprise Git workflows and team collaboration patterns for IBM Cloud infrastructure management. The lab provides hands-on experience with GitFlow, GitHub Flow, GitLab Flow, and trunk-based development patterns while implementing robust CI/CD pipelines, security scanning, cost management, and policy enforcement.

## 📋 **Prerequisites**

### Required Tools
- **Terraform** >= 1.5.0
- **IBM Cloud CLI** with VPC plugin
- **Git** >= 2.30.0
- **GitHub CLI** (gh) for workflow automation
- **jq** for JSON processing
- **curl** for API interactions

### Optional Security Tools
- **tfsec** for Terraform security scanning
- **Checkov** for infrastructure security analysis
- **Terrascan** for policy validation
- **Infracost** for cost analysis
- **OPA/Conftest** for policy as code

### IBM Cloud Requirements
- Valid IBM Cloud account with appropriate permissions
- API key with VPC infrastructure access
- Resource group access (or use default)
- Sufficient quota for VPC resources

## 🏗️ **Architecture Overview**

This lab creates a comprehensive Git collaboration environment including:

### Infrastructure Components
- **VPC** with multi-zone subnets (web, app, data tiers)
- **Security Groups** with role-based access rules
- **Virtual Server Instances** for development environments
- **Cloud Object Storage** for Terraform state management
- **Activity Tracker** for audit logging and compliance
- **SSH Key Management** for secure team access

### Git Workflow Patterns
- **GitFlow**: Feature → Develop → Release → Main
- **GitHub Flow**: Feature → Main (with PR reviews)
- **GitLab Flow**: Environment-based branching
- **Trunk-based**: Short-lived feature branches

### Team Collaboration Features
- **Role-Based Access Control (RBAC)** with 4 predefined roles
- **Multi-team Configuration** supporting 4+ teams
- **Approval Workflows** with automated review requirements
- **Branch Protection Rules** with status checks
- **CODEOWNERS** integration for code review governance

## 📁 **Project Structure**

```
Terraform-Code-Lab-5.3/
├── README.md                    # This comprehensive guide
├── providers.tf                 # Provider configuration with multi-region support
├── variables.tf                 # 15+ comprehensive variables with validation
├── main.tf                      # Core infrastructure configuration
├── outputs.tf                   # 10+ structured outputs for integration
├── terraform.tfvars.example     # Complete example configuration
├── scripts/                     # Automation and validation scripts
│   ├── deploy.sh               # Automated deployment with Git workflow integration
│   ├── validate.sh             # Comprehensive validation (Terraform, Git, Security)
│   ├── team-setup.sh           # Team collaboration setup automation
│   └── cleanup.sh              # Resource cleanup and state management
├── templates/                   # Configuration templates
│   ├── user-data.sh            # Instance initialization script
│   ├── github-workflow.yml     # GitHub Actions CI/CD template
│   ├── gitlab-ci.yml           # GitLab CI/CD template
│   └── pre-commit-config.yaml  # Pre-commit hooks configuration
├── workflows/                   # Git workflow configurations
│   ├── gitflow/                # GitFlow specific configurations
│   ├── github-flow/            # GitHub Flow configurations
│   ├── gitlab-flow/            # GitLab Flow configurations
│   └── trunk-based/            # Trunk-based development configurations
├── modules/                     # Reusable Terraform modules
│   ├── vpc/                    # VPC module with security groups
│   ├── compute/                # Compute instances with team configuration
│   └── monitoring/             # Monitoring and logging module
└── generated/                   # Generated files (SSH keys, reports)
    ├── ssh-keys/               # Generated SSH key pairs
    ├── reports/                # Validation and cost reports
    └── outputs/                # Terraform outputs and state information
```

## 🚀 **Quick Start Guide**

### 1. Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd Terraform-Code-Lab-5.3

# Copy and customize configuration
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Edit with your specific values

# Set IBM Cloud API key
export IBMCLOUD_API_KEY="your-api-key-here"
# OR
export TF_VAR_ibmcloud_api_key="your-api-key-here"
```

### 2. Configuration Customization

Edit `terraform.tfvars` to match your environment:

```hcl
# Organization configuration
organization_config = {
  name         = "YourCompany"
  environment  = "development"  # development, staging, production
  cost_center  = "CC-ENG-001"
  # ... other settings
}

# Git workflow selection
git_workflow_config = {
  workflow_pattern = "gitflow"  # gitflow, github-flow, gitlab-flow, trunk-based
  # ... workflow-specific settings
}

# Team configuration
team_configuration = {
  teams = {
    platform-team = {
      name = "Platform Team"
      lead = "platform-lead@company.com"
      members = ["dev1@company.com", "dev2@company.com"]
      # ... team settings
    }
    # ... additional teams
  }
}
```

### 3. Validation and Deployment

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run comprehensive validation
./scripts/validate.sh

# Deploy infrastructure (dry run first)
./scripts/deploy.sh --dry-run --environment development

# Deploy for real
./scripts/deploy.sh --environment development --workflow gitflow
```

## 🔧 **Configuration Reference**

### Core Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `ibmcloud_api_key` | string | IBM Cloud API key (sensitive) | Required |
| `organization_config` | object | Organization and project settings | See example |
| `team_configuration` | object | Team structure and RBAC | See example |
| `git_workflow_config` | object | Git workflow pattern settings | gitflow |
| `cicd_pipeline_config` | object | CI/CD pipeline configuration | See example |
| `security_config` | object | Security and compliance settings | See example |
| `regional_configuration` | object | Multi-region deployment settings | us-south |
| `cost_configuration` | object | Cost management and budgets | $1000/month |
| `infrastructure_config` | object | VPC and compute configuration | See example |
| `feature_flags` | object | Feature toggles and experiments | See example |

### Git Workflow Patterns

#### GitFlow Configuration
```hcl
git_workflow_config = {
  workflow_pattern = "gitflow"
  branch_protection = {
    main_branch = {
      required_status_checks = ["terraform-validate", "security-scan"]
      required_reviewers = 2
      enforce_admins = true
    }
    develop_branch = {
      required_reviewers = 1
    }
  }
}
```

#### GitHub Flow Configuration
```hcl
git_workflow_config = {
  workflow_pattern = "github-flow"
  merge_policies = {
    default_merge_method = "squash"
    auto_merge_enabled = false
  }
}
```

### Team Configuration Examples

#### Platform Team (Admin Role)
```hcl
platform-team = {
  name = "Platform Team"
  description = "Infrastructure platform and shared services"
  lead = "platform-lead@company.com"
  members = ["dev1@company.com", "dev2@company.com"]
  repositories = ["*"]
  permissions = ["admin", "write", "read"]
  environments = ["development", "staging", "production"]
}
```

#### Development Team (Standard Role)
```hcl
web-team = {
  name = "Web Team"
  description = "Frontend applications and web services"
  lead = "web-lead@company.com"
  members = ["frontend1@company.com", "frontend2@company.com"]
  repositories = ["web-infrastructure", "frontend-services"]
  permissions = ["write", "read"]
  environments = ["development", "staging"]
}
```

## 🔐 **Security Configuration**

### Policy as Code
```hcl
security_config = {
  policy_as_code = {
    enabled = true
    frameworks = ["opa", "sentinel", "conftest"]
    enforcement_level = "enforcing"  # advisory, enforcing, blocking
  }
  
  secrets_management = {
    vault_integration = true
    pre_commit_hooks = true
    secret_scanning = true
  }
  
  compliance = {
    frameworks = ["SOC2", "ISO27001", "PCI-DSS"]
    audit_logging = true
    automated_remediation = false
  }
}
```

### Security Scanning Tools
- **tfsec**: Terraform security scanner
- **Checkov**: Infrastructure security analysis
- **Terrascan**: Policy validation
- **Pre-commit hooks**: Prevent sensitive data commits

## 💰 **Cost Management**

### Budget Configuration
```hcl
cost_configuration = {
  monthly_budget_limit = 1000.00
  cost_alerts = {
    enabled = true
    thresholds = [50.0, 75.0, 90.0, 100.0]
    notification_channels = ["email", "slack"]
  }
  
  optimization = {
    auto_scaling_enabled = true
    scheduled_shutdown = true
    right_sizing_enabled = true
  }
}
```

### Cost Analysis Tools
- **Infracost**: Automated cost estimation
- **Budget alerts**: Proactive cost monitoring
- **Resource tagging**: Cost allocation tracking
- **Optimization recommendations**: Right-sizing suggestions

## 🔄 **CI/CD Pipeline Integration**

### GitHub Actions Workflow
```yaml
name: Terraform CI/CD
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Terraform Validate
      run: terraform validate
    - name: Security Scan
      run: tfsec .
    - name: Cost Analysis
      run: infracost breakdown --path .
```

### Required Secrets
- `IBMCLOUD_API_KEY`: IBM Cloud authentication
- `INFRACOST_API_KEY`: Cost analysis integration
- `SLACK_WEBHOOK`: Notification integration

## 📊 **Monitoring and Observability**

### Activity Tracker Integration
```hcl
infrastructure_config = {
  monitoring = {
    enable_activity_tracker = true
    log_retention_days = 30
    alerting = {
      enabled = true
      alert_thresholds = {
        "cpu_utilization" = 80.0
        "memory_utilization" = 85.0
      }
    }
  }
}
```

### Monitoring Features
- **Activity Tracker**: Audit logging for compliance
- **Resource monitoring**: CPU, memory, disk utilization
- **Cost tracking**: Real-time cost monitoring
- **Security alerts**: Automated security incident detection

## 🧪 **Testing and Validation**

### Automated Testing
```bash
# Run all validations
./scripts/validate.sh

# Run specific validations
./scripts/validate.sh --terraform --security
./scripts/validate.sh --no-cost --no-policy

# Verbose output with fail-fast
./scripts/validate.sh --verbose --fail-fast
```

### Validation Categories
- **Terraform**: Syntax, formatting, best practices
- **Git**: Repository structure, workflow compliance
- **Security**: Vulnerability scanning, policy validation
- **Cost**: Budget compliance, optimization opportunities
- **Policy**: Compliance framework adherence

## 🚀 **Deployment Strategies**

### Environment-Specific Deployment
```bash
# Development environment
./scripts/deploy.sh --environment development --workflow gitflow

# Staging environment with approval
./scripts/deploy.sh --environment staging --workflow gitflow --auto-approve

# Production deployment with full validation
./scripts/deploy.sh --environment production --workflow gitflow --verbose
```

### Deployment Features
- **Multi-environment support**: dev, staging, production
- **Workflow integration**: Git branch validation
- **Security scanning**: Pre-deployment security checks
- **Cost validation**: Budget compliance verification
- **Rollback capability**: Automated rollback on failure

## 📈 **Scaling and Optimization**

### Auto-scaling Configuration
```hcl
feature_flags = {
  enable_cost_optimization = true
  enable_resource_scheduling = true
  enable_automated_rollbacks = true
}

environment_overrides = {
  production = {
    instance_count_override = 3
    instance_profile_override = "bx2-8x32"
    security_level_override = "enterprise"
  }
}
```

### Performance Optimization
- **Instance right-sizing**: Automatic profile optimization
- **Scheduled operations**: Cost-effective resource scheduling
- **Multi-region deployment**: High availability and disaster recovery
- **Load balancing**: Traffic distribution across zones

## 🔧 **Troubleshooting Guide**

### Common Issues

#### Authentication Problems
```bash
# Verify IBM Cloud CLI authentication
ibmcloud auth

# Check API key permissions
ibmcloud iam api-keys

# Test Terraform provider authentication
terraform plan
```

#### Validation Failures
```bash
# Check Terraform formatting
terraform fmt -check=true -diff=true

# Validate configuration
terraform validate

# Run security scan
tfsec .

# Check cost analysis
infracost breakdown --path .
```

#### Git Workflow Issues
```bash
# Check current branch and status
git status
git branch -a

# Verify workflow pattern compliance
./scripts/validate.sh --git

# Check pre-commit hooks
pre-commit run --all-files
```

### Debug Mode
```bash
# Enable verbose logging
export TF_LOG=DEBUG
export VERBOSE=true

# Run deployment with debug output
./scripts/deploy.sh --verbose --environment development
```

## 📚 **Additional Resources**

### Documentation Links
- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)
- [Terraform IBM Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [GitFlow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [GitLab Flow](https://docs.gitlab.com/ee/topics/gitlab_flow.html)

### Best Practices
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Git Workflow Best Practices](https://www.atlassian.com/git/tutorials/comparing-workflows)
- [Infrastructure Security](https://cloud.ibm.com/docs/security)
- [Cost Optimization](https://cloud.ibm.com/docs/billing-usage)

## 🤝 **Contributing**

### Development Workflow
1. Fork the repository
2. Create feature branch following naming convention
3. Make changes with comprehensive testing
4. Run validation suite: `./scripts/validate.sh`
5. Submit pull request with detailed description
6. Address review feedback and security scans

### Code Standards
- Follow Terraform formatting: `terraform fmt`
- Include comprehensive variable descriptions
- Add validation rules for all variables
- Document all outputs with descriptions
- Include security and cost considerations

## 📄 **License**

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 **Support**

For support and questions:
- Create an issue in the repository
- Contact the platform team: platform-team@company.com
- Review troubleshooting guide above
- Check IBM Cloud documentation

---

**Happy Infrastructure Coding! 🚀**
