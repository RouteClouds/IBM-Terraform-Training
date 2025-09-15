# Test Your Understanding: Topic 5.1 - Creating Reusable Modules

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your understanding of Terraform module creation concepts, patterns, and best practices for IBM Cloud infrastructure. The assessment includes multiple choice questions, scenario-based problems, and hands-on challenges.

**Time Limit**: 90 minutes  
**Passing Score**: 80% (24/30 points)  
**Format**: 20 Multiple Choice + 5 Scenarios + 3 Hands-on Challenges

---

## 📝 **Part 1: Multiple Choice Questions (20 points)**

### **Question 1** (1 point)
What is the primary benefit of using Terraform modules for infrastructure as code?

A) Faster execution of Terraform commands  
B) Reduced file sizes in Terraform configurations  
C) Reusability and standardization of infrastructure patterns  
D) Automatic cost optimization for cloud resources  

**Answer**: C

---

### **Question 2** (1 point)
Which file is required for a basic Terraform module structure?

A) `README.md`  
B) `main.tf`  
C) `terraform.tfvars`  
D) `outputs.tf`  

**Answer**: B

---

### **Question 3** (1 point)
What is the correct syntax for defining a variable validation rule in Terraform?

A) `validate { condition = true }`  
B) `validation { condition = true; error_message = "Error" }`  
C) `check { rule = true; message = "Error" }`  
D) `constraint { expression = true; description = "Error" }`  

**Answer**: B

---

### **Question 4** (1 point)
In semantic versioning (SemVer), what does a MAJOR version increment indicate?

A) Bug fixes and patches  
B) New backward-compatible features  
C) Breaking changes that require user intervention  
D) Performance improvements only  

**Answer**: C

---

### **Question 5** (1 point)
Which IBM Cloud service provides native Terraform-as-a-Service capabilities?

A) IBM Cloud Functions  
B) IBM Cloud Schematics  
C) IBM Cloud Code Engine  
D) IBM Cloud App ID  

**Answer**: B

---

### **Question 6** (1 point)
What is the recommended approach for handling sensitive data in Terraform modules?

A) Store in plain text variables  
B) Use the `sensitive = true` attribute  
C) Encrypt manually before input  
D) Store in comments for reference  

**Answer**: B

---

### **Question 7** (1 point)
Which testing level is at the top of the testing pyramid for Terraform modules?

A) Unit tests  
B) Integration tests  
C) End-to-end tests  
D) Performance tests  

**Answer**: C

---

### **Question 8** (1 point)
What is the purpose of the `locals` block in Terraform?

A) Define input variables  
B) Create computed values and expressions  
C) Configure provider settings  
D) Define output values  

**Answer**: B

---

### **Question 9** (1 point)
Which version constraint allows patch updates but prevents minor version changes?

A) `~> 1.0`  
B) `>= 1.0.0`  
C) `~> 1.0.0`  
D) `= 1.0.0`  

**Answer**: C

---

### **Question 10** (1 point)
What is the primary purpose of module outputs?

A) Debug module execution  
B) Provide integration points for other modules  
C) Store module configuration  
D) Log module activities  

**Answer**: B

---

### **Question 11** (1 point)
Which tool is commonly used for security scanning of Terraform configurations?

A) TFLint  
B) TFSec  
C) Terratest  
D) Infracost  

**Answer**: B

---

### **Question 12** (1 point)
What is the recommended naming convention for Terraform module directories?

A) camelCase  
B) PascalCase  
C) kebab-case  
D) snake_case  

**Answer**: C

---

### **Question 13** (1 point)
Which IBM Cloud resource is free of charge in VPC environments?

A) Virtual Server Instances  
B) Public Gateways  
C) VPC and Subnets  
D) Load Balancers  

**Answer**: C

---

### **Question 14** (1 point)
What is the purpose of the `count` meta-argument in Terraform?

A) Count the number of resources  
B) Create multiple instances of a resource  
C) Validate resource configuration  
D) Monitor resource performance  

**Answer**: B

---

### **Question 15** (1 point)
Which file should contain example values for all module variables?

A) `terraform.tfvars`  
B) `variables.tf`  
C) `terraform.tfvars.example`  
D) `examples.tf`  

**Answer**: C

---

### **Question 16** (1 point)
What is the recommended comment ratio for enterprise Terraform code?

A) 10%  
B) 15%  
C) 20%  
D) 25%  

**Answer**: C

---

### **Question 17** (1 point)
Which provider is required for generating SSH keys in Terraform?

A) `ibm`  
B) `random`  
C) `tls`  
D) `local`  

**Answer**: C

---

### **Question 18** (1 point)
What is the maximum number of subnets allowed per VPC in IBM Cloud?

A) 10  
B) 15  
C) 20  
D) 25  

