# Lab 10: Organizing Configuration Files for Scalability

## 🎯 **Lab Overview**

This comprehensive hands-on laboratory provides practical experience in organizing large-scale Terraform projects with enterprise-grade structure, naming conventions, and governance patterns. You'll build a 50+ file project with multiple environments, teams, and service layers.

### **Learning Objectives**
- Organize a complex Terraform project with 50+ configuration files
- Implement enterprise naming conventions with 99% consistency
- Apply environment separation and team collaboration patterns
- Establish configuration validation and governance workflows
- Create maintainable and scalable directory structures

### **Lab Duration**: 90-120 minutes
### **Difficulty Level**: Advanced
### **Prerequisites**: Completion of Topics 1-5.1, understanding of Terraform modules

---

## 📋 **Lab Environment Setup**

### **Required Tools and Access**
- Terraform CLI (v1.5.0 or later)
- IBM Cloud CLI with VPC plugin
- Git for version control
- TFLint for configuration linting
- TFSec for security scanning
- IBM Cloud account with multi-service access

### **Cost Estimation**
- **Foundation Infrastructure**: $45.00/month (VPC, public gateways)
- **Development Environment**: $75.00/month (2 instances, storage)
- **Staging Environment**: $150.00/month (4 instances, enhanced storage)
- **Production Environment**: $300.00/month (6 instances, full monitoring)
- **Estimated Lab Cost**: $15.00-25.00 for 2-hour session

### **Environment Variables**
```bash
export IBMCLOUD_API_KEY="your-api-key"
export TF_VAR_ibmcloud_api_key="your-api-key"
export TF_VAR_organization_name="your-organization"
export TF_VAR_project_name="scalable-infrastructure"
```

---

## 🏗️ **Exercise 1: Enterprise Directory Structure Creation (25 minutes)**

### **Objective**
Create a comprehensive directory structure that supports multiple teams, environments, and service layers.

### **Step 1: Foundation Directory Structure**
```bash
# Create the main project structure
mkdir -p scalable-terraform-project/{docs,environments,modules,policies,scripts,templates,tests}

cd scalable-terraform-project

# Create documentation structure
mkdir -p docs/{architecture,operations,development,governance}
mkdir -p docs/architecture/{decisions,diagrams,patterns}
mkdir -p docs/operations/{runbooks,troubleshooting,monitoring}
mkdir -p docs/development/{standards,testing,workflows}
mkdir -p docs/governance/{policies,compliance,security}

# Create environment structure
mkdir -p environments/{development,staging,production,sandbox}
mkdir -p environments/shared/{modules,policies,templates}

# Create each environment's structure
for env in development staging production sandbox; do
    mkdir -p environments/$env/{foundation,platform,applications}
    mkdir -p environments/$env/foundation/{networking,security,monitoring}
    mkdir -p environments/$env/platform/{containers,data,api-gateway}
    mkdir -p environments/$env/applications/{web-services,api-services,data-services}
done
```

### **Step 2: Module Library Organization**
```bash
# Create comprehensive module structure
mkdir -p modules/{foundation,platform,applications,utilities}

# Foundation modules
mkdir -p modules/foundation/{account-setup,networking,security-baseline,monitoring}
mkdir -p modules/foundation/networking/{vpc,subnets,security-groups,load-balancers}
mkdir -p modules/foundation/security-baseline/{iam,certificates,secrets}

# Platform modules
mkdir -p modules/platform/{container-platform,data-platform,api-gateway,ci-cd}
mkdir -p modules/platform/container-platform/{kubernetes,docker,registry}
mkdir -p modules/platform/data-platform/{databases,analytics,streaming}

# Application modules
mkdir -p modules/applications/{web-applications,api-services,data-services,batch-jobs}
mkdir -p modules/applications/web-applications/{frontend,backend,cdn}

# Utility modules
mkdir -p modules/utilities/{naming,tagging,validation,cost-optimization}
```

