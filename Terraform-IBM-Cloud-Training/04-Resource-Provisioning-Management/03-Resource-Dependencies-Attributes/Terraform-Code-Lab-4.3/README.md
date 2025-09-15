# Resource Dependencies and Attributes Lab - Topic 4.3

## Overview

This Terraform configuration demonstrates advanced resource dependency management and attribute usage patterns in IBM Cloud infrastructure. The lab showcases implicit dependencies, explicit dependencies, data source integration, and complex resource attribute references in a multi-tier application architecture.

## Architecture

The lab deploys a comprehensive multi-tier architecture including:

- **Foundation Layer**: VPC, subnets, public gateways
- **Security Layer**: Security groups with cross-references
- **Data Layer**: PostgreSQL database, Redis cache, Virtual Private Endpoint
- **Compute Layer**: Web and application server instances
- **Load Balancing**: Public and internal load balancers
- **Monitoring**: Optional monitoring and backup services

## Dependency Patterns Demonstrated

### 1. Implicit Dependencies
- **VPC → Subnets**: Subnets reference VPC ID through resource attributes
- **Subnet → Instances**: Instances reference subnet IDs for placement
- **Security Group Cross-References**: Rules reference other security groups
- **Instance → Load Balancer**: Pool members use instance IP addresses

### 2. Explicit Dependencies
- **Network → Database**: Database services explicitly depend on VPC and subnets
- **Database → Application**: App servers explicitly depend on database services
- **Application → Web**: Web servers explicitly depend on app servers for configuration
- **VPE Dependencies**: Virtual Private Endpoint depends on both database and network

### 3. Data Source Integration
- **Dynamic Discovery**: Images, profiles, zones, and SSH keys discovered dynamically
- **Conditional Logic**: Resources created based on data source results
- **Environment Agnostic**: Configuration adapts to different environments

### 4. Complex Attribute Usage
- `instance.primary_network_interface[0].primary_ipv4_address`
- `database.connectionstrings[0].composed`
- `vpc.default_security_group`
- `subnet.ipv4_cidr_block`

## Prerequisites

### Required Tools
- Terraform >= 1.0
- IBM Cloud CLI
- jq (for JSON parsing)
- bc (for cost calculations)

### IBM Cloud Setup
1. **IBM Cloud Account**: Active IBM Cloud account with appropriate permissions
2. **API Key**: IBM Cloud API key with VPC and database service access
3. **Resource Group**: Existing resource group for resource organization
4. **SSH Keys**: At least one SSH key uploaded to IBM Cloud

### Environment Variables
```bash
export IBMCLOUD_API_KEY="your-api-key-here"
export TF_VAR_resource_group_id="your-resource-group-id"
```

## Quick Start

### 1. Clone and Navigate
```bash
git clone <repository-url>
cd Terraform-Code-Lab-4.3
```

### 2. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
```

### 3. Initialize and Plan
```bash
terraform init
terraform plan -out=tfplan
```

### 4. Apply Configuration
```bash
terraform apply tfplan
```

### 5. Verify Deployment
```bash
# Check dependency analysis
./scripts/dependency-analysis.sh

# Estimate costs
./scripts/cost-estimate.sh development
```

## Configuration Files

### Core Configuration
- **`providers.tf`**: Multi-provider configuration with aliases
- **`variables.tf`**: Comprehensive variable definitions with validation
- **`main.tf`**: Resource definitions with dependency patterns
- **`outputs.tf`**: Structured outputs with attribute usage
- **`terraform.tfvars.example`**: Example variable values

### Templates and Scripts
- **`templates/web-server-setup.sh`**: Web server configuration script
- **`templates/app-server-setup.sh`**: Application server setup script
- **`scripts/dependency-analysis.sh`**: Dependency analysis tool
- **`scripts/cost-estimate.sh`**: Cost estimation utility

## Variable Configuration

### Project Configuration
```hcl
project_configuration = {
  project_name = "dependency-lab"
  environment = {
    name        = "development"  # development, staging, production
    criticality = "low"          # low, medium, high, critical
  }
  dependency_management = {
    enable_implicit_dependencies = true
    enable_explicit_dependencies = true
    optimization_level           = "balanced"  # performance, balanced, cost
  }
}
```

### Infrastructure Configuration
```hcl
infrastructure_configuration = {
  network = {
    vpc_cidr_blocks = ["10.0.0.0/16"]
    subnet_configuration = {
      public_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      private_subnets  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
      database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
    }
  }
  compute = {
    instance_types = {
      web_tier = {
        instance_profile  = "bx2-2x8"
        desired_instances = 2
      }
      app_tier = {
        instance_profile  = "bx2-4x16"
        desired_instances = 3
      }
    }
  }
}
```

### Feature Flags
```hcl
feature_flags = {
  enable_multi_region      = false
  enable_disaster_recovery = false
  enable_monitoring        = true
  enable_backup           = true
  enable_advanced_features = false
}
```

## Dependency Analysis

### Analyze Dependencies
```bash
# Run comprehensive dependency analysis
./scripts/dependency-analysis.sh

