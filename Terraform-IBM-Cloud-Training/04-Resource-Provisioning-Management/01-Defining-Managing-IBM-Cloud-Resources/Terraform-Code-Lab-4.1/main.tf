# =============================================================================
# MAIN TERRAFORM CONFIGURATION
# Topic 4.1: Defining and Managing IBM Cloud Resources
# Complete 3-Tier Web Application Infrastructure
# =============================================================================

# Generate unique suffix for resource naming
resource "random_string" "unique_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Timestamp for resource tracking and lifecycle management
resource "time_static" "deployment_time" {}

# =============================================================================
# DATA SOURCES FOR VALIDATION AND REFERENCE
# =============================================================================

# Resource group data source
data "ibm_resource_group" "project_rg" {
  name = var.resource_group_name
}

# Available zones in the primary region
data "ibm_is_zones" "regional_zones" {
  region = var.ibm_region
}

# SSH key data source (if specified)
data "ibm_is_ssh_key" "project_key" {
  count = var.ssh_key_name != "" ? 1 : 0
  name  = var.ssh_key_name
}

# OS image data sources for different instance types
data "ibm_is_image" "ubuntu_image" {
  name = "ibm-ubuntu-20-04-3-minimal-amd64-2"
}

data "ibm_is_image" "centos_image" {
  name = "ibm-centos-8-3-minimal-amd64-2"
}

# =============================================================================
# LOCAL VALUES AND COMPUTED CONFIGURATIONS
# =============================================================================

locals {
  # Generate consistent naming convention
  name_prefix = "${var.project_name}-${var.environment}-${random_string.unique_suffix.result}"
  
  # Common tags for all resources
  common_tags = merge(var.resource_tags, {
    environment     = var.environment
    region         = var.ibm_region
    owner          = var.owner
    cost-center    = var.cost_center
    created-date   = formatdate("YYYY-MM-DD", time_static.deployment_time.rfc3339)
    created-time   = formatdate("hh:mm:ss", time_static.deployment_time.rfc3339)
    terraform-managed = "true"
  })
  
  # Available zones (use first 3 for multi-zone deployment)
  availability_zones = slice(data.ibm_is_zones.regional_zones.zones, 0, min(3, length(data.ibm_is_zones.regional_zones.zones)))
  
  # Subnet configurations with zone mapping
  subnet_configs = {
    for name, config in var.subnet_configurations : name => merge(config, {
      zone = "${var.ibm_region}-${config.zone_offset}"
      full_name = "${local.name_prefix}-${name}-subnet"
    })
  }
  
  # Instance configurations with enhanced metadata
  instance_configs = {
    for name, config in var.instance_configurations : name => merge(config, {
      full_name_prefix = "${local.name_prefix}-${name}"
      subnet_key = "${config.tier}-tier-1"  # Default to zone 1
    })
  }
  
  # Storage configurations with enhanced metadata
  storage_configs = {
    for name, config in var.storage_configurations : name => merge(config, {
      full_name_prefix = "${local.name_prefix}-${name}"
    })
  }
}

# =============================================================================
# VPC FOUNDATION INFRASTRUCTURE
# =============================================================================

# Virtual Private Cloud with comprehensive configuration
resource "ibm_is_vpc" "main_vpc" {
  name                        = "${local.name_prefix}-vpc"
  resource_group              = data.ibm_resource_group.project_rg.id
  address_prefix_management   = "manual"
  default_network_acl_name    = "${local.name_prefix}-default-acl"
  default_routing_table_name  = "${local.name_prefix}-default-rt"
  default_security_group_name = "${local.name_prefix}-default-sg"
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:vpc",
      "tier:foundation",
      "criticality:high"
    ]
  )
}

# VPC address prefixes for manual address management
resource "ibm_is_vpc_address_prefix" "main_prefix" {
  name = "${local.name_prefix}-main-prefix"
  vpc  = ibm_is_vpc.main_vpc.id
  zone = local.availability_zones[0]
  cidr = var.vpc_address_prefix
}

# Additional address prefixes for multi-zone deployment
resource "ibm_is_vpc_address_prefix" "secondary_prefixes" {
  count = length(local.availability_zones) - 1
  
  name = "${local.name_prefix}-prefix-${count.index + 2}"
  vpc  = ibm_is_vpc.main_vpc.id
  zone = local.availability_zones[count.index + 1]
  cidr = cidrsubnet(var.vpc_address_prefix, 8, count.index + 1)
}

# =============================================================================
# SUBNET INFRASTRUCTURE
# =============================================================================