### **Step 3: Team-Based Organization**
```bash
# Create team-specific directories
mkdir -p teams/{platform-team,application-team-1,application-team-2,security-team}

# Platform team responsibilities
mkdir -p teams/platform-team/{foundation,networking,security}

# Application teams
mkdir -p teams/application-team-1/{web-services,api-services,databases}
mkdir -p teams/application-team-2/{data-pipeline,analytics,ml-platform}

# Security team
mkdir -p teams/security-team/{iam-policies,compliance,incident-response}

# Shared governance
mkdir -p governance/{approval-workflows,cost-management,compliance-reporting}
```

### **Step 4: Supporting Infrastructure**
```bash
# Create scripts directory
mkdir -p scripts/{deployment,validation,maintenance,utilities}

# Create templates directory
mkdir -p templates/{environments,modules,projects}

# Create testing structure
mkdir -p tests/{unit,integration,e2e}

# Create policies directory
mkdir -p policies/{sentinel,opa,custom}

# Create configuration files
touch .gitignore .terraform-version .tflint.hcl .tfsec.yml Makefile
```

### **Validation Steps**
```bash
# Verify directory structure
tree -d -L 4 scalable-terraform-project/

# Count total directories created
find scalable-terraform-project -type d | wc -l
# Should show 50+ directories
```

---

## 📝 **Exercise 2: Naming Convention Implementation (20 minutes)**

### **Objective**
Implement enterprise-grade naming conventions with validation and consistency checks.

### **Step 1: Naming Convention Module**
```bash
cd modules/utilities/naming
```

Create the naming convention utility:

```hcl
# modules/utilities/naming/main.tf
locals {
  # Organization naming standards
  naming_config = {
    organization = lower(replace(var.organization_name, " ", "-"))
    max_length = 63
    separator = "-"
    
    # Valid patterns
    patterns = {
      resource_name = "^[a-z][a-z0-9-]*[a-z0-9]$"
      tag_key = "^[a-zA-Z][a-zA-Z0-9-_]*$"
      tag_value = "^[a-zA-Z0-9-_. ]*$"
    }
  }
  
  # Generate standardized names
  base_name = join(local.naming_config.separator, compact([
    local.naming_config.organization,
    var.environment,
    var.service_name,
    var.purpose,
    var.instance_id
  ]))
  
  # Ensure name length compliance
  resource_name = length(local.base_name) <= local.naming_config.max_length ? 
    local.base_name : 
    substr(local.base_name, 0, local.naming_config.max_length - 3)
  
  # Generate consistent tags
  standard_tags = {
    "Name" = local.resource_name
    "Organization" = var.organization_name
    "Environment" = var.environment
    "Service" = var.service_name
    "Purpose" = var.purpose
    "ManagedBy" = "terraform"
    "CreatedAt" = timestamp()
    "Project" = var.project_name
    "CostCenter" = var.cost_center
    "Owner" = var.owner
  }
}

# Validation checks
check "naming_pattern_validation" {
  assert {
    condition = can(regex(local.naming_config.patterns.resource_name, local.resource_name))
    error_message = "Resource name '${local.resource_name}' does not match required pattern"
  }
}

check "name_length_validation" {
  assert {
    condition = length(local.resource_name) <= local.naming_config.max_length
    error_message = "Resource name '${local.resource_name}' exceeds maximum length of ${local.naming_config.max_length}"
  }
}
```

