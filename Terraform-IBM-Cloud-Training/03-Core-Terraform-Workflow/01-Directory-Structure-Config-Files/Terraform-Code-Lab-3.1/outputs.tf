# =============================================================================
# NETWORKING OUTPUTS
# Lab 3.1: Directory Structure and Configuration Files
# =============================================================================

output "vpc_id" {
  description = "ID of the created VPC for resource references and integration"
  value       = ibm_is_vpc.project_vpc.id
}

output "vpc_name" {
  description = "Name of the created VPC for identification and management"
  value       = ibm_is_vpc.project_vpc.name
}

output "vpc_crn" {
  description = "Cloud Resource Name (CRN) of the VPC for IBM Cloud service integration"
  value       = ibm_is_vpc.project_vpc.crn
}

output "vpc_status" {
  description = "Current status of the VPC (available, pending, etc.)"
  value       = ibm_is_vpc.project_vpc.status
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the VPC for network planning"
  value       = var.vpc_cidr_block
}

output "subnet_ids" {
  description = "List of subnet IDs for compute resource deployment"
  value       = ibm_is_subnet.project_subnets[*].id
}

output "subnet_names" {
  description = "List of subnet names for identification and management"
  value       = ibm_is_subnet.project_subnets[*].name
}

output "subnet_details" {
  description = "Comprehensive subnet information including IDs, names, zones, and CIDR blocks"
  value = [
    for subnet in ibm_is_subnet.project_subnets : {
      id          = subnet.id
      name        = subnet.name
      zone        = subnet.zone
      cidr_block  = subnet.ipv4_cidr_block
      status      = subnet.status
      available_ipv4_address_count = subnet.available_ipv4_address_count
    }
  ]
}

output "public_gateway_ids" {
  description = "Map of public gateway IDs by availability zone for internet access configuration"
  value       = { for k, v in ibm_is_public_gateway.project_gateways : k => v.id }
}

output "public_gateway_details" {
  description = "Comprehensive public gateway information for network configuration"
  value = {
    for k, v in ibm_is_public_gateway.project_gateways : k => {
      id     = v.id
      name   = v.name
      zone   = v.zone
      status = v.status
      crn    = v.crn
    }
  }
}

# =============================================================================
# SECURITY OUTPUTS
# =============================================================================

output "security_group_id" {
  description = "ID of the default security group for instance configuration"
  value       = ibm_is_security_group.project_sg.id
}

output "security_group_name" {
  description = "Name of the default security group for identification"
  value       = ibm_is_security_group.project_sg.name
}

output "security_group_crn" {
  description = "CRN of the security group for IBM Cloud service integration"
  value       = ibm_is_security_group.project_sg.crn
}

output "security_rules_summary" {
  description = "Summary of configured security group rules for network access control"
  value = {
    outbound_rules = 1
    ssh_rules      = length(var.allowed_ssh_cidr_blocks)
    http_rules     = length(var.allowed_http_cidr_blocks)
    https_rules    = length(var.allowed_http_cidr_blocks)
    total_rules    = 1 + length(var.allowed_ssh_cidr_blocks) + (2 * length(var.allowed_http_cidr_blocks))
  }
}

# =============================================================================
# PROJECT INFORMATION OUTPUTS
# =============================================================================

output "project_info" {
  description = "Comprehensive project deployment information for documentation and integration"
  value = {
    project_name    = var.project_name
    environment     = var.environment
    region          = var.ibm_region
    owner           = var.owner
    cost_center     = var.cost_center
    name_prefix     = local.name_prefix
    random_suffix   = random_string.suffix.result
    deployment_time = time_static.deployment_start.rfc3339
    lab_exercise    = "3.1-directory-structure"
  }
}

output "resource_summary" {
  description = "Summary of all created resources for inventory and cost tracking"
  value = {
    vpc_count             = 1
    subnet_count          = length(local.subnet_configs)
    public_gateway_count  = var.enable_public_gateway ? length(local.availability_zones) : 0
    security_group_count  = 1
    security_rule_count   = 1 + length(var.allowed_ssh_cidr_blocks) + (2 * length(var.allowed_http_cidr_blocks))
    total_resources       = 1 + length(local.subnet_configs) + (var.enable_public_gateway ? length(local.availability_zones) : 0) + 1
    estimated_monthly_cost = var.enable_public_gateway ? "$45-135 USD" : "$0-5 USD"
  }
}

