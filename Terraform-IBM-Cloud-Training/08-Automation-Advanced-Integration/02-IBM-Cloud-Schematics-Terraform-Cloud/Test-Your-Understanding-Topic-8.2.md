# Test Your Understanding - Topic 8.2: IBM Cloud Schematics & Terraform Cloud Integration

## 📋 **Assessment Overview**

**Topic**: IBM Cloud Schematics & Terraform Cloud Integration  
**Duration**: 45 minutes  
**Total Points**: 100 points  
**Passing Score**: 80%  

**Assessment Structure**:
- **Part A**: Multiple Choice Questions (20 questions × 3 points = 60 points)
- **Part B**: Scenario-Based Questions (5 scenarios × 6 points = 30 points)  
- **Part C**: Hands-On Challenges (3 challenges × 3-4 points = 10 points)

---

## 📝 **Part A: Multiple Choice Questions (60 points)**

### **Question 1** (3 points)
What is the primary benefit of integrating IBM Cloud Schematics with Terraform Cloud?

A) Reduced infrastructure costs by 50%  
B) Unified workflow management across hybrid cloud environments  
C) Automatic resource provisioning without configuration  
D) Elimination of all manual processes  

**Correct Answer**: B

---

### **Question 2** (3 points)
Which IBM Cloud service provides managed Terraform execution with enterprise-grade security?

A) IBM Cloud Functions  
B) IBM Cloud Schematics  
C) IBM Cloud Code Engine  
D) IBM Cloud Container Registry  

**Correct Answer**: B

---

### **Question 3** (3 points)
In a multi-workspace orchestration scenario, what determines the execution order?

A) Alphabetical order of workspace names  
B) Creation timestamp of workspaces  
C) Workspace dependencies and data sharing requirements  
D) Resource group assignment  

**Correct Answer**: C

---

### **Question 4** (3 points)
What is the recommended approach for managing sensitive variables in Schematics workspaces?

A) Store them in plain text in terraform.tfvars  
B) Use environment variables with secure flag enabled  
C) Include them directly in the Terraform configuration  
D) Share them via email with team members  

**Correct Answer**: B

---

### **Question 5** (3 points)
Which IAM role provides the minimum permissions needed to execute Terraform plans in Schematics?

A) Viewer  
B) Operator  
C) Editor  
D) Manager  

**Correct Answer**: B

---

### **Question 6** (3 points)
What is the primary purpose of workspace templates in IBM Cloud Schematics?

A) To reduce storage costs  
B) To standardize infrastructure patterns and configurations  
C) To increase execution speed  
D) To eliminate the need for Terraform knowledge  

**Correct Answer**: B

---

### **Question 7** (3 points)
In Terraform Cloud integration, what enables cross-platform variable sharing?

A) Local file synchronization  
B) Environment variables and workspace data sources  
C) Manual copy-paste operations  
D) Email notifications  

**Correct Answer**: B

---

### **Question 8** (3 points)
Which feature enables automated cost optimization in Schematics workspaces?

A) Manual resource review  
B) Policy as code with budget enforcement  
C) Daily email reports  
D) Resource naming conventions  

**Correct Answer**: B

---

### **Question 9** (3 points)
What is the maximum number of workspaces that can be managed in a single IBM Cloud Schematics instance?

A) 10 workspaces  
B) 50 workspaces  
C) 100 workspaces  
D) No specific limit (depends on account quotas)  

**Correct Answer**: D

---

### **Question 10** (3 points)
Which service provides comprehensive audit logging for Schematics workspace activities?

A) IBM Cloud Monitoring  
B) IBM Cloud Activity Tracker  
C) IBM Cloud Log Analysis  
D) IBM Cloud Security Advisor  

**Correct Answer**: B

---

### **Question 11** (3 points)
In team collaboration scenarios, what determines workspace access permissions?

A) Workspace creation order  
B) IAM access groups and policies  
C) Resource group ownership  
D) Terraform configuration complexity  

**Correct Answer**: B

---

### **Question 12** (3 points)
What is the recommended frequency for workspace state backups in production environments?

A) Never (not necessary)  
B) Monthly  
C) Weekly  
D) Before every apply operation  

