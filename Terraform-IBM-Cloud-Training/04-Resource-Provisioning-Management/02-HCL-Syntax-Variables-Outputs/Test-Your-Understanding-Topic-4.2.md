# Test Your Understanding: Topic 4.2 - HCL Syntax, Variables, and Outputs

## Overview

This assessment evaluates your mastery of advanced HCL (HashiCorp Configuration Language) syntax, sophisticated variable patterns, complex validation rules, and comprehensive output strategies. The assessment covers enterprise-grade configuration management techniques for IBM Cloud infrastructure.

**Time Allocation**: 90 minutes  
**Total Points**: 100 points  
**Passing Score**: 80 points

---

## Section A: Multiple Choice Questions (40 points)
*Select the best answer for each question. Each question is worth 2 points.*

### Question 1
Which HCL syntax correctly defines a complex object variable with validation?

A) ```hcl
variable "config" {
  type = object({
    name = string
    size = number
  })
  validation {
    condition = length(var.config.name) > 0
    error_message = "Name cannot be empty"
  }
}
```

B) ```hcl
variable "config" {
  type = map(string)
  validate {
    condition = var.config.name != ""
    message = "Name required"
  }
}
```

C) ```hcl
variable "config" = {
  type = object
  validation = true
}
```

D) ```hcl
variable "config" {
  object {
    name = string
    size = number
  }
}
```

### Question 2
What is the correct way to reference a local value in HCL?

A) `${local.value_name}`
B) `local.value_name`
C) `locals.value_name`
D) `var.local.value_name`

### Question 3
Which validation rule correctly ensures a project name follows naming conventions?

A) ```hcl
validation {
  condition = regex("^[a-z][a-z0-9-]{2,29}$", var.project_name)
  error_message = "Invalid project name"
}
```

B) ```hcl
validation {
  condition = can(regex("^[a-z][a-z0-9-]{2,29}$", var.project_name))
  error_message = "Project name must be 3-30 characters, start with letter"
}
```

C) ```hcl
validation {
  condition = length(var.project_name) >= 3
  error_message = "Name too short"
}
```

D) ```hcl
validate {
  rule = var.project_name matches "^[a-z]"
  message = "Must start with letter"
}
```

### Question 4
How do you create a conditional resource in Terraform?

A) ```hcl
resource "ibm_is_vpc" "main" {
  if var.create_vpc {
    name = "my-vpc"
  }
}
```

B) ```hcl
resource "ibm_is_vpc" "main" {
  count = var.create_vpc ? 1 : 0
  name  = "my-vpc"
}
```

C) ```hcl
resource "ibm_is_vpc" "main" {
  enabled = var.create_vpc
  name    = "my-vpc"
}
```

D) ```hcl
conditional "ibm_is_vpc" "main" {
  condition = var.create_vpc
  name      = "my-vpc"
}
```

### Question 5
Which output configuration correctly marks sensitive data?

A) ```hcl
output "password" {
  value = random_password.db.result
  sensitive = true
  description = "Database password"
}
```

B) ```hcl
output "password" {
  value = random_password.db.result
  secret = true
}
```

C) ```hcl
sensitive_output "password" {
  value = random_password.db.result
}
```

D) ```hcl
output "password" {
  sensitive_value = random_password.db.result
}
```

### Question 6
What is the correct syntax for a dynamic block in HCL?

A) ```hcl
dynamic "subnet" {
  for_each = var.subnets
  content {
    cidr = subnet.value
  }
}
```

B) ```hcl
for subnet in var.subnets {
  subnet {
    cidr = subnet
  }
}
```

C) ```hcl
dynamic subnet {
  iterator = var.subnets
  content {
    cidr = subnet.value
  }
}
```

D) ```hcl
repeat "subnet" {
  count = length(var.subnets)
  cidr  = var.subnets[count.index]
}
```

### Question 7
How do you properly use the `for` expression to transform a list?

A) ```hcl
[for item in var.list : upper(item)]
```

B) ```hcl
for(item in var.list) { upper(item) }
```

C) ```hcl
var.list.map(item => upper(item))
```

D) ```hcl
transform(var.list, upper)
```

### Question 8
Which local value correctly implements conditional logic?

A) ```hcl
locals {
  instance_count = var.environment == "production" ? 3 : 1
}
```

B) ```hcl
locals {
  instance_count = if var.environment == "production" then 3 else 1
}
```

