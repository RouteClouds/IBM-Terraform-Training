# Test Your Understanding: Topic 4.1 - Defining and Managing IBM Cloud Resources

## 📋 **Assessment Overview**

This comprehensive assessment evaluates your understanding of IBM Cloud resource provisioning and management using Terraform. The assessment includes multiple-choice questions, scenario-based problems, and hands-on challenges that test both theoretical knowledge and practical implementation skills.

**Time Allocation**: 90 minutes
**Passing Score**: 80% (24/30 points)
**Assessment Type**: Mixed (Theory + Practical)

---

## 🎯 **Part A: Multiple Choice Questions (20 points)**

*Select the best answer for each question. Each question is worth 1 point.*

### **Question 1**
Which IBM Cloud service provides the foundational networking layer for resource provisioning?
- A) IBM Cloud Internet Services
- B) Virtual Private Cloud (VPC)
- C) Cloud Load Balancer
- D) Direct Link

### **Question 2**
What is the primary purpose of security groups in IBM Cloud VPC?
- A) Load balancing traffic between instances
- B) Controlling network traffic at the instance level
- C) Managing DNS resolution
- D) Encrypting data in transit

### **Question 3**
Which Terraform resource type is used to create virtual server instances in IBM Cloud?
- A) `ibm_compute_vm_instance`
- B) `ibm_is_instance`
- C) `ibm_cloud_instance`
- D) `ibm_vpc_instance`

### **Question 4**
What is the recommended approach for managing sensitive data like API keys in Terraform?
- A) Store them directly in .tf files
- B) Use environment variables or secure vaults
- C) Include them in version control
- D) Hard-code them in the configuration

### **Question 5**
Which storage profile provides the highest IOPS performance in IBM Cloud?
- A) general-purpose
- B) 5iops-tier
- C) 10iops-tier
- D) custom

### **Question 6**
What is the purpose of a public gateway in IBM Cloud VPC?
- A) Load balancing incoming traffic
- B) Providing internet access to private subnets
- C) Encrypting network traffic
- D) Managing DNS resolution

### **Question 7**
Which command validates Terraform configuration syntax without applying changes?
- A) `terraform check`
- B) `terraform validate`
- C) `terraform verify`
- D) `terraform test`

### **Question 8**
What is the maximum number of availability zones typically available in an IBM Cloud region?
- A) 2
- B) 3
- C) 4
- D) 5

### **Question 9**
Which load balancer type is recommended for internet-facing applications?
- A) Network Load Balancer
- B) Application Load Balancer (public)
- C) Application Load Balancer (private)
- D) Classic Load Balancer

### **Question 10**
What is the primary benefit of using Infrastructure as Code (IaC)?
- A) Reduced infrastructure costs
- B) Faster manual deployments
- C) Consistent and repeatable deployments
- D) Simplified user interfaces

### **Question 11**
Which IBM Cloud service provides centralized logging capabilities?
- A) IBM Cloud Monitoring
- B) IBM Log Analysis with LogDNA
- C) IBM Activity Tracker
- D) IBM Cloud Security Advisor

### **Question 12**
What is the recommended subnet CIDR block size for a production environment?
- A) /16
- B) /20
- C) /24
- D) /28

### **Question 13**
Which Terraform command shows the current state of managed resources?
- A) `terraform list`
- B) `terraform show`
- C) `terraform state list`
- D) `terraform status`

### **Question 14**
What is the purpose of resource tagging in IBM Cloud?
- A) Improving performance
- B) Cost allocation and resource organization
- C) Enhancing security
- D) Enabling auto-scaling

### **Question 15**
Which instance profile provides 4 vCPUs and 16 GB of RAM?
- A) bx2-2x8
- B) bx2-4x16
- C) bx2-8x32
- D) cx2-4x8

### **Question 16**
What is the default behavior when a Terraform resource is removed from configuration?
- A) The resource is automatically destroyed
- B) The resource remains but becomes unmanaged
- C) Terraform shows an error
- D) The resource is marked for deletion

### **Question 17**
Which security practice is most important for production deployments?
- A) Using default passwords
- B) Allowing access from 0.0.0.0/0
- C) Implementing least privilege access
- D) Disabling encryption

