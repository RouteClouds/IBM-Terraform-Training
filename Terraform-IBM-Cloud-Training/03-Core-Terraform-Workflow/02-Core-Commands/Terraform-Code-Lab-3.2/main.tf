# Core Terraform Commands Lab - Main Configuration
# Demonstrates infrastructure for command workflow practice

# ============================================================================
# Data Sources
# ============================================================================

# Get available zones in the region
data "ibm_is_zones" "regional_zones" {
  region = var.ibm_region
}

# Get resource group information
data "ibm_resource_group" "project_rg" {
  count = var.resource_group_id != null ? 1 : 0
  name  = var.resource_group_id
}

# ============================================================================
# Local Values for Resource Management
# ============================================================================

locals {
  # Resource naming convention: {project}-{environment}-{resource-type}-{identifier}
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags for all resources
  common_tags = merge({
    "project"           = var.project_name
    "environment"       = var.environment
    "owner"            = var.owner
    "created_by"       = "terraform"
    "training-lab"     = "core-commands"
    "cost_center"      = var.cost_center
    "managed"          = "true"
    "terraform_config" = "lab-3.2"
  }, var.additional_tags)
  
  # Zone mapping for multi-AZ deployment
  zones = data.ibm_is_zones.regional_zones.zones
  
  # Subnet configurations with zone validation
  validated_subnets = {
    for name, config in var.subnet_configurations : name => merge(config, {
      zone = contains(local.zones, config.zone) ? config.zone : local.zones[0]
    })
  }
  
  # Cost estimation calculations
  estimated_costs = var.enable_cost_estimation ? {
    vpc_cost              = 0.00  # VPC is free
    subnet_cost           = 0.00  # Subnets are free
    security_group_cost   = 0.00  # Security groups are free
    public_gateway_cost   = var.enable_public_gateway ? 45.00 : 0.00  # $45/month per gateway
    total_monthly_cost    = var.enable_public_gateway ? 45.00 : 0.00
  } : {}
}

# ============================================================================
# Random Resources for Unique Naming
# ============================================================================

# Generate unique suffix for resource names
resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
  
  keepers = {
    project     = var.project_name
    environment = var.environment
    owner       = var.owner
  }
}

# Generate random password for demonstration
resource "random_password" "demo_password" {
  length  = 16
  special = true
  
  keepers = {
    project = var.project_name
  }
}

# ============================================================================
# Time Resources for Command Timing
# ============================================================================

# Track deployment start time
resource "time_static" "deployment_start" {}

# Add delay for resource stabilization
resource "time_sleep" "resource_stabilization" {
  depends_on = [
    ibm_is_vpc.command_lab_vpc,
    ibm_is_subnet.command_lab_subnets
  ]
  
  create_duration = "30s"
}

# ============================================================================
# VPC Infrastructure
# ============================================================================

# Create VPC for command practice
resource "ibm_is_vpc" "command_lab_vpc" {
  name           = "${local.name_prefix}-vpc-${random_string.unique_suffix.result}"
  resource_group = var.resource_group_id
  tags           = local.common_tags
  
  # Address prefix management
  address_prefix_management = "manual"
}

# Create address prefix for the VPC
resource "ibm_is_vpc_address_prefix" "command_lab_prefix" {
  name = "${local.name_prefix}-prefix-${random_string.unique_suffix.result}"
  vpc  = ibm_is_vpc.command_lab_vpc.id
  zone = local.zones[0]
  cidr = var.vpc_address_prefix
}

# Create public gateway (conditional)
resource "ibm_is_public_gateway" "command_lab_gateway" {
  count = var.enable_public_gateway ? 1 : 0
  
  name           = "${local.name_prefix}-gateway-${random_string.unique_suffix.result}"
  vpc            = ibm_is_vpc.command_lab_vpc.id
  zone           = local.zones[0]
  resource_group = var.resource_group_id
  tags           = local.common_tags
}

# ============================================================================
# Subnet Configuration
# ============================================================================