C) ```hcl
locals {
  instance_count = case(var.environment) {
    "production" = 3
    default = 1
  }
}
```

D) ```hcl
locals {
  instance_count = switch(var.environment, "production", 3, 1)
}
```

### Question 9
What is the correct way to merge maps in HCL?

A) `merge(map1, map2, map3)`
B) `map1 + map2 + map3`
C) `concat(map1, map2, map3)`
D) `join(map1, map2, map3)`

### Question 10
Which variable type definition allows for optional attributes?

A) ```hcl
type = object({
  name = string
  size = optional(number)
})
```

B) ```hcl
type = object({
  name = string
  size = number?
})
```

C) ```hcl
type = object({
  name = string
  size = nullable(number)
})
```

D) ```hcl
type = object({
  name = string
  size = maybe(number)
})
```

### Question 11
How do you reference an output from another module?

A) `module.network.vpc_id`
B) `output.network.vpc_id`
C) `modules.network.outputs.vpc_id`
D) `${module.network.vpc_id}`

### Question 12
Which function correctly checks if a value can be converted to a specific type?

A) `can(tonumber(var.value))`
B) `try(number(var.value))`
C) `validate(var.value, number)`
D) `isnumber(var.value)`

### Question 13
What is the correct syntax for a complex validation rule with multiple conditions?

A) ```hcl
validation {
  condition = length(var.name) >= 3 && length(var.name) <= 30 && can(regex("^[a-z]", var.name))
  error_message = "Name must be 3-30 characters and start with lowercase letter"
}
```

B) ```hcl
validation {
  conditions = [
    length(var.name) >= 3,
    length(var.name) <= 30,
    startswith(var.name, "[a-z]")
  ]
  error_message = "Invalid name format"
}
```

C) ```hcl
validation {
  condition = all([
    length(var.name) >= 3,
    length(var.name) <= 30,
    regex("^[a-z]", var.name)
  ])
  error_message = "Invalid name"
}
```

D) ```hcl
validate {
  rule = var.name matches "^[a-z].{2,29}$"
  message = "Invalid name format"
}
```

### Question 14
How do you create a map from a list using a for expression?

A) ```hcl
{for item in var.list : item.name => item.value}
```

B) ```hcl
map(var.list, item => {item.name: item.value})
```

C) ```hcl
tomap([for item in var.list : {item.name = item.value}])
```

D) ```hcl
{var.list.map(item => item.name: item.value)}
```

### Question 15
Which output structure is best for module integration?

A) ```hcl
output "vpc_info" {
  value = {
    id   = ibm_is_vpc.main.id
    name = ibm_is_vpc.main.name
    cidr = ibm_is_vpc.main.default_network_acl
  }
}
```

B) ```hcl
output "vpc_id" {
  value = ibm_is_vpc.main.id
}
output "vpc_name" {
  value = ibm_is_vpc.main.name
}
```

C) ```hcl
output "network_configuration" {
  value = {
    vpc = {
      id   = ibm_is_vpc.main.id
      name = ibm_is_vpc.main.name
      cidr = ibm_is_vpc.main.default_network_acl
    }
    subnets = {
      public  = ibm_is_subnet.public[*].id
      private = ibm_is_subnet.private[*].id
    }
  }
}
```

D) ```hcl
output "all_resources" {
  value = "*"
}
```

### Question 16
What is the correct way to use the `try` function?

A) `try(var.optional_value, "default")`
B) `try(var.optional_value) || "default"`
C) `try(var.optional_value, else: "default")`
D) `try(var.optional_value, default="default")`

### Question 17
How do you properly implement a feature flag pattern?

A) ```hcl
resource "ibm_is_vpc" "main" {
  count = var.features.enable_vpc
  name  = "my-vpc"
}
```

B) ```hcl
resource "ibm_is_vpc" "main" {
  count = var.features.enable_vpc ? 1 : 0
  name  = "my-vpc"
}
```

C) ```hcl
resource "ibm_is_vpc" "main" {
  enabled = var.features.enable_vpc
  name    = "my-vpc"
}
```

D) ```hcl
if (var.features.enable_vpc) {
  resource "ibm_is_vpc" "main" {
    name = "my-vpc"
  }
}
```

### Question 18
Which local value correctly implements environment-based configuration?

