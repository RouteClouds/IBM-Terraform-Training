# Enhanced Terraform Configuration for Cost Optimization Lab 1.2
# This configuration demonstrates IBM Cloud IaC benefits and cost optimization strategies

# Generate unique suffix for resource naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Data sources
data "ibm_resource_group" "training" {
  name = var.resource_group_name
}

data "ibm_is_zones" "regional" {
  region = var.ibm_region
}

data "ibm_is_image" "ubuntu" {
  name = var.vsi_image_name
}

# Local values for cost optimization
locals {
  # Resource naming with cost center identification
  vpc_name    = "${var.project_name}-${var.environment}-vpc-${random_string.suffix.result}"
  subnet_name = "${var.project_name}-${var.environment}-subnet-${random_string.suffix.result}"
  vsi_name    = "${var.project_name}-${var.environment}-vsi-${random_string.suffix.result}"
  
  # Cost optimization tags
  cost_tags = {
    "cost-center"           = var.cost_center
    "project"              = var.project_name
    "environment"          = var.environment
    "owner"                = var.owner
    "auto-shutdown"        = var.enable_auto_shutdown ? "enabled" : "disabled"
    "billing-code"         = var.billing_code
    "created-by"           = "terraform"
    "created-date"         = formatdate("YYYY-MM-DD", timestamp())
    "cost-optimization"    = "enabled"
    "reserved-eligible"    = var.reserved_instance_eligible ? "yes" : "no"
  }
  
  # Combined tags
  all_tags = concat(var.tags, [
    for k, v in local.cost_tags : "${k}:${v}"
  ])
  
  # Availability zone selection
  subnet_zone = var.subnet_zone != "" ? var.subnet_zone : data.ibm_is_zones.regional.zones[0]
}