# Subnets for multi-tier architecture
resource "ibm_is_subnet" "tier_subnets" {
  for_each = local.subnet_configs
  
  name            = each.value.full_name
  vpc             = ibm_is_vpc.main_vpc.id
  zone            = each.value.zone
  ipv4_cidr_block = each.value.cidr_block
  resource_group  = data.ibm_resource_group.project_rg.id
  
  # Attach public gateway for public subnets
  public_gateway = each.value.public_access ? ibm_is_public_gateway.zone_gateways[each.value.zone].id : null
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:subnet",
      "tier:${each.value.tier}",
      "access:${each.value.public_access ? "public" : "private"}",
      "zone:${each.value.zone}",
      "description:${each.value.description}"
    ]
  )
  
  depends_on = [
    ibm_is_vpc_address_prefix.main_prefix,
    ibm_is_vpc_address_prefix.secondary_prefixes
  ]
}

# =============================================================================
# PUBLIC GATEWAYS FOR INTERNET ACCESS
# =============================================================================

# Public gateways for each zone with public subnets
resource "ibm_is_public_gateway" "zone_gateways" {
  for_each = toset([
    for name, config in local.subnet_configs : config.zone if config.public_access
  ])
  
  name           = "${local.name_prefix}-${each.key}-gateway"
  vpc            = ibm_is_vpc.main_vpc.id
  zone           = each.key
  resource_group = data.ibm_resource_group.project_rg.id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:public-gateway",
      "zone:${each.key}",
      "purpose:internet-access"
    ]
  )
}

# =============================================================================
# SECURITY GROUPS AND NETWORK SECURITY
# =============================================================================

# Web tier security group
resource "ibm_is_security_group" "web_tier_sg" {
  name           = "${local.name_prefix}-web-sg"
  vpc            = ibm_is_vpc.main_vpc.id
  resource_group = data.ibm_resource_group.project_rg.id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:security-group",
      "tier:web",
      "access-level:public"
    ]
  )
}

# Web tier security rules
resource "ibm_is_security_group_rule" "web_http_inbound" {
  group     = ibm_is_security_group.web_tier_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "web_https_inbound" {
  group     = ibm_is_security_group.web_tier_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "web_ssh_inbound" {
  count     = length(var.security_configurations.allowed_ssh_cidr_blocks)
  group     = ibm_is_security_group.web_tier_sg.id
  direction = "inbound"
  remote    = var.security_configurations.allowed_ssh_cidr_blocks[count.index]
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Application tier security group
resource "ibm_is_security_group" "app_tier_sg" {
  name           = "${local.name_prefix}-app-sg"
  vpc            = ibm_is_vpc.main_vpc.id
  resource_group = data.ibm_resource_group.project_rg.id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:security-group",
      "tier:application",
      "access-level:private"
    ]
  )
}

# Application tier security rules
resource "ibm_is_security_group_rule" "app_from_web" {
  group     = ibm_is_security_group.app_tier_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.web_tier_sg.id
  
  tcp {
    port_min = 8080
    port_max = 8080
  }
}

resource "ibm_is_security_group_rule" "app_ssh_from_web" {
  group     = ibm_is_security_group.app_tier_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.web_tier_sg.id
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Database tier security group
resource "ibm_is_security_group" "db_tier_sg" {
  name           = "${local.name_prefix}-db-sg"
  vpc            = ibm_is_vpc.main_vpc.id
  resource_group = data.ibm_resource_group.project_rg.id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:security-group",
      "tier:database",
      "access-level:private"
    ]
  )
}

# Database tier instances
resource "ibm_is_instance" "db_servers" {
  count   = var.instance_configurations["db-servers"].count
  name    = "${local.instance_configs["db-servers"].full_name_prefix}-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu_image.id
  profile = var.instance_configurations["db-servers"].profile

  primary_network_interface {
    subnet = ibm_is_subnet.tier_subnets["data-tier-${((count.index % 2) + 1)}"].id
    security_groups = [ibm_is_security_group.db_tier_sg.id]
  }

  vpc  = ibm_is_vpc.main_vpc.id
  zone = ibm_is_subnet.tier_subnets["data-tier-${((count.index % 2) + 1)}"].zone
  keys = var.ssh_key_name != "" ? [data.ibm_is_ssh_key.project_key[0].id] : []

  resource_group = data.ibm_resource_group.project_rg.id

  # Boot volume configuration
  boot_volume {
    name    = "${local.instance_configs["db-servers"].full_name_prefix}-boot-${count.index + 1}"
    size    = var.instance_configurations["db-servers"].boot_volume_size
    profile = "general-purpose"
  }

  # User data for database server initialization
  user_data = base64encode(templatefile("${path.module}/scripts/${var.instance_configurations["db-servers"].user_data_template}", {
    server_index = count.index + 1
    environment  = var.environment
    tier         = "database"
  }))

  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:instance",
      "tier:database",
      "role:data-storage",
      "server-index:${count.index + 1}",
      "monitoring:${var.instance_configurations["db-servers"].enable_monitoring ? "enabled" : "disabled"}"
    ]
  )
}

