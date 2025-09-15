# Test Your Understanding: Resource Dependencies and Attributes
## Topic 4.3 Assessment

### Instructions
- Complete all sections to demonstrate mastery of resource dependencies and attributes
- Multiple choice questions have one correct answer unless otherwise specified
- Scenario questions require detailed explanations
- Hands-on challenges should be completed in a test environment
- Time allocation: 90 minutes total

---

## Section A: Multiple Choice Questions (40 points)
*Select the best answer for each question*

### Question 1 (2 points)
Which type of dependency is automatically created when one resource references another resource's attribute?

A) Explicit dependency
B) Implicit dependency  
C) Data source dependency
D) Provider dependency

### Question 2 (2 points)
When should you use the `depends_on` meta-argument in Terraform?

A) For all resource relationships
B) Only when implicit dependencies are insufficient
C) To improve performance
D) To reduce configuration complexity

### Question 3 (2 points)
What is the correct syntax to reference the ID of a VPC resource named "main_vpc" in another resource?

A) `vpc.main_vpc.id`
B) `ibm_is_vpc.main_vpc.id`
C) `resource.ibm_is_vpc.main_vpc.id`
D) `${ibm_is_vpc.main_vpc.id}`

### Question 4 (2 points)
Which of the following represents a complex resource attribute path?

A) `vpc.id`
B) `subnet.zone`
C) `instance.primary_network_interface[0].primary_ipv4_address`
D) `security_group.name`

### Question 5 (2 points)
What happens when Terraform detects a circular dependency?

A) It automatically resolves the cycle
B) It creates resources in random order
C) It fails with an error
D) It skips the problematic resources

### Question 6 (2 points)
Data sources in Terraform are primarily used for:

A) Creating new resources
B) Discovering existing infrastructure
C) Defining variables
D) Managing state files

### Question 7 (2 points)
Which IBM Cloud resource attribute would you use to get database connection information?

A) `ibm_database.connection_string`
B) `ibm_database.connectionstrings[0].composed`
C) `ibm_database.endpoint`
D) `ibm_database.url`

### Question 8 (2 points)
Security group cross-references in IBM Cloud allow:

A) Automatic rule creation
B) Rules to reference other security groups as sources/destinations
C) Shared security group configurations
D) Dynamic port assignment

### Question 9 (2 points)
What is the benefit of using data sources for image discovery?

A) Faster resource creation
B) Environment-agnostic configurations
C) Reduced costs
D) Better security

### Question 10 (2 points)
Which meta-argument can be used to create multiple similar resources?

A) `for_each`
B) `count`
C) `dynamic`
D) All of the above

### Question 11 (2 points)
When using `for_each` with a map, how do you access the current key?

A) `each.key`
B) `each.value`
C) `each.index`
D) `each.name`

### Question 12 (2 points)
Virtual Private Endpoints (VPE) in IBM Cloud are used for:

A) Public internet access
B) Private connectivity to cloud services
C) Load balancing
D) DNS resolution

### Question 13 (2 points)
What is the primary advantage of implicit dependencies over explicit dependencies?

A) Better performance
B) Automatic dependency resolution
C) Easier troubleshooting
D) More control over creation order

### Question 14 (2 points)
Which command generates a visual representation of resource dependencies?

A) `terraform plan`
B) `terraform graph`
C) `terraform show`
D) `terraform state list`

### Question 15 (2 points)
Load balancer pool members typically reference which instance attribute?

A) `instance.id`
B) `instance.name`
C) `instance.primary_network_interface[0].primary_ipv4_address`
D) `instance.zone`

### Question 16 (2 points)
What is the correct way to reference a resource created with `count`?

A) `resource_type.resource_name[count.index]`
B) `resource_type.resource_name[0]`
C) `resource_type.resource_name[index]`
D) `resource_type.resource_name.count`

### Question 17 (2 points)
Data source caching in Terraform helps with:

A) Reducing API calls
B) Improving performance
C) Consistency across runs
D) All of the above

### Question 18 (2 points)
Which of the following is NOT a valid dependency type in Terraform?

A) Implicit dependency
B) Explicit dependency
C) Conditional dependency
D) Provider dependency

### Question 19 (2 points)
When should you use conditional resource creation?

A) Always for better flexibility
B) When resources depend on external factors
C) To reduce costs
D) For better security

### Question 20 (2 points)
The `templatefile()` function is commonly used for:

A) Creating configuration files with dynamic content
B) Generating random values
C) Validating inputs
D) Managing state

---

## Section B: Scenario-Based Questions (30 points)
*Provide detailed explanations for each scenario*

### Scenario 1: Multi-Tier Application Dependencies (10 points)

You are designing a three-tier application with the following components:
- Web tier: 3 instances behind a public load balancer
- Application tier: 5 instances behind an internal load balancer  
- Database tier: PostgreSQL with Redis cache

**Question**: Design the dependency relationships for this architecture. Explain:
1. Which dependencies should be implicit vs explicit
2. How you would handle the database connection strings
3. The optimal resource creation order
4. How to ensure web servers can communicate with app servers

