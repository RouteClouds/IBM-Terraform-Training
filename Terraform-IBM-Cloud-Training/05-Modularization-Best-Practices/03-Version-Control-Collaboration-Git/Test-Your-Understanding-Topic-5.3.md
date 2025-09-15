# Test Your Understanding: Topic 5.3 - Version Control and Collaboration with Git

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your understanding of Git workflows, team collaboration patterns, CI/CD integration, and enterprise governance for Terraform projects. The assessment includes multiple choice questions, scenario-based problems, and hands-on challenges that mirror real-world enterprise environments.

**Time Allocation:**
- Multiple Choice Questions: 30 minutes
- Scenario-Based Questions: 45 minutes  
- Hands-On Challenges: 90 minutes
- **Total Time: 165 minutes (2 hours 45 minutes)**

---

## 🎯 **Part A: Multiple Choice Questions (20 Questions)**

### **Git Workflow Fundamentals**

**1. In GitFlow workflow, which branch should be used for preparing a new production release?**
a) `main`
b) `develop` 
c) `release/v1.2.0`
d) `feature/new-release`

**2. What is the primary advantage of GitHub Flow over GitFlow for continuous deployment?**
a) Better support for hotfixes
b) Simpler branching model with faster integration
c) More comprehensive testing stages
d) Better isolation of features

**3. In trunk-based development, what is the maximum recommended lifetime for feature branches?**
a) 1 week
b) 2-3 days
c) 1 month
d) Until the feature is complete

**4. Which Git workflow pattern is most suitable for teams practicing continuous deployment to production?**
a) GitFlow
b) GitHub Flow
c) GitLab Flow
d) Feature branching

### **Branch Protection and Security**

**5. What is the purpose of requiring status checks before merging to the main branch?**
a) To ensure code formatting consistency
b) To validate that automated tests and security scans pass
c) To enforce commit message standards
d) To prevent merge conflicts

**6. In a CODEOWNERS file, what does the pattern `*.tf @platform-team @security-team` accomplish?**
a) Assigns ownership of all Terraform files to both teams
b) Requires approval from both teams for Terraform file changes
c) Notifies both teams when Terraform files are modified
d) Grants write access to both teams for Terraform files

**7. Which pre-commit hook is most critical for Terraform security?**
a) Code formatting validation
b) Commit message linting
c) Secret scanning and sensitive data detection
d) Documentation generation

**8. What is the recommended approach for storing sensitive values in Terraform configurations?**
a) Encrypt them in the terraform.tfvars file
b) Use environment variables or external secret management
c) Store them in a separate encrypted file
d) Use Terraform's built-in encryption

### **CI/CD Pipeline Integration**

**9. In a Terraform CI/CD pipeline, what should happen when a pull request is created?**
a) Automatically apply the changes to staging
b) Run terraform plan and security scans
c) Merge the changes to develop branch
d) Deploy to production environment

**10. Which tool is specifically designed for Terraform cost analysis in CI/CD pipelines?**
a) TFSec
b) Checkov
c) Infracost
d) Terrascan

**11. What is the purpose of running `terraform plan` in a CI/CD pipeline?**
a) To apply changes to infrastructure
b) To validate syntax and show proposed changes
c) To format the Terraform code
d) To initialize the Terraform backend

**12. When should `terraform apply` be automatically executed in a CI/CD pipeline?**
a) On every pull request
b) Only on pushes to the main branch after approval
c) When security scans pass
d) During the validation stage

### **Team Collaboration and RBAC**

**13. In a multi-team environment, what is the best practice for organizing Terraform code repositories?**
a) One repository per team
b) One monolithic repository for all infrastructure
c) Separate repositories by environment (dev, staging, prod)
d) Organize by service or domain boundaries

**14. What role should have the ability to approve production deployments?**
a) Any team member
b) Senior engineers only
c) Platform team and security team leads
d) External auditors

**15. How should team access to different environments be managed?**
a) All teams have access to all environments
b) Role-based access with environment-specific permissions
c) Only platform team has production access
d) Access based on seniority level