# Generate dependency graph
terraform graph > dependency-graph.dot

# Visualize graph (requires Graphviz)
dot -Tpng dependency-graph.dot -o dependency-graph.png
```

### Dependency Types
1. **Implicit**: Resource attribute references
2. **Explicit**: `depends_on` declarations
3. **Data Source**: Dynamic discovery dependencies
4. **Cross-Reference**: Security group rule references

## Cost Estimation

### Environment-Based Costs
```bash
# Development environment
./scripts/cost-estimate.sh development

# Staging environment
./scripts/cost-estimate.sh staging

# Production environment
./scripts/cost-estimate.sh production
```

### Cost Components
- **Compute**: Instance costs based on profile and count
- **Network**: Load balancers, public gateways, VPE
- **Database**: PostgreSQL and Redis services
- **Storage**: Block storage and object storage
- **Monitoring**: Sysdig monitoring services

## Environment Examples

### Development Environment
- **Instances**: 2 web (bx2-2x8), 3 app (bx2-4x16)
- **Database**: Standard plan
- **Monitoring**: Lite plan
- **Estimated Cost**: ~$200-300/month

### Staging Environment
- **Instances**: 3 web (bx2-4x16), 5 app (bx2-8x32)
- **Database**: Standard plan
- **Monitoring**: Graduated tier
- **Estimated Cost**: ~$500-700/month

### Production Environment
- **Instances**: 5 web (bx2-8x32), 10 app (bx2-16x64)
- **Database**: Enterprise plan
- **Monitoring**: Graduated tier
- **Multi-Region**: Enabled
- **Estimated Cost**: ~$1500-2000/month

## Troubleshooting

### Common Issues

#### 1. Resource Group Not Found
```bash
# Verify resource group exists
ibmcloud resource groups

# Update terraform.tfvars with correct ID
resource_group_id = "correct-resource-group-id"
```

#### 2. SSH Key Not Found
```bash
# List available SSH keys
ibmcloud is keys

# Upload SSH key if needed
ibmcloud is key-create my-key @~/.ssh/id_rsa.pub
```

#### 3. Dependency Cycles
```bash
# Check for circular dependencies
terraform graph | grep -i cycle

# Review dependency analysis
./scripts/dependency-analysis.sh
```

#### 4. Database Connection Issues
```bash
# Check VPE configuration
terraform output database_tier

# Verify network connectivity
terraform output security_configuration
```

### Validation Commands
```bash
# Validate configuration
terraform validate

# Check formatting
terraform fmt -check

# Plan with detailed output
terraform plan -detailed-exitcode
```

## Best Practices Demonstrated

### 1. Dependency Management
- ✅ Use implicit dependencies through resource attributes
- ✅ Use explicit dependencies only when timing is critical
- ✅ Avoid circular dependencies through proper design
- ✅ Leverage data sources for dynamic discovery

### 2. Resource Organization
- ✅ Logical grouping of related resources
- ✅ Consistent naming conventions
- ✅ Comprehensive tagging strategy
- ✅ Environment-specific configurations

### 3. Security
- ✅ Security group cross-references
- ✅ Private database connectivity
- ✅ Encrypted storage and transit
- ✅ Least privilege access patterns

### 4. Scalability
- ✅ Environment-based scaling
- ✅ Auto-scaling configuration
- ✅ Load balancer distribution
- ✅ Multi-zone deployment

## Learning Objectives

By completing this lab, you will understand:

1. **Implicit Dependencies**: How Terraform automatically determines resource creation order
2. **Explicit Dependencies**: When and how to use `depends_on`
3. **Resource Attributes**: Complex attribute paths and references
4. **Data Sources**: Dynamic infrastructure discovery
5. **Cross-References**: Security group and network references
6. **Dependency Optimization**: Parallel creation and performance tuning
7. **Troubleshooting**: Identifying and resolving dependency issues

## Cleanup

### Destroy Resources
```bash
# Plan destruction
terraform plan -destroy

# Destroy all resources
terraform destroy

# Verify cleanup
ibmcloud is instances
ibmcloud is vpcs
```

### Cleanup Scripts
```bash
# Remove generated files
rm -f dependency-graph.*
rm -f dependency-analysis-report.md
rm -f terraform.tfvars
```

## Support and Documentation

### Additional Resources
- [IBM Cloud Terraform Provider Documentation](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [Terraform Dependency Management](https://www.terraform.io/docs/language/resources/behavior.html#resource-dependencies)
- [IBM Cloud VPC Documentation](https://cloud.ibm.com/docs/vpc)

### Lab Support
- Review the dependency analysis output for detailed insights
- Use the cost estimation tool for budget planning
- Check the troubleshooting section for common issues
- Refer to the best practices for production deployments

---

**Note**: This lab is designed for educational purposes. Actual production deployments should include additional security, monitoring, and compliance considerations.