**Correct Answer**: D

---

### **Question 13** (3 points)
Which Terraform Cloud feature enhances security when integrated with IBM Cloud Schematics?

A) Automatic resource tagging  
B) Policy as code validation  
C) Cost estimation  
D) Version control integration  

**Correct Answer**: B

---

### **Question 14** (3 points)
What is the primary advantage of using workspace dependencies over monolithic configurations?

A) Reduced execution time  
B) Improved modularity and risk isolation  
C) Lower storage requirements  
D) Simplified debugging  

**Correct Answer**: B

---

### **Question 15** (3 points)
In cost optimization scenarios, what triggers automated resource cleanup?

A) Manual intervention only  
B) Scheduled policies and budget thresholds  
C) Resource age limits  
D) User inactivity  

**Correct Answer**: B

---

### **Question 16** (3 points)
Which data source enables cross-workspace communication in Schematics?

A) `ibm_schematics_workspace`  
B) `ibm_resource_group`  
C) `ibm_iam_account`  
D) `ibm_cloud_region`  

**Correct Answer**: A

---

### **Question 17** (3 points)
What is the recommended approach for handling workspace failures in production?

A) Immediately retry the operation  
B) Analyze logs, fix issues, then retry with validation  
C) Delete and recreate the workspace  
D) Switch to manual resource management  

**Correct Answer**: B

---

### **Question 18** (3 points)
Which feature enables real-time collaboration between team members on Schematics workspaces?

A) Shared file systems  
B) Workspace locking and approval workflows  
C) Email notifications  
D) Chat integration  

**Correct Answer**: B

---

### **Question 19** (3 points)
In hybrid cloud scenarios, what ensures consistency between Schematics and Terraform Cloud workspaces?

A) Manual synchronization  
B) Shared variable sets and standardized templates  
C) Identical naming conventions  
D) Regular backup procedures  

**Correct Answer**: B

---

### **Question 20** (3 points)
What is the primary benefit of implementing policy as code in Schematics workspaces?

A) Faster execution times  
B) Automated compliance validation and governance  
C) Reduced storage costs  
D) Simplified user interface  

**Correct Answer**: B

---

## 🎯 **Part B: Scenario-Based Questions (30 points)**

### **Scenario 1: Enterprise Multi-Team Environment** (6 points)

**Context**: A large enterprise has three teams (Development, Infrastructure, Operations) that need to collaborate on cloud infrastructure using IBM Cloud Schematics. Each team requires different access levels and responsibilities.

**Question**: Design an access control strategy that enables secure collaboration while maintaining proper separation of duties. Include IAM access groups, policies, and workspace organization.

**Expected Answer Elements**:
- Three distinct IAM access groups for each team
- Graduated permissions (Dev: Viewer, Infra: Operator, Ops: Manager)
- Resource group segregation by environment
- Workspace naming conventions and organization
- Audit logging and compliance controls

---

### **Scenario 2: Cost Optimization Challenge** (6 points)

**Context**: A company's monthly IBM Cloud costs have increased by 40% due to unmanaged Schematics workspaces. They need to implement automated cost controls and optimization strategies.

**Question**: Propose a comprehensive cost optimization solution using Schematics features, including budget controls, automated cleanup, and monitoring strategies.

**Expected Answer Elements**:
- Budget enforcement policies and alert thresholds
- Automated resource lifecycle management
- Scheduled cleanup for non-production environments
- Cost tracking tags and reporting
- Resource right-sizing recommendations

---

### **Scenario 3: Hybrid Cloud Integration** (6 points)

**Context**: An organization uses both IBM Cloud and AWS, requiring unified infrastructure automation. They want to leverage both IBM Cloud Schematics and Terraform Cloud for optimal hybrid cloud management.

**Question**: Design an integration architecture that enables seamless workflow management across both platforms while maintaining security and governance standards.

**Expected Answer Elements**:
- Terraform Cloud workspace configuration
- Cross-platform variable sharing mechanisms
- Unified policy enforcement
- State management strategies
- Security and compliance considerations

---

### **Scenario 4: Disaster Recovery Planning** (6 points)

