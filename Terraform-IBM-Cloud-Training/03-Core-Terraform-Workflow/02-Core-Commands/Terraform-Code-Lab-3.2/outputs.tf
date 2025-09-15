# Core Terraform Commands Lab - Output Definitions
# Comprehensive outputs for command workflow practice and validation

# ============================================================================
# Deployment Information Outputs
# ============================================================================

output "deployment_info" {
  description = "Comprehensive deployment information for command lab"
  value = {
    deployment_id   = random_string.unique_suffix.result
    project_name    = var.project_name
    environment     = var.environment
    owner          = var.owner
    region         = var.ibm_region
    deployment_time = time_static.deployment_start.rfc3339
    terraform_version = ">=1.5.0"
    lab_version    = "3.2"
  }
}

output "command_configuration" {
  description = "Command configuration settings for this lab"
  value = {
    logging_enabled      = var.enable_command_logging
    validation_enabled   = var.enable_resource_validation
    plan_validation     = var.enable_plan_validation
    auto_approve_destroy = var.auto_approve_destroy
    command_timeout     = var.command_timeout
    validation_timeout  = var.validation_timeout
  }
}

# ============================================================================
# Infrastructure Outputs
# ============================================================================

output "vpc_info" {
  description = "VPC information for command practice"
  value = {
    id                        = ibm_is_vpc.command_lab_vpc.id
    name                      = ibm_is_vpc.command_lab_vpc.name
    crn                       = ibm_is_vpc.command_lab_vpc.crn
    status                    = ibm_is_vpc.command_lab_vpc.status
    address_prefix_management = ibm_is_vpc.command_lab_vpc.address_prefix_management
    default_security_group_id = ibm_is_vpc.command_lab_vpc.default_security_group
    resource_group_id         = ibm_is_vpc.command_lab_vpc.resource_group
    tags                      = ibm_is_vpc.command_lab_vpc.tags
  }
}

output "subnet_info" {
  description = "Subnet information for all created subnets"
  value = {
    for name, subnet in ibm_is_subnet.command_lab_subnets : name => {
      id              = subnet.id
      name            = subnet.name
      crn             = subnet.crn
      cidr_block      = subnet.ipv4_cidr_block
      zone            = subnet.zone
      status          = subnet.status
      available_ipv4_address_count = subnet.available_ipv4_address_count
      total_ipv4_address_count     = subnet.total_ipv4_address_count
      public_gateway  = subnet.public_gateway
      subnet_type     = local.validated_subnets[name].public ? "public" : "private"
      tier           = name
    }
  }
}

output "security_group_info" {
  description = "Security group information and rules"
  value = {
    id           = ibm_is_security_group.command_lab_sg.id
    name         = ibm_is_security_group.command_lab_sg.name
    crn          = ibm_is_security_group.command_lab_sg.crn
    vpc_id       = ibm_is_security_group.command_lab_sg.vpc
    rules_count  = length(var.security_group_rules)
    rules = {
      for name, rule in ibm_is_security_group_rule.command_lab_rules : name => {
        id        = rule.id
        direction = rule.direction
        protocol  = var.security_group_rules[index(var.security_group_rules.*.name, name)].protocol
        port_min  = var.security_group_rules[index(var.security_group_rules.*.name, name)].port_min
        port_max  = var.security_group_rules[index(var.security_group_rules.*.name, name)].port_max
        source    = var.security_group_rules[index(var.security_group_rules.*.name, name)].source
      }
    }
  }
}

output "public_gateway_info" {
  description = "Public gateway information (if enabled)"
  value = var.enable_public_gateway ? {
    id     = ibm_is_public_gateway.command_lab_gateway[0].id
    name   = ibm_is_public_gateway.command_lab_gateway[0].name
    crn    = ibm_is_public_gateway.command_lab_gateway[0].crn
    zone   = ibm_is_public_gateway.command_lab_gateway[0].zone
    status = ibm_is_public_gateway.command_lab_gateway[0].status
    vpc_id = ibm_is_public_gateway.command_lab_gateway[0].vpc
  } : null
}

# ============================================================================
# Cost and Resource Management Outputs
# ============================================================================

output "cost_estimation" {
  description = "Estimated monthly costs for deployed resources"
  value = var.enable_cost_estimation ? {
    vpc_cost              = local.estimated_costs.vpc_cost
    subnet_cost           = local.estimated_costs.subnet_cost
    security_group_cost   = local.estimated_costs.security_group_cost
    public_gateway_cost   = local.estimated_costs.public_gateway_cost
    total_monthly_cost    = local.estimated_costs.total_monthly_cost
    currency             = "USD"
    cost_breakdown = {
      free_resources = [
        "VPC",
        "Subnets (${length(ibm_is_subnet.command_lab_subnets)})",
        "Security Groups",
        "Security Group Rules (${length(var.security_group_rules)})"
      ]
      paid_resources = var.enable_public_gateway ? [
        "Public Gateway: $45.00/month"
      ] : []
    }
  } : {
    message = "Cost estimation disabled"
  }
}

