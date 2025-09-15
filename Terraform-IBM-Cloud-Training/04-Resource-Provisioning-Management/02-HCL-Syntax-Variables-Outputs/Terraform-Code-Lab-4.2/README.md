# Advanced HCL Configuration Lab 4.2

## Overview

This Terraform configuration demonstrates sophisticated HCL (HashiCorp Configuration Language) patterns, advanced variable structures, complex validation rules, and comprehensive output strategies. The lab showcases enterprise-grade configuration management techniques for IBM Cloud infrastructure.

## Learning Objectives

By completing this lab, you will master:

- **Advanced Variable Patterns**: Complex object types, nested structures, and validation rules
- **Local Value Computations**: Dynamic expressions and conditional logic
- **Output Strategies**: Comprehensive output design for module integration
- **Conditional Logic**: Feature flags and environment-based configurations
- **Enterprise Patterns**: Tagging strategies, naming conventions, and governance
- **Cost Optimization**: Configuration patterns for cost management
- **Security Integration**: Compliance frameworks and security configurations

## Architecture

This configuration implements a sophisticated multi-tier architecture with:

- **Network Layer**: VPC with public, private, and database subnets
- **Compute Layer**: Multi-tier instance configuration with auto-scaling
- **Storage Layer**: Encrypted volumes with backup strategies
- **Security Layer**: Comprehensive encryption and access controls
- **Monitoring Layer**: Metrics, logging, and alerting configuration
- **Governance Layer**: Compliance frameworks and audit requirements

## File Structure

```
Terraform-Code-Lab-4.2/
├── providers.tf              # Provider configuration with multi-region support
├── variables.tf               # Advanced variable definitions with validation
├── main.tf                   # Main configuration with local values and logic
├── outputs.tf                # Comprehensive output strategies
├── terraform.tfvars.example  # Example configurations for different environments
├── .gitignore                # Git ignore patterns for Terraform
├── README.md                 # This documentation
├── scripts/                  # Supporting scripts
│   ├── validate.sh           # Configuration validation script
│   ├── cost-estimate.sh      # Cost estimation script
│   └── deploy.sh             # Deployment automation script
└── templates/                # Template files
    └── terraform.tfvars.tpl  # Dynamic tfvars template
```

## Prerequisites

### Required Tools

- **Terraform**: Version >= 1.0
- **IBM Cloud CLI**: Latest version
- **Git**: For version control
- **jq**: For JSON processing (optional)

### IBM Cloud Setup

1. **IBM Cloud Account**: Active account with appropriate permissions
2. **API Key**: IBM Cloud API key with infrastructure permissions
3. **Resource Group**: Target resource group for deployment
4. **Regions**: Access to multiple IBM Cloud regions

### Authentication

Set your IBM Cloud API key as an environment variable:

```bash
export IBMCLOUD_API_KEY="your-api-key-here"
```

Or alternatively:

```bash
export IC_API_KEY="your-api-key-here"
```

## Quick Start

### 1. Clone and Navigate

```bash
cd Terraform-IBM-Cloud-Training/04-Resource-Provisioning-Management/02-HCL-Syntax-Variables-Outputs/Terraform-Code-Lab-4.2
```

### 2. Configure Variables

```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your specific values
nano terraform.tfvars
```

### 3. Initialize and Validate

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Review the plan
terraform plan
```

### 4. Deploy (Optional)

```bash
# Apply the configuration
terraform apply

# Review outputs
terraform output
```

## Configuration Examples

### Development Environment

```hcl
project_configuration = {
  project_name = "hcl-advanced-lab"
  environment = {
    name        = "development"
    criticality = "low"
  }
  # ... additional configuration
}

feature_flags = {
  enable_cost_optimization = true
  enable_debug_mode       = true
  enable_monitoring       = true
  # ... additional flags
}
```

### Production Environment

```hcl
project_configuration = {
  project_name = "hcl-advanced-lab"
  environment = {
    name        = "production"
    criticality = "critical"
  }
  compliance = {
    frameworks = ["sox", "iso27001", "pci-dss"]
    audit_required = true
  }
}