A) ```hcl
locals {
  config = var.environment == "prod" ? var.prod_config : var.dev_config
}
```

B) ```hcl
locals {
  config = {
    prod = var.prod_config
    dev  = var.dev_config
  }[var.environment]
}
```

C) ```hcl
locals {
  config = lookup({
    prod = var.prod_config
    dev  = var.dev_config
  }, var.environment, var.default_config)
}
```

D) All of the above are correct

### Question 19
What is the correct syntax for variable validation with custom error messages?

A) ```hcl
validation {
  condition     = contains(["dev", "staging", "prod"], var.environment)
  error_message = "Environment must be dev, staging, or prod"
}
```

B) ```hcl
validate {
  rule    = var.environment in ["dev", "staging", "prod"]
  message = "Invalid environment"
}
```

C) ```hcl
validation {
  check = var.environment matches ["dev", "staging", "prod"]
  error = "Environment must be dev, staging, or prod"
}
```

D) ```hcl
constraint {
  condition = var.environment == "dev" || var.environment == "staging" || var.environment == "prod"
  message   = "Invalid environment"
}
```

### Question 20
How do you properly handle sensitive outputs in a structured format?

A) ```hcl
output "credentials" {
  sensitive = true
  value = {
    username = var.username
    password = random_password.db.result
  }
}
```

B) ```hcl
output "credentials" {
  value = {
    username = var.username
    password = sensitive(random_password.db.result)
  }
}
```

C) ```hcl
sensitive_output "credentials" {
  value = {
    username = var.username
    password = random_password.db.result
  }
}
```

D) ```hcl
output "credentials" {
  value = sensitive({
    username = var.username
    password = random_password.db.result
  })
}
```

---

## Section B: Scenario-Based Questions (30 points)
*Analyze each scenario and provide the best solution. Each question is worth 6 points.*

### Scenario 1: Multi-Environment Configuration
You need to create a Terraform configuration that supports development, staging, and production environments with different resource sizing, security requirements, and compliance frameworks.

**Question**: Design a variable structure that allows for environment-specific configurations while maintaining code reusability. Include validation rules and default values.

**Requirements**:
- Support for 3 environments with different instance sizes
- Environment-specific compliance frameworks
- Validation for environment names and resource limits
- Default values for development environment

### Scenario 2: Dynamic Resource Creation
Your organization needs to deploy a variable number of subnets across multiple availability zones based on configuration. The number of subnets and their CIDR blocks should be configurable.

**Question**: Create a solution using HCL that dynamically creates subnets based on input variables. Include proper validation for CIDR blocks and availability zone distribution.

**Requirements**:
- Dynamic subnet creation based on input list
- CIDR block validation
- Availability zone distribution
- Proper resource naming conventions

### Scenario 3: Complex Output Strategy
You're building a Terraform module that needs to provide comprehensive outputs for integration with other modules. The outputs should include network information, security configurations, and cost estimates.

**Question**: Design an output structure that provides all necessary information for module consumers while properly handling sensitive data and providing clear documentation.

**Requirements**:
- Structured outputs for easy consumption
- Sensitive data handling
- Integration-ready format
- Clear documentation and descriptions

### Scenario 4: Feature Flag Implementation
Your team wants to implement feature flags to enable/disable various infrastructure components based on requirements and environment. This should include conditional resource creation and configuration.

**Question**: Implement a comprehensive feature flag system using HCL that allows for granular control over infrastructure components.

**Requirements**:
- Boolean feature flags for major components
- Conditional resource creation
- Environment-based default values
- Impact on resource configuration

### Scenario 5: Cost Optimization Configuration
You need to implement cost optimization features that adjust resource configurations based on environment and usage patterns. This should include instance sizing, storage types, and backup strategies.

**Question**: Create a configuration system that automatically optimizes costs based on environment and feature flags while maintaining performance requirements.

**Requirements**:
- Environment-based resource optimization
- Cost-performance trade-offs
- Configurable optimization levels
- Impact analysis and reporting

---

## Section C: Hands-On Challenges (30 points)
*Complete the practical exercises using the provided lab environment. Each challenge is worth 10 points.*

### Challenge 1: Advanced Variable Implementation (10 points)
Using the provided Terraform configuration in Lab 4.2:

1. **Modify the `project_configuration` variable** to include a new nested object for `security_requirements` with the following attributes:
   - `encryption_level` (string): "basic", "standard", or "advanced"
   - `access_controls` (list of strings): List of required access controls
   - `audit_frequency` (number): Days between audits (7-365)

