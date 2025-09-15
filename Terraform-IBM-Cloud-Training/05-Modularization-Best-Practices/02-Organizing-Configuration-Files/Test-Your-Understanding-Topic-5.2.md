# Test Your Understanding: Topic 5.2 - Organizing Configuration Files for Scalability

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your understanding of Terraform configuration organization patterns, scalability principles, and enterprise governance frameworks. The assessment includes multiple choice questions, scenario-based problems, and hands-on challenges.

**Time Limit**: 90 minutes  
**Passing Score**: 80% (24/30 points)  
**Format**: 20 Multiple Choice + 5 Scenarios + 3 Hands-on Challenges

---

## 📝 **Part 1: Multiple Choice Questions (20 points)**

### **Question 1** (1 point)
What is the recommended maximum number of subnets per VPC in IBM Cloud?

A) 10  
B) 15  
C) 20  
D) 25  

**Answer**: B

---

### **Question 2** (1 point)
Which directory structure pattern best supports team-based collaboration in large Terraform projects?

A) Flat structure with all files in root directory  
B) Environment-based directories with shared modules  
C) Service-based directories with team ownership  
D) Random organization based on creation date  

**Answer**: C

---

### **Question 3** (1 point)
What is the correct naming convention pattern for enterprise Terraform resources?

A) `{random}-{service}-{environment}`  
B) `{organization}-{environment}-{service}-{purpose}-{instance}`  
C) `{environment}-{service}`  
D) `{service}-{random}`  

**Answer**: B

---

### **Question 4** (1 point)
Which validation approach is most effective for large-scale Terraform configurations?

A) Manual code review only  
B) Single-stage validation at deployment  
C) Multi-stage validation with automated checks  
D) No validation needed with experienced teams  

**Answer**: C

---

### **Question 5** (1 point)
What is the primary benefit of using hierarchical variable management?

A) Faster execution  
B) Smaller file sizes  
C) Configuration inheritance and consistency  
D) Reduced memory usage  

**Answer**: C

---

### **Question 6** (1 point)
Which file should contain example values for all module variables?

A) `variables.tf`  
B) `terraform.tfvars`  
C) `terraform.tfvars.example`  
D) `examples.tf`  

**Answer**: C

---

### **Question 7** (1 point)
What is the recommended approach for handling environment-specific configurations?

A) Separate repositories for each environment  
B) Single configuration with environment variables  
C) Environment-specific directories with shared modules  
D) Hardcoded values for each environment  

**Answer**: C

---

### **Question 8** (1 point)
Which tagging strategy provides the best cost allocation visibility?

A) Random tags  
B) Hierarchical tags with cost center, project, and environment  
C) Single environment tag  
D) No tags needed  

**Answer**: B

---

### **Question 9** (1 point)
What is the purpose of the RACI matrix in Terraform project organization?

A) Resource allocation  
B) Responsibility assignment for components  
C) Cost calculation  
D) Performance monitoring  

**Answer**: B

---

### **Question 10** (1 point)
Which validation rule ensures naming convention compliance?

A) `length(var.name) > 0`  
B) `can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.name))`  
C) `var.name != null`  
D) `contains(["dev", "prod"], var.name)`  

**Answer**: B

---

### **Question 11** (1 point)
What is the recommended comment ratio for enterprise Terraform code?

A) 10%  
B) 15%  
C) 20%  
D) 25%  

**Answer**: C

---

### **Question 12** (1 point)
Which output structure best supports module integration?

A) Flat list of individual values  
B) Nested objects with logical grouping  
C) Single concatenated string  
D) No outputs needed  

**Answer**: B

---

### **Question 13** (1 point)
What is the primary purpose of configuration validation workflows?

A) Improve performance  
B) Reduce file sizes  
C) Catch errors early and maintain quality  
D) Speed up deployment  

**Answer**: C

---

### **Question 14** (1 point)
Which approach best handles configuration drift in large projects?

A) Manual monitoring  
B) Automated validation and drift detection  
C) Periodic recreation  
D) Ignore drift issues  

**Answer**: B

---