feature_flags = {
  enable_multi_region      = true
  enable_disaster_recovery = true
  enable_security_scanning = true
  enable_compliance_checks = true
}
```

## Advanced Features

### Variable Validation

The configuration includes comprehensive validation rules:

```hcl
variable "project_configuration" {
  validation {
    condition = can(regex("^[a-z][a-z0-9-]{2,29}$", var.project_configuration.project_name))
    error_message = "Project name must be 3-30 characters, start with a letter..."
  }
}
```

### Conditional Logic

Environment-based resource configuration:

```hcl
locals {
  instance_count = var.project_configuration.environment.name == "production" ? 3 : 1
  backup_enabled = var.project_configuration.environment.name == "production" ? true : var.feature_flags.enable_backup
}
```

### Dynamic Outputs

Comprehensive output structure for integration:

```hcl
output "deployment_summary" {
  value = {
    project     = var.project_configuration
    environment = local.environment_config
    costs       = local.optimization_config.estimated_monthly_cost
  }
}
```

## Cost Management

### Cost Optimization Features

- **Environment-based Sizing**: Automatic instance sizing based on environment
- **Resource Scheduling**: Auto start/stop for development environments
- **Rightsizing Analysis**: Monitoring for optimization opportunities
- **Cost Estimation**: Built-in cost calculation and reporting

### Cost Estimation

The configuration provides estimated monthly costs:

```bash
terraform output cost_analysis
```

Example output:
```json
{
  "estimated_monthly_costs": {
    "compute": 150,
    "storage": 25,
    "network": 25,
    "monitoring": 30,
    "backup": 20
  },
  "total_estimated_monthly_cost": 250
}
```

## Security and Compliance

### Security Features

- **Encryption**: At-rest and in-transit encryption
- **Access Control**: IAM roles and MFA configuration
- **Key Management**: IBM-managed or customer-managed keys
- **Network Security**: VPC isolation and security groups

### Compliance Frameworks

Supported compliance frameworks:
- SOX (Sarbanes-Oxley)
- HIPAA (Health Insurance Portability and Accountability Act)
- PCI-DSS (Payment Card Industry Data Security Standard)
- ISO 27001 (Information Security Management)
- GDPR (General Data Protection Regulation)
- FedRAMP (Federal Risk and Authorization Management Program)

## Monitoring and Operations

### Monitoring Configuration

- **Metrics Collection**: System and application metrics
- **Log Aggregation**: Centralized logging with retention policies
- **Alerting**: Threshold-based alerts with notification channels
- **Performance Monitoring**: Resource utilization tracking

### Operational Features

- **Maintenance Windows**: Scheduled maintenance configuration
- **Change Management**: Approval workflows and rollback capabilities
- **Incident Response**: Automated response and escalation procedures

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```bash
   # Verify API key
   ibmcloud iam api-key-get <key-name>
   
   # Test authentication
   ibmcloud resource groups
   ```

2. **Validation Failures**
   ```bash
   # Check variable validation
   terraform plan -detailed-exitcode
   
   # Review validation errors
   terraform validate
   ```

3. **Resource Conflicts**
   ```bash
   # Check existing resources
   terraform state list
   
   # Import existing resources if needed
   terraform import <resource_type>.<name> <resource_id>
   ```

### Debug Mode

Enable debug mode for detailed information:

```hcl
feature_flags = {
  enable_debug_mode = true
}
```

This generates additional files:
- `generated_config.json`: Complete configuration summary
- `generated_terraform.tfvars.template`: Dynamic template

## Best Practices

### Variable Design

1. **Use Complex Types**: Leverage object types for related configurations
2. **Implement Validation**: Add comprehensive validation rules
3. **Provide Defaults**: Sensible defaults for optional parameters
4. **Document Thoroughly**: Clear descriptions and examples

### Local Values

1. **Computed Expressions**: Use locals for complex calculations
2. **Conditional Logic**: Environment-based configurations
3. **Naming Conventions**: Consistent resource naming patterns
4. **Tag Strategies**: Comprehensive tagging for governance

### Output Design

1. **Structured Outputs**: Organized output hierarchies
2. **Integration Ready**: Outputs designed for module consumption
3. **Sensitive Data**: Proper handling of sensitive information
4. **Documentation**: Clear output descriptions and usage

## Integration

### Module Integration

This configuration is designed for integration with other modules:

```hcl
module "network" {
  source = "./modules/network"
  
  vpc_configuration = module.hcl_lab.network_configuration
  project_tags     = module.hcl_lab.resource_metadata.common_tags
}
```

### Cross-Module References

Use outputs for cross-module integration:

```hcl
# Reference network configuration
vpc_id = module.hcl_lab.network_configuration.vpc.id

# Reference security settings
encryption_key = module.hcl_lab.security_configuration.encryption.key_id
```

## Learning Exercises

### Exercise 1: Variable Validation

1. Modify validation rules in `variables.tf`
2. Test with invalid values
3. Observe validation error messages

### Exercise 2: Conditional Logic

1. Change environment from "development" to "production"
2. Observe configuration changes in outputs
3. Compare cost estimates

### Exercise 3: Feature Flags

1. Enable/disable different feature flags
2. Review impact on resource configuration
3. Analyze cost implications

### Exercise 4: Custom Configurations

1. Create a new environment configuration
2. Add custom validation rules
3. Implement environment-specific logic

## Support and Resources

### Documentation

- [Terraform HCL Syntax](https://www.terraform.io/docs/language/syntax/configuration.html)
- [IBM Cloud Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [Variable Validation](https://www.terraform.io/docs/language/values/variables.html#custom-validation-rules)

### Community

- [Terraform Community](https://discuss.hashicorp.com/c/terraform-core)
- [IBM Cloud Community](https://community.ibm.com/community/user/cloud)

### Training Resources

- Previous labs in this training series
- IBM Cloud Terraform documentation
- HashiCorp Learn platform

---

**Lab Version**: 4.2  
**Last Updated**: 2024-01-15  
**Terraform Version**: >= 1.0  
**IBM Provider Version**: ~> 1.60