2. **Add comprehensive validation rules** for the new attributes:
   - Encryption level must be one of the allowed values
   - Access controls list cannot be empty
   - Audit frequency must be within the specified range

3. **Update the default values** to include reasonable defaults for a development environment

4. **Test your implementation** by running `terraform validate` and attempting to use invalid values

**Deliverables**:
- Modified `variables.tf` file
- Test results showing validation working correctly
- Documentation of the changes made

### Challenge 2: Dynamic Configuration with Local Values (10 points)
Enhance the existing configuration with advanced local value computations:

1. **Create a local value** called `optimized_configuration` that:
   - Calculates optimal instance types based on environment and workload
   - Determines storage configurations based on performance requirements
   - Sets appropriate backup and monitoring levels

2. **Implement conditional logic** that:
   - Adjusts configurations based on compliance requirements
   - Optimizes costs for non-production environments
   - Ensures security requirements are met for production

3. **Add computed tags** that include:
   - Cost center allocation based on environment
   - Compliance framework indicators
   - Optimization level indicators

4. **Validate the logic** by testing with different environment configurations

**Deliverables**:
- Enhanced `main.tf` with new local values
- Test results with different environment configurations
- Documentation explaining the optimization logic

### Challenge 3: Comprehensive Output Design (10 points)
Design and implement a sophisticated output strategy:

1. **Create structured outputs** that provide:
   - Complete deployment summary with metadata
   - Integration-ready configuration data
   - Cost analysis and optimization recommendations
   - Security and compliance status

2. **Implement conditional outputs** that:
   - Show different information based on environment
   - Handle sensitive data appropriately
   - Provide debug information when enabled

3. **Add output validation** that:
   - Ensures all required outputs are present
   - Validates output format and structure
   - Provides meaningful descriptions

4. **Test the outputs** by running `terraform plan` and reviewing the output structure

**Deliverables**:
- Enhanced `outputs.tf` with comprehensive output strategy
- Test results showing output structure
- Documentation of output usage patterns

---

## Answer Key and Scoring Rubric

### Section A: Multiple Choice (40 points)
1. A (2 pts) - Correct object type definition with validation
2. B (2 pts) - Local values are referenced with `local.`
3. B (2 pts) - Uses `can()` function for safe regex validation
4. B (2 pts) - Conditional resources use count with ternary operator
5. A (2 pts) - Correct sensitive output syntax
6. A (2 pts) - Proper dynamic block syntax
7. A (2 pts) - Correct for expression syntax
8. A (2 pts) - Ternary operator for conditional logic
9. A (2 pts) - merge() function for combining maps
10. A (2 pts) - optional() for optional attributes
11. A (2 pts) - Module outputs referenced with module.name.output
12. A (2 pts) - can() function for type checking
13. A (2 pts) - Multiple conditions with && operator
14. A (2 pts) - For expression creating map with key => value
15. C (2 pts) - Structured output for module integration
16. A (2 pts) - try() with fallback value
17. B (2 pts) - Feature flags with conditional count
18. D (2 pts) - All approaches are valid for environment-based config
19. A (2 pts) - Correct validation syntax with contains()
20. A (2 pts) - Sensitive flag on entire output

### Section B: Scenarios (30 points)
Each scenario is evaluated based on:
- **Technical Accuracy** (2 pts): Correct HCL syntax and Terraform concepts
- **Completeness** (2 pts): Addresses all requirements
- **Best Practices** (2 pts): Follows Terraform and HCL best practices

### Section C: Hands-On (30 points)
Each challenge is evaluated based on:
- **Implementation** (4 pts): Working code that meets requirements
- **Testing** (3 pts): Proper validation and testing
- **Documentation** (3 pts): Clear documentation and explanations

### Grading Scale
- **90-100 points**: Excellent - Demonstrates mastery of advanced HCL concepts
- **80-89 points**: Good - Shows solid understanding with minor gaps
- **70-79 points**: Satisfactory - Basic understanding but needs improvement
- **Below 70 points**: Needs Review - Requires additional study and practice

---

**Assessment Duration**: 90 minutes  
**Resources Allowed**: Terraform documentation, HCL syntax reference  
**Submission**: Submit all files and documentation as specified in each section