### **Question 18**
What is the purpose of a bastion host in a multi-tier architecture?
- A) Load balancing web traffic
- B) Providing secure access to private resources
- C) Storing application data
- D) Managing DNS resolution

### **Question 19**
Which Terraform feature helps prevent accidental resource destruction?
- A) Resource locks
- B) Lifecycle rules
- C) State backup
- D) All of the above

### **Question 20**
What is the estimated monthly cost for a bx2-4x16 instance in IBM Cloud?
- A) $73
- B) $146
- C) $292
- D) $584

---

## 🎭 **Part B: Scenario-Based Questions (5 points)**

*Analyze each scenario and provide the best solution. Each question is worth 1 point.*

### **Scenario 1: Multi-Region Deployment**
Your organization needs to deploy a web application across two IBM Cloud regions for disaster recovery. The application requires:
- 99.9% availability
- Automatic failover
- Data synchronization between regions

**Question**: What is the most appropriate architecture pattern?
- A) Active-passive with manual failover
- B) Active-active with load balancing
- C) Single region with multiple zones
- D) Hybrid cloud deployment

### **Scenario 2: Security Compliance**
A healthcare organization must deploy infrastructure that complies with HIPAA requirements. The infrastructure must include:
- Encrypted data at rest and in transit
- Network isolation
- Audit logging
- Access controls

**Question**: Which security configuration is most appropriate?
- A) Default security groups with basic encryption
- B) Custom security groups, customer-managed encryption, and comprehensive logging
- C) Public subnets with firewall rules
- D) Shared infrastructure with standard security

### **Scenario 3: Cost Optimization**
A startup needs to minimize infrastructure costs while maintaining development and production environments. Current usage patterns show:
- Development: 8 hours/day, 5 days/week
- Production: 24/7 with variable load
- Budget constraint: $500/month

**Question**: What cost optimization strategy should be implemented?
- A) Use the same instance sizes for both environments
- B) Implement scheduled scaling for development, auto-scaling for production
- C) Deploy everything in a single environment
- D) Use only the smallest instance types

### **Scenario 4: Performance Requirements**
An e-commerce application experiences high traffic during peak hours (3x normal load) and requires:
- Sub-second response times
- Database performance optimization
- Minimal downtime during scaling

**Question**: Which infrastructure design best meets these requirements?
- A) Single large instance with local storage
- B) Auto-scaling groups with load balancing and high-IOPS storage
- C) Manual scaling with standard storage
- D) Containerized deployment on single instance

### **Scenario 5: Data Management**
A financial services company needs to implement a data management strategy that includes:
- Daily automated backups
- Point-in-time recovery
- Cross-region data replication
- 7-year retention policy

**Question**: What storage and backup strategy should be implemented?
- A) Local storage with manual backups
- B) Block storage with automated backup policies and cross-region replication
- C) Object storage with manual replication
- D) Shared file systems with weekly backups

---

## 🛠️ **Part C: Hands-On Challenges (5 points)**

*Complete these practical exercises to demonstrate your implementation skills.*

### **Challenge 1: Resource Provisioning (2 points)**

**Task**: Create a Terraform configuration that provisions:
- 1 VPC with custom address space
- 2 subnets in different availability zones
- 1 security group allowing HTTP and SSH access
- 1 virtual server instance

**Requirements**:
- Use proper resource naming conventions
- Include comprehensive resource tags
- Implement input validation for variables
- Generate meaningful outputs

**Deliverables**:
- Complete Terraform configuration files
- Successful `terraform validate` execution
- Documentation of design decisions

### **Challenge 2: Security Implementation (2 points)**

**Task**: Enhance the configuration from Challenge 1 with:
- Network ACLs for additional security
- Encrypted storage volumes
- Restricted security group rules (no 0.0.0.0/0)
- Monitoring and logging configuration

**Requirements**:
- Follow security best practices
- Document security controls implemented
- Validate configuration with security scanning tools
- Provide security compliance report

**Deliverables**:
- Enhanced Terraform configuration
- Security documentation
- Compliance validation report