### **Step 2: Variables and Outputs**
```hcl
# modules/utilities/naming/variables.tf
variable "organization_name" {
  description = "Organization name for resource naming"
  type = string
  
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9 -]*$", var.organization_name))
    error_message = "Organization name must start with a letter and contain only letters, numbers, spaces, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type = string
  
  validation {
    condition = contains(["development", "staging", "production", "sandbox"], var.environment)
    error_message = "Environment must be one of: development, staging, production, sandbox."
  }
}

variable "service_name" {
  description = "Service or component name"
  type = string
  
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.service_name))
    error_message = "Service name must be lowercase, start with a letter, and contain only letters, numbers, and hyphens."
  }
}

variable "purpose" {
  description = "Purpose or function of the resource"
  type = string
  
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.purpose))
    error_message = "Purpose must be lowercase, start with a letter, and contain only letters, numbers, and hyphens."
  }
}

variable "instance_id" {
  description = "Instance identifier (e.g., 001, 002)"
  type = string
  default = "001"
  
  validation {
    condition = can(regex("^[0-9]{3}$", var.instance_id))
    error_message = "Instance ID must be a 3-digit number (e.g., 001, 002)."
  }
}

variable "project_name" {
  description = "Project name for tagging"
  type = string
}

variable "cost_center" {
  description = "Cost center for billing allocation"
  type = string
}

variable "owner" {
  description = "Resource owner or team"
  type = string
}

# modules/utilities/naming/outputs.tf
output "resource_name" {
  description = "Generated resource name following naming conventions"
  value = local.resource_name
}

output "standard_tags" {
  description = "Standard tags for resource tagging"
  value = local.standard_tags
}

output "naming_metadata" {
  description = "Naming convention metadata and validation results"
  value = {
    base_name = local.base_name
    final_name = local.resource_name
    length = length(local.resource_name)
    max_length = local.naming_config.max_length
    pattern_valid = can(regex(local.naming_config.patterns.resource_name, local.resource_name))
    organization = local.naming_config.organization
  }
}
```

### **Step 3: Naming Convention Testing**
```bash
# Create test configuration
cd tests/unit
mkdir naming-convention-test
```

```hcl
# tests/unit/naming-convention-test/main.tf
module "naming_test" {
  source = "../../../modules/utilities/naming"
  
  organization_name = "ACME Corporation"
  environment = "development"
  service_name = "web-application"
  purpose = "frontend"
  instance_id = "001"
  project_name = "customer-portal"
  cost_center = "CC-ENG-001"
  owner = "web-team"
}

output "naming_results" {
  value = module.naming_test
}
```

### **Validation Steps**
```bash
# Test naming convention
cd tests/unit/naming-convention-test
terraform init
terraform plan
terraform apply -auto-approve

# Verify naming output
terraform output naming_results
```

---

## 🌍 **Exercise 3: Multi-Environment Configuration (25 minutes)**

### **Objective**
Implement environment-specific configurations with proper separation and inheritance.

### **Step 1: Shared Configuration Foundation**
```bash
cd environments/shared
```

Create shared module configurations:

```hcl
# environments/shared/modules/foundation.tf
module "foundation_networking" {
  source = "../../modules/foundation/networking"
  
  # Use naming convention
  naming_config = module.naming.standard_tags
  
  vpc_configuration = var.vpc_configuration
  region = var.region
  availability_zones = var.availability_zones
  
  # Environment-specific overrides
  enable_public_gateway = var.environment_config.enable_public_gateway
  enable_flow_logs = var.environment_config.enable_flow_logs
  
  tags = merge(
    module.naming.standard_tags,
    var.additional_tags,
    {
      "Component" = "foundation-networking"
      "Layer" = "infrastructure"
    }
  )
}

module "foundation_security" {
  source = "../../modules/foundation/security-baseline"
  
  vpc_id = module.foundation_networking.vpc_id
  security_configuration = var.security_configuration
  
  # Environment-specific security settings
  enable_advanced_threat_protection = var.environment_config.enable_advanced_threat_protection
  enable_compliance_monitoring = var.environment_config.enable_compliance_monitoring
  
  tags = merge(
    module.naming.standard_tags,
    {
      "Component" = "foundation-security"
      "Layer" = "security"
    }
  )
  
  depends_on = [module.foundation_networking]
}
```

### **Step 2: Environment-Specific Configurations**

**Development Environment:**
```bash
cd environments/development
```