# =============================================================================
# STORAGE VOLUMES AND ATTACHMENTS
# =============================================================================

# Application data volumes
resource "ibm_is_volume" "app_data_volumes" {
  count          = var.instance_configurations["app-servers"].count
  name           = "${local.storage_configs["app-data"].full_name_prefix}-${count.index + 1}"
  profile        = var.storage_configurations["app-data"].profile
  zone           = ibm_is_instance.app_servers[count.index].zone
  capacity       = var.storage_configurations["app-data"].volume_size_gb
  resource_group = data.ibm_resource_group.project_rg.id

  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:volume",
      "tier:application",
      "purpose:data-storage",
      "server-index:${count.index + 1}",
      "encrypted:${var.storage_configurations["app-data"].encrypted ? "true" : "false"}",
      "backup:${var.storage_configurations["app-data"].backup_enabled ? "enabled" : "disabled"}"
    ]
  )
}

# Database data volumes
resource "ibm_is_volume" "db_data_volumes" {
  count          = var.instance_configurations["db-servers"].count
  name           = "${local.storage_configs["db-data"].full_name_prefix}-${count.index + 1}"
  profile        = var.storage_configurations["db-data"].profile
  zone           = ibm_is_instance.db_servers[count.index].zone
  capacity       = var.storage_configurations["db-data"].volume_size_gb
  resource_group = data.ibm_resource_group.project_rg.id

  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:volume",
      "tier:database",
      "purpose:database-storage",
      "server-index:${count.index + 1}",
      "encrypted:${var.storage_configurations["db-data"].encrypted ? "true" : "false"}",
      "backup:${var.storage_configurations["db-data"].backup_enabled ? "enabled" : "disabled"}"
    ]
  )
}

# Shared storage volume for common resources
resource "ibm_is_volume" "shared_storage" {
  name           = "${local.storage_configs["shared-storage"].full_name_prefix}"
  profile        = var.storage_configurations["shared-storage"].profile
  zone           = local.availability_zones[0]
  capacity       = var.storage_configurations["shared-storage"].volume_size_gb
  resource_group = data.ibm_resource_group.project_rg.id

  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:volume",
      "tier:shared",
      "purpose:shared-storage",
      "encrypted:${var.storage_configurations["shared-storage"].encrypted ? "true" : "false"}",
      "backup:${var.storage_configurations["shared-storage"].backup_enabled ? "enabled" : "disabled"}"
    ]
  )
}

# Attach application data volumes to instances
resource "ibm_is_instance_volume_attachment" "app_data_attachments" {
  count                           = var.instance_configurations["app-servers"].count
  instance                        = ibm_is_instance.app_servers[count.index].id
  name                           = "app-data-attachment-${count.index + 1}"
  volume                         = ibm_is_volume.app_data_volumes[count.index].id
  delete_volume_on_instance_delete = false
}

# Attach database data volumes to instances
resource "ibm_is_instance_volume_attachment" "db_data_attachments" {
  count                           = var.instance_configurations["db-servers"].count
  instance                        = ibm_is_instance.db_servers[count.index].id
  name                           = "db-data-attachment-${count.index + 1}"
  volume                         = ibm_is_volume.db_data_volumes[count.index].id
  delete_volume_on_instance_delete = false
}

# =============================================================================
# LOAD BALANCER CONFIGURATION
# =============================================================================

# Application Load Balancer for web tier
resource "ibm_is_lb" "web_load_balancer" {
  name           = "${local.name_prefix}-web-lb"
  subnets        = [for subnet in ibm_is_subnet.tier_subnets : subnet.id if can(regex("web-tier", subnet.name))]
  type           = var.load_balancer_configuration.type
  resource_group = data.ibm_resource_group.project_rg.id

  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:load-balancer",
      "tier:web",
      "access:${var.load_balancer_configuration.type}",
      "algorithm:${var.load_balancer_configuration.algorithm}"
    ]
  )
}

# Backend pool for web servers
resource "ibm_is_lb_pool" "web_backend_pool" {
  name           = "${local.name_prefix}-web-pool"
  lb             = ibm_is_lb.web_load_balancer.id
  algorithm      = var.load_balancer_configuration.algorithm
  protocol       = "http"
  health_delay   = var.load_balancer_configuration.health_check_interval
  health_retries = 5
  health_timeout = 30
  health_type    = "http"
  health_monitor_url = var.load_balancer_configuration.health_check_url

  session_persistence_type = var.load_balancer_configuration.session_persistence ? "source_ip" : null
}

