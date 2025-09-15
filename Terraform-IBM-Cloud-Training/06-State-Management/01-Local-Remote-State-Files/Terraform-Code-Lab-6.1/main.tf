# =============================================================================
# MAIN INFRASTRUCTURE CONFIGURATION
# Subtopic 6.1: Local and Remote State Files
# Demonstrates state management patterns with IBM Cloud infrastructure
# =============================================================================

# =============================================================================
# DATA SOURCES
# =============================================================================

# Fetch existing resource group
data "ibm_resource_group" "main" {
  name = var.resource_group_name
}

# Fetch available zones in the region
data "ibm_is_zones" "regional_zones" {
  region = var.primary_region
}

# Fetch available VSI profiles
data "ibm_is_instance_profiles" "available_profiles" {}

# Fetch VSI image
data "ibm_is_image" "ubuntu" {
  name = var.vsi_image_name
}

# Fetch SSH key if specified
data "ibm_is_ssh_key" "existing_key" {
  count = var.ssh_key_name != "" ? 1 : 0
  name  = var.ssh_key_name
}

# =============================================================================
# LOCAL VALUES AND COMPUTED CONFIGURATIONS
# =============================================================================

locals {
  # Resource naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Availability zone selection
  availability_zone = data.ibm_is_zones.regional_zones.zones[0]
  
  # Common tags for all resources
  common_tags = [
    "project:${var.project_name}",
    "environment:${var.environment}",
    "terraform:managed",
    "lab:state-management",
    "cost-center:${var.cost_center}"
  ]
  
  # State management configuration
  state_config = {
    enabled           = var.enable_remote_state
    bucket_name      = var.state_bucket_name != "" ? var.state_bucket_name : "${local.name_prefix}-state-${random_string.suffix.result}"
    versioning       = var.enable_state_versioning
    encryption       = var.enable_state_encryption
    retention_days   = var.state_backup_retention_days
  }
  
  # Team access configuration
  team_config = {
    enabled           = var.enable_team_access
    members          = var.team_members
    developer_perms  = var.developer_role_permissions
    operator_perms   = var.operator_role_permissions
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

# Random password for demonstration (not used in production)
resource "random_password" "demo_password" {
  length  = 16
  special = true
}

# =============================================================================
# TIME TRACKING FOR DEPLOYMENT
# =============================================================================

# Track deployment time
resource "time_static" "deployment_time" {}

# =============================================================================
# NETWORKING INFRASTRUCTURE
# =============================================================================

# VPC for state management demonstration
resource "ibm_is_vpc" "state_demo_vpc" {
  name           = "${local.name_prefix}-vpc"
  resource_group = data.ibm_resource_group.main.id
  address_prefix_management = "manual"
  
  tags = concat(local.common_tags, [
    "resource-type:vpc",
    "tier:networking"
  ])
}

# Address prefix for VPC
resource "ibm_is_vpc_address_prefix" "state_demo_prefix" {
  name = "${local.name_prefix}-address-prefix"
  vpc  = ibm_is_vpc.state_demo_vpc.id
  zone = local.availability_zone
  cidr = var.vpc_address_prefix
}

# Public gateway for internet access
resource "ibm_is_public_gateway" "state_demo_gateway" {
  count = var.enable_public_gateway ? 1 : 0
  
  name           = "${local.name_prefix}-gateway"
  vpc            = ibm_is_vpc.state_demo_vpc.id
  zone           = local.availability_zone
  resource_group = data.ibm_resource_group.main.id
  
  tags = concat(local.common_tags, [
    "resource-type:public-gateway",
    "tier:networking"
  ])
}

# Subnet for compute resources
resource "ibm_is_subnet" "state_demo_subnet" {
  name                     = "${local.name_prefix}-subnet"
  vpc                      = ibm_is_vpc.state_demo_vpc.id
  zone                     = local.availability_zone
  ipv4_cidr_block         = var.subnet_address_prefix
  public_gateway          = var.enable_public_gateway ? ibm_is_public_gateway.state_demo_gateway[0].id : null
  resource_group          = data.ibm_resource_group.main.id
  
  depends_on = [ibm_is_vpc_address_prefix.state_demo_prefix]
  
  tags = concat(local.common_tags, [
    "resource-type:subnet",
    "tier:networking"
  ])
}

# =============================================================================
# SECURITY GROUPS
# =============================================================================

# Security group for state management demo
resource "ibm_is_security_group" "state_demo_sg" {
  name           = "${local.name_prefix}-sg"
  vpc            = ibm_is_vpc.state_demo_vpc.id
  resource_group = data.ibm_resource_group.main.id
  
  tags = concat(local.common_tags, [
    "resource-type:security-group",
    "tier:security"
  ])
}

# SSH access rule
resource "ibm_is_security_group_rule" "ssh_inbound" {
  group     = ibm_is_security_group.state_demo_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# HTTP access rule
resource "ibm_is_security_group_rule" "http_inbound" {
  group     = ibm_is_security_group.state_demo_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 80
    port_max = 80
  }
}

# HTTPS access rule
resource "ibm_is_security_group_rule" "https_inbound" {
  group     = ibm_is_security_group.state_demo_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 443
    port_max = 443
  }
}

# Outbound rule for all traffic
resource "ibm_is_security_group_rule" "all_outbound" {
  group     = ibm_is_security_group.state_demo_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# =============================================================================
# COMPUTE RESOURCES
# =============================================================================

# Virtual Server Instance for state management demonstration
resource "ibm_is_instance" "state_demo_vsi" {
  name           = "${local.name_prefix}-vsi"
  vpc            = ibm_is_vpc.state_demo_vpc.id
  zone           = local.availability_zone
  profile        = var.vsi_profile
  image          = data.ibm_is_image.ubuntu.id
  keys           = var.ssh_key_name != "" ? [data.ibm_is_ssh_key.existing_key[0].id] : []
  resource_group = data.ibm_resource_group.main.id
  
  # Primary network interface
  primary_network_interface {
    subnet          = ibm_is_subnet.state_demo_subnet.id
    security_groups = [ibm_is_security_group.state_demo_sg.id]
  }
  
  # Boot volume configuration
  boot_volume {
    name                             = "${local.name_prefix}-boot-volume"
    delete_volume_on_instance_delete = var.auto_delete_volume
    tags                            = local.common_tags
  }
  
  # User data for initial configuration
  user_data = templatefile("${path.module}/templates/user-data.sh", {
    project_name = var.project_name
    environment  = var.environment
  })
  
  tags = concat(local.common_tags, [
    "resource-type:vsi",
    "tier:compute"
  ])
}

# Floating IP for VSI (optional)
resource "ibm_is_floating_ip" "state_demo_fip" {
  count  = var.enable_floating_ip ? 1 : 0
  name   = "${local.name_prefix}-fip"
  target = ibm_is_instance.state_demo_vsi.primary_network_interface[0].id
  
  tags = concat(local.common_tags, [
    "resource-type:floating-ip",
    "tier:networking"
  ])
}

# =============================================================================
# CLOUD OBJECT STORAGE FOR STATE BACKEND
# =============================================================================

# COS instance for state management
resource "ibm_resource_instance" "state_cos" {
  count = var.enable_remote_state ? 1 : 0
  
  name              = "${local.name_prefix}-state-cos"
  resource_group_id = data.ibm_resource_group.main.id
  service           = "cloud-object-storage"
  plan              = "lite"  # Use lite plan for cost optimization
  location          = "global"
  
  tags = concat(local.common_tags, [
    "service:cloud-object-storage",
    "purpose:state-backend"
  ])
}

# State storage bucket
resource "ibm_cos_bucket" "state_bucket" {
  count = var.enable_remote_state ? 1 : 0
  
  bucket_name          = local.state_config.bucket_name
  resource_instance_id = ibm_resource_instance.state_cos[0].id
  region_location      = var.primary_region
  storage_class        = "standard"
  
  # Enable versioning for state history
  dynamic "object_versioning" {
    for_each = local.state_config.versioning ? [1] : []
    content {
      enable = true
    }
  }
  
  # Activity tracking for audit compliance
  activity_tracking {
    read_data_events     = true
    write_data_events    = true
    management_events    = true
  }
  
  # Lifecycle management for cost optimization
  lifecycle_rule {
    id     = "state-lifecycle"
    status = "Enabled"
    
    # Archive old state versions
    transition {
      days          = 30
      storage_class = "cold"
    }
    
    # Delete very old versions
    expiration {
      days = local.state_config.retention_days
    }
  }
}

# Service credentials for state backend access
resource "ibm_resource_key" "state_cos_credentials" {
  count = var.enable_remote_state ? 1 : 0
  
  name                 = "${local.name_prefix}-state-credentials"
  resource_instance_id = ibm_resource_instance.state_cos[0].id
  role                 = "Writer"
  
  parameters = {
    HMAC = true
  }
}

# =============================================================================
# MONITORING AND COMPLIANCE
# =============================================================================

# Activity Tracker for audit logging
resource "ibm_resource_instance" "activity_tracker" {
  count = var.enable_activity_tracker ? 1 : 0
  
  name              = "${local.name_prefix}-activity-tracker"
  resource_group_id = data.ibm_resource_group.main.id
  service           = "logdnaat"
  plan              = var.activity_tracker_plan
  location          = var.primary_region
  
  tags = concat(local.common_tags, [
    "service:activity-tracker",
    "purpose:audit-logging"
  ])
}

# Monitoring instance
resource "ibm_resource_instance" "monitoring" {
  count = var.enable_monitoring ? 1 : 0
  
  name              = "${local.name_prefix}-monitoring"
  resource_group_id = data.ibm_resource_group.main.id
  service           = "sysdig-monitor"
  plan              = "graduated-tier"
  location          = var.primary_region
  
  tags = concat(local.common_tags, [
    "service:monitoring",
    "purpose:infrastructure-monitoring"
  ])
}

# =============================================================================
# TEAM ACCESS MANAGEMENT
# =============================================================================

# Additional service credentials for team members (developers)
resource "ibm_resource_key" "developer_credentials" {
  count = var.enable_remote_state && local.team_config.enabled ? 1 : 0
  
  name                 = "${local.name_prefix}-developer-access"
  resource_instance_id = ibm_resource_instance.state_cos[0].id
  role                 = local.team_config.developer_perms[0]
  
  parameters = {
    HMAC = true
  }
}

# Additional service credentials for team members (operators)
resource "ibm_resource_key" "operator_credentials" {
  count = var.enable_remote_state && local.team_config.enabled ? 1 : 0
  
  name                 = "${local.name_prefix}-operator-access"
  resource_instance_id = ibm_resource_instance.state_cos[0].id
  role                 = local.team_config.operator_perms[0]
  
  parameters = {
    HMAC = true
  }
}

# =============================================================================
# LOCAL FILE GENERATION
# =============================================================================

# Generate backend configuration file
resource "local_file" "backend_config" {
  count = var.enable_remote_state ? 1 : 0
  
  filename = "${path.module}/generated_backend.tf"
  content = templatefile("${path.module}/templates/backend.tf.tpl", {
    bucket_name = local.state_config.bucket_name
    region      = var.primary_region
    endpoint    = ibm_cos_bucket.state_bucket[0].s3_endpoint_public
  })
  
  file_permission = "0644"
}

# Generate team access documentation
resource "local_file" "team_access_guide" {
  count = local.team_config.enabled ? 1 : 0
  
  filename = "${path.module}/team_access_guide.md"
  content = templatefile("${path.module}/templates/team-access.md.tpl", {
    project_name = var.project_name
    environment  = var.environment
    team_members = local.team_config.members
  })
  
  file_permission = "0644"
}