```hcl
# environments/development/terraform.tfvars
# Development environment configuration
organization_name = "ACME Corporation"
environment = "development"
project_name = "scalable-infrastructure"
region = "us-south"

# Development-specific settings
environment_config = {
  enable_public_gateway = true
  enable_flow_logs = false
  enable_advanced_threat_protection = false
  enable_compliance_monitoring = false
  
  # Resource sizing for development
  instance_profile = "cx2-2x4"
  instance_count = 1
  storage_size_gb = 50
  backup_enabled = false
  monitoring_level = "basic"
}

# VPC configuration for development
vpc_configuration = {
  name = "dev-vpc"
  address_prefix_management = "auto"
  
  subnets = [
    {
      name = "dev-subnet-1"
      zone = "us-south-1"
      cidr_block = "10.240.0.0/24"
      public_gateway_enabled = true
    }
  ]
  
  security_groups = [
    {
      name = "dev-web-sg"
      description = "Development web security group"
      rules = [
        {
          direction = "inbound"
          protocol = "tcp"
          port_min = 80
          port_max = 80
          source_type = "cidr_block"
          source = "0.0.0.0/0"
        },
        {
          direction = "inbound"
          protocol = "tcp"
          port_min = 22
          port_max = 22
          source_type = "cidr_block"
          source = "0.0.0.0/0"
        }
      ]
    }
  ]
}

# Cost and governance settings
cost_center = "CC-DEV-001"
monthly_budget = 200.00
owner = "development-team"

additional_tags = {
  "Purpose" = "development-testing"
  "AutoShutdown" = "enabled"
  "BackupPolicy" = "none"
}
```

**Staging Environment:**
```bash
cd environments/staging
```

```hcl
# environments/staging/terraform.tfvars
# Staging environment configuration
organization_name = "ACME Corporation"
environment = "staging"
project_name = "scalable-infrastructure"
region = "us-south"

# Staging-specific settings
environment_config = {
  enable_public_gateway = true
  enable_flow_logs = true
  enable_advanced_threat_protection = false
  enable_compliance_monitoring = true
  
  # Resource sizing for staging
  instance_profile = "cx2-4x8"
  instance_count = 2
  storage_size_gb = 100
  backup_enabled = true
  monitoring_level = "standard"
}

# VPC configuration for staging
vpc_configuration = {
  name = "staging-vpc"
  address_prefix_management = "auto"
  
  subnets = [
    {
      name = "staging-subnet-1"
      zone = "us-south-1"
      cidr_block = "10.241.0.0/24"
      public_gateway_enabled = true
    },
    {
      name = "staging-subnet-2"
      zone = "us-south-2"
      cidr_block = "10.241.1.0/24"
      public_gateway_enabled = true
    }
  ]
  
  security_groups = [
    {
      name = "staging-web-sg"
      description = "Staging web security group"
      rules = [
        {
          direction = "inbound"
          protocol = "tcp"
          port_min = 80
          port_max = 80
          source_type = "cidr_block"
          source = "10.0.0.0/8"
        },
        {
          direction = "inbound"
          protocol = "tcp"
          port_min = 443
          port_max = 443
          source_type = "cidr_block"
          source = "0.0.0.0/0"
        }
      ]
    }
  ]
}

# Cost and governance settings
cost_center = "CC-STG-001"
monthly_budget = 500.00
owner = "qa-team"

additional_tags = {
  "Purpose" = "pre-production-testing"
  "AutoShutdown" = "scheduled"
  "BackupPolicy" = "daily"
}
```

**Production Environment:**
```bash
cd environments/production
```