# Create subnets based on configuration
resource "ibm_is_subnet" "command_lab_subnets" {
  for_each = local.validated_subnets
  
  name                     = "${local.name_prefix}-subnet-${each.key}-${random_string.unique_suffix.result}"
  vpc                      = ibm_is_vpc.command_lab_vpc.id
  zone                     = each.value.zone
  ipv4_cidr_block         = each.value.cidr_block
  resource_group          = var.resource_group_id
  public_gateway          = each.value.public && var.enable_public_gateway ? ibm_is_public_gateway.command_lab_gateway[0].id : null
  tags                    = merge(local.common_tags, {
    "subnet_type" = each.value.public ? "public" : "private"
    "tier"        = each.key
  })
  
  depends_on = [
    ibm_is_vpc_address_prefix.command_lab_prefix
  ]
}

# ============================================================================
# Security Group Configuration
# ============================================================================

# Create security group for command lab
resource "ibm_is_security_group" "command_lab_sg" {
  name           = "${local.name_prefix}-sg-${random_string.unique_suffix.result}"
  vpc            = ibm_is_vpc.command_lab_vpc.id
  resource_group = var.resource_group_id
  tags           = local.common_tags
}

# Create security group rules
resource "ibm_is_security_group_rule" "command_lab_rules" {
  for_each = {
    for idx, rule in var.security_group_rules : rule.name => rule
  }
  
  group     = ibm_is_security_group.command_lab_sg.id
  direction = each.value.direction
  
  dynamic "tcp" {
    for_each = each.value.protocol == "tcp" ? [1] : []
    content {
      port_min = each.value.port_min
      port_max = each.value.port_max
    }
  }
  
  dynamic "udp" {
    for_each = each.value.protocol == "udp" ? [1] : []
    content {
      port_min = each.value.port_min
      port_max = each.value.port_max
    }
  }
  
  dynamic "icmp" {
    for_each = each.value.protocol == "icmp" ? [1] : []
    content {
      type = each.value.port_min
      code = each.value.port_max
    }
  }
  
  # Handle source/destination based on direction
  remote = each.value.source
}

# ============================================================================
# Command Execution Resources
# ============================================================================

# Null resource for command validation
resource "null_resource" "command_validation" {
  count = var.enable_resource_validation ? 1 : 0

  # Trigger validation when key resources change
  triggers = {
    vpc_id            = ibm_is_vpc.command_lab_vpc.id
    subnet_ids        = join(",", [for s in ibm_is_subnet.command_lab_subnets : s.id])
    security_group_id = ibm_is_security_group.command_lab_sg.id
    timestamp         = timestamp()
  }

  # Validation commands
  provisioner "local-exec" {
    command = <<-EOT
      echo "🔍 Validating command lab resources..."
      echo "VPC ID: ${ibm_is_vpc.command_lab_vpc.id}"
      echo "Subnet Count: ${length(ibm_is_subnet.command_lab_subnets)}"
      echo "Security Group: ${ibm_is_security_group.command_lab_sg.id}"
      echo "✅ Resource validation completed"
    EOT
  }

  depends_on = [
    time_sleep.resource_stabilization
  ]
}

# Null resource for command logging
resource "null_resource" "command_logging" {
  count = var.enable_command_logging ? 1 : 0

  triggers = {
    deployment_id = random_string.unique_suffix.result
    timestamp     = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "📝 Command Lab Deployment Log" > command-lab-log.txt
      echo "Deployment ID: ${random_string.unique_suffix.result}" >> command-lab-log.txt
      echo "Start Time: ${time_static.deployment_start.rfc3339}" >> command-lab-log.txt
      echo "Project: ${var.project_name}" >> command-lab-log.txt
      echo "Environment: ${var.environment}" >> command-lab-log.txt
      echo "Owner: ${var.owner}" >> command-lab-log.txt
      echo "Region: ${var.ibm_region}" >> command-lab-log.txt
      echo "VPC CIDR: ${var.vpc_address_prefix}" >> command-lab-log.txt
      echo "Public Gateway: ${var.enable_public_gateway}" >> command-lab-log.txt
      echo "Estimated Monthly Cost: $${local.estimated_costs.total_monthly_cost}" >> command-lab-log.txt
    EOT
  }
}

# ============================================================================
# Local File Generation
# ============================================================================

