# Test Your Understanding: Topic 3.1 - Directory Structure and Configuration Files

## 📋 **Assessment Overview**

This assessment evaluates your understanding of Terraform project organization, configuration file structure, and enterprise best practices for IBM Cloud infrastructure automation. Complete all sections to demonstrate mastery of directory structure and configuration file concepts.

**Time Allocation**: 45-60 minutes  
**Passing Score**: 80% (24/30 points)  
**Assessment Type**: Mixed format (Multiple Choice, Scenarios, Hands-on)

---

## 📝 **Section A: Multiple Choice Questions (20 points)**

### **Question 1** (1 point)
Which file is responsible for defining input parameters in a Terraform project?

A) `providers.tf`  
B) `variables.tf`  
C) `main.tf`  
D) `outputs.tf`

### **Question 2** (1 point)
What is the recommended naming convention for IBM Cloud resources in this course?

A) `{resource-type}-{project}-{environment}`  
B) `{project}-{environment}-{resource-type}-{identifier}`  
C) `{environment}-{project}-{identifier}`  
D) `{identifier}-{resource-type}-{project}`

### **Question 3** (1 point)
Which file should contain the Terraform version constraints and provider requirements?

A) `main.tf`  
B) `variables.tf`  
C) `providers.tf`  
D) `versions.tf`

### **Question 4** (1 point)
What is the purpose of the `terraform.tfvars.example` file?

A) Store actual variable values for deployment  
B) Provide example variable values for team members  
C) Define variable validation rules  
D) Configure provider authentication

### **Question 5** (1 point)
Which of the following should NOT be committed to version control?

A) `providers.tf`  
B) `terraform.tfvars`  
C) `variables.tf`  
D) `README.md`

### **Question 6** (1 point)
In the enterprise directory pattern, what is the recommended approach for multi-environment organization?

A) Single directory with environment variables  
B) Separate directories for each environment  
C) Different repositories for each environment  
D) Environment-specific provider configurations only

### **Question 7** (1 point)
What is the primary benefit of using local values in Terraform configurations?

A) Reduce code duplication and improve maintainability  
B) Store sensitive information securely  
C) Define input parameters  
D) Configure provider authentication

### **Question 8** (1 point)
Which validation constraint ensures a project name contains only lowercase letters, numbers, and hyphens?

A) `can(regex("^[a-zA-Z0-9-]+$", var.project_name))`  
B) `can(regex("^[a-z0-9-]+$", var.project_name))`  
C) `contains(["a-z", "0-9", "-"], var.project_name)`  
D) `length(var.project_name) > 0`

### **Question 9** (1 point)
What is the estimated monthly cost for a basic VPC with 3 subnets and no public gateways?

A) $45-135 USD  
B) $15-35 USD  
C) $0-5 USD  
D) $100-200 USD

### **Question 10** (1 point)
Which command should be run first when working with a new Terraform configuration?

A) `terraform plan`  
B) `terraform apply`  
C) `terraform init`  
D) `terraform validate`

### **Question 11** (1 point)
What is the purpose of the `random_string` resource in the lab configuration?

A) Generate passwords for authentication  
B) Create unique suffixes for resource names  
C) Provide encryption keys  
D) Generate random IP addresses

### **Question 12** (1 point)
Which IBM Cloud resource incurs the highest cost in the lab configuration?

A) VPC  
B) Subnets  
C) Security Groups  
D) Public Gateways

### **Question 13** (1 point)
What is the recommended approach for handling sensitive variables like API keys?

A) Store in `terraform.tfvars` and commit to version control  
B) Use environment variables or external secret management  
C) Hard-code in `variables.tf`  
D) Store in `main.tf` with encryption

### **Question 14** (1 point)
Which file extension is used for Terraform configuration files?

A) `.terraform`  
B) `.tf`  
C) `.hcl`  
D) `.json`

### **Question 15** (1 point)
What is the purpose of the `depends_on` attribute in Terraform resources?

A) Define variable dependencies  
B) Specify explicit resource dependencies  
C) Configure provider dependencies  
D) Set output dependencies

### **Question 16** (1 point)
Which security group rule direction allows resources to access the internet?

A) `inbound`  
B) `outbound`  
C) `bidirectional`  
D) `external`

### **Question 17** (1 point)
What is the recommended minimum Terraform version for this lab?

A) 1.0.0  
B) 1.3.0  
C) 1.5.0  
D) 1.7.0

### **Question 18** (1 point)
Which tag is automatically added to resources in the lab configuration?

A) `created_by = "terraform"`  
B) `managed_by = "user"`  
C) `environment = "production"`  
D) `cost_center = "default"`

### **Question 19** (1 point)
What is the purpose of the `time_sleep` resource in the configuration?

A) Add delays for resource stabilization  
B) Track deployment duration  
C) Schedule resource creation  
D) Implement timeout controls

### **Question 20** (1 point)
Which output provides comprehensive project deployment information?

A) `vpc_id`  
B) `project_info`  
C) `subnet_ids`  
D) `security_group_id`

---

## 🎯 **Section B: Scenario-Based Questions (5 points)**

### **Scenario 1** (2 points)
Your team is implementing a multi-environment Terraform setup for a web application. You need to organize the project to support development, staging, and production environments while maintaining code reusability and security.

**Question**: Design a directory structure that supports this requirement. Explain how you would organize the files and what considerations you would make for each environment.