### **Question 15** (1 point)
What is the benefit of using feature flags in Terraform configurations?

A) Faster execution  
B) Conditional functionality and gradual rollouts  
C) Smaller configurations  
D) Better security  

**Answer**: B

---

### **Question 16** (1 point)
Which cost management strategy is most effective for non-production environments?

A) No cost controls  
B) Scheduled shutdown and auto-scaling  
C) Maximum resource allocation  
D) Manual cost tracking  

**Answer**: B

---

### **Question 17** (1 point)
What is the recommended approach for handling sensitive configuration data?

A) Store in plain text files  
B) Use environment variables and sensitive attributes  
C) Include in version control  
D) Share via email  

**Answer**: B

---

### **Question 18** (1 point)
Which directory naming convention supports the best organization?

A) CamelCase  
B) snake_case  
C) kebab-case  
D) UPPERCASE  

**Answer**: C

---

### **Question 19** (1 point)
What is the primary benefit of using local values in Terraform?

A) Faster execution  
B) Computed expressions and DRY principle  
C) Better security  
D) Smaller file sizes  

**Answer**: B

---

### **Question 20** (1 point)
Which validation tool is specifically designed for Terraform security scanning?

A) TFLint  
B) TFSec  
C) Terratest  
D) Infracost  

**Answer**: B

---

## 🎯 **Part 2: Scenario-Based Questions (5 points)**

### **Scenario 1** (1 point)
Your organization has 5 teams working on different applications, each requiring their own VPC infrastructure. The teams need to maintain independence while sharing common modules and following enterprise standards.

**Question**: What organizational structure would best support this requirement?

A) Single shared VPC for all teams  
B) Team-based directories with shared module library and governance policies  
C) Separate repositories for each team with no coordination  
D) Centralized team managing all infrastructure  

**Answer**: B

**Explanation**: Team-based directories allow independence while shared modules and governance policies ensure consistency and standards compliance across all teams.

---

### **Scenario 2** (1 point)
You're implementing a configuration organization strategy for a project that will grow from 10 files to over 100 files across multiple environments and services. The project needs to support both current simplicity and future complexity.

**Question**: Which approach provides the best scalability foundation?

A) Start with flat structure and reorganize later  
B) Implement hierarchical structure with clear separation of concerns from the beginning  
C) Use random organization and rely on search tools  
D) Create separate projects for each service  

**Answer**: B

**Explanation**: Implementing proper hierarchical structure early prevents technical debt and provides a solid foundation for growth without requiring major refactoring.

---

### **Scenario 3** (1 point)
Your team needs to ensure 99% consistency in naming conventions across a large Terraform project with multiple contributors. Manual reviews are not catching all violations.

**Question**: What is the most effective approach to achieve this consistency?

A) More frequent manual reviews  
B) Automated validation rules with CI/CD integration  
C) Documentation and training only  
D) Post-deployment naming fixes  

**Answer**: B

**Explanation**: Automated validation rules integrated into CI/CD pipelines catch naming violations before they reach production, ensuring consistent enforcement.

---

### **Scenario 4** (1 point)
You're designing a configuration structure for a multi-region deployment where some resources are global, some are regional, and some are environment-specific. The structure needs to minimize duplication while maintaining clarity.

**Question**: What configuration organization pattern best addresses this requirement?

A) Duplicate all configurations for each region  
B) Hierarchical configuration with global, regional, and environment layers  
C) Single configuration file with complex conditionals  
D) Separate projects for each region  

**Answer**: B

**Explanation**: Hierarchical configuration with inheritance allows sharing of global settings while enabling regional and environment-specific customization without duplication.

---

### **Scenario 5** (1 point)
Your organization requires comprehensive cost tracking and allocation across multiple projects, environments, and teams. The finance team needs detailed reporting capabilities.

**Question**: Which tagging and organization strategy provides the best cost visibility?

A) Simple environment tags only  
B) Comprehensive hierarchical tagging with cost center, project, team, and environment  
C) Random tagging based on resource type  
D) No tagging with manual cost allocation  

**Answer**: B