# Generate deployment summary
resource "local_file" "deployment_summary" {
  filename = "command-lab-deployment-summary.json"
  content = jsonencode({
    deployment_info = {
      deployment_id   = random_string.unique_suffix.result
      project_name    = var.project_name
      environment     = var.environment
      owner          = var.owner
      region         = var.ibm_region
      deployment_time = time_static.deployment_start.rfc3339
    }

    infrastructure = {
      vpc = {
        id   = ibm_is_vpc.command_lab_vpc.id
        name = ibm_is_vpc.command_lab_vpc.name
        cidr = var.vpc_address_prefix
      }

      subnets = {
        for name, subnet in ibm_is_subnet.command_lab_subnets : name => {
          id   = subnet.id
          name = subnet.name
          cidr = subnet.ipv4_cidr_block
          zone = subnet.zone
          type = local.validated_subnets[name].public ? "public" : "private"
        }
      }

      security_group = {
        id    = ibm_is_security_group.command_lab_sg.id
        name  = ibm_is_security_group.command_lab_sg.name
        rules = length(var.security_group_rules)
      }

      public_gateway = var.enable_public_gateway ? {
        id   = ibm_is_public_gateway.command_lab_gateway[0].id
        name = ibm_is_public_gateway.command_lab_gateway[0].name
        zone = ibm_is_public_gateway.command_lab_gateway[0].zone
      } : null
    }

    cost_estimation = local.estimated_costs

    command_configuration = {
      logging_enabled      = var.enable_command_logging
      validation_enabled   = var.enable_resource_validation
      plan_validation     = var.enable_plan_validation
      auto_approve_destroy = var.auto_approve_destroy
      command_timeout     = var.command_timeout
    }

    tags = local.common_tags
  })

  depends_on = [
    ibm_is_vpc.command_lab_vpc,
    ibm_is_subnet.command_lab_subnets,
    ibm_is_security_group.command_lab_sg
  ]
}

# Generate command reference file
resource "local_file" "command_reference" {
  filename = "terraform-commands-reference.md"
  content = <<-EOT
# Terraform Commands Reference - Lab 3.2

## Project Information
- **Project**: ${var.project_name}
- **Environment**: ${var.environment}
- **Owner**: ${var.owner}
- **Deployment ID**: ${random_string.unique_suffix.result}

## Core Commands for This Lab

### 1. terraform init
```bash
# Initialize the working directory
terraform init

# Initialize with upgrade
terraform init -upgrade

# Initialize for CI/CD
terraform init -no-color -input=false
```

### 2. terraform validate
```bash
# Validate configuration
terraform validate

# Validate with JSON output
terraform validate -json

# Validate for automation
terraform validate -no-color
```

### 3. terraform plan
```bash
# Generate execution plan
terraform plan

# Save plan for later execution
terraform plan -out=lab32.tfplan

# Plan with variable overrides
terraform plan -var="enable_public_gateway=false"
```

### 4. terraform apply
```bash
# Apply with confirmation
terraform apply

# Apply saved plan
terraform apply lab32.tfplan

# Apply with auto-approval (use with caution)
terraform apply -auto-approve
```

### 5. terraform destroy
```bash
# Plan destruction
terraform plan -destroy

# Destroy with confirmation
terraform destroy

# Destroy with auto-approval (use with caution)
terraform destroy -auto-approve
```

## Resource Information
- **VPC ID**: ${ibm_is_vpc.command_lab_vpc.id}
- **Security Group ID**: ${ibm_is_security_group.command_lab_sg.id}
- **Estimated Monthly Cost**: $${local.estimated_costs.total_monthly_cost}

## Command Best Practices
1. Always run `terraform validate` before `terraform plan`
2. Save plans for production deployments
3. Use `-no-color` flag for CI/CD pipelines
4. Enable logging for troubleshooting
5. Review plans carefully before applying
6. Use targeted operations when needed

## Troubleshooting Commands
```bash
# Check Terraform version
terraform version

# List providers
terraform providers

# Show current state
terraform show

# List resources in state
terraform state list

# Refresh state
terraform refresh
```

Generated on: ${time_static.deployment_start.rfc3339}
EOT

  depends_on = [
    ibm_is_vpc.command_lab_vpc,
    ibm_is_security_group.command_lab_sg
  ]
}
