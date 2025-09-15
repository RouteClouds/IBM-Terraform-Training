# Test Your Understanding: Topic 2 - Terraform CLI & Provider Installation

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your understanding of **Topic 2: Terraform CLI & Provider Installation** through multiple choice questions, scenario-based challenges, and hands-on practical exercises.

### **Assessment Structure**
- **Part A**: 20 Multiple Choice Questions (40 points)
- **Part B**: 5 Scenario-Based Questions (30 points) 
- **Part C**: 3 Hands-On Challenges (30 points)
- **Total Points**: 100 points
- **Passing Score**: 80 points
- **Time Limit**: 120 minutes

---

## 📝 **Part A: Multiple Choice Questions (40 points)**

### **Question 1** (2 points)
Which command is used to verify that Terraform CLI is properly installed?
a) `terraform --help`
b) `terraform version`
c) `terraform validate`
d) `terraform init`

### **Question 2** (2 points)
What is the recommended method for managing multiple Terraform versions on a single system?
a) Manual installation and PATH modification
b) Using tfenv version manager
c) Docker containers only
d) Virtual machines for each version

### **Question 3** (2 points)
Which IBM Cloud provider configuration parameter controls the maximum time to wait for operations?
a) `max_retries`
b) `retry_delay`
c) `ibmcloud_timeout`
d) `operation_timeout`

### **Question 4** (2 points)
What is the primary security benefit of using private endpoints in IBM Cloud provider configuration?
a) Faster API response times
b) Lower costs for data transfer
c) Traffic stays within IBM Cloud network
d) Automatic encryption of all data

### **Question 5** (2 points)
Which authentication method is recommended for production IBM Cloud provider configurations?
a) Username and password
b) API keys with appropriate IAM policies
c) SSH keys
d) OAuth tokens

### **Question 6** (2 points)
What does the `terraform providers` command display?
a) Available provider versions
b) Currently configured providers and their versions
c) Provider installation status
d) Provider performance metrics

### **Question 7** (2 points)
Which provider configuration enables debug tracing for troubleshooting?
a) `debug_mode = true`
b) `ibmcloud_trace = true`
c) `enable_logging = true`
d) `verbose_output = true`

### **Question 8** (2 points)
What is the purpose of provider aliases in Terraform?
a) To create backup providers
b) To use multiple instances of the same provider
c) To improve provider performance
d) To enable provider caching

### **Question 9** (2 points)
Which file should contain sensitive provider configuration values?
a) `providers.tf`
b) `main.tf`
c) `terraform.tfvars`
d) `variables.tf`

### **Question 10** (2 points)
What happens when `max_retries` is set to 0 in IBM Cloud provider configuration?
a) Infinite retries
b) No retries on failures
c) Default retry behavior
d) Configuration error

### **Question 11** (2 points)
Which command initializes Terraform and downloads required providers?
a) `terraform plan`
b) `terraform apply`
c) `terraform init`
d) `terraform validate`

### **Question 12** (2 points)
What is the recommended approach for managing IBM Cloud API keys in team environments?
a) Share a single API key among team members
b) Use individual API keys with appropriate permissions
c) Store API keys in version control
d) Use hardcoded API keys in configuration files

### **Question 13** (2 points)
Which provider configuration parameter affects the delay between retry attempts?
a) `retry_delay`
b) `retry_interval`
c) `backoff_delay`
d) `wait_time`

### **Question 14** (2 points)
What is the primary purpose of the `terraform validate` command?
a) Check provider connectivity
b) Validate configuration syntax and logic
c) Test resource deployment
d) Verify API credentials

### **Question 15** (2 points)
Which IBM Cloud provider configuration enables the use of VPC Generation 2?
a) `vpc_version = 2`
b) `generation = 2`
c) `vpc_gen = 2`
d) `vpc_type = "gen2"`

### **Question 16** (2 points)
What is the benefit of using Service IDs for IBM Cloud provider authentication?
a) Faster authentication
b) Lower costs
c) Programmatic access without user credentials
d) Automatic credential rotation

### **Question 17** (2 points)
Which environment variable can be used to enable Terraform debug logging?
a) `TF_DEBUG=1`
b) `TF_LOG=DEBUG`
c) `TERRAFORM_DEBUG=true`
d) `DEBUG_TERRAFORM=1`

### **Question 18** (2 points)
What is the purpose of the `required_providers` block in Terraform configuration?
a) To install providers automatically
b) To specify provider versions and sources
c) To configure provider settings
d) To enable provider caching

### **Question 19** (2 points)
Which IBM Cloud provider configuration parameter specifies the target region?
a) `location`
b) `region`
c) `zone`
d) `datacenter`

### **Question 20** (2 points)
What is the recommended practice for provider version constraints?
a) Always use the latest version
b) Pin to exact versions
c) Use pessimistic version constraints (~>)
d) Avoid version constraints

---

## 🎯 **Part B: Scenario-Based Questions (30 points)**

### **Scenario 1: Multi-Region Deployment** (6 points)
Your organization needs to deploy infrastructure across US South, EU Germany, and Japan Tokyo regions for a global application. Design the provider configuration approach.

**Question**: Describe how you would configure multiple IBM Cloud providers for this scenario, including:
- Provider alias naming strategy
- Authentication approach
- Regional optimization considerations
- Disaster recovery implications

### **Scenario 2: Enterprise Security Requirements** (6 points)
A financial services company requires maximum security for their Terraform deployments, including private endpoints, audit logging, and compliance with SOC 2 requirements.