### **Challenge 3: Cost Optimization (1 point)**

**Task**: Analyze and optimize the infrastructure from previous challenges:
- Calculate estimated monthly costs
- Identify cost optimization opportunities
- Implement at least 3 cost-saving measures
- Document potential savings

**Requirements**:
- Provide detailed cost analysis
- Implement practical optimizations
- Maintain performance requirements
- Document ROI calculations

**Deliverables**:
- Cost analysis spreadsheet
- Optimized Terraform configuration
- ROI documentation

---

## 📊 **Assessment Rubric**

### **Multiple Choice Questions (20 points)**
- **Excellent (18-20 points)**: Demonstrates comprehensive understanding of IBM Cloud resources and Terraform concepts
- **Good (15-17 points)**: Shows solid grasp of core concepts with minor gaps
- **Satisfactory (12-14 points)**: Basic understanding with some misconceptions
- **Needs Improvement (<12 points)**: Significant knowledge gaps requiring additional study

### **Scenario-Based Questions (5 points)**
- **Excellent (5 points)**: Provides optimal solutions considering all requirements and constraints
- **Good (4 points)**: Offers appropriate solutions with minor considerations missed
- **Satisfactory (3 points)**: Basic solutions that meet primary requirements
- **Needs Improvement (<3 points)**: Solutions that don't adequately address scenarios

### **Hands-On Challenges (5 points)**
- **Excellent (5 points)**: Complete, well-documented solutions exceeding requirements
- **Good (4 points)**: Functional solutions meeting all requirements
- **Satisfactory (3 points)**: Basic working solutions with minimal documentation
- **Needs Improvement (<3 points)**: Incomplete or non-functional solutions

---

## 🎯 **Learning Outcomes Validation**

Upon successful completion of this assessment, you will have demonstrated:

### **Technical Competencies**
- ✅ IBM Cloud resource provisioning expertise
- ✅ Terraform configuration and management skills
- ✅ Security implementation and compliance knowledge
- ✅ Cost optimization and monitoring capabilities
- ✅ Troubleshooting and problem-solving abilities

### **Business Value Understanding**
- ✅ Infrastructure cost management (30-50% savings potential)
- ✅ Operational efficiency improvements (95% faster deployments)
- ✅ Risk mitigation through automation (93% fewer errors)
- ✅ Scalability and performance optimization
- ✅ Compliance and governance implementation

### **Professional Skills**
- ✅ Documentation and communication
- ✅ Best practices implementation
- ✅ Strategic thinking and planning
- ✅ Quality assurance and validation
- ✅ Continuous improvement mindset

---

## 📚 **Additional Resources**

### **Study Materials**
- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)
- [Terraform IBM Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm)
- [IBM Cloud Architecture Center](https://www.ibm.com/cloud/architecture)

### **Practice Labs**
- Complete Lab 6: Hands-on Resource Provisioning
- Review Concept.md for theoretical foundations
- Explore DaC diagrams for visual understanding

### **Next Steps**
- **Topic 4.2**: HCL Syntax, Variables, and Outputs
- **Topic 4.3**: Resource Dependencies and Attributes
- **Topic 5**: Modularization Best Practices

---

## 📝 **Submission Guidelines**

### **Format Requirements**
- Submit all files in a compressed archive (.zip or .tar.gz)
- Include a README.md with submission details
- Ensure all Terraform configurations validate successfully
- Provide clear documentation for all solutions

### **File Structure**
```
submission/
├── README.md
├── multiple-choice-answers.txt
├── scenario-answers.md
└── hands-on-challenges/
    ├── challenge-1/
    ├── challenge-2/
    └── challenge-3/
```

### **Evaluation Timeline**
- **Submission Deadline**: As specified by instructor
- **Initial Review**: Within 48 hours
- **Detailed Feedback**: Within 1 week
- **Remediation Period**: 2 weeks if needed

---

**Good luck with your assessment! 🚀**

*Remember: This assessment validates your readiness to implement enterprise-grade IBM Cloud infrastructure using Terraform. Focus on demonstrating both technical competency and business value understanding.*