**Answer Space:**
```
[Provide your detailed answer here - minimum 200 words]
```

### Scenario 2: Cross-Region Dependency Management (10 points)

Your organization needs to deploy infrastructure across two IBM Cloud regions for disaster recovery. The primary region contains the main application, while the secondary region has backup services.

**Question**: Explain how you would:
1. Structure the provider configuration for multi-region deployment
2. Handle cross-region dependencies
3. Manage data replication dependencies
4. Ensure proper failover sequences

**Answer Space:**
```
[Provide your detailed answer here - minimum 200 words]
```

### Scenario 3: Dependency Troubleshooting (10 points)

A team reports that their Terraform deployment is failing with dependency-related errors. The infrastructure includes VPC, subnets, security groups, instances, and databases.

**Question**: Describe your troubleshooting approach:
1. What commands would you use to analyze dependencies?
2. How would you identify circular dependencies?
3. What are common dependency anti-patterns to look for?
4. How would you optimize the dependency graph for better performance?

**Answer Space:**
```
[Provide your detailed answer here - minimum 200 words]
```

---

## Section C: Hands-On Challenges (30 points)
*Complete these practical exercises*

### Challenge 1: Security Group Cross-References (10 points)

Create a Terraform configuration that demonstrates security group cross-references:

**Requirements:**
- Create 3 security groups: web, app, and database
- Web SG allows inbound HTTP/HTTPS from internet
- Web SG allows outbound to App SG on port 8080
- App SG allows inbound from Web SG on port 8080
- App SG allows outbound to DB SG on port 5432
- DB SG allows inbound from App SG on port 5432

**Deliverable:** Provide the Terraform code below:

```hcl
# Your security group configuration here
```

### Challenge 2: Complex Attribute Usage (10 points)

Create a configuration that uses complex resource attributes:

**Requirements:**
- Create 2 instances in different subnets
- Create a load balancer with pool members using instance IP addresses
- Use templatefile() to generate a configuration file with instance IPs
- Output the complex attribute paths used

**Deliverable:** Provide the Terraform code below:

```hcl
# Your complex attribute configuration here
```

### Challenge 3: Data Source Integration (10 points)

Create a configuration that uses data sources for dynamic discovery:

**Requirements:**
- Use data sources to discover available zones
- Use data sources to find the latest Ubuntu image
- Create subnets distributed across discovered zones
- Create instances using the discovered image
- Implement conditional logic based on data source results

**Deliverable:** Provide the Terraform code below:

```hcl
# Your data source integration configuration here
```

---

## Answer Key and Scoring Guide

### Section A: Multiple Choice (40 points)
1. B - Implicit dependency
2. B - Only when implicit dependencies are insufficient
3. B - `ibm_is_vpc.main_vpc.id`
4. C - `instance.primary_network_interface[0].primary_ipv4_address`
5. C - It fails with an error
6. B - Discovering existing infrastructure
7. B - `ibm_database.connectionstrings[0].composed`
8. B - Rules to reference other security groups as sources/destinations
9. B - Environment-agnostic configurations
10. D - All of the above
11. A - `each.key`
12. B - Private connectivity to cloud services
13. B - Automatic dependency resolution
14. B - `terraform graph`
15. C - `instance.primary_network_interface[0].primary_ipv4_address`
16. A - `resource_type.resource_name[count.index]`
17. D - All of the above
18. C - Conditional dependency
19. B - When resources depend on external factors
20. A - Creating configuration files with dynamic content

### Section B: Scenario Scoring (30 points)

**Scenario 1 (10 points):**
- Implicit vs explicit dependencies (3 points)
- Database connection handling (2 points)
- Resource creation order (3 points)
- Communication setup (2 points)

**Scenario 2 (10 points):**
- Provider configuration (3 points)
- Cross-region dependencies (3 points)
- Data replication (2 points)
- Failover sequences (2 points)

**Scenario 3 (10 points):**
- Troubleshooting commands (3 points)
- Circular dependency identification (3 points)
- Anti-patterns (2 points)
- Performance optimization (2 points)

### Section C: Hands-On Scoring (30 points)

**Challenge 1 (10 points):**
- Correct security group structure (4 points)
- Proper cross-references (4 points)
- Complete rule definitions (2 points)

**Challenge 2 (10 points):**
- Complex attribute usage (4 points)
- Load balancer configuration (3 points)
- Template file integration (3 points)

**Challenge 3 (10 points):**
- Data source implementation (4 points)
- Dynamic resource creation (3 points)
- Conditional logic (3 points)

### Passing Criteria
- **Excellent (90-100 points)**: Demonstrates mastery of all dependency concepts
- **Proficient (80-89 points)**: Strong understanding with minor gaps
- **Developing (70-79 points)**: Basic understanding, needs improvement
- **Needs Support (<70 points)**: Requires additional study and practice

### Additional Learning Resources
- Review Lab 8 exercises for practical examples
- Study the dependency analysis script outputs
- Practice with the provided Terraform configurations
- Explore IBM Cloud documentation for service-specific attributes
