# =============================================================================
# MAIN TERRAFORM CONFIGURATION
# =============================================================================
# Terraform Code Lab 5.1: Creating Reusable Modules
# This configuration demonstrates enterprise-grade module creation patterns
# with comprehensive IBM Cloud service integration.

# =============================================================================
# DATA SOURCES AND LOOKUPS
# =============================================================================

# Resource group lookup
data "ibm_resource_group" "main" {
  name = var.resource_group_name
}

# SSH key lookup for compute instances
data "ibm_is_ssh_key" "lab_key" {
  count = var.compute_configuration.ssh_key_name != null ? 1 : 0
  name  = var.compute_configuration.ssh_key_name
}

# Image lookup for compute instances
data "ibm_is_image" "base_image" {
  name = var.compute_configuration.base_image_name
}

# Account information for enterprise features
data "ibm_iam_account_settings" "account_settings" {
  count = var.enable_enterprise_features ? 1 : 0
}

# =============================================================================
# LOCAL VALUES AND COMPUTATIONS
# =============================================================================

locals {
  # Naming convention implementation
  name_prefix = "${var.module_config.name_prefix}-${var.organization_config.environment}"
  
  # Comprehensive tagging strategy
  base_tags = [
    "terraform:managed",
    "module:vpc-lab",
    "version:${var.module_config.version}",
    "environment:${var.organization_config.environment}",
    "cost-center:${var.organization_config.cost_center}",
    "project:${var.organization_config.project}",
    "owner:${var.organization_config.owner}",
    "region:${var.primary_region}"
  ]
  
  # Merge all tags
  all_tags = concat(
    local.base_tags,
    var.global_tags,
    [for k, v in var.custom_tags : "${k}:${v}"]
  )
  
  # VPC configuration with defaults
  vpc_config = {
    name                        = "${local.name_prefix}-${var.vpc_configuration.name}"
    address_prefix_management   = var.vpc_configuration.address_prefix_management
    classic_access             = var.vpc_configuration.classic_access
    default_network_acl_name    = coalesce(var.vpc_configuration.default_network_acl_name, "${local.name_prefix}-${var.vpc_configuration.name}-default-acl")
    default_routing_table_name  = coalesce(var.vpc_configuration.default_routing_table_name, "${local.name_prefix}-${var.vpc_configuration.name}-default-rt")
    default_security_group_name = coalesce(var.vpc_configuration.default_security_group_name, "${local.name_prefix}-${var.vpc_configuration.name}-default-sg")
  }
  
  # Subnet configuration with zone mapping
  subnet_configs = [
    for subnet in var.vpc_configuration.subnets : {
      name                    = "${local.name_prefix}-${subnet.name}"
      zone                    = subnet.zone
      cidr_block             = subnet.cidr_block
      public_gateway_enabled = subnet.public_gateway_enabled || var.vpc_configuration.enable_public_gateway
      resource_group_id      = coalesce(subnet.resource_group_id, data.ibm_resource_group.main.id)
    }
  ]
  
  # Security group configuration
  security_group_configs = [
    for sg in var.vpc_configuration.security_groups : {
      name        = "${local.name_prefix}-${sg.name}"
      description = sg.description
      rules       = sg.rules
    }
  ]
  
  # Cost tracking and optimization
  cost_allocation = {
    organization = var.organization_config.name
    division     = var.organization_config.division
    cost_center  = var.organization_config.cost_center
    environment  = var.organization_config.environment
    project      = var.organization_config.project
    owner        = var.organization_config.owner
  }
  
  # Module metadata
  module_metadata = {
    name           = "vpc-compute-lab"
    version        = var.module_config.version
    created_at     = timestamp()
    terraform_version = "~> 1.5.0"
    provider_version  = "~> 1.58.0"
    lab_topic      = "5.1"
    lab_name       = "Creating Reusable Modules"
  }
}

# =============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# =============================================================================

# Random suffix for unique resource naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Random password for potential use in compute instances
resource "random_password" "admin_password" {
  count   = var.compute_configuration.instance_count > 0 ? 1 : 0
  length  = 16
  special = true
}

# =============================================================================
# VPC MODULE IMPLEMENTATION
# =============================================================================