**Answer Guidelines**:
- Describe directory organization approach
- Explain file separation strategy
- Address security considerations
- Discuss variable management across environments

### **Scenario 2** (1.5 points)
A developer on your team has created a Terraform configuration but is experiencing validation errors. The configuration includes hardcoded values, missing variable descriptions, and no validation rules.

**Question**: Identify the issues and provide specific recommendations for improving the configuration following enterprise best practices.

**Answer Guidelines**:
- Identify specific issues with hardcoded values
- Recommend variable validation improvements
- Suggest documentation enhancements
- Propose security improvements

### **Scenario 3** (1.5 points)
Your organization wants to implement cost optimization for their IBM Cloud Terraform deployments. The current configuration creates public gateways for all environments, even when internet access isn't required.

**Question**: Propose a solution that allows flexible public gateway configuration while maintaining cost efficiency. Include specific variable and resource modifications.

**Answer Guidelines**:
- Propose variable-driven public gateway configuration
- Explain cost implications
- Suggest environment-specific defaults
- Recommend monitoring approaches

---

## 🛠️ **Section C: Hands-on Challenges (5 points)**

### **Challenge 1: Configuration Enhancement** (2 points)
Modify the provided Terraform configuration to add the following features:
1. Add a variable for VPC address prefix management
2. Implement validation for the new variable
3. Add an output that displays the total estimated monthly cost
4. Include proper documentation for all changes

**Deliverables**:
- Modified `variables.tf` with new variable and validation
- Updated `outputs.tf` with cost calculation
- Documentation explaining the changes

### **Challenge 2: Security Hardening** (1.5 points)
Enhance the security configuration by:
1. Adding a variable for custom security group rules
2. Implementing a data source for SSH key retrieval
3. Adding validation for CIDR block overlaps
4. Creating outputs for security compliance reporting

**Deliverables**:
- Enhanced security group configuration
- New variables with appropriate validation
- Security-focused outputs

### **Challenge 3: Enterprise Integration** (1.5 points)
Prepare the configuration for enterprise deployment by:
1. Adding support for remote state configuration
2. Implementing proper tagging strategy with required tags
3. Adding monitoring and logging configuration variables
4. Creating a deployment validation script

**Deliverables**:
- Backend configuration for remote state
- Comprehensive tagging implementation
- Monitoring configuration variables
- Validation script with enterprise checks

---

## 📊 **Assessment Rubric**

### **Multiple Choice (20 points)**
- **18-20 points**: Excellent understanding of concepts
- **15-17 points**: Good understanding with minor gaps
- **12-14 points**: Adequate understanding, needs improvement
- **Below 12 points**: Requires additional study

### **Scenarios (5 points)**
- **4.5-5 points**: Comprehensive solutions with enterprise considerations
- **3.5-4.4 points**: Good solutions with most requirements addressed
- **2.5-3.4 points**: Adequate solutions with some missing elements
- **Below 2.5 points**: Incomplete or incorrect solutions

### **Hands-on (5 points)**
- **4.5-5 points**: All challenges completed with best practices
- **3.5-4.4 points**: Most challenges completed with good quality
- **2.5-3.4 points**: Some challenges completed with basic quality
- **Below 2.5 points**: Minimal completion or poor quality

---

## 🎯 **Answer Key and Explanations**

### **Section A: Multiple Choice Answers**

1. **B** - `variables.tf` defines input parameters
2. **B** - `{project}-{environment}-{resource-type}-{identifier}` is the recommended pattern
3. **C** - `providers.tf` contains version constraints and provider requirements
4. **B** - Provides example values for team members without exposing secrets
5. **B** - `terraform.tfvars` may contain sensitive information
6. **B** - Separate directories provide better isolation and management
7. **A** - Local values reduce duplication and improve maintainability
8. **B** - The regex pattern `^[a-z0-9-]+$` enforces lowercase letters, numbers, and hyphens
9. **C** - VPC, subnets, and security groups are free; only public gateways incur costs
10. **C** - `terraform init` downloads providers and initializes the working directory
11. **B** - Creates unique suffixes to avoid naming conflicts
12. **D** - Public gateways cost $45/month each
13. **B** - Environment variables or external secret management are secure approaches
14. **B** - Terraform files use the `.tf` extension
15. **B** - `depends_on` specifies explicit resource dependencies
16. **B** - Outbound rules allow resources to access external services
17. **C** - Terraform >= 1.5.0 is required for this lab
18. **A** - `created_by = "terraform"` is automatically added
19. **A** - Adds delays for resource stabilization
20. **B** - `project_info` provides comprehensive deployment information

### **Learning Outcomes Validation**

This assessment validates the following learning objectives:
- ✅ Understanding of Terraform project organization principles
- ✅ Comprehension of configuration file purposes and relationships
- ✅ Knowledge of IBM Cloud-specific patterns and conventions
- ✅ Application of enterprise best practices and security considerations
- ✅ Ability to implement proper naming conventions and documentation
- ✅ Skills in cost optimization and resource management

### **Next Steps**

Based on your assessment results:
- **Score 24-30**: Proceed to Topic 3.2 (Core Commands)
- **Score 18-23**: Review weak areas and retake assessment
- **Score Below 18**: Complete additional practice exercises before proceeding

**🎉 Congratulations on completing the Topic 3.1 assessment!**