**Explanation**: Comprehensive hierarchical tagging enables detailed cost allocation and reporting across all organizational dimensions required by finance teams.

---

## 🛠️ **Part 3: Hands-on Challenges (5 points)**

### **Challenge 1: Configuration Organization Design** (2 points)

**Task**: Design a directory structure for a large organization with the following requirements:
- 3 environments (dev, staging, prod)
- 4 teams (platform, web, api, data)
- Shared modules and policies
- Team-specific configurations
- Governance and compliance requirements

**Deliverable**: Create the directory structure with explanations for each level.

**Sample Solution**:
```
terraform-infrastructure/
├── README.md
├── .gitignore
├── governance/
│   ├── policies/
│   ├── compliance/
│   └── cost-management/
├── shared/
│   ├── modules/
│   │   ├── foundation/
│   │   ├── networking/
│   │   └── security/
│   ├── policies/
│   └── templates/
├── environments/
│   ├── development/
│   │   ├── foundation/
│   │   ├── teams/
│   │   └── shared-services/
│   ├── staging/
│   │   ├── foundation/
│   │   ├── teams/
│   │   └── shared-services/
│   └── production/
│       ├── foundation/
│       ├── teams/
│       └── shared-services/
├── teams/
│   ├── platform-team/
│   │   ├── foundation/
│   │   ├── networking/
│   │   └── monitoring/
│   ├── web-team/
│   │   ├── applications/
│   │   └── cdn/
│   ├── api-team/
│   │   ├── services/
│   │   └── gateways/
│   └── data-team/
│       ├── databases/
│       ├── analytics/
│       └── pipelines/
└── docs/
    ├── architecture/
    ├── runbooks/
    └── standards/
```