**Answer**: B

---

### **Question 19** (1 point)
Which attribute is used to create dependencies between resources in Terraform?

A) `requires`  
B) `depends_on`  
C) `needs`  
D) `after`  

**Answer**: B

---

### **Question 20** (1 point)
What is the primary benefit of using IBM Cloud resource groups?

A) Improved performance  
B) Cost reduction  
C) Resource organization and access control  
D) Automatic backups  

**Answer**: C

---

## 🎯 **Part 2: Scenario-Based Questions (5 points)**

### **Scenario 1** (1 point)
Your organization needs to deploy VPC infrastructure across multiple environments (dev, staging, production) with different configurations. The development environment needs 1 subnet, staging needs 2 subnets, and production needs 3 subnets with high availability.

**Question**: What is the best approach to handle this requirement using Terraform modules?

A) Create separate modules for each environment  
B) Use conditional logic with count or for_each based on environment variables  
C) Hardcode different configurations in each environment  
D) Use different Terraform providers for each environment  

**Answer**: B

**Explanation**: Using conditional logic with variables allows a single module to handle different environment requirements while maintaining consistency and reducing code duplication.

---

### **Scenario 2** (1 point)
You're developing a module that creates IBM Cloud VPC resources. During testing, you discover that some variable combinations result in invalid CIDR blocks that cause deployment failures.

**Question**: What is the most effective way to prevent this issue?

A) Document the valid combinations in README  
B) Implement validation rules in variable definitions  
C) Use try() functions to handle errors  
D) Create separate variables for each valid combination  

**Answer**: B

**Explanation**: Variable validation rules provide immediate feedback and prevent invalid configurations from being applied, improving user experience and preventing deployment failures.

---

### **Scenario 3** (1 point)
Your team is building a module library for IBM Cloud infrastructure. You need to ensure that modules can be easily discovered, versioned, and shared across multiple teams while maintaining quality standards.

**Question**: What is the most comprehensive approach to achieve this?

A) Store modules in a shared Git repository with tags  
B) Implement a private module registry with automated testing and governance  
C) Share modules via email attachments  
D) Use public GitHub repositories for all modules  

**Answer**: B

**Explanation**: A private module registry with automated testing, governance, and proper versioning provides the best solution for enterprise module management and distribution.

---

### **Scenario 4** (1 point)
You're creating a module that provisions compute instances in IBM Cloud VPC. The module should support both development (1 instance) and production (3+ instances with load balancing) use cases while maintaining cost efficiency.

**Question**: What design pattern best addresses this requirement?

A) Create two separate modules for dev and production  
B) Use variable-driven configuration with conditional resource creation  
C) Always create maximum resources and scale down manually  
D) Use different instance profiles for different environments  

**Answer**: B

**Explanation**: Variable-driven configuration with conditional resource creation allows a single module to efficiently handle different deployment scenarios while optimizing costs.

---

### **Scenario 5** (1 point)
Your module creates VPC infrastructure and needs to provide connection information for other modules that will deploy applications. The consuming modules need VPC ID, subnet IDs, security group IDs, and network endpoints.

**Question**: What is the best practice for structuring module outputs?

A) Create individual outputs for each piece of information  
B) Use structured outputs with nested objects for logical grouping  
C) Store information in local files for other modules to read  
D) Use data sources in consuming modules to discover resources  

**Answer**: B

**Explanation**: Structured outputs with nested objects provide organized, comprehensive information that's easy for consuming modules to use while maintaining clear interfaces.

---

## 🛠️ **Part 3: Hands-on Challenges (5 points)**

### **Challenge 1: Module Interface Design** (2 points)

**Task**: Design a variable structure for a VPC module that supports the following requirements:
- VPC name with validation (3-63 characters, lowercase, alphanumeric with hyphens)
- 1-5 subnets with zone, CIDR, and optional public gateway
- Optional security groups with custom rules
- Enterprise tagging with cost center and environment

**Deliverable**: Write the variable definitions with appropriate validation rules.

**Sample Solution**:
```hcl
variable "vpc_configuration" {
  description = "VPC configuration with validation"
  type = object({
    name = string
    subnets = list(object({
      name       = string
      zone       = string
      cidr_block = string
      public_gateway_enabled = optional(bool, false)
    }))
    security_groups = optional(list(object({
      name = string
      rules = list(object({
        direction = string
        protocol  = string
        port_min  = optional(number)
        port_max  = optional(number)
        source    = string
      }))
    })), [])
  })
  
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.vpc_configuration.name))
    error_message = "VPC name must be 3-63 characters, lowercase, alphanumeric with hyphens."
  }
  
  validation {
    condition = length(var.vpc_configuration.subnets) >= 1 && length(var.vpc_configuration.subnets) <= 5
    error_message = "Must have 1-5 subnets."
  }
}

variable "enterprise_tags" {
  description = "Enterprise tagging configuration"
  type = object({
    cost_center = string
    environment = string
    project     = string
  })
  
  validation {
    condition = contains(["development", "staging", "production"], var.enterprise_tags.environment)
    error_message = "Environment must be development, staging, or production."
  }
}
```

