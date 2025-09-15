# Main Terraform Configuration for IBM Cloud IaC Training Lab 1.1
# This file contains the primary resource definitions for demonstrating IaC concepts

# Generate a random suffix for unique resource naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Data source to get the specified resource group
data "ibm_resource_group" "training" {
  name = var.resource_group_name
}

# Data source to get available zones in the specified region
data "ibm_is_zones" "regional" {
  region = var.ibm_region
}

# Data source to get the specified OS image
data "ibm_is_image" "ubuntu" {
  name = var.vsi_image_name
}

# Data source to get SSH key if specified
data "ibm_is_ssh_key" "training_key" {
  count = var.vsi_ssh_key_name != "" ? 1 : 0
  name  = var.vsi_ssh_key_name
}

# Local values for computed resource names and configurations
locals {
  # Generate resource names with consistent naming convention
  vpc_name    = var.vpc_name != "" ? var.vpc_name : "${var.project_name}-${var.environment}-vpc-${random_string.suffix.result}"
  subnet_name = var.subnet_name != "" ? var.subnet_name : "${var.project_name}-${var.environment}-subnet-${random_string.suffix.result}"
  vsi_name    = var.vsi_name != "" ? var.vsi_name : "${var.project_name}-${var.environment}-vsi-${random_string.suffix.result}"
  
  # Determine the availability zone
  subnet_zone = var.subnet_zone != "" ? var.subnet_zone : data.ibm_is_zones.regional.zones[0]
  
  # Combine default and additional tags
  all_tags = concat(var.tags, [
    "project:${var.project_name}",
    "environment:${var.environment}",
    "owner:${var.owner}",
    "created-by:terraform"
  ])
  
  # Security group name
  security_group_name = "${var.project_name}-${var.environment}-sg-${random_string.suffix.result}"
  
  # Public gateway name
  public_gateway_name = "${var.project_name}-${var.environment}-pgw-${random_string.suffix.result}"
}

# Create a Virtual Private Cloud (VPC)
resource "ibm_is_vpc" "training_vpc" {
  name                        = local.vpc_name
  resource_group              = data.ibm_resource_group.training.id
  address_prefix_management   = var.vpc_address_prefix_management
  classic_access              = var.vpc_classic_access
  tags                        = local.all_tags
  
  # Add timeouts for resource creation
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Create a Public Gateway for internet access (if enabled)
resource "ibm_is_public_gateway" "training_gateway" {
  count          = var.create_public_gateway ? 1 : 0
  name           = local.public_gateway_name
  vpc            = ibm_is_vpc.training_vpc.id
  zone           = local.subnet_zone
  resource_group = data.ibm_resource_group.training.id
  tags           = local.all_tags
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Create a Subnet within the VPC
resource "ibm_is_subnet" "training_subnet" {
  name                     = local.subnet_name
  vpc                      = ibm_is_vpc.training_vpc.id
  zone                     = local.subnet_zone
  ipv4_cidr_block         = var.subnet_cidr
  resource_group          = data.ibm_resource_group.training.id
  public_gateway          = var.create_public_gateway && var.subnet_public_gateway ? ibm_is_public_gateway.training_gateway[0].id : null
  tags                    = local.all_tags
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
  
  # Ensure public gateway is created first if needed
  depends_on = [ibm_is_public_gateway.training_gateway]
}

# Create a Security Group with custom rules
resource "ibm_is_security_group" "training_sg" {
  name           = local.security_group_name
  vpc            = ibm_is_vpc.training_vpc.id
  resource_group = data.ibm_resource_group.training.id
  tags           = local.all_tags
}

# Create Security Group Rules
resource "ibm_is_security_group_rule" "training_sg_rules" {
  count     = length(var.security_group_rules)
  group     = ibm_is_security_group.training_sg.id
  direction = var.security_group_rules[count.index].direction
  remote    = var.security_group_rules[count.index].remote
  
  # Handle different protocol types
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
      type = 8
      code = 0
    }
  }
}

# Create a Virtual Server Instance (VSI)
resource "ibm_is_instance" "training_vsi" {
  name           = local.vsi_name
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.vsi_profile
  resource_group = data.ibm_resource_group.training.id
  tags           = local.all_tags
  
  # Primary network interface configuration
  primary_network_interface {
    subnet          = ibm_is_subnet.training_subnet.id
    security_groups = [ibm_is_security_group.training_sg.id]
    allow_ip_spoofing = var.enable_ip_spoofing
  }
  
  # VPC configuration
  vpc  = ibm_is_vpc.training_vpc.id
  zone = local.subnet_zone
  
  # SSH key configuration (if provided)
  keys = var.vsi_ssh_key_name != "" ? [data.ibm_is_ssh_key.training_key[0].id] : []
  
  # Boot volume configuration
  boot_volume {
    name = "${local.vsi_name}-boot"
    tags = local.all_tags
  }
  
  # User data for initial configuration (optional)
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    hostname = local.vsi_name
  }))
  
  timeouts {
    create = "15m"
    delete = "15m"
  }
  
  # Ensure all dependencies are created first
  depends_on = [
    ibm_is_subnet.training_subnet,
    ibm_is_security_group_rule.training_sg_rules
  ]
}

# Create a Floating IP for the VSI (if enabled)
resource "ibm_is_floating_ip" "training_fip" {
  count          = var.create_floating_ip ? 1 : 0
  name           = "${local.vsi_name}-fip"
  target         = ibm_is_instance.training_vsi.primary_network_interface[0].id
  resource_group = data.ibm_resource_group.training.id
  tags           = local.all_tags
  
  timeouts {
    create = "10m"
    delete = "10m"
  }
}

# Add a timestamp for tracking deployment time
resource "time_static" "deployment_time" {}

# Create a local file with deployment information
resource "local_file" "deployment_info" {
  filename = "${path.module}/deployment-info.json"
  content = jsonencode({
    deployment_time = time_static.deployment_time.rfc3339
    vpc_id         = ibm_is_vpc.training_vpc.id
    subnet_id      = ibm_is_subnet.training_subnet.id
    vsi_id         = ibm_is_instance.training_vsi.id
    region         = var.ibm_region
    zone           = local.subnet_zone
    project_name   = var.project_name
    environment    = var.environment
  })
}
