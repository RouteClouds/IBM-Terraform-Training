# =============================================================================
# DATA SOURCES
# Lab 3.1: Directory Structure and Configuration Files
# =============================================================================

# Get information about the specified resource group
data "ibm_resource_group" "project_rg" {
  name = var.resource_group_name
}

# Get available zones in the specified region
data "ibm_is_zones" "regional_zones" {
  region = var.ibm_region
}

# =============================================================================
# LOCAL VALUES AND COMPUTED CONFIGURATIONS
# =============================================================================

locals {
  # Naming convention: {project}-{environment}-{resource-type}-{identifier}
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Determine availability zones to use
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : data.ibm_is_zones.regional_zones.zones
  
  # Create subnet configurations with zone distribution
  subnet_configs = [
    for i, cidr in var.subnet_cidr_blocks : {
      name = "${local.name_prefix}-subnet-${i + 1}"
      cidr = cidr
      zone = local.availability_zones[i % length(local.availability_zones)]
    }
  ]
  
  # Common tags applied to all resources
  common_tags = merge(var.resource_tags, {
    environment   = var.environment
    region        = var.ibm_region
    owner         = var.owner
    cost_center   = var.cost_center
    created_by    = "terraform"
    created_at    = timestamp()
    lab_exercise  = "3.1-directory-structure"
  })
  
  # Security group rules configuration
  ssh_rules = [
    for cidr in var.allowed_ssh_cidr_blocks : {
      direction = "inbound"
      remote    = cidr
      tcp = {
        port_min = 22
        port_max = 22
      }
    }
  ]
  
  http_rules = [
    for cidr in var.allowed_http_cidr_blocks : {
      direction = "inbound"
      remote    = cidr
      tcp = {
        port_min = 80
        port_max = 80
      }
    }
  ]
}

# =============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# =============================================================================

# Generate random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  
  # Ensure consistent naming across resources
  keepers = {
    project_name = var.project_name
    environment  = var.environment
  }
}

# Generate random password for demonstration purposes
resource "random_password" "demo_password" {
  length  = 16
  special = true
  
  keepers = {
    project_name = var.project_name
  }
}

# =============================================================================
# TIME RESOURCES FOR DEPLOYMENT TRACKING
# =============================================================================

# Track deployment start time
resource "time_static" "deployment_start" {}

# Add delay for resource stabilization if needed
resource "time_sleep" "resource_stabilization" {
  depends_on = [ibm_is_vpc.project_vpc]
  
  create_duration = "30s"
}

# =============================================================================
# NETWORKING RESOURCES
# =============================================================================

# VPC for network isolation and organization
resource "ibm_is_vpc" "project_vpc" {
  name           = "${local.name_prefix}-vpc-${random_string.suffix.result}"
  resource_group = data.ibm_resource_group.project_rg.id
  tags           = local.common_tags
  
  # Enable classic access if specified
  classic_access = var.enable_classic_access
}

# Public gateways for internet access (one per zone if enabled)
resource "ibm_is_public_gateway" "project_gateways" {
  for_each = var.enable_public_gateway ? toset(local.availability_zones) : toset([])
  
  name           = "${local.name_prefix}-gateway-${each.key}-${random_string.suffix.result}"
  vpc            = ibm_is_vpc.project_vpc.id
  zone           = each.key
  resource_group = data.ibm_resource_group.project_rg.id
  tags           = local.common_tags
  
  depends_on = [time_sleep.resource_stabilization]
}

# Subnets distributed across availability zones
resource "ibm_is_subnet" "project_subnets" {
  count = length(local.subnet_configs)
  
  name            = local.subnet_configs[count.index].name
  vpc             = ibm_is_vpc.project_vpc.id
  zone            = local.subnet_configs[count.index].zone
  ipv4_cidr_block = local.subnet_configs[count.index].cidr
  resource_group  = data.ibm_resource_group.project_rg.id
  
  # Attach public gateway if enabled and available for this zone
  public_gateway = var.enable_public_gateway && contains(keys(ibm_is_public_gateway.project_gateways), local.subnet_configs[count.index].zone) ? ibm_is_public_gateway.project_gateways[local.subnet_configs[count.index].zone].id : null
  
  tags = merge(local.common_tags, {
    subnet_type = "general"
    zone        = local.subnet_configs[count.index].zone
  })
  
  depends_on = [time_sleep.resource_stabilization]
}

# =============================================================================
# SECURITY RESOURCES
# =============================================================================

# Default security group for the VPC
resource "ibm_is_security_group" "project_sg" {
  name           = "${local.name_prefix}-sg-default-${random_string.suffix.result}"
  vpc            = ibm_is_vpc.project_vpc.id
  resource_group = data.ibm_resource_group.project_rg.id
  tags           = local.common_tags
}

# Outbound rule - allow all outbound traffic
resource "ibm_is_security_group_rule" "outbound_all" {
  group     = ibm_is_security_group.project_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Inbound SSH rules based on allowed CIDR blocks
resource "ibm_is_security_group_rule" "inbound_ssh" {
  count = length(var.allowed_ssh_cidr_blocks)

  group     = ibm_is_security_group.project_sg.id
  direction = "inbound"
  remote    = var.allowed_ssh_cidr_blocks[count.index]

  tcp {
    port_min = 22
    port_max = 22
  }
}

# Inbound HTTP rules based on allowed CIDR blocks
resource "ibm_is_security_group_rule" "inbound_http" {
  count = length(var.allowed_http_cidr_blocks)

  group     = ibm_is_security_group.project_sg.id
  direction = "inbound"
  remote    = var.allowed_http_cidr_blocks[count.index]

  tcp {
    port_min = 80
    port_max = 80
  }
}

# Inbound HTTPS rule for secure web traffic
resource "ibm_is_security_group_rule" "inbound_https" {
  count = length(var.allowed_http_cidr_blocks)

  group     = ibm_is_security_group.project_sg.id
  direction = "inbound"
  remote    = var.allowed_http_cidr_blocks[count.index]

  tcp {
    port_min = 443
    port_max = 443
  }
}

# =============================================================================
# LOCAL FILE RESOURCES FOR DOCUMENTATION
# =============================================================================

# Generate deployment summary file
resource "local_file" "deployment_summary" {
  filename = "${path.module}/deployment-summary.json"

  content = jsonencode({
    deployment_info = {
      project_name    = var.project_name
      environment     = var.environment
      region          = var.ibm_region
      deployment_time = time_static.deployment_start.rfc3339
      terraform_version = ">=1.5.0"
    }

    resources_created = {
      vpc_count             = 1
      subnet_count          = length(local.subnet_configs)
      public_gateway_count  = var.enable_public_gateway ? length(local.availability_zones) : 0
      security_group_count  = 1
      security_rule_count   = 1 + length(var.allowed_ssh_cidr_blocks) + (2 * length(var.allowed_http_cidr_blocks))
    }

    network_configuration = {
      vpc_cidr           = var.vpc_cidr_block
      subnet_cidrs       = var.subnet_cidr_blocks
      availability_zones = local.availability_zones
      public_access      = var.enable_public_gateway
    }

    estimated_costs = {
      monthly_estimate_usd = "$15-35"
      cost_factors = [
        "VPC: Free",
        "Subnets: Free",
        "Public Gateways: $45/month each (if enabled)",
        "Security Groups: Free"
      ]
    }
  })

  depends_on = [
    ibm_is_vpc.project_vpc,
    ibm_is_subnet.project_subnets,
    ibm_is_security_group.project_sg
  ]
}