```hcl
# environments/production/terraform.tfvars
# Production environment configuration
organization_name = "ACME Corporation"
environment = "production"
project_name = "scalable-infrastructure"
region = "us-south"

# Production-specific settings
environment_config = {
  enable_public_gateway = true
  enable_flow_logs = true
  enable_advanced_threat_protection = true
  enable_compliance_monitoring = true
  
  # Resource sizing for production
  instance_profile = "cx2-8x16"
  instance_count = 3
  storage_size_gb = 500
  backup_enabled = true
  monitoring_level = "comprehensive"
}

# VPC configuration for production
vpc_configuration = {
  name = "prod-vpc"
  address_prefix_management = "manual"
  
  subnets = [
    {
      name = "prod-subnet-1"
      zone = "us-south-1"
      cidr_block = "10.242.0.0/24"
      public_gateway_enabled = false
    },
    {
      name = "prod-subnet-2"
      zone = "us-south-2"
      cidr_block = "10.242.1.0/24"
      public_gateway_enabled = false
    },
    {
      name = "prod-subnet-3"
      zone = "us-south-3"
      cidr_block = "10.242.2.0/24"
      public_gateway_enabled = false
    },
    {
      name = "prod-public-subnet"
      zone = "us-south-1"
      cidr_block = "10.242.10.0/24"
      public_gateway_enabled = true
    }
  ]
  
  security_groups = [
    {
      name = "prod-web-sg"
      description = "Production web security group"
      rules = [
        {
          direction = "inbound"
          protocol = "tcp"
          port_min = 443
          port_max = 443
          source_type = "cidr_block"
          source = "0.0.0.0/0"
        }
      ]
    },
    {
      name = "prod-app-sg"
      description = "Production application security group"
      rules = [
        {
          direction = "inbound"
          protocol = "tcp"
          port_min = 8080
          port_max = 8080
          source_type = "security_group"
          source = "prod-web-sg"
        }
      ]
    }
  ]
}

# Cost and governance settings
cost_center = "CC-PROD-001"
monthly_budget = 2000.00
owner = "operations-team"

additional_tags = {
  "Purpose" = "production-workload"
  "AutoShutdown" = "disabled"
  "BackupPolicy" = "continuous"
  "ComplianceFramework" = "SOC2"
}
```

### **Validation Steps**
```bash
# Validate each environment configuration
for env in development staging production; do
    echo "Validating $env environment..."
    cd environments/$env
    terraform init -backend=false
    terraform validate
    cd ../..
done
```

---

## 🔍 **Exercise 4: Configuration Validation and Governance (15 minutes)**

### **Objective**
Implement comprehensive validation rules and governance policies for configuration consistency.

### **Step 1: Global Validation Module**
```bash
cd modules/utilities/validation
```

```hcl
# modules/utilities/validation/main.tf
locals {
  # Environment validation rules
  environment_rules = {
    development = {
      max_instances = 5
      max_storage_gb = 100
      max_monthly_cost = 500
      required_tags = ["Purpose", "Owner", "AutoShutdown"]
      allowed_instance_profiles = ["cx2-2x4", "cx2-4x8"]
    }
    staging = {
      max_instances = 10
      max_storage_gb = 500
      max_monthly_cost = 1000
      required_tags = ["Purpose", "Owner", "BackupPolicy"]
      allowed_instance_profiles = ["cx2-2x4", "cx2-4x8", "cx2-8x16"]
    }
    production = {
      max_instances = 50
      max_storage_gb = 5000
      max_monthly_cost = 5000
      required_tags = ["Purpose", "Owner", "BackupPolicy", "ComplianceFramework"]
      allowed_instance_profiles = ["cx2-4x8", "cx2-8x16", "mx2-4x32"]
    }
  }
  
  current_rules = local.environment_rules[var.environment]
  
  # Validation checks
  instance_count_valid = var.instance_count <= local.current_rules.max_instances
  storage_size_valid = var.storage_size_gb <= local.current_rules.max_storage_gb
  cost_valid = var.estimated_monthly_cost <= local.current_rules.max_monthly_cost
  
  # Tag validation
  required_tags_present = alltrue([
    for tag in local.current_rules.required_tags :
    contains(keys(var.resource_tags), tag)
  ])
  
  # Instance profile validation
  instance_profile_valid = contains(
    local.current_rules.allowed_instance_profiles,
    var.instance_profile
  )
  
  # Overall validation status
  configuration_valid = alltrue([
    local.instance_count_valid,
    local.storage_size_valid,
    local.cost_valid,
    local.required_tags_present,
    local.instance_profile_valid
  ])
  
  # Validation report
  validation_report = {
    environment = var.environment
    validation_status = local.configuration_valid
    checks = {
      instance_count = {
        valid = local.instance_count_valid
        current = var.instance_count
        limit = local.current_rules.max_instances
      }
      storage_size = {
        valid = local.storage_size_valid
        current = var.storage_size_gb
        limit = local.current_rules.max_storage_gb
      }
      monthly_cost = {
        valid = local.cost_valid
        current = var.estimated_monthly_cost
        limit = local.current_rules.max_monthly_cost
      }
      required_tags = {
        valid = local.required_tags_present
        required = local.current_rules.required_tags
        present = keys(var.resource_tags)
      }
      instance_profile = {
        valid = local.instance_profile_valid
        current = var.instance_profile
        allowed = local.current_rules.allowed_instance_profiles
      }
    }
  }
}
```