---

### **Challenge 2: Output Design** (2 points)

**Task**: Design comprehensive outputs for the VPC module that provide:
- Complete VPC information for integration
- Subnet details with zone mapping
- Security group information
- Cost tracking data
- Integration endpoints for other modules

**Deliverable**: Write the output definitions with proper descriptions and structure.

**Sample Solution**:
```hcl
output "vpc_infrastructure" {
  description = "Complete VPC infrastructure for integration"
  value = {
    vpc = {
      id   = ibm_is_vpc.main.id
      name = ibm_is_vpc.main.name
      crn  = ibm_is_vpc.main.crn
    }
    subnets = {
      for subnet in ibm_is_subnet.main : subnet.name => {
        id   = subnet.id
        zone = subnet.zone
        cidr = subnet.ipv4_cidr_block
      }
    }
    security_groups = {
      for sg in ibm_is_security_group.custom : sg.name => {
        id = sg.id
      }
    }
  }
}

output "integration_endpoints" {
  description = "Integration points for other modules"
  value = {
    vpc_id = ibm_is_vpc.main.id
    subnet_ids = [for subnet in ibm_is_subnet.main : subnet.id]
    security_group_ids = [for sg in ibm_is_security_group.custom : sg.id]
  }
}

output "cost_tracking" {
  description = "Cost allocation and tracking information"
  value = {
    resource_count = {
      vpc_count    = 1
      subnet_count = length(ibm_is_subnet.main)
      sg_count     = length(ibm_is_security_group.custom)
    }
    cost_allocation = var.enterprise_tags
    estimated_monthly_cost = {
      vpc_cost = 0.00
      total_cost = 0.00
    }
  }
}
```

---

### **Challenge 3: Testing Strategy** (1 point)

**Task**: Design a testing strategy for the VPC module that includes:
- Unit tests for variable validation
- Integration tests for resource creation
- Security tests for compliance
- Performance tests for large deployments

**Deliverable**: Outline the testing approach with specific test cases.

**Sample Solution**:

**Testing Strategy:**

1. **Unit Tests**:
   - Variable validation with valid/invalid inputs
   - Local value computations
   - Conditional logic testing
   - Output value generation

2. **Integration Tests**:
   - End-to-end VPC creation with real IBM Cloud resources
   - Multi-subnet deployment scenarios
   - Security group rule application
   - Cross-module integration testing

3. **Security Tests**:
   - TFSec security scanning
   - Network ACL validation
   - Security group rule compliance
   - Encryption verification

4. **Performance Tests**:
   - Large-scale deployments (maximum subnets)
   - Resource creation time measurement
   - API rate limiting handling
   - Concurrent deployment testing

**Test Cases**:
```go
func TestVPCModuleValidation(t *testing.T) {
    // Test valid VPC name
    // Test invalid VPC name
    // Test subnet count limits
    // Test CIDR validation
}

func TestVPCModuleDeployment(t *testing.T) {
    // Deploy VPC with minimal configuration
    // Deploy VPC with maximum configuration
    // Verify resource creation
    // Test resource cleanup
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
- **90-100% (27-30 points)**: Excellent - Advanced understanding
- **80-89% (24-26 points)**: Good - Proficient understanding
- **70-79% (21-23 points)**: Satisfactory - Basic understanding
- **Below 70% (<21 points)**: Needs Improvement - Review required

### **Passing Criteria**
- Minimum score: 24/30 points (80%)
- All hands-on challenges must be attempted
- At least 16/20 multiple choice questions correct
- At least 4/5 scenario questions correct

---

## 🎯 **Learning Outcomes Assessment**

Upon successful completion, you should be able to:

✅ **Design Enterprise Module Interfaces**
- Create comprehensive variable definitions with validation
- Implement structured outputs for integration
- Apply consistent naming and tagging strategies

✅ **Implement Testing and Validation**
- Develop multi-level testing strategies
- Apply security scanning and compliance checks
- Validate module functionality and performance

✅ **Apply Best Practices**
- Follow semantic versioning for module releases
- Implement proper documentation and examples
- Establish governance and distribution workflows

✅ **Integrate with IBM Cloud Services**
- Leverage native IBM Cloud provider features
- Implement cost optimization strategies
- Apply enterprise security and compliance requirements

**Next Steps**: Proceed to Topic 5.2 - Organizing Configuration Files for Scalability to build upon your module creation skills with advanced organizational patterns.