**16. What is the recommended approach for handling emergency hotfixes in GitFlow?**
a) Create hotfix branch from main, merge back to main and develop
b) Push directly to main branch
c) Create feature branch and fast-track through normal process
d) Apply changes directly in production

### **Policy as Code and Compliance**

**17. What is the primary purpose of Open Policy Agent (OPA) in Terraform workflows?**
a) Code formatting and linting
b) Automated testing of infrastructure
c) Policy enforcement and compliance validation
d) Cost optimization recommendations

**18. Which compliance framework requires the most comprehensive audit logging?**
a) SOC 2
b) ISO 27001
c) PCI DSS
d) All require similar levels of audit logging

**19. What should happen when a policy violation is detected in the CI/CD pipeline?**
a) Log a warning and continue
b) Block the deployment and require manual review
c) Automatically fix the violation
d) Send notification to security team

**20. How should policy violations be handled in different environments?**
a) Same enforcement level across all environments
b) Stricter enforcement in production, warnings in development
c) No enforcement in development, strict in production
d) Manual review required for all violations

---

## 🎭 **Part B: Scenario-Based Questions (5 Scenarios)**

### **Scenario 1: Multi-Team Collaboration Crisis**

Your organization has 4 development teams working on the same infrastructure codebase. Recently, there have been conflicts with teams overwriting each other's changes, inconsistent deployment practices, and security vulnerabilities being introduced. The platform team has asked you to design a comprehensive Git workflow and collaboration strategy.

**Questions:**
1. **Workflow Design (15 points):** Design a Git workflow strategy that accommodates 4 teams with different responsibilities (web, API, data, security). Include branching strategy, merge policies, and approval workflows.

2. **RBAC Implementation (10 points):** Define role-based access control with specific permissions for each team. Include repository access, branch permissions, and deployment rights.

3. **Security Integration (10 points):** Describe how you would integrate security scanning, policy enforcement, and compliance validation into the workflow.

**Sample Answer Framework:**
- Choose appropriate workflow pattern (GitFlow recommended for multiple teams)
- Define team-specific branch permissions and review requirements
- Implement CODEOWNERS for mandatory security team reviews
- Set up automated security scanning with blocking policies
- Establish environment-specific deployment gates

### **Scenario 2: CI/CD Pipeline Optimization**

Your current CI/CD pipeline for Terraform deployments takes 45 minutes to complete and frequently fails due to various validation issues. The business is demanding faster deployment cycles while maintaining security and compliance standards.

**Questions:**
1. **Pipeline Optimization (15 points):** Design an optimized CI/CD pipeline that reduces deployment time while maintaining quality gates. Include parallel execution strategies and caching mechanisms.

2. **Failure Handling (10 points):** Describe how you would implement automated rollback and failure recovery mechanisms.

3. **Performance Metrics (10 points):** Define key performance indicators (KPIs) for measuring pipeline effectiveness and team productivity.

### **Scenario 3: Compliance and Audit Requirements**

Your organization must comply with SOC 2, ISO 27001, and PCI DSS requirements. Auditors have identified gaps in your current Terraform workflow including insufficient audit logging, lack of policy enforcement, and inadequate access controls.

**Questions:**
1. **Audit Trail Implementation (15 points):** Design a comprehensive audit logging strategy that captures all infrastructure changes, approvals, and access patterns.

2. **Policy Enforcement (10 points):** Implement policy as code using OPA/Conftest to enforce compliance requirements automatically.

3. **Access Control Hardening (10 points):** Strengthen access controls to meet compliance requirements while maintaining operational efficiency.

### **Scenario 4: Cost Management and Optimization**

Infrastructure costs have increased by 300% over the past year due to uncontrolled resource provisioning and lack of cost visibility. You need to implement cost management controls within the Git workflow and CI/CD pipeline.

**Questions:**
1. **Cost Control Integration (15 points):** Design cost management controls that integrate with the Git workflow to prevent budget overruns.

2. **Optimization Automation (10 points):** Implement automated cost optimization recommendations and resource right-sizing.