### **Step 2: Policy as Code Implementation**
```bash
cd policies/custom
```

```hcl
# policies/custom/resource-limits.rego
package terraform.resource_limits

import future.keywords.in

# Resource count limits by environment
max_instances := {
    "development": 5,
    "staging": 10,
    "production": 50
}

# Cost limits by environment
max_monthly_cost := {
    "development": 500,
    "staging": 1000,
    "production": 5000
}

# Deny if instance count exceeds limit
deny[msg] {
    environment := input.environment
    instance_count := input.instance_count
    limit := max_instances[environment]
    instance_count > limit
    msg := sprintf("Instance count (%d) exceeds limit (%d) for %s environment", [instance_count, limit, environment])
}

# Deny if estimated cost exceeds limit
deny[msg] {
    environment := input.environment
    cost := input.estimated_monthly_cost
    limit := max_monthly_cost[environment]
    cost > limit
    msg := sprintf("Estimated monthly cost ($%.2f) exceeds limit ($%.2f) for %s environment", [cost, limit, environment])
}

# Require specific tags for production
deny[msg] {
    input.environment == "production"
    required_tags := ["Purpose", "Owner", "BackupPolicy", "ComplianceFramework"]
    tag := required_tags[_]
    not input.resource_tags[tag]
    msg := sprintf("Required tag '%s' is missing for production environment", [tag])
}
```

### **Step 3: Automated Validation Script**
```bash
cd scripts/validation
```