**Question**: Design a comprehensive security configuration that addresses:
- Network security (private endpoints)
- Authentication and authorization
- Audit and compliance logging
- Credential management best practices

### **Scenario 3: Development Team Workflow** (6 points)
A development team of 10 engineers needs to use Terraform with IBM Cloud. They work across development, staging, and production environments with different security requirements.

**Question**: Design a provider configuration strategy that includes:
- Environment separation approach
- Credential management for team members
- Different security levels per environment
- Troubleshooting and debugging capabilities

### **Scenario 4: Performance Optimization** (6 points)
Your Terraform deployments are experiencing timeouts and slow performance when creating large numbers of resources in IBM Cloud.

**Question**: Identify optimization strategies including:
- Provider timeout and retry configurations
- Network optimization approaches
- Parallel resource creation considerations
- Performance monitoring and measurement

### **Scenario 5: Troubleshooting Provider Issues** (6 points)
A team is experiencing intermittent authentication failures and network connectivity issues with their IBM Cloud provider configuration.

**Question**: Outline a systematic troubleshooting approach including:
- Diagnostic commands and techniques
- Common causes and solutions
- Debug logging and tracing
- Escalation procedures and support resources

---

## 🛠️ **Part C: Hands-On Challenges (30 points)**

### **Challenge 1: Provider Configuration Implementation** (10 points)

**Task**: Create a complete provider configuration that demonstrates:
- Primary provider for us-south region
- Secondary provider for eu-de region with alias
- Enterprise security settings (private endpoints, audit logging)
- Performance optimization (appropriate timeouts and retries)

**Deliverables**:
- `providers.tf` file with complete configuration
- `variables.tf` file with necessary input variables
- `terraform.tfvars.example` with sample values

**Evaluation Criteria**:
- Correct provider syntax and configuration
- Appropriate security settings
- Performance optimization
- Documentation and comments

### **Challenge 2: Multi-Environment Setup** (10 points)

**Task**: Design and implement a provider configuration supporting:
- Development environment (relaxed security, fast feedback)
- Staging environment (production-like, enhanced monitoring)
- Production environment (maximum security, reliability)

**Deliverables**:
- Provider configurations for each environment
- Environment-specific variable definitions
- Security and performance differentiation
- Validation and testing approach

**Evaluation Criteria**:
- Environment-appropriate configurations
- Security level differentiation
- Performance optimization per environment
- Validation and testing implementation

### **Challenge 3: Troubleshooting and Validation** (10 points)

**Task**: Create a comprehensive validation and troubleshooting framework:
- Provider connectivity testing
- Authentication validation
- Performance measurement
- Error handling and recovery

**Deliverables**:
- Validation resource configurations
- Troubleshooting documentation
- Performance testing implementation
- Error handling strategies

**Evaluation Criteria**:
- Comprehensive validation coverage
- Effective troubleshooting procedures
- Performance measurement accuracy
- Error handling robustness

---

## 📊 **Answer Key and Scoring Rubric**

### **Part A: Multiple Choice Answers**
1. b) `terraform version`
2. b) Using tfenv version manager
3. c) `ibmcloud_timeout`
4. c) Traffic stays within IBM Cloud network
5. b) API keys with appropriate IAM policies
6. b) Currently configured providers and their versions
7. b) `ibmcloud_trace = true`
8. b) To use multiple instances of the same provider
9. c) `terraform.tfvars`
10. b) No retries on failures
11. c) `terraform init`
12. b) Use individual API keys with appropriate permissions
13. a) `retry_delay`
14. b) Validate configuration syntax and logic
15. b) `generation = 2`
16. c) Programmatic access without user credentials
17. b) `TF_LOG=DEBUG`
18. b) To specify provider versions and sources
19. b) `region`
20. c) Use pessimistic version constraints (~>)

### **Part B: Scenario Scoring Rubric**
**Excellent (6 points)**: Comprehensive solution addressing all requirements with best practices
**Good (4-5 points)**: Solid solution addressing most requirements with minor gaps
**Satisfactory (2-3 points)**: Basic solution addressing some requirements
**Needs Improvement (0-1 points)**: Incomplete or incorrect solution

### **Part C: Hands-On Scoring Rubric**
**Excellent (9-10 points)**: Complete, working implementation with best practices
**Good (7-8 points)**: Working implementation with minor issues
**Satisfactory (5-6 points)**: Partial implementation with some functionality
**Needs Improvement (0-4 points)**: Non-functional or incomplete implementation

---

## 🎓 **Assessment Results Interpretation**

### **Score Ranges**
- **90-100 points**: Excellent - Ready for advanced topics and production implementation
- **80-89 points**: Good - Solid understanding with minor knowledge gaps
- **70-79 points**: Satisfactory - Basic understanding, review recommended areas
- **Below 70 points**: Needs Improvement - Additional study and practice required

### **Remediation Recommendations**
- **Score < 70**: Review all Topic 2 materials, complete additional labs
- **Score 70-79**: Focus on weak areas identified in assessment
- **Score 80-89**: Review specific topics with incorrect answers
- **Score 90+**: Proceed to Topic 3 with confidence

### **Next Steps**
- **Immediate**: Review incorrect answers and understand concepts
- **Short-term**: Practice hands-on implementation in lab environments
- **Long-term**: Apply learned concepts in real-world projects
- **Advanced**: Proceed to Topic 3: Core Terraform Workflow

---

**Assessment Version**: 2.0  
**Last Updated**: September 2024  
**Estimated Completion Time**: 120 minutes