output "network_configuration" {
  description = "Complete network configuration details for documentation and troubleshooting"
  value = {
    vpc_cidr           = var.vpc_cidr_block
    subnet_cidrs       = var.subnet_cidr_blocks
    availability_zones = local.availability_zones
    public_access      = var.enable_public_gateway
    classic_access     = var.enable_classic_access
    dns_servers        = length(var.dns_servers) > 0 ? var.dns_servers : ["IBM Cloud Default"]
    flow_logs_enabled  = var.enable_flow_logs
  }
}

output "connection_info" {
  description = "Information for connecting to and using the infrastructure"
  value = {
    vpc_id              = ibm_is_vpc.project_vpc.id
    primary_subnet_id   = length(ibm_is_subnet.project_subnets) > 0 ? ibm_is_subnet.project_subnets[0].id : null
    security_group_id   = ibm_is_security_group.project_sg.id
    internet_access     = var.enable_public_gateway
    ssh_access_allowed  = length(var.allowed_ssh_cidr_blocks) > 0
    web_access_allowed  = length(var.allowed_http_cidr_blocks) > 0
    deployment_region   = var.ibm_region
  }
}

# =============================================================================
# DEPLOYMENT TRACKING OUTPUTS
# =============================================================================

output "deployment_metadata" {
  description = "Metadata about the deployment for tracking and auditing"
  value = {
    terraform_version   = ">=1.5.0"
    ibm_provider_version = "~>1.58.0"
    deployment_start    = time_static.deployment_start.rfc3339
    configuration_hash  = md5(jsonencode({
      project_name = var.project_name
      environment  = var.environment
      vpc_cidr     = var.vpc_cidr_block
      subnets      = var.subnet_cidr_blocks
    }))
    resource_group_id   = data.ibm_resource_group.project_rg.id
    resource_group_name = var.resource_group_name
  }
}

output "cost_estimation" {
  description = "Detailed cost estimation for budget planning and tracking"
  value = {
    monthly_estimate = {
      vpc                = "$0 USD (Free)"
      subnets           = "$0 USD (Free)"
      security_groups   = "$0 USD (Free)"
      public_gateways   = var.enable_public_gateway ? "$${length(local.availability_zones) * 45} USD" : "$0 USD"
      total_estimated   = var.enable_public_gateway ? "$${length(local.availability_zones) * 45}-${length(local.availability_zones) * 45 + 10} USD" : "$0-5 USD"
    }
    cost_factors = [
      "VPC: No charge for VPC itself",
      "Subnets: No charge for subnet creation",
      "Security Groups: No charge for security group rules",
      var.enable_public_gateway ? "Public Gateways: $45 USD per gateway per month" : "Public Gateways: Disabled (no cost)",
      "Data Transfer: Additional charges may apply for data transfer"
    ]
    optimization_tips = [
      "Disable public gateways if internet access is not required",
      "Use private endpoints for IBM Cloud services to reduce data transfer costs",
      "Monitor usage with IBM Cloud Cost and Resource Tracking",
      "Consider using reserved capacity for predictable workloads"
    ]
  }
}

# =============================================================================
# NEXT STEPS OUTPUTS
# =============================================================================

output "next_steps" {
  description = "Recommended next steps for using this infrastructure"
  value = {
    immediate_actions = [
      "Review the generated deployment-summary.json file",
      "Test network connectivity between subnets",
      "Verify security group rules meet your requirements",
      "Document any custom configurations for your team"
    ]
    integration_options = [
      "Deploy virtual server instances in the created subnets",
      "Configure load balancers for high availability",
      "Set up VPN connections for hybrid connectivity",
      "Implement monitoring and logging solutions"
    ]
    learning_progression = [
      "Proceed to Topic 3.2: Core Commands (init, validate, plan, apply, destroy)",
      "Explore Topic 3.3: Provider Configuration and Authentication",
      "Advance to Topic 4: Resource Provisioning & Management",
      "Study Topic 5: Modularization & Best Practices"
    ]
  }
}

# =============================================================================
# VALIDATION OUTPUTS
# =============================================================================

output "validation_results" {
  description = "Validation results for configuration verification"
  value = {
    configuration_valid = true
    vpc_created        = ibm_is_vpc.project_vpc.status == "available"
    subnets_created    = length([for s in ibm_is_subnet.project_subnets : s if s.status == "available"]) == length(local.subnet_configs)
    security_configured = ibm_is_security_group.project_sg.id != null
    naming_consistent  = can(regex("^${local.name_prefix}-", ibm_is_vpc.project_vpc.name))
    tags_applied       = length(ibm_is_vpc.project_vpc.tags) > 0
  }
}