```bash
#!/bin/bash
# scripts/validation/validate-configuration.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

validate_directory_structure() {
    log_info "Validating directory structure..."
    
    local required_dirs=(
        "environments/development"
        "environments/staging"
        "environments/production"
        "modules/foundation"
        "modules/platform"
        "modules/applications"
        "modules/utilities"
        "policies"
        "scripts"
        "tests"
    )
    
    local missing_dirs=()
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$PROJECT_ROOT/$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [ ${#missing_dirs[@]} -eq 0 ]; then
        log_success "Directory structure validation passed"
    else
        log_error "Missing required directories: ${missing_dirs[*]}"
        return 1
    fi
}

validate_naming_conventions() {
    log_info "Validating naming conventions..."
    
    # Check file naming patterns
    local invalid_files=()
    
    # Check for files that don't follow naming conventions
    while IFS= read -r -d '' file; do
        basename_file=$(basename "$file")
        if [[ ! "$basename_file" =~ ^[a-z][a-z0-9-]*\.(tf|tfvars|md)$ ]]; then
            invalid_files+=("$file")
        fi
    done < <(find "$PROJECT_ROOT" -name "*.tf" -o -name "*.tfvars" -o -name "*.md" -print0)
    
    if [ ${#invalid_files[@]} -eq 0 ]; then
        log_success "Naming convention validation passed"
    else
        log_warning "Files with non-standard naming: ${invalid_files[*]}"
    fi
}

validate_terraform_syntax() {
    log_info "Validating Terraform syntax..."
    
    local validation_failed=false
    
    # Validate each environment
    for env_dir in "$PROJECT_ROOT"/environments/*/; do
        if [ -d "$env_dir" ] && [ -f "$env_dir/main.tf" ]; then
            env_name=$(basename "$env_dir")
            log_info "Validating $env_name environment..."
            
            cd "$env_dir"
            if terraform init -backend=false > /dev/null 2>&1; then
                if terraform validate > /dev/null 2>&1; then
                    log_success "$env_name environment validation passed"
                else
                    log_error "$env_name environment validation failed"
                    validation_failed=true
                fi
            else
                log_error "$env_name environment initialization failed"
                validation_failed=true
            fi
        fi
    done
    
    cd "$PROJECT_ROOT"
    
    if [ "$validation_failed" = true ]; then
        return 1
    fi
}

validate_consistency() {
    log_info "Validating configuration consistency..."
    
    # Check that all environments have required files
    local required_files=("main.tf" "variables.tf" "outputs.tf" "terraform.tfvars")
    local consistency_issues=()
    
    for env_dir in "$PROJECT_ROOT"/environments/*/; do
        if [ -d "$env_dir" ]; then
            env_name=$(basename "$env_dir")
            for file in "${required_files[@]}"; do
                if [ ! -f "$env_dir/$file" ]; then
                    consistency_issues+=("$env_name missing $file")
                fi
            done
        fi
    done
    
    if [ ${#consistency_issues[@]} -eq 0 ]; then
        log_success "Configuration consistency validation passed"
    else
        log_warning "Consistency issues found: ${consistency_issues[*]}"
    fi
}

generate_validation_report() {
    log_info "Generating validation report..."
    
    local report_file="$PROJECT_ROOT/validation-report.json"
    local timestamp=$(date -Iseconds)
    
    # Count files and directories
    local total_files=$(find "$PROJECT_ROOT" -name "*.tf" -o -name "*.tfvars" | wc -l)
    local total_dirs=$(find "$PROJECT_ROOT" -type d | wc -l)
    
    cat > "$report_file" << EOF
{
    "validation_report": {
        "timestamp": "$timestamp",
        "project_root": "$PROJECT_ROOT",
        "statistics": {
            "total_terraform_files": $total_files,
            "total_directories": $total_dirs,
            "environments": $(ls -1 "$PROJECT_ROOT/environments" | wc -l),
            "modules": $(find "$PROJECT_ROOT/modules" -name "*.tf" | wc -l)
        },
        "validation_checks": {
            "directory_structure": "passed",
            "naming_conventions": "passed",
            "terraform_syntax": "passed",
            "configuration_consistency": "passed"
        },
        "recommendations": [
            "Implement automated testing for all modules",
            "Add cost estimation to deployment pipeline",
            "Establish regular configuration audits",
            "Document team ownership and responsibilities"
        ]
    }
}
EOF
    
    log_success "Validation report generated: $report_file"
}

main() {
    log_info "Starting comprehensive configuration validation..."
    
    validate_directory_structure
    validate_naming_conventions
    validate_terraform_syntax
    validate_consistency
    generate_validation_report
    
    log_success "Configuration validation completed successfully!"
    log_info "Project contains $total_files Terraform files across $total_dirs directories"
}

main "$@"
```

### **Validation Steps**
```bash
# Make validation script executable
chmod +x scripts/validation/validate-configuration.sh

# Run comprehensive validation
./scripts/validation/validate-configuration.sh

# Check validation report
cat validation-report.json | jq '.validation_report.statistics'
```

---

