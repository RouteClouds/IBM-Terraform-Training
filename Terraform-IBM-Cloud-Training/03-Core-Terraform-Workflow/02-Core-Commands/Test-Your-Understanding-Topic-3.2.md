# Test Your Understanding: Topic 3.2 - Core Terraform Commands

## 📋 **Assessment Overview**

This assessment evaluates your mastery of the five core Terraform commands (init, validate, plan, apply, destroy) and their application in enterprise workflows. Complete all sections to demonstrate comprehensive understanding of command execution, sequencing, and best practices.

**Time Allocation**: 60-75 minutes  
**Passing Score**: 80% (24/30 points)  
**Assessment Type**: Mixed format (Multiple Choice, Scenarios, Hands-on)

---

## 📝 **Section A: Multiple Choice Questions (20 points)**

### **Question 1** (1 point)
Which command must be run first when working with a new Terraform configuration?

A) `terraform validate`  
B) `terraform plan`  
C) `terraform init`  
D) `terraform apply`

### **Question 2** (1 point)
What is the primary purpose of the `terraform validate` command?

A) Deploy infrastructure resources  
B) Check configuration syntax and references  
C) Generate execution plans  
D) Initialize provider plugins

### **Question 3** (1 point)
Which flag makes `terraform init` suitable for CI/CD pipelines?

A) `-upgrade`  
B) `-reconfigure`  
C) `-no-color -input=false`  
D) `-migrate-state`

### **Question 4** (1 point)
What does the `+` symbol indicate in a `terraform plan` output?

A) Resource will be updated  
B) Resource will be created  
C) Resource will be destroyed  
D) Resource will be replaced

### **Question 5** (1 point)
Which approach is recommended for production deployments?

A) `terraform apply` with interactive confirmation  
B) `terraform apply -auto-approve`  
C) `terraform apply saved-plan.tfplan`  
D) `terraform apply -target=all`

### **Question 6** (1 point)
What is the estimated monthly cost for the lab configuration with public gateway enabled?

A) $0.00  
B) $15.00  
C) $45.00  
D) $90.00

### **Question 7** (1 point)
Which command should you run to see what resources will be destroyed?

A) `terraform destroy`  
B) `terraform plan -destroy`  
C) `terraform show -destroy`  
D) `terraform state list -destroy`

### **Question 8** (1 point)
What does the `-/+` symbol indicate in a plan output?

A) Resource will be created  
B) Resource will be updated in place  
C) Resource will be destroyed and recreated  
D) Resource will be imported

### **Question 9** (1 point)
Which command refreshes the state file without making changes?

A) `terraform refresh`  
B) `terraform plan -refresh-only`  
C) `terraform apply -refresh-only`  
D) All of the above

### **Question 10** (1 point)
What is the purpose of saving a plan with `-out` flag?

A) Create a backup of the configuration  
B) Enable plan review and approval workflows  
C) Improve plan generation performance  
D) Store plan in version control

### **Question 11** (1 point)
Which validation rule ensures the project name follows naming conventions?

A) `length(var.project_name) > 0`  
B) `can(regex("^[a-z0-9-]+$", var.project_name))`  
C) `contains(["dev", "prod"], var.project_name)`  
D) `var.project_name != null`

### **Question 12** (1 point)
What happens when `terraform apply` encounters an error mid-execution?

A) All changes are automatically rolled back  
B) Terraform stops and updates state with completed changes  
C) The entire operation fails with no changes  
D) Terraform retries the failed operation automatically

### **Question 13** (1 point)
Which command shows the current state without making changes?

A) `terraform show`  
B) `terraform state list`  
C) `terraform output`  
D) All of the above

### **Question 14** (1 point)
What is the recommended approach for destroying specific resources?

A) Edit configuration and run apply  
B) Use `terraform destroy -target=resource`  
C) Manually delete from cloud console  
D) Use `terraform state rm` command

### **Question 15** (1 point)
Which environment variable enables debug logging for Terraform commands?

A) `TF_DEBUG=true`  
B) `TF_LOG=DEBUG`  
C) `TERRAFORM_LOG=debug`  
D) `DEBUG=terraform`

### **Question 16** (1 point)
What is the purpose of the `.terraform.lock.hcl` file?

A) Lock the working directory during operations  
B) Store provider version constraints  
C) Prevent concurrent Terraform runs  
D) Lock specific resource configurations

### **Question 17** (1 point)
Which flag prevents `terraform plan` from refreshing state?

A) `-no-refresh`  
B) `-refresh=false`  
C) `-skip-refresh`  
D) `-disable-refresh`

### **Question 18** (1 point)
What is the maximum recommended timeout for command execution in the lab?

A) 60 seconds  
B) 300 seconds  
C) 600 seconds  
D) 3600 seconds

### **Question 19** (1 point)
Which command combination provides the safest deployment workflow?

A) `init → validate → apply`  
B) `init → plan → apply`  
C) `init → validate → plan → apply`  
D) `validate → plan → apply → destroy`

### **Question 20** (1 point)
What does the `<=` symbol indicate in a plan output?

A) Data source will be read  
B) Resource will be imported  
C) Resource has dependencies  
D) Resource will be updated

---

## 🎯 **Section B: Scenario-Based Questions (5 points)**

### **Scenario 1** (2 points)
Your team is implementing a CI/CD pipeline for Terraform deployments. The pipeline needs to run in an automated environment without user interaction and should produce machine-readable output for further processing.

**Question**: Design a complete command sequence for the CI/CD pipeline, including all necessary flags and options. Explain how you would handle plan approval and error scenarios.

