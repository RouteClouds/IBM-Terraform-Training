# Terraform Code for Lab 1.1: Infrastructure as Code Fundamentals

This directory contains complete, working Terraform code examples specifically designed for IBM Cloud services. The code demonstrates Infrastructure as Code (IaC) principles through practical implementation of cloud resources.

## Overview

This Terraform configuration creates a complete, functional infrastructure on IBM Cloud including:
- Virtual Private Cloud (VPC) with custom configuration
- Subnet with proper CIDR allocation and zone placement
- Security Group with customizable rules
- Virtual Server Instance (VSI) with Ubuntu 20.04
- Public Gateway for internet access (optional)
- Floating IP for external access (optional)

## File Structure

```
Terraform-Code-Lab-1.1/
├── README.md                    # This file - comprehensive documentation
├── providers.tf                 # Provider configuration and version constraints
├── variables.tf                 # Input variable definitions with validation
├── main.tf                      # Primary resource definitions
├── outputs.tf                   # Output value definitions
├── terraform.tfvars.example     # Example variable values and configuration
├── user_data.sh                 # Bootstrap script for VSI initialization
└── .gitignore                   # Git ignore file (to be created)
```

## Prerequisites

### Required Software
- **Terraform**: Version 1.5.0 or higher
- **IBM Cloud CLI**: Latest version
- **Git**: For version control (recommended)

### IBM Cloud Requirements
- Active IBM Cloud account
- API key with appropriate permissions
- Access to VPC Infrastructure services
- Resource group with proper permissions

### Required IBM Cloud Permissions
Your API key must have the following IAM permissions:
- **VPC Infrastructure Services**: Editor or Administrator
- **Resource Group**: Viewer (minimum)
- **Identity and Access Management**: Viewer (for SSH key access)

## Quick Start

### 1. Clone and Setup
```bash
# Navigate to this directory
cd Terraform-Code-Lab-1.1

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the variables file with your specific values
vim terraform.tfvars  # or use your preferred editor
```

### 2. Configure Variables
Edit `terraform.tfvars` and provide at minimum:
```hcl
ibmcloud_api_key = "your-api-key-here"
ibm_region = "us-south"
project_name = "your-project-name"
owner = "your-name"
```

### 3. Initialize and Deploy
```bash
# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Apply the configuration
terraform apply
```

### 4. Verify Deployment
```bash
# Check created resources
terraform show

# View outputs
terraform output

# Verify in IBM Cloud CLI
ibmcloud is vpcs
ibmcloud is instances
```

## Configuration Details

### Provider Configuration (`providers.tf`)
- **IBM Cloud Provider**: Version ~> 1.58.0 for latest features and bug fixes
- **Random Provider**: For generating unique resource names
- **Time Provider**: For deployment timestamps and time-based resources

### Variables (`variables.tf`)
The configuration includes comprehensive variable definitions with:
- **Validation Rules**: Ensure valid inputs for regions, profiles, etc.
- **Default Values**: Sensible defaults for quick deployment
- **Descriptions**: Clear documentation for each variable
- **Type Constraints**: Proper typing for complex variables

### Main Resources (`main.tf`)
Creates the following IBM Cloud resources:

#### 1. Virtual Private Cloud (VPC)
- Configurable address prefix management
- Optional classic infrastructure access
- Comprehensive tagging strategy

#### 2. Public Gateway
- Enables internet access for subnet resources
- Conditionally created based on variables
- Proper zone placement

#### 3. Subnet
- Configurable CIDR block
- Automatic zone selection or manual specification
- Optional public gateway attachment

#### 4. Security Group
- Custom security group with configurable rules
- Support for TCP, UDP, and ICMP protocols
- Flexible rule definitions via variables

#### 5. Virtual Server Instance
- Ubuntu 20.04 LTS image
- Configurable instance profiles
- Optional SSH key integration
- Custom user data for initialization
- Boot volume configuration with encryption support

#### 6. Optional Resources
- Floating IP for external access
- Enhanced monitoring and logging
- Custom volume encryption

### Outputs (`outputs.tf`)
Comprehensive output values including:
- **Resource IDs**: For integration with other Terraform configurations
- **Network Information**: IP addresses, CIDR blocks, zone details
- **Connection Details**: SSH commands and access information
- **Summary Information**: Formatted data for lab reports

## Advanced Configuration

### Custom Security Group Rules
```hcl
security_group_rules = [
  {
    direction   = "inbound"
    ip_version  = "ipv4"
    protocol    = "tcp"
    port_min    = 80
    port_max    = 80
    remote      = "0.0.0.0/0"
    description = "Allow HTTP"
  },
  {
    direction   = "inbound"
    ip_version  = "ipv4"
    protocol    = "tcp"
    port_min    = 443
    port_max    = 443
    remote      = "0.0.0.0/0"
    description = "Allow HTTPS"
  }
]
```

### Multi-Environment Support
```hcl
# Development environment
environment = "dev"
vsi_profile = "bx2-2x8"
create_floating_ip = true

# Production environment
environment = "prod"
vsi_profile = "bx2-4x16"
enable_monitoring = true
volume_encryption_key = "crn:v1:bluemix:public:kms:..."
```

### SSH Key Integration
```hcl
# First, create an SSH key in IBM Cloud
vsi_ssh_key_name = "my-training-key"
```

## User Data Script

The `user_data.sh` script automatically:
- Sets the hostname to match the VSI name
- Updates system packages
- Installs essential development tools
- Creates a welcome message and info script
- Sets up a simple web server for testing
- Logs deployment completion