3. **Budget Governance (10 points):** Establish budget governance with approval workflows for high-cost deployments.

### **Scenario 5: Disaster Recovery and Business Continuity**

A critical production outage has occurred due to a failed Terraform deployment that corrupted the state file. The business is demanding a comprehensive disaster recovery plan for infrastructure deployments.

**Questions:**
1. **State Management Strategy (15 points):** Design a robust state management strategy with backup, versioning, and recovery capabilities.

2. **Rollback Procedures (10 points):** Implement automated and manual rollback procedures for different failure scenarios.

3. **Business Continuity Planning (10 points):** Develop a business continuity plan that ensures infrastructure deployments can continue during various disaster scenarios.

---

## 🛠️ **Part C: Hands-On Challenges (3 Challenges)**

### **Challenge 1: Complete Git Workflow Implementation (30 points)**

**Objective:** Implement a complete GitFlow workflow with team collaboration features for a multi-environment Terraform project.

**Requirements:**
1. **Repository Setup (10 points):**
   - Initialize Git repository with GitFlow branching model
   - Configure branch protection rules for main and develop branches
   - Set up CODEOWNERS file with team-based review requirements

2. **CI/CD Pipeline (10 points):**
   - Create GitHub Actions workflow with validation stages
   - Implement security scanning with TFSec and Checkov
   - Add cost analysis with Infracost integration

3. **Team Collaboration (10 points):**
   - Configure approval workflows for different environments
   - Set up automated notifications for deployment status
   - Implement policy enforcement with OPA/Conftest

**Deliverables:**
- Configured Git repository with all workflow files
- Working CI/CD pipeline with all validation stages
- Documentation of team collaboration processes

**Evaluation Criteria:**
- Correct implementation of GitFlow branching model
- Comprehensive security and cost validation
- Proper team access controls and approval workflows
- Clear documentation and operational procedures

### **Challenge 2: Security and Compliance Integration (25 points)**

**Objective:** Implement comprehensive security and compliance controls for a Terraform project managing sensitive financial data.

**Requirements:**
1. **Security Scanning (10 points):**
   - Integrate multiple security scanning tools (TFSec, Checkov, Terrascan)
   - Configure pre-commit hooks for secret detection
   - Implement vulnerability assessment automation

2. **Policy as Code (10 points):**
   - Create OPA policies for PCI DSS compliance
   - Implement automated policy validation in CI/CD
   - Set up policy violation reporting and remediation

3. **Audit and Compliance (5 points):**
   - Configure comprehensive audit logging
   - Implement compliance reporting automation
   - Set up automated compliance validation

**Deliverables:**
- Complete security scanning integration
- Working policy as code implementation
- Comprehensive audit and compliance reporting

**Evaluation Criteria:**
- Effectiveness of security scanning and vulnerability detection
- Correctness of policy implementation and enforcement
- Completeness of audit trail and compliance reporting

### **Challenge 3: Enterprise-Scale Deployment Automation (35 points)**

**Objective:** Build a complete enterprise deployment automation system with multi-environment support, cost management, and disaster recovery.

**Requirements:**
1. **Multi-Environment Pipeline (15 points):**
   - Implement environment-specific deployment pipelines
   - Configure environment promotion workflows
   - Set up automated testing and validation for each environment

2. **Cost Management Integration (10 points):**
   - Implement automated cost analysis and budget validation
   - Set up cost optimization recommendations
   - Configure budget alerts and approval workflows

3. **Disaster Recovery (10 points):**
   - Implement state backup and recovery automation
   - Configure automated rollback procedures
   - Set up cross-region disaster recovery capabilities

**Deliverables:**
- Complete multi-environment deployment system
- Working cost management and optimization
- Comprehensive disaster recovery implementation

**Evaluation Criteria:**
- Robustness of multi-environment deployment automation
- Effectiveness of cost management and optimization
- Completeness of disaster recovery and business continuity planning
- Overall system reliability and operational excellence

---

## 📊 **Assessment Scoring Guide**