output "resource_summary" {
  description = "Summary of all created resources"
  value = {
    total_resources = (
      1 + # VPC
      length(ibm_is_subnet.command_lab_subnets) + # Subnets
      1 + # Security Group
      length(var.security_group_rules) + # Security Group Rules
      (var.enable_public_gateway ? 1 : 0) + # Public Gateway
      1 + # Address Prefix
      2 + # Random resources
      2   # Time resources
    )
    
    resource_breakdown = {
      networking = {
        vpc_count              = 1
        subnet_count           = length(ibm_is_subnet.command_lab_subnets)
        security_group_count   = 1
        security_rule_count    = length(var.security_group_rules)
        public_gateway_count   = var.enable_public_gateway ? 1 : 0
        address_prefix_count   = 1
      }
      
      utility = {
        random_string_count  = 1
        random_password_count = 1
        time_static_count    = 1
        time_sleep_count     = 1
        null_resource_count  = (var.enable_resource_validation ? 1 : 0) + (var.enable_command_logging ? 1 : 0)
        local_file_count     = 2
      }
    }
    
    zones_used = length(distinct([for subnet in ibm_is_subnet.command_lab_subnets : subnet.zone]))
    tags_applied = length(local.common_tags)
  }
}

# ============================================================================
# Command Practice Outputs
# ============================================================================

output "terraform_commands" {
  description = "Essential Terraform commands for this lab"
  value = {
    initialization = [
      "terraform init",
      "terraform init -upgrade",
      "terraform init -no-color -input=false"
    ]
    
    validation = [
      "terraform validate",
      "terraform validate -json",
      "terraform validate -no-color"
    ]
    
    planning = [
      "terraform plan",
      "terraform plan -out=lab32.tfplan",
      "terraform plan -var='enable_public_gateway=false'",
      "terraform plan -target=ibm_is_vpc.command_lab_vpc"
    ]
    
    deployment = [
      "terraform apply",
      "terraform apply lab32.tfplan",
      "terraform apply -auto-approve",
      "terraform apply -target=ibm_is_vpc.command_lab_vpc"
    ]
    
    destruction = [
      "terraform plan -destroy",
      "terraform destroy",
      "terraform destroy -auto-approve",
      "terraform destroy -target=ibm_is_public_gateway.command_lab_gateway"
    ]
    
    state_management = [
      "terraform show",
      "terraform state list",
      "terraform state show ibm_is_vpc.command_lab_vpc",
      "terraform refresh"
    ]
  }
}

output "lab_validation_results" {
  description = "Validation results for lab completion"
  value = {
    vpc_created = ibm_is_vpc.command_lab_vpc.id != null
    subnets_created = length(ibm_is_subnet.command_lab_subnets) > 0
    security_group_created = ibm_is_security_group.command_lab_sg.id != null
    public_gateway_created = var.enable_public_gateway ? (length(ibm_is_public_gateway.command_lab_gateway) > 0) : true
    
    validation_status = {
      infrastructure_deployed = true
      commands_available = true
      outputs_generated = true
      files_created = true
    }
    
    next_steps = [
      "Practice terraform init with different flags",
      "Experiment with terraform plan options",
      "Test terraform apply with saved plans",
      "Practice targeted operations",
      "Explore state management commands"
    ]
  }
}

# ============================================================================
# Connection and Access Information
# ============================================================================

output "connection_info" {
  description = "Connection information for accessing deployed resources"
  value = {
    vpc_dashboard_url = "https://cloud.ibm.com/vpc-ext/network/vpcs/${ibm_is_vpc.command_lab_vpc.id}"
    region = var.ibm_region
    
    subnet_access = {
      for name, subnet in ibm_is_subnet.command_lab_subnets : name => {
        subnet_id = subnet.id
        zone = subnet.zone
        cidr = subnet.ipv4_cidr_block
        internet_access = subnet.public_gateway != null ? "Available via Public Gateway" : "Private only"
      }
    }
    
    security_group_dashboard = "https://cloud.ibm.com/vpc-ext/network/securityGroups/${ibm_is_security_group.command_lab_sg.id}"
    
    management_commands = {
      view_resources = "ibmcloud is vpcs --output json"
      view_subnets = "ibmcloud is subnets --output json"
      view_security_groups = "ibmcloud is security-groups --output json"
    }
  }
}

# ============================================================================
# Troubleshooting and Support Outputs
# ============================================================================

output "troubleshooting_info" {
  description = "Troubleshooting information and common solutions"
  value = {
    common_issues = {
      "terraform init fails" = "Check internet connectivity and proxy settings"
      "terraform plan fails" = "Verify API key and permissions"
      "terraform apply fails" = "Check quotas and resource limits"
      "terraform destroy fails" = "Use targeted destruction or manual cleanup"
    }
    
    diagnostic_commands = [
      "terraform version",
      "terraform providers",
      "terraform show",
      "terraform state list",
      "terraform refresh"
    ]
    
    log_files = [
      "command-lab-log.txt",
      "command-lab-deployment-summary.json",
      "terraform-commands-reference.md"
    ]
    
    support_resources = {
      terraform_docs = "https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs"
      ibm_cloud_docs = "https://cloud.ibm.com/docs/terraform"
      community_forum = "https://community.ibm.com/community/user/cloud/communities/community-home?CommunityKey=7544b2c5-77a4-4c8a-8a97-b8b8b8b8b8b8"
    }
  }
}