# Pool members (web server instances)
resource "ibm_is_lb_pool_member" "web_pool_members" {
  count          = var.instance_configurations["web-servers"].count
  lb             = ibm_is_lb.web_load_balancer.id
  pool           = ibm_is_lb_pool.web_backend_pool.id
  port           = 80
  target_address = ibm_is_instance.web_servers[count.index].primary_network_interface[0].primary_ipv4_address
  weight         = 50
}

# Load balancer listener for HTTP traffic
resource "ibm_is_lb_listener" "web_http_listener" {
  lb                   = ibm_is_lb.web_load_balancer.id
  port                 = 80
  protocol             = "http"
  default_pool         = ibm_is_lb_pool.web_backend_pool.id
  connection_limit     = 2000
  accept_proxy_protocol = false
}

# Load balancer listener for HTTPS traffic (if SSL certificate provided)
resource "ibm_is_lb_listener" "web_https_listener" {
  count = var.load_balancer_configuration.ssl_certificate_crn != "" ? 1 : 0

  lb                   = ibm_is_lb.web_load_balancer.id
  port                 = 443
  protocol             = "https"
  default_pool         = ibm_is_lb_pool.web_backend_pool.id
  connection_limit     = 2000
  accept_proxy_protocol = false
  certificate_instance = var.load_balancer_configuration.ssl_certificate_crn
}

# Database tier security rules
resource "ibm_is_security_group_rule" "db_from_app" {
  group     = ibm_is_security_group.db_tier_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.app_tier_sg.id
  
  tcp {
    port_min = 5432
    port_max = 5432
  }
}

resource "ibm_is_security_group_rule" "db_ssh_from_app" {
  group     = ibm_is_security_group.db_tier_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.app_tier_sg.id
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# =============================================================================
# COMPUTE INSTANCES
# =============================================================================

# Web tier instances
resource "ibm_is_instance" "web_servers" {
  count   = var.instance_configurations["web-servers"].count
  name    = "${local.instance_configs["web-servers"].full_name_prefix}-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu_image.id
  profile = var.instance_configurations["web-servers"].profile
  
  primary_network_interface {
    subnet = ibm_is_subnet.tier_subnets["web-tier-${((count.index % 2) + 1)}"].id
    security_groups = [ibm_is_security_group.web_tier_sg.id]
  }
  
  vpc  = ibm_is_vpc.main_vpc.id
  zone = ibm_is_subnet.tier_subnets["web-tier-${((count.index % 2) + 1)}"].zone
  keys = var.ssh_key_name != "" ? [data.ibm_is_ssh_key.project_key[0].id] : []
  
  resource_group = data.ibm_resource_group.project_rg.id
  
  # Boot volume configuration
  boot_volume {
    name    = "${local.instance_configs["web-servers"].full_name_prefix}-boot-${count.index + 1}"
    size    = var.instance_configurations["web-servers"].boot_volume_size
    profile = "general-purpose"
  }
  
  # User data for web server initialization
  user_data = base64encode(templatefile("${path.module}/scripts/${var.instance_configurations["web-servers"].user_data_template}", {
    server_index = count.index + 1
    environment  = var.environment
    tier         = "web"
  }))
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:instance",
      "tier:web",
      "role:frontend",
      "server-index:${count.index + 1}",
      "monitoring:${var.instance_configurations["web-servers"].enable_monitoring ? "enabled" : "disabled"}"
    ]
  )
}

# Application tier instances
resource "ibm_is_instance" "app_servers" {
  count   = var.instance_configurations["app-servers"].count
  name    = "${local.instance_configs["app-servers"].full_name_prefix}-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu_image.id
  profile = var.instance_configurations["app-servers"].profile
  
  primary_network_interface {
    subnet = ibm_is_subnet.tier_subnets["app-tier-${((count.index % 2) + 1)}"].id
    security_groups = [ibm_is_security_group.app_tier_sg.id]
  }
  
  vpc  = ibm_is_vpc.main_vpc.id
  zone = ibm_is_subnet.tier_subnets["app-tier-${((count.index % 2) + 1)}"].zone
  keys = var.ssh_key_name != "" ? [data.ibm_is_ssh_key.project_key[0].id] : []
  
  resource_group = data.ibm_resource_group.project_rg.id
  
  # Boot volume configuration
  boot_volume {
    name    = "${local.instance_configs["app-servers"].full_name_prefix}-boot-${count.index + 1}"
    size    = var.instance_configurations["app-servers"].boot_volume_size
    profile = "general-purpose"
  }
  
  # User data for application server initialization
  user_data = base64encode(templatefile("${path.module}/scripts/${var.instance_configurations["app-servers"].user_data_template}", {
    server_index = count.index + 1
    environment  = var.environment
    tier         = "application"
  }))
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:instance",
      "tier:application",
      "role:backend",
      "server-index:${count.index + 1}",
      "monitoring:${var.instance_configurations["app-servers"].enable_monitoring ? "enabled" : "disabled"}"
    ]
  )
}