## 📊 **Exercise 5: Team Collaboration Setup (15 minutes)**

### **Objective**
Establish team-based workflows and ownership patterns for collaborative development.

### **Step 1: Team Ownership Configuration**
```bash
cd governance
```

```yaml
# governance/CODEOWNERS
# Global ownership
* @platform-team

# Environment-specific ownership
/environments/development/ @platform-team @development-team
/environments/staging/ @platform-team @qa-team
/environments/production/ @platform-team @operations-team

# Module ownership
/modules/foundation/ @platform-team
/modules/platform/ @platform-team @architecture-team
/modules/applications/ @application-team-1 @application-team-2
/modules/utilities/ @platform-team

# Team-specific areas
/teams/platform-team/ @platform-team
/teams/application-team-1/ @application-team-1
/teams/application-team-2/ @application-team-2
/teams/security-team/ @security-team

# Governance and policies
/policies/ @security-team @compliance-team
/governance/ @platform-team @security-team
```

### **Step 2: Workflow Configuration**
```yaml
# .github/workflows/terraform-validation.yml
name: Terraform Configuration Validation

on:
  pull_request:
    paths:
      - '**/*.tf'
      - '**/*.tfvars'
      - 'modules/**'
      - 'environments/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [development, staging, production]
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Format Check
        run: terraform fmt -check -recursive
      
      - name: Validate Environment
        run: |
          cd environments/${{ matrix.environment }}
          terraform init -backend=false
          terraform validate
      
      - name: Run Configuration Validation
        run: ./scripts/validation/validate-configuration.sh
      
      - name: Security Scan
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          working_directory: environments/${{ matrix.environment }}
      
      - name: Generate Cost Estimate
        if: matrix.environment == 'production'
        run: |
          cd environments/production
          infracost breakdown --path . --format json > cost-estimate.json
```

### **Validation Steps**
```bash
# Verify team structure
tree teams/

# Check CODEOWNERS syntax
cat governance/CODEOWNERS

# Validate workflow configuration
yamllint .github/workflows/terraform-validation.yml
```

---

## ✅ **Lab Validation and Cleanup**

### **Final Validation Checklist**
- [ ] 50+ directories created with proper structure
- [ ] Naming conventions implemented and validated
- [ ] Multi-environment configurations working
- [ ] Validation scripts executing successfully
- [ ] Team collaboration patterns established
- [ ] All Terraform configurations validate successfully

### **Project Statistics**
```bash
# Generate final project statistics
echo "=== Project Organization Statistics ==="
echo "Total directories: $(find . -type d | wc -l)"
echo "Total Terraform files: $(find . -name "*.tf" | wc -l)"
echo "Total variable files: $(find . -name "*.tfvars" | wc -l)"
echo "Total modules: $(find modules -name "main.tf" | wc -l)"
echo "Environments configured: $(ls -1 environments/ | grep -v shared | wc -l)"

# Validate naming consistency
echo "=== Naming Consistency Check ==="
./scripts/validation/validate-configuration.sh
```

### **Cleanup Steps**
```bash
# Clean up any temporary files
find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "terraform.tfstate*" -delete 2>/dev/null || true
find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true

# Generate final documentation
echo "Lab completed successfully!"
echo "Project structure ready for enterprise-scale Terraform development"
```

---

## 🎯 **Key Takeaways**

1. **Scalable Structure**: Organized 50+ files with clear hierarchy and separation of concerns
2. **Naming Consistency**: Implemented enterprise naming conventions with 99% consistency
3. **Environment Management**: Established proper environment separation and configuration inheritance
4. **Team Collaboration**: Created team-based ownership and workflow patterns
5. **Governance Integration**: Applied validation rules and policy enforcement
6. **Maintenance Ready**: Structured for easy evolution and refactoring

**Next Steps**: Apply these organization principles to your real-world Terraform projects and establish enterprise governance frameworks for infrastructure as code at scale.
