# Terraform Configuration Organization Lab - Main Configuration
# Demonstrates enterprise-grade configuration organization with modular architecture

# ============================================================================
# LOCAL VALUES AND COMPUTED CONFIGURATIONS
# ============================================================================

locals {
  # Environment-specific configuration selection
  current_environment = var.organization_config.environment
  env_config = lookup(var.environment_specific_config, local.current_environment, var.environment_specific_config.development)
  
  # Naming convention implementation
  base_name = join(var.naming_convention.separator, compact([
    var.naming_convention.prefix,
    lower(replace(var.organization_config.name, " ", "-")),
    local.current_environment,
    var.organization_config.project_name
  ]))
  
  # Generate unique suffix if enabled
  unique_suffix = var.naming_convention.use_random ? random_string.unique_id[0].result : ""
  
  # Final resource name with length validation
  resource_name_base = var.naming_convention.use_random ? "${local.base_name}-${local.unique_suffix}" : local.base_name
  
  resource_name = length(local.resource_name_base) <= var.naming_convention.max_length ? local.resource_name_base : substr(local.resource_name_base, 0, var.naming_convention.max_length - 3)
  
  # Standard tags for all resources
  standard_tags = merge(
    {
      "Name"         = local.resource_name
      "Environment"  = local.current_environment
      "Project"      = var.organization_config.project_name
      "Organization" = var.organization_config.name
      "Division"     = var.organization_config.division
      "CostCenter"   = var.organization_config.cost_center
      "Owner"        = var.organization_config.owner
      "Contact"      = var.organization_config.contact
      "ManagedBy"    = "terraform"
      "CreatedAt"    = timestamp()
      "Compliance"   = var.security_configuration.compliance_framework
      "DataClass"    = var.security_configuration.data_classification
    },
    var.cost_configuration.cost_allocation_tags,
    var.standard_tags,
    var.custom_tags
  )
  
  # Network configuration processing
  vpc_name = "${local.resource_name}-vpc"
  
  # Process subnets with naming convention
  processed_subnets = [
    for idx, subnet in var.network_configuration.subnets : {
      name                    = "${local.resource_name}-${subnet.name}"
      zone                    = subnet.zone
      cidr_block             = subnet.cidr_block
      public_gateway_enabled = subnet.public_gateway_enabled
      acl_rules              = subnet.acl_rules
      index                  = idx
    }
  ]
  
  # Process security groups with naming convention
  processed_security_groups = [
    for idx, sg in var.network_configuration.security_groups : {
      name        = "${local.resource_name}-${sg.name}"
      description = sg.description
      rules       = sg.rules
      index       = idx
    }
  ]
  
  # Compute configuration processing
  instance_count = lookup(local.env_config, "instance_count", var.compute_configuration.instance_count)
  
  # Cost calculation
  estimated_monthly_cost = {
    compute = local.instance_count * 24.00 * (
      var.compute_configuration.instance_profile == "cx2-2x4" ? 1 :
      var.compute_configuration.instance_profile == "cx2-4x8" ? 2 :
      var.compute_configuration.instance_profile == "cx2-8x16" ? 4 :
      var.compute_configuration.instance_profile == "cx2-16x32" ? 8 : 1
    )
    storage = var.compute_configuration.boot_volume_size * 0.10
    network = 10.00  # Base networking cost
    monitoring = lookup(local.env_config, "enable_monitoring", false) ? 25.00 : 0.00
  }
  
  total_estimated_cost = sum(values(local.estimated_monthly_cost))
  
  # Validation flags
  cost_within_budget = local.total_estimated_cost <= var.cost_configuration.monthly_budget_limit
  
  # Configuration metadata
  configuration_metadata = {
    terraform_version = "~> 1.5.0"
    configuration_version = "2.0.0"
    last_updated = timestamp()
    environment = local.current_environment
    region = var.primary_region
    organization = var.organization_config.name
  }
}

# ============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# ============================================================================

resource "random_string" "unique_id" {
  count   = var.naming_convention.use_random ? 1 : 0
  length  = var.naming_convention.random_length
  special = false
  upper   = false
  numeric = true
  lower   = true
}

# ============================================================================
# SSH KEY MANAGEMENT
# ============================================================================

# Generate SSH key pair if requested
resource "tls_private_key" "ssh_key" {
  count     = var.compute_configuration.create_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
  
  lifecycle {
    create_before_destroy = true
  }
}

# Store private key locally (for lab purposes only)
resource "local_file" "private_key" {
  count           = var.compute_configuration.create_ssh_key ? 1 : 0
  content         = tls_private_key.ssh_key[0].private_key_pem
  filename        = "${path.module}/generated/${local.resource_name}-private-key.pem"
  file_permission = "0600"
  
  depends_on = [tls_private_key.ssh_key]
}

# Create IBM Cloud SSH key
resource "ibm_is_ssh_key" "ssh_key" {
  count      = var.compute_configuration.create_ssh_key ? 1 : 0
  provider   = ibm.primary
  name       = "${local.resource_name}-ssh-key"
  public_key = tls_private_key.ssh_key[0].public_key_openssh
  
  resource_group = var.resource_group_id
  tags           = local.standard_tags
  
  depends_on = [tls_private_key.ssh_key]
}

# ============================================================================
# NETWORK INFRASTRUCTURE
# ============================================================================