**Context**: A critical production environment managed by Schematics needs a comprehensive disaster recovery strategy to ensure business continuity.

**Question**: Develop a disaster recovery plan that includes backup strategies, recovery procedures, and business continuity measures for Schematics-managed infrastructure.

**Expected Answer Elements**:
- State backup and versioning strategies
- Multi-region deployment patterns
- Recovery time and point objectives
- Automated failover procedures
- Testing and validation protocols

---

### **Scenario 5: Compliance and Governance** (6 points)

**Context**: A financial services company must ensure their Schematics workspaces comply with strict regulatory requirements including SOX, PCI-DSS, and internal governance policies.

**Question**: Design a governance framework that ensures continuous compliance while enabling efficient infrastructure automation.

**Expected Answer Elements**:
- Policy as code implementation
- Automated compliance validation
- Audit trail and reporting mechanisms
- Role-based access controls
- Regular compliance assessments

---

## 🛠️ **Part C: Hands-On Challenges (10 points)**

### **Challenge 1: Workspace Dependency Configuration** (3 points)

**Task**: Configure a network infrastructure workspace that outputs VPC and subnet information, then create a dependent application workspace that consumes these outputs.

**Deliverables**:
- Network workspace configuration with proper outputs
- Application workspace with data source references
- Dependency validation and testing

**Evaluation Criteria**:
- Correct data source configuration
- Proper output formatting
- Successful dependency resolution

---

### **Challenge 2: Team Access Group Setup** (3 points)

**Task**: Create an IAM access group for a development team with appropriate Schematics permissions, add team members, and validate access levels.

**Deliverables**:
- IAM access group configuration
- Policy assignments for Schematics access
- Team member assignments and validation

**Evaluation Criteria**:
- Correct permission levels
- Proper policy configuration
- Successful access validation

---

### **Challenge 3: Cost Tracking Implementation** (4 points)

**Task**: Implement comprehensive cost tracking for a Schematics workspace including budget alerts, resource tagging, and automated reporting.

**Deliverables**:
- Budget configuration with alert thresholds
- Resource tagging strategy implementation
- Cost monitoring dashboard setup

**Evaluation Criteria**:
- Accurate budget configuration
- Comprehensive resource tagging
- Functional monitoring setup

---

## 📊 **Answer Key and Scoring Guide**

### **Part A Scoring** (60 points total)
- Each correct answer: 3 points
- Partial credit: Not applicable for multiple choice

### **Part B Scoring** (30 points total)
- **Excellent (6 points)**: Comprehensive solution addressing all requirements
- **Good (4-5 points)**: Solid solution with minor gaps
- **Satisfactory (2-3 points)**: Basic solution meeting core requirements
- **Needs Improvement (0-1 points)**: Incomplete or incorrect solution

### **Part C Scoring** (10 points total)
- **Challenge 1 & 2 (3 points each)**:
  - Complete and functional: 3 points
  - Mostly functional with minor issues: 2 points
  - Partially functional: 1 point
  - Non-functional: 0 points

- **Challenge 3 (4 points)**:
  - Complete implementation: 4 points
  - Good implementation with minor gaps: 3 points
  - Basic implementation: 2 points
  - Incomplete implementation: 1 point
  - Non-functional: 0 points

---

## 🎓 **Learning Outcomes Validation**

Upon successful completion of this assessment, students demonstrate:

1. **Technical Mastery**: Understanding of Schematics and Terraform Cloud integration
2. **Practical Application**: Ability to implement real-world solutions
3. **Problem-Solving**: Capability to address complex enterprise scenarios
4. **Best Practices**: Knowledge of security, cost optimization, and governance
5. **Hands-On Skills**: Practical experience with configuration and implementation

---

## 📚 **Additional Study Resources**

- **Concept.md**: Comprehensive theoretical foundation
- **Lab-16.md**: Hands-on practical exercises
- **Terraform-Code-Lab-8.2**: Complete working examples
- **IBM Cloud Documentation**: Official Schematics documentation
- **Terraform Cloud Documentation**: Integration best practices

---

*This assessment validates comprehensive understanding of IBM Cloud Schematics and Terraform Cloud integration for enterprise-grade infrastructure automation.*