**Explanation**:
- **governance/**: Enterprise policies and compliance frameworks
- **shared/**: Common modules and templates used across teams
- **environments/**: Environment-specific configurations with consistent structure
- **teams/**: Team-specific areas with clear ownership boundaries
- **docs/**: Comprehensive documentation and operational procedures

---

### **Challenge 2: Variable Validation Implementation** (2 points)

**Task**: Implement comprehensive validation rules for a configuration that includes:
- Organization naming with specific pattern requirements
- Environment validation (only specific values allowed)
- Cost budget validation with environment-specific limits
- Network CIDR validation for non-overlapping ranges

**Deliverable**: Write the variable definitions with validation rules.

**Sample Solution**:
```hcl
variable "organization_config" {
  description = "Organization configuration with validation"
  type = object({
    name        = string
    environment = string
    cost_center = string
  })
  
  validation {
    condition = can(regex("^[A-Z][a-zA-Z0-9 ]*$", var.organization_config.name))
    error_message = "Organization name must start with uppercase letter and contain only letters, numbers, and spaces."
  }
  
  validation {
    condition = contains(["development", "staging", "production"], var.organization_config.environment)
    error_message = "Environment must be development, staging, or production."
  }
  
  validation {
    condition = can(regex("^CC-[A-Z]{3}-[0-9]{3}$", var.organization_config.cost_center))
    error_message = "Cost center must follow format CC-XXX-000."
  }
}

variable "network_config" {
  description = "Network configuration with CIDR validation"
  type = object({
    vpc_cidr = string
    subnets  = list(object({
      cidr = string
      zone = string
    }))
  })
  
  validation {
    condition = can(cidrhost(var.network_config.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
  
  validation {
    condition = alltrue([
      for subnet in var.network_config.subnets :
      can(cidrhost(subnet.cidr, 0))
    ])
    error_message = "All subnet CIDRs must be valid CIDR blocks."
  }
}

variable "cost_budget" {
  description = "Monthly cost budget with environment-specific validation"
  type        = number
  
  validation {
    condition = var.cost_budget > 0 && var.cost_budget <= (
      var.organization_config.environment == "development" ? 1000 :
      var.organization_config.environment == "staging" ? 5000 :
      var.organization_config.environment == "production" ? 50000 : 1000
    )
    error_message = "Cost budget must be within environment limits: dev($1000), staging($5000), prod($50000)."
  }
}
```

---

### **Challenge 3: Output Structure Design** (1 point)

**Task**: Design a comprehensive output structure that provides:
- Infrastructure integration points
- Cost tracking information
- Security compliance status
- Operational metadata
- Development debugging information

**Deliverable**: Create the output definitions with proper structure and descriptions.

**Sample Solution**:
```hcl
output "infrastructure_integration" {
  description = "Integration points for other modules and applications"
  value = {
    networking = {
      vpc_id = ibm_is_vpc.main.id
      subnet_ids = {
        for subnet in ibm_is_subnet.subnets : subnet.zone => subnet.id
      }
      security_group_ids = [for sg in ibm_is_security_group.main : sg.id]
    }
    
    connectivity = {
      public_gateways = {
        for gw in ibm_is_public_gateway.main : gw.zone => gw.id
      }
      ssh_key_id = ibm_is_ssh_key.main.id
    }
  }
}

output "cost_tracking" {
  description = "Cost allocation and tracking information"
  value = {
    estimated_monthly_cost = local.total_estimated_cost
    cost_breakdown = local.estimated_monthly_cost
    budget_status = {
      budget_limit = var.cost_budget
      utilization_percent = (local.total_estimated_cost / var.cost_budget) * 100
      within_budget = local.total_estimated_cost <= var.cost_budget
    }
    allocation_tags = local.cost_allocation_tags
  }
}

output "security_compliance" {
  description = "Security configuration and compliance status"
  value = {
    compliance_framework = var.security_config.compliance_framework
    encryption_status = {
      at_rest = var.security_config.encryption_at_rest
      in_transit = var.security_config.encryption_in_transit
    }
    monitoring_enabled = var.security_config.enable_monitoring
    compliance_score = local.compliance_score
  }
}

output "operational_metadata" {
  description = "Operational information for management and monitoring"
  value = {
    deployment_info = {
      timestamp = timestamp()
      environment = var.organization_config.environment
      terraform_version = "~> 1.5.0"
    }
    resource_inventory = {
      vpc_count = 1
      subnet_count = length(ibm_is_subnet.subnets)
      security_group_count = length(ibm_is_security_group.main)
    }
    naming_convention = {
      pattern = local.resource_name_pattern
      organization = var.organization_config.name
    }
  }
}
```

---

## 📊 **Assessment Scoring**

### **Scoring Breakdown**
- **Part 1 (Multiple Choice)**: 20 points (1 point each)
- **Part 2 (Scenarios)**: 5 points (1 point each)
- **Part 3 (Hands-on)**: 5 points (2+2+1 points)
- **Total**: 30 points

### **Grading Scale**
- **90-100% (27-30 points)**: Excellent - Advanced understanding of configuration organization
- **80-89% (24-26 points)**: Good - Proficient understanding with minor gaps
- **70-79% (21-23 points)**: Satisfactory - Basic understanding with some weaknesses
- **Below 70% (<21 points)**: Needs Improvement - Review required

### **Passing Criteria**
- Minimum score: 24/30 points (80%)
- All hands-on challenges must be attempted
- At least 16/20 multiple choice questions correct
- At least 4/5 scenario questions correct

---

## 🎯 **Learning Outcomes Assessment**

Upon successful completion, you should be able to:

✅ **Design Scalable Directory Structures**
- Create hierarchical organization patterns that support growth
- Implement team-based collaboration structures
- Establish clear separation of concerns

✅ **Implement Enterprise Naming Conventions**
- Apply consistent naming patterns across all resources
- Create validation rules for naming compliance
- Achieve 99% naming consistency

✅ **Apply Configuration Management Patterns**
- Use hierarchical variable management
- Implement environment-specific configurations
- Create maintainable and scalable structures

✅ **Establish Governance Frameworks**
- Implement validation workflows and quality gates
- Apply cost management and tracking strategies
- Create security and compliance frameworks

✅ **Enable Team Collaboration**
- Design ownership and responsibility matrices
- Implement change management workflows
- Create integration patterns for multi-team development

**Next Steps**: Proceed to Topic 5.3 - Version Control and Collaboration with Git to learn advanced Git workflows for organized Terraform development.