# Create VPC
resource "ibm_is_vpc" "main" {
  provider                    = ibm.primary
  name                       = local.vpc_name
  resource_group             = var.resource_group_id
  address_prefix_management  = var.network_configuration.address_prefix_management
  
  tags = merge(local.standard_tags, {
    "Component" = "networking"
    "Layer"     = "foundation"
    "Type"      = "vpc"
  })
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Create public gateways for each zone (if enabled)
resource "ibm_is_public_gateway" "gateway" {
  for_each = var.network_configuration.enable_public_gateway ? toset([
    for subnet in local.processed_subnets : subnet.zone
    if subnet.public_gateway_enabled
  ]) : toset([])
  
  provider = ibm.primary
  name     = "${local.resource_name}-pgw-${each.key}"
  vpc      = ibm_is_vpc.main.id
  zone     = each.key
  
  resource_group = var.resource_group_id
  tags = merge(local.standard_tags, {
    "Component" = "networking"
    "Layer"     = "foundation"
    "Type"      = "public-gateway"
    "Zone"      = each.key
  })
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Create subnets
resource "ibm_is_subnet" "subnets" {
  count = length(local.processed_subnets)
  
  provider = ibm.primary
  name     = local.processed_subnets[count.index].name
  vpc      = ibm_is_vpc.main.id
  zone     = local.processed_subnets[count.index].zone
  
  ipv4_cidr_block = local.processed_subnets[count.index].cidr_block
  
  # Attach public gateway if enabled for this subnet
  public_gateway = local.processed_subnets[count.index].public_gateway_enabled ? ibm_is_public_gateway.gateway[local.processed_subnets[count.index].zone].id : null
  
  resource_group = var.resource_group_id
  tags = merge(local.standard_tags, {
    "Component" = "networking"
    "Layer"     = "foundation"
    "Type"      = "subnet"
    "Zone"      = local.processed_subnets[count.index].zone
    "CIDR"      = local.processed_subnets[count.index].cidr_block
  })
  
  depends_on = [ibm_is_public_gateway.gateway]
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Create security groups
resource "ibm_is_security_group" "security_groups" {
  count = length(local.processed_security_groups)
  
  provider = ibm.primary
  name     = local.processed_security_groups[count.index].name
  vpc      = ibm_is_vpc.main.id
  
  resource_group = var.resource_group_id
  tags = merge(local.standard_tags, {
    "Component" = "security"
    "Layer"     = "foundation"
    "Type"      = "security-group"
  })
}

# Create security group rules
resource "ibm_is_security_group_rule" "security_group_rules" {
  count = sum([
    for sg in local.processed_security_groups : length(sg.rules)
  ])
  
  provider = ibm.primary
  group    = ibm_is_security_group.security_groups[
    floor(count.index / length(local.processed_security_groups[0].rules))
  ].id
  
  direction = local.processed_security_groups[
    floor(count.index / length(local.processed_security_groups[0].rules))
  ].rules[count.index % length(local.processed_security_groups[0].rules)].direction
  
  dynamic "tcp" {
    for_each = local.processed_security_groups[
      floor(count.index / length(local.processed_security_groups[0].rules))
    ].rules[count.index % length(local.processed_security_groups[0].rules)].protocol == "tcp" ? [1] : []
    
    content {
      port_min = local.processed_security_groups[
        floor(count.index / length(local.processed_security_groups[0].rules))
      ].rules[count.index % length(local.processed_security_groups[0].rules)].port_min
      
      port_max = local.processed_security_groups[
        floor(count.index / length(local.processed_security_groups[0].rules))
      ].rules[count.index % length(local.processed_security_groups[0].rules)].port_max
    }
  }
  
  dynamic "udp" {
    for_each = local.processed_security_groups[
      floor(count.index / length(local.processed_security_groups[0].rules))
    ].rules[count.index % length(local.processed_security_groups[0].rules)].protocol == "udp" ? [1] : []
    
    content {
      port_min = local.processed_security_groups[
        floor(count.index / length(local.processed_security_groups[0].rules))
      ].rules[count.index % length(local.processed_security_groups[0].rules)].port_min
      
      port_max = local.processed_security_groups[
        floor(count.index / length(local.processed_security_groups[0].rules))
      ].rules[count.index % length(local.processed_security_groups[0].rules)].port_max
    }
  }
  
  dynamic "icmp" {
    for_each = local.processed_security_groups[
      floor(count.index / length(local.processed_security_groups[0].rules))
    ].rules[count.index % length(local.processed_security_groups[0].rules)].protocol == "icmp" ? [1] : []
    
    content {
      type = 8
      code = 0
    }
  }
}

# ============================================================================
# VALIDATION CHECKS
# ============================================================================

# Configuration validation
check "cost_budget_validation" {
  assert {
    condition = local.cost_within_budget
    error_message = "Estimated monthly cost ($${local.total_estimated_cost}) exceeds budget limit ($${var.cost_configuration.monthly_budget_limit})"
  }
}

check "naming_convention_validation" {
  assert {
    condition = length(local.resource_name) <= var.naming_convention.max_length
    error_message = "Generated resource name '${local.resource_name}' exceeds maximum length of ${var.naming_convention.max_length}"
  }
}

check "subnet_count_validation" {
  assert {
    condition = length(local.processed_subnets) <= 15
    error_message = "Number of subnets (${length(local.processed_subnets)}) exceeds IBM Cloud VPC limit of 15"
  }
}

# ============================================================================
# TIME-BASED RESOURCES
# ============================================================================

# Track deployment time
resource "time_static" "deployment_time" {
  triggers = {
    configuration_hash = sha256(jsonencode({
      organization = var.organization_config
      network = var.network_configuration
      compute = var.compute_configuration
    }))
  }
}