# Primary VPC resource
resource "ibm_is_vpc" "main" {
  name                        = local.vpc_config.name
  resource_group              = data.ibm_resource_group.main.id
  address_prefix_management   = local.vpc_config.address_prefix_management
  classic_access              = local.vpc_config.classic_access
  default_network_acl_name    = local.vpc_config.default_network_acl_name
  default_routing_table_name  = local.vpc_config.default_routing_table_name
  default_security_group_name = local.vpc_config.default_security_group_name
  
  tags = local.all_tags
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Public gateways for internet access
resource "ibm_is_public_gateway" "main" {
  count = var.vpc_configuration.enable_public_gateway ? length(data.ibm_is_zones.primary_region_validation.zones) : 0
  
  name           = "${local.name_prefix}-gateway-${count.index + 1}"
  vpc            = ibm_is_vpc.main.id
  zone           = data.ibm_is_zones.primary_region_validation.zones[count.index]
  resource_group = data.ibm_resource_group.main.id
  
  tags = concat(local.all_tags, [
    "component:public-gateway",
    "zone:${data.ibm_is_zones.primary_region_validation.zones[count.index]}"
  ])
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# VPC subnets with advanced configuration
resource "ibm_is_subnet" "main" {
  count = length(local.subnet_configs)
  
  name                     = local.subnet_configs[count.index].name
  vpc                      = ibm_is_vpc.main.id
  zone                     = local.subnet_configs[count.index].zone
  ipv4_cidr_block         = local.subnet_configs[count.index].cidr_block
  resource_group          = local.subnet_configs[count.index].resource_group_id
  
  # Conditional public gateway assignment
  public_gateway = local.subnet_configs[count.index].public_gateway_enabled ? (
    length(ibm_is_public_gateway.main) > 0 ? 
    ibm_is_public_gateway.main[index(data.ibm_is_zones.primary_region_validation.zones, local.subnet_configs[count.index].zone)].id : 
    null
  ) : null
  
  tags = concat(local.all_tags, [
    "component:subnet",
    "zone:${local.subnet_configs[count.index].zone}",
    "cidr:${local.subnet_configs[count.index].cidr_block}"
  ])
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Custom security groups
resource "ibm_is_security_group" "custom" {
  count = length(local.security_group_configs)
  
  name           = local.security_group_configs[count.index].name
  vpc            = ibm_is_vpc.main.id
  resource_group = data.ibm_resource_group.main.id
  
  tags = concat(local.all_tags, [
    "component:security-group",
    "custom:true"
  ])
}

# Security group rules for custom security groups
resource "ibm_is_security_group_rule" "custom_rules" {
  count = sum([
    for sg in local.security_group_configs : length(sg.rules)
  ])
  
  # Calculate which security group and rule this belongs to
  group     = ibm_is_security_group.custom[floor(count.index / length(local.security_group_configs[0].rules))].id
  direction = local.security_group_configs[floor(count.index / length(local.security_group_configs[0].rules))].rules[count.index % length(local.security_group_configs[0].rules)].direction
  
  dynamic "remote" {
    for_each = local.security_group_configs[floor(count.index / length(local.security_group_configs[0].rules))].rules[count.index % length(local.security_group_configs[0].rules)].source_type == "cidr_block" ? [1] : []
    content {
      cidr_block = local.security_group_configs[floor(count.index / length(local.security_group_configs[0].rules))].rules[count.index % length(local.security_group_configs[0].rules)].source
    }
  }
  
  dynamic "tcp" {
    for_each = local.security_group_configs[floor(count.index / length(local.security_group_configs[0].rules))].rules[count.index % length(local.security_group_configs[0].rules)].protocol == "tcp" ? [1] : []
    content {
      port_min = local.security_group_configs[floor(count.index / length(local.security_group_configs[0].rules))].rules[count.index % length(local.security_group_configs[0].rules)].port_min
      port_max = local.security_group_configs[floor(count.index / length(local.security_group_configs[0].rules))].rules[count.index % length(local.security_group_configs[0].rules)].port_max
    }
  }
  
  dynamic "udp" {
    for_each = local.security_group_configs[floor(count.index / length(local.security_group_configs[0].rules))].rules[count.index % length(local.security_group_configs[0].rules)].protocol == "udp" ? [1] : []
    content {
      port_min = local.security_group_configs[floor(count.index / length(local.security_group_configs[0].rules))].rules[count.index % length(local.security_group_configs[0].rules)].port_min
      port_max = local.security_group_configs[floor(count.index / length(local.security_group_configs[0].rules))].rules[count.index % length(local.security_group_configs[0].rules)].port_max
    }
  }
  
  dynamic "icmp" {
    for_each = local.security_group_configs[floor(count.index / length(local.security_group_configs[0].rules))].rules[count.index % length(local.security_group_configs[0].rules)].protocol == "icmp" ? [1] : []
    content {
      type = 8
      code = 0
    }
  }
}

# =============================================================================
# COMPUTE MODULE IMPLEMENTATION
# =============================================================================

# SSH key creation for lab purposes
resource "tls_private_key" "lab_ssh_key" {
  count     = var.compute_configuration.ssh_key_name == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "lab_ssh_key" {
  count      = var.compute_configuration.ssh_key_name == null ? 1 : 0
  name       = "${local.name_prefix}-ssh-key"
  public_key = tls_private_key.lab_ssh_key[0].public_key_openssh
  
  tags = concat(local.all_tags, [
    "component:ssh-key",
    "generated:true"
  ])
}

# Security group for compute instances
resource "ibm_is_security_group" "compute" {
  count = var.compute_configuration.instance_count > 0 ? 1 : 0
  
  name           = "${local.name_prefix}-compute-sg"
  vpc            = ibm_is_vpc.main.id
  resource_group = data.ibm_resource_group.main.id
  
  tags = concat(local.all_tags, [
    "component:security-group",
    "purpose:compute"
  ])
}

# Security group rules for compute instances
resource "ibm_is_security_group_rule" "compute_ssh" {
  count = var.compute_configuration.instance_count > 0 ? 1 : 0
  
  group     = ibm_is_security_group.compute[0].id
  direction = "inbound"
  
  remote {
    cidr_block = "0.0.0.0/0"
  }
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "compute_http" {
  count = var.compute_configuration.instance_count > 0 ? 1 : 0
  
  group     = ibm_is_security_group.compute[0].id
  direction = "inbound"
  
  remote {
    cidr_block = "0.0.0.0/0"
  }
  
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "compute_https" {
  count = var.compute_configuration.instance_count > 0 ? 1 : 0
  
  group     = ibm_is_security_group.compute[0].id
  direction = "inbound"
  
  remote {
    cidr_block = "0.0.0.0/0"
  }
  
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "compute_outbound" {
  count = var.compute_configuration.instance_count > 0 ? 1 : 0
  
  group     = ibm_is_security_group.compute[0].id
  direction = "outbound"
  
  remote {
    cidr_block = "0.0.0.0/0"
  }
}

# Virtual server instances
resource "ibm_is_instance" "compute" {
  count = var.compute_configuration.instance_count
  
  name           = "${local.name_prefix}-instance-${count.index + 1}"
  image          = data.ibm_is_image.base_image.id
  profile        = var.compute_configuration.instance_profile
  vpc            = ibm_is_vpc.main.id
  zone           = ibm_is_subnet.main[count.index % length(ibm_is_subnet.main)].zone
  resource_group = data.ibm_resource_group.main.id
  
  # SSH keys
  keys = var.compute_configuration.ssh_key_name != null ? [
    data.ibm_is_ssh_key.lab_key[0].id
  ] : [
    ibm_is_ssh_key.lab_ssh_key[0].id
  ]
  
  # Primary network interface
  primary_network_interface {
    subnet = ibm_is_subnet.main[count.index % length(ibm_is_subnet.main)].id
    security_groups = var.compute_configuration.instance_count > 0 ? [
      ibm_is_security_group.compute[0].id
    ] : []
  }
  
  # Boot volume configuration
  boot_volume {
    name       = "${local.name_prefix}-boot-${count.index + 1}"
    size       = var.compute_configuration.boot_volume.size
    profile    = var.compute_configuration.boot_volume.profile
    encryption = var.compute_configuration.boot_volume.encryption
  }
  
  # User data for instance initialization
  user_data = base64encode(templatefile("${path.module}/templates/user-data.sh", {
    hostname     = "${local.name_prefix}-instance-${count.index + 1}"
    environment  = var.organization_config.environment
    project      = var.organization_config.project
    instance_id  = count.index + 1
  }))
  
  tags = concat(local.all_tags, [
    "component:compute",
    "instance:${count.index + 1}",
    "zone:${ibm_is_subnet.main[count.index % length(ibm_is_subnet.main)].zone}"
  ])
  
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

# =============================================================================
# ENTERPRISE FEATURES
# =============================================================================

# Activity Tracker integration (if enabled)
resource "ibm_resource_instance" "activity_tracker" {
  count = var.enable_monitoring_services && var.organization_config.environment == "production" ? 1 : 0
  
  name              = "${local.name_prefix}-activity-tracker"
  service           = "logdnaat"
  plan              = "lite"
  location          = var.primary_region
  resource_group_id = data.ibm_resource_group.main.id
  
  tags = concat(local.all_tags, [
    "service:activity-tracker",
    "monitoring:enabled"
  ])
}

# Flow logs for network monitoring (if enabled)
resource "ibm_is_flow_log" "vpc_flow_logs" {
  count = var.enable_monitoring_services && var.monitoring_configuration.logging.enable_structured_logs ? 1 : 0
  
  name           = "${local.name_prefix}-flow-logs"
  target         = ibm_is_vpc.main.id
  active         = true
  storage_bucket = "${local.name_prefix}-flow-logs-bucket"
  resource_group = data.ibm_resource_group.main.id
  
  tags = concat(local.all_tags, [
    "component:flow-logs",
    "monitoring:network"
  ])
}

# =============================================================================
# TIME STAMPS AND TRACKING
# =============================================================================

# Resource creation timestamp
resource "time_static" "creation_time" {}

# Rotation schedule for sensitive resources
resource "time_rotating" "rotation_schedule" {
  rotation_days = 90
}

# =============================================================================
# LOCAL FILE OUTPUTS FOR DEVELOPMENT
# =============================================================================

# SSH private key output (for development only)
resource "local_file" "ssh_private_key" {
  count = var.compute_configuration.ssh_key_name == null && var.module_config.development.enable_debug_mode ? 1 : 0
  
  content  = tls_private_key.lab_ssh_key[0].private_key_pem
  filename = "${path.module}/generated/ssh-private-key.pem"
  
  file_permission = "0600"
}

# Module configuration output
resource "local_file" "module_config" {
  count = var.module_config.development.enable_debug_mode ? 1 : 0
  
  content = jsonencode({
    module_metadata = local.module_metadata
    vpc_config      = local.vpc_config
    cost_allocation = local.cost_allocation
    creation_time   = time_static.creation_time.rfc3339
  })
  
  filename = "${path.module}/generated/module-config.json"
}