# VPC with cost optimization features
resource "ibm_is_vpc" "cost_optimized_vpc" {
  name                        = local.vpc_name
  resource_group              = data.ibm_resource_group.training.id
  address_prefix_management   = var.vpc_address_prefix_management
  classic_access              = var.vpc_classic_access
  tags                        = local.all_tags
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Public Gateway with conditional creation for cost optimization
resource "ibm_is_public_gateway" "cost_optimized_gateway" {
  count          = var.create_public_gateway ? 1 : 0
  name           = "${local.vpc_name}-pgw"
  vpc            = ibm_is_vpc.cost_optimized_vpc.id
  zone           = local.subnet_zone
  resource_group = data.ibm_resource_group.training.id
  tags           = local.all_tags
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Subnet with cost-aware configuration
resource "ibm_is_subnet" "cost_optimized_subnet" {
  name                     = local.subnet_name
  vpc                      = ibm_is_vpc.cost_optimized_vpc.id
  zone                     = local.subnet_zone
  ipv4_cidr_block         = var.subnet_cidr
  resource_group          = data.ibm_resource_group.training.id
  public_gateway          = var.create_public_gateway && var.subnet_public_gateway ? ibm_is_public_gateway.cost_optimized_gateway[0].id : null
  tags                    = local.all_tags
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Security Group with cost optimization considerations
resource "ibm_is_security_group" "cost_optimized_sg" {
  name           = "${local.vpc_name}-sg"
  vpc            = ibm_is_vpc.cost_optimized_vpc.id
  resource_group = data.ibm_resource_group.training.id
  tags           = local.all_tags
}

# Security Group Rules
resource "ibm_is_security_group_rule" "cost_optimized_sg_rules" {
  count     = length(var.security_group_rules)
  group     = ibm_is_security_group.cost_optimized_sg.id
  direction = var.security_group_rules[count.index].direction
  remote    = var.security_group_rules[count.index].remote
  
  dynamic "tcp" {
    for_each = var.security_group_rules[count.index].protocol == "tcp" ? [1] : []
    content {
      port_min = var.security_group_rules[count.index].port_min
      port_max = var.security_group_rules[count.index].port_max
    }
  }
  
  dynamic "udp" {
    for_each = var.security_group_rules[count.index].protocol == "udp" ? [1] : []
    content {
      port_min = var.security_group_rules[count.index].port_min
      port_max = var.security_group_rules[count.index].port_max
    }
  }
  
  dynamic "icmp" {
    for_each = var.security_group_rules[count.index].protocol == "icmp" ? [1] : []
    content {
      type = -1
      code = -1
    }
  }
}

# Cost-optimized Virtual Server Instance
resource "ibm_is_instance" "cost_optimized_vsi" {
  name           = local.vsi_name
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.vsi_profile
  resource_group = data.ibm_resource_group.training.id
  tags           = local.all_tags
  
  # Primary network interface
  primary_network_interface {
    subnet          = ibm_is_subnet.cost_optimized_subnet.id
    security_groups = [ibm_is_security_group.cost_optimized_sg.id]
    allow_ip_spoofing = var.enable_ip_spoofing
  }
  
  vpc  = ibm_is_vpc.cost_optimized_vpc.id
  zone = local.subnet_zone
  
  # SSH key configuration
  keys = var.vsi_ssh_key_name != "" ? [data.ibm_is_ssh_key.training_key[0].id] : []
  
  # Cost-optimized boot volume
  boot_volume {
    name                             = "${local.vsi_name}-boot"
    delete_volume_on_instance_delete = var.auto_delete_volume
    encryption_key                   = var.volume_encryption_key != "" ? var.volume_encryption_key : null
    tags                            = local.all_tags
    
    # Right-sizing for cost optimization
    size = var.boot_volume_size
  }
  
  # Enhanced user data with cost optimization features
  user_data = base64encode(templatefile("${path.module}/cost_optimized_user_data.sh", {
    hostname                = local.vsi_name
    enable_auto_shutdown    = var.enable_auto_shutdown
    shutdown_schedule       = var.auto_shutdown_schedule
    startup_schedule        = var.auto_startup_schedule
    cost_center            = var.cost_center
    environment            = var.environment
  }))
  
  timeouts {
    create = "15m"
    delete = "15m"
  }
  
  depends_on = [
    ibm_is_subnet.cost_optimized_subnet,
    ibm_is_security_group_rule.cost_optimized_sg_rules
  ]
}

# Conditional Floating IP for cost optimization
resource "ibm_is_floating_ip" "cost_optimized_fip" {
  count          = var.create_floating_ip ? 1 : 0
  name           = "${local.vsi_name}-fip"
  target         = ibm_is_instance.cost_optimized_vsi.primary_network_interface[0].id
  resource_group = data.ibm_resource_group.training.id
  tags           = local.all_tags
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Cloud Object Storage for cost optimization demonstration
resource "ibm_resource_instance" "cos_instance" {
  count             = var.enable_cos_demo ? 1 : 0
  name              = "${var.project_name}-${var.environment}-cos"
  resource_group_id = data.ibm_resource_group.training.id
  service           = "cloud-object-storage"
  plan              = "lite"  # Free tier for cost optimization
  location          = "global"
  tags              = local.all_tags
}

# COS Bucket with lifecycle management for cost optimization
resource "ibm_cos_bucket" "cost_optimized_bucket" {
  count                = var.enable_cos_demo ? 1 : 0
  bucket_name          = "${var.project_name}-${var.environment}-data-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos_instance[0].id
  region_location      = var.ibm_region
  storage_class        = "smart"  # Intelligent tiering for cost optimization
  
  # Cost optimization through lifecycle management
  lifecycle_rule {
    id     = "cost-optimization-lifecycle"
    status = "Enabled"
    
    # Transition to cold storage after 30 days
    transition {
      days          = 30
      storage_class = "cold"
    }
    
    # Archive after 90 days
    transition {
      days          = 90
      storage_class = "vault"
    }
    
    # Delete after 365 days (if enabled)
    dynamic "expiration" {
      for_each = var.enable_data_expiration ? [1] : []
      content {
        days = 365
      }
    }
  }
  
  # Cost allocation tags
  object_versioning {
    enable = false  # Disable versioning to reduce costs
  }
}

# Key Protect instance for security benefits demonstration
resource "ibm_resource_instance" "key_protect" {
  count             = var.enable_key_protect ? 1 : 0
  name              = "${var.project_name}-${var.environment}-kp"
  resource_group_id = data.ibm_resource_group.training.id
  service           = "kms"
  plan              = "tiered-pricing"
  location          = var.ibm_region
  tags              = local.all_tags
}

# Monitoring instance for operational efficiency
resource "ibm_resource_instance" "monitoring" {
  count             = var.enable_monitoring ? 1 : 0
  name              = "${var.project_name}-${var.environment}-monitoring"
  resource_group_id = data.ibm_resource_group.training.id
  service           = "sysdig-monitor"
  plan              = "lite"  # Free tier
  location          = var.ibm_region
  tags              = local.all_tags
}

# Activity Tracker for compliance and audit benefits
resource "ibm_resource_instance" "activity_tracker" {
  count             = var.enable_activity_tracker ? 1 : 0
  name              = "${var.project_name}-${var.environment}-at"
  resource_group_id = data.ibm_resource_group.training.id
  service           = "logdnaat"
  plan              = "lite"  # Free tier
  location          = var.ibm_region
  tags              = local.all_tags
}

# Cost tracking and deployment information
resource "time_static" "deployment_time" {}

resource "local_file" "cost_optimization_report" {
  filename = "${path.module}/cost-optimization-report.json"
  content = jsonencode({
    deployment_info = {
      timestamp    = time_static.deployment_time.rfc3339
      region       = var.ibm_region
      zone         = local.subnet_zone
      project      = var.project_name
      environment  = var.environment
      cost_center  = var.cost_center
    }
    
    cost_optimization_features = {
      auto_shutdown_enabled     = var.enable_auto_shutdown
      reserved_instance_eligible = var.reserved_instance_eligible
      smart_storage_enabled     = var.enable_cos_demo
      monitoring_enabled        = var.enable_monitoring
      right_sizing_applied      = true
    }
    
    estimated_monthly_costs = {
      vsi_cost              = var.vsi_profile == "bx2-2x8" ? 73 : 146
      public_gateway_cost   = var.create_public_gateway ? 32 : 0
      floating_ip_cost      = var.create_floating_ip ? 3 : 0
      storage_cost          = var.enable_cos_demo ? 5 : 0
      total_base_cost       = var.vsi_profile == "bx2-2x8" ? 113 : 186
    }
    
    potential_savings = {
      auto_shutdown_savings_percent = var.enable_auto_shutdown ? 40 : 0
      smart_storage_savings_percent = var.enable_cos_demo ? 30 : 0
      right_sizing_savings_percent  = 15
      total_potential_savings_percent = var.enable_auto_shutdown ? 55 : 15
    }
    
    resources_created = {
      vpc_id     = ibm_is_vpc.cost_optimized_vpc.id
      subnet_id  = ibm_is_subnet.cost_optimized_subnet.id
      vsi_id     = ibm_is_instance.cost_optimized_vsi.id
      cos_id     = var.enable_cos_demo ? ibm_resource_instance.cos_instance[0].id : null
    }
  })
}