## Best Practices Demonstrated

### 1. Resource Naming
- Consistent naming convention with project, environment, and random suffix
- Descriptive names that indicate purpose and ownership

### 2. Tagging Strategy
- Comprehensive tagging for cost allocation and resource management
- Combination of default and custom tags
- Environment and project identification

### 3. Security Configuration
- Least privilege security group rules
- Optional encryption for volumes
- Secure handling of sensitive variables

### 4. Error Handling
- Input validation for variables
- Proper resource dependencies
- Timeout configurations for resource creation

### 5. Documentation
- Comprehensive comments in all files
- Clear variable descriptions
- Example configurations for different scenarios

## Troubleshooting

### Common Issues

#### 1. Authentication Errors
```bash
# Verify API key
ibmcloud iam api-key-get YOUR_KEY_NAME

# Re-authenticate
ibmcloud login --apikey YOUR_API_KEY
```

#### 2. Resource Conflicts
```bash
# Check for existing resources
ibmcloud is vpcs | grep training
ibmcloud is instances | grep training

# Modify resource names if conflicts exist
```

#### 3. Permission Issues
- Verify IAM permissions for VPC services
- Check resource group access
- Ensure API key has sufficient privileges

#### 4. Region/Zone Issues
```bash
# List available regions
ibmcloud regions

# List zones in a region
ibmcloud is zones us-south
```

### Debugging Commands
```bash
# Enable detailed Terraform logging
export TF_LOG=DEBUG
terraform plan

# Validate configuration
terraform validate

# Check state
terraform state list
terraform state show RESOURCE_NAME
```

## Cost Management

### Estimated Costs (USD, approximate)
- **bx2-2x8 VSI**: $0.10-0.15 per hour
- **VPC and Subnet**: No additional charge
- **Public Gateway**: $0.045 per hour
- **Floating IP**: $0.004 per hour (if created)

### Cost Optimization Tips
- Use `auto_delete_volume = true` for training environments
- Run `terraform destroy` after lab completion
- Monitor IBM Cloud billing dashboard
- Set up billing alerts for cost control

## Security Considerations

### For Training Environments
- Default security group allows SSH (port 22) from anywhere
- ICMP (ping) enabled for connectivity testing
- All outbound traffic allowed

### For Production Environments
- Restrict SSH access to specific IP ranges
- Implement more granular security group rules
- Enable volume encryption
- Use dedicated resource groups
- Implement proper IAM policies

## Integration with Lab Exercises

This Terraform code is specifically designed to support:
- **Lab 1.1**: Comparing manual vs automated infrastructure provisioning
- **Version Control**: Demonstrating infrastructure change management
- **Reproducibility**: Creating identical environments multiple times
- **Documentation**: Code as living documentation

## Cleanup

### Automated Cleanup
```bash
# Destroy all resources
terraform destroy

# Verify cleanup
terraform state list  # Should be empty
```

### Manual Verification
```bash
# Check IBM Cloud console or CLI
ibmcloud is vpcs
ibmcloud is instances
ibmcloud is floating-ips
```

## Next Steps

After completing this lab:
1. Experiment with different variable values
2. Add additional resources (load balancers, databases)
3. Implement Terraform modules for reusability
4. Explore Terraform state management
5. Integrate with CI/CD pipelines

## Contributing

To improve this Terraform code:
1. Test changes in a separate environment
2. Validate with `terraform validate`
3. Check formatting with `terraform fmt`
4. Update documentation as needed
5. Submit changes through proper review process

## Support

For issues with this Terraform code:
1. Check the troubleshooting section above
2. Review Terraform and IBM Cloud provider documentation
3. Consult IBM Cloud support for platform-specific issues
4. Refer to the main training documentation

## Cross-References and Educational Integration

### **Visual Learning Aids**
This lab is enhanced by professional diagrams that illustrate key concepts:
- **Traditional vs IaC Comparison**: See `../DaC/generated_diagrams/traditional_vs_iac_comparison.png` (Figure 1.1)
- **IaC Core Principles**: Reference `../DaC/generated_diagrams/iac_principles.png` (Figure 1.2)
- **IaC Benefits**: View `../DaC/generated_diagrams/iac_benefits.png` (Figure 1.3)
- **IaC Tools Landscape**: Consult `../DaC/generated_diagrams/iac_tools_landscape.png` (Figure 1.4)
- **IaC Workflow**: Use `../DaC/generated_diagrams/iac_workflow.png` (Figure 1 in Lab-1.md)

### **Related Training Materials**
- **Concept.md**: Theoretical foundation for IaC concepts and principles
- **Lab-1.md**: Hands-on laboratory exercise for practical implementation
- **Topic 1.2**: Benefits and Use Cases (`../../02-Benefits-and-Use-Cases/`)
- **Topic Assessment**: `../Test-Your-Understanding-Topic-1.md`

### **Integration Points**
- **Figure References**: All diagrams are strategically placed in educational content
- **Cross-Topic Learning**: Builds foundation for Topic 2 advanced implementations
- **Assessment Support**: Visual aids enhance theoretical understanding for testing

---

## Version History

- **v1.0**: Initial implementation with basic VPC, subnet, and VSI
- **v1.1**: Added security group customization and user data
- **v1.2**: Enhanced outputs and error handling
- **v1.3**: Added optional floating IP and monitoring support

---

**Lab Completion**: Estimated 90 minutes
**Certification**: Contributes to IBM Cloud IaC Specialist certification
**Business Value**: Foundation for advanced IaC implementations and cost optimization strategies