### **Scoring Breakdown:**
- **Part A (Multiple Choice):** 40 points (2 points per question)
- **Part B (Scenarios):** 175 points (35 points per scenario)
- **Part C (Hands-On):** 90 points (30 + 25 + 35 points)
- **Total Possible Points:** 305 points

### **Grade Scale:**
- **A (90-100%):** 275-305 points - Exceptional understanding with enterprise-ready implementation
- **B (80-89%):** 244-274 points - Strong understanding with minor gaps
- **C (70-79%):** 214-243 points - Adequate understanding requiring additional practice
- **D (60-69%):** 183-213 points - Basic understanding with significant gaps
- **F (Below 60%):** Below 183 points - Insufficient understanding requiring remediation

### **Competency Areas:**
1. **Git Workflow Mastery (25%):** Understanding of different workflow patterns and their applications
2. **Team Collaboration (20%):** RBAC, approval workflows, and multi-team coordination
3. **CI/CD Integration (20%):** Pipeline design, automation, and validation
4. **Security and Compliance (20%):** Policy enforcement, scanning, and audit requirements
5. **Operational Excellence (15%):** Cost management, disaster recovery, and business continuity

---

## 🎯 **Answer Key and Explanations**

### **Part A - Multiple Choice Answers:**

1. **c) `release/v1.2.0`** - Release branches are specifically created for preparing new production releases in GitFlow
2. **b) Simpler branching model with faster integration** - GitHub Flow's simplicity enables faster continuous deployment
3. **b) 2-3 days** - Trunk-based development emphasizes very short-lived feature branches
4. **b) GitHub Flow** - Its simplicity and direct-to-main approach suits continuous deployment
5. **b) To validate that automated tests and security scans pass** - Status checks ensure quality gates
6. **b) Requires approval from both teams for Terraform file changes** - CODEOWNERS enforces review requirements
7. **c) Secret scanning and sensitive data detection** - Prevents accidental exposure of sensitive information
8. **b) Use environment variables or external secret management** - Best practice for sensitive data handling
9. **b) Run terraform plan and security scans** - PR validation without applying changes
10. **c) Infracost** - Specifically designed for Terraform cost analysis
11. **b) To validate syntax and show proposed changes** - Plan shows what will be changed without applying
12. **b) Only on pushes to the main branch after approval** - Controlled deployment to production
13. **d) Organize by service or domain boundaries** - Promotes team autonomy and clear ownership
14. **c) Platform team and security team leads** - Requires elevated privileges and security oversight
15. **b) Role-based access with environment-specific permissions** - Principle of least privilege
16. **a) Create hotfix branch from main, merge back to main and develop** - Standard GitFlow hotfix process
17. **c) Policy enforcement and compliance validation** - OPA's primary purpose in infrastructure
18. **d) All require similar levels of audit logging** - Comprehensive logging needed for all frameworks
19. **b) Block the deployment and require manual review** - Policy violations should halt deployment
20. **b) Stricter enforcement in production, warnings in development** - Risk-appropriate enforcement levels

---

## 📚 **Study Resources and References**

### **Essential Reading:**
- [Git Workflow Comparison Guide](https://www.atlassian.com/git/tutorials/comparing-workflows)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [IBM Cloud Security and Compliance](https://cloud.ibm.com/docs/security)
- [Infrastructure as Code Security](https://www.hashicorp.com/resources/what-is-infrastructure-as-code)

### **Hands-On Practice:**
- Complete Lab 5.3 exercises with different workflow patterns
- Practice implementing security scanning tools
- Experiment with policy as code using OPA
- Build CI/CD pipelines with comprehensive validation

### **Additional Resources:**
- [GitHub Flow Documentation](https://guides.github.com/introduction/flow/)
- [GitLab Flow Best Practices](https://docs.gitlab.com/ee/topics/gitlab_flow.html)
- [Terraform Security Best Practices](https://blog.gitguardian.com/terraform-security/)
- [Cost Optimization with Infracost](https://www.infracost.io/docs/)

---

**Good luck with your assessment! Remember to apply enterprise-grade thinking and consider real-world operational requirements in your solutions.** 🚀