**Answer Guidelines**:
- Include appropriate flags for automation
- Address plan-based deployment workflow
- Explain error handling strategies
- Consider security and approval processes

### **Scenario 2** (1.5 points)
A developer reports that `terraform plan` is showing unexpected changes to resources that haven't been modified in the configuration. The state file appears to be out of sync with the actual infrastructure.

**Question**: Diagnose the issue and provide a step-by-step resolution process. Include commands to investigate and fix the state synchronization problem.

**Answer Guidelines**:
- Identify potential causes of state drift
- Provide diagnostic commands
- Explain state refresh procedures
- Recommend prevention strategies

### **Scenario 3** (1.5 points)
Your organization requires a two-stage approval process for production deployments: technical review of the plan and business approval for cost implications. The process must maintain audit trails and prevent unauthorized changes.

**Question**: Design a workflow that implements this approval process using Terraform commands. Include specific commands and explain how to maintain security and auditability.

**Answer Guidelines**:
- Design plan generation and review process
- Explain plan storage and security
- Address approval workflow integration
- Include audit trail considerations

---

## 🛠️ **Section C: Hands-on Challenges (5 points)**

### **Challenge 1: Advanced Command Automation** (2 points)
Create a comprehensive automation script that implements enterprise-grade command workflows with proper error handling, logging, and validation.

**Requirements**:
1. Implement complete workflow: init → validate → plan → apply → verify
2. Add proper error handling and rollback procedures
3. Include detailed logging and progress reporting
4. Support both deployment and destruction workflows
5. Add validation checkpoints and safety measures

**Deliverables**:
- Complete automation script with error handling
- Documentation explaining workflow and safety measures
- Example usage for different scenarios

### **Challenge 2: Plan Analysis and Reporting** (1.5 points)
Develop a solution that generates detailed plan analysis reports for stakeholder review and approval processes.

**Requirements**:
1. Generate plan in multiple formats (human-readable and JSON)
2. Extract and summarize resource changes by type and action
3. Calculate cost implications and resource counts
4. Create approval-ready reports with change summaries
5. Include risk assessment based on change types

**Deliverables**:
- Plan analysis script with multiple output formats
- Sample reports showing change analysis
- Risk assessment methodology

### **Challenge 3: State Management and Recovery** (1.5 points)
Implement a comprehensive state management solution with backup, validation, and recovery capabilities.

**Requirements**:
1. Create automated state backup procedures
2. Implement state validation and consistency checks
3. Develop state recovery and rollback mechanisms
4. Add state drift detection and reporting
5. Include disaster recovery procedures

**Deliverables**:
- State management automation scripts
- Backup and recovery procedures
- Drift detection and reporting tools

---

## 📊 **Assessment Rubric**

### **Multiple Choice (20 points)**
- **18-20 points**: Excellent command mastery and understanding
- **15-17 points**: Good understanding with minor knowledge gaps
- **12-14 points**: Adequate understanding, needs reinforcement
- **Below 12 points**: Requires additional study and practice

### **Scenarios (5 points)**
- **4.5-5 points**: Comprehensive solutions with enterprise considerations
- **3.5-4.4 points**: Good solutions addressing most requirements
- **2.5-3.4 points**: Adequate solutions with some missing elements
- **Below 2.5 points**: Incomplete or incorrect solutions

### **Hands-on (5 points)**
- **4.5-5 points**: All challenges completed with advanced techniques
- **3.5-4.4 points**: Most challenges completed with good implementation
- **2.5-3.4 points**: Some challenges completed with basic implementation
- **Below 2.5 points**: Minimal completion or poor implementation

---

## 🎯 **Answer Key and Explanations**

### **Section A: Multiple Choice Answers**

1. **C** - `terraform init` must be run first to download providers and initialize the working directory
2. **B** - `terraform validate` checks configuration syntax and references without accessing remote services
3. **C** - `-no-color -input=false` flags make init suitable for automated environments
4. **B** - `+` indicates a new resource will be created
5. **C** - Plan-based deployment with saved plans is recommended for production
6. **C** - Public gateway costs $45/month, other resources are free
7. **B** - `terraform plan -destroy` shows what will be destroyed without executing
8. **C** - `-/+` indicates resource will be destroyed and recreated (replaced)
9. **D** - All three commands can refresh state without making changes
10. **B** - Saved plans enable review and approval workflows
11. **B** - The regex pattern enforces lowercase letters, numbers, and hyphens
12. **B** - Terraform stops on error and updates state with completed changes
13. **D** - All commands show current state information without changes
14. **B** - Targeted destruction is the recommended approach for specific resources
15. **B** - `TF_LOG=DEBUG` enables debug logging
16. **B** - Lock file stores provider version constraints and checksums
17. **B** - `-refresh=false` prevents state refresh during planning
18. **B** - 300 seconds (5 minutes) is the recommended timeout
19. **C** - Complete sequence ensures safety and validation
20. **A** - `<=` indicates a data source will be read

### **Learning Outcomes Validation**

This assessment validates the following learning objectives:
- ✅ Mastery of all five core Terraform commands
- ✅ Understanding of command sequencing and dependencies
- ✅ Knowledge of enterprise workflow patterns
- ✅ Ability to implement automation and error handling
- ✅ Skills in plan-based deployment processes
- ✅ Comprehension of state management concepts

### **Next Steps**

Based on your assessment results:
- **Score 24-30**: Proceed to Topic 3.3 (Provider Configuration)
- **Score 18-23**: Review weak areas and practice additional exercises
- **Score Below 18**: Complete additional hands-on practice before proceeding

**🎉 Congratulations on completing the Core Commands assessment!**
