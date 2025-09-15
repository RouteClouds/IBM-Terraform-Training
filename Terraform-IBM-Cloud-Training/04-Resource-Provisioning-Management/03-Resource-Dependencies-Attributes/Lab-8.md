# Lab 8: Resource Dependencies and Attributes
## Advanced Dependency Management in IBM Cloud Terraform

### Lab Overview

**Duration**: 90-120 minutes  
**Difficulty**: Advanced  
**Prerequisites**: Completion of Labs 6 and 7

This comprehensive lab provides hands-on experience with Terraform resource dependencies and attributes in IBM Cloud environments. You'll build a complex multi-tier architecture while mastering dependency management, data sources, and troubleshooting techniques.

### Learning Objectives

By completing this lab, you will:
1. Implement implicit and explicit dependencies in complex architectures
2. Master resource attribute references and cross-resource communication
3. Leverage data sources for dynamic infrastructure discovery
4. Analyze and optimize dependency graphs for performance
5. Troubleshoot common dependency issues and circular dependencies
6. Design enterprise-grade multi-tier architectures with proper dependencies
7. Implement disaster recovery patterns with cross-region dependencies

### Lab Architecture

You'll build a sophisticated e-commerce platform with:
- **Web Tier**: Load balancer and web servers with auto-scaling
- **Application Tier**: Application servers with service discovery
- **Data Tier**: PostgreSQL cluster with read replicas
- **Shared Services**: Monitoring, logging, and backup systems
- **Disaster Recovery**: Cross-region replication and failover

---

## Exercise 1: Foundation Infrastructure with Implicit Dependencies (20 minutes)

### Objective
Create the foundational VPC infrastructure using implicit dependencies to establish proper resource ordering.

### Step 1.1: Initialize Lab Environment

```bash
# Create lab directory
mkdir -p ~/terraform-labs/lab-8-dependencies
cd ~/terraform-labs/lab-8-dependencies

# Initialize Terraform
terraform init
```

### Step 1.2: Create VPC Foundation

Create `01-foundation.tf`:

```hcl
# =============================================================================
# FOUNDATION INFRASTRUCTURE - VPC AND NETWORKING
# =============================================================================

# Resource group for the project
data "ibm_resource_group" "project_rg" {
  name = var.resource_group_name
}

# Main VPC - Foundation for all resources
resource "ibm_is_vpc" "ecommerce_vpc" {
  name           = "${var.project_name}-vpc"
  resource_group = data.ibm_resource_group.project_rg.id
  
  tags = [
    "project:${var.project_name}",
    "environment:${var.environment}",
    "tier:foundation"
  ]
}

# Availability zones data source
data "ibm_is_zones" "regional_zones" {
  region = var.region
}

# Public subnets for web tier (implicit dependency on VPC)
resource "ibm_is_subnet" "public_subnets" {
  count = length(data.ibm_is_zones.regional_zones.zones)
  
  name            = "${var.project_name}-public-subnet-${count.index + 1}"
  vpc             = ibm_is_vpc.ecommerce_vpc.id  # Implicit dependency
  zone            = data.ibm_is_zones.regional_zones.zones[count.index]
  ipv4_cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  
  tags = [
    "project:${var.project_name}",
    "tier:public",
    "zone:${data.ibm_is_zones.regional_zones.zones[count.index]}"
  ]
}

# Private subnets for application tier (implicit dependency on VPC)
resource "ibm_is_subnet" "private_subnets" {
  count = length(data.ibm_is_zones.regional_zones.zones)
  
  name            = "${var.project_name}-private-subnet-${count.index + 1}"
  vpc             = ibm_is_vpc.ecommerce_vpc.id  # Implicit dependency
  zone            = data.ibm_is_zones.regional_zones.zones[count.index]
  ipv4_cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  
  tags = [
    "project:${var.project_name}",
    "tier:private",
    "zone:${data.ibm_is_zones.regional_zones.zones[count.index]}"
  ]
}

# Database subnets for data tier (implicit dependency on VPC)
resource "ibm_is_subnet" "database_subnets" {
  count = length(data.ibm_is_zones.regional_zones.zones)
  
  name            = "${var.project_name}-database-subnet-${count.index + 1}"
  vpc             = ibm_is_vpc.ecommerce_vpc.id  # Implicit dependency
  zone            = data.ibm_is_zones.regional_zones.zones[count.index]
  ipv4_cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  
  tags = [
    "project:${var.project_name}",
    "tier:database",
    "zone:${data.ibm_is_zones.regional_zones.zones[count.index]}"
  ]
}

# Internet gateway for public access (implicit dependency on VPC)
resource "ibm_is_public_gateway" "public_gateways" {
  count = length(data.ibm_is_zones.regional_zones.zones)
  
  name = "${var.project_name}-pgw-${count.index + 1}"
  vpc  = ibm_is_vpc.ecommerce_vpc.id  # Implicit dependency
  zone = data.ibm_is_zones.regional_zones.zones[count.index]
  
  tags = [
    "project:${var.project_name}",
    "component:gateway",
    "zone:${data.ibm_is_zones.regional_zones.zones[count.index]}"
  ]
}

# Attach public gateways to private subnets (implicit dependencies)
resource "ibm_is_subnet_public_gateway_attachment" "private_subnet_pgw" {
  count = length(ibm_is_subnet.private_subnets)
  
  subnet         = ibm_is_subnet.private_subnets[count.index].id  # Implicit dependency
  public_gateway = ibm_is_public_gateway.public_gateways[count.index].id  # Implicit dependency
}
```

### Step 1.3: Create Variables File

Create `variables.tf`:

```hcl
# =============================================================================
# VARIABLES FOR DEPENDENCY LAB
# =============================================================================

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "ecommerce-platform"
  
  validation {
    condition     = length(var.project_name) > 3 && length(var.project_name) < 20
    error_message = "Project name must be between 4 and 19 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "region" {
  description = "IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "default"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "enable_monitoring" {
  description = "Enable monitoring and logging services"
  type        = bool
  default     = true
}

variable "enable_disaster_recovery" {
  description = "Enable disaster recovery setup"
  type        = bool
  default     = false
}

variable "web_server_count" {
  description = "Number of web servers to deploy"
  type        = number
  default     = 2
  
  validation {
    condition     = var.web_server_count >= 1 && var.web_server_count <= 10
    error_message = "Web server count must be between 1 and 10."
  }
}

variable "app_server_count" {
  description = "Number of application servers to deploy"
  type        = number
  default     = 3
  
  validation {
    condition     = var.app_server_count >= 1 && var.app_server_count <= 20
    error_message = "Application server count must be between 1 and 20."
  }
}
```

### Step 1.4: Test Foundation Infrastructure

```bash
# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Apply foundation infrastructure
terraform apply -auto-approve

# Verify implicit dependencies
terraform show | grep -A 5 -B 5 "depends_on"
```

### Validation Checkpoint 1

Verify that:
- [ ] VPC is created successfully
- [ ] All subnets reference the VPC ID (implicit dependency)
- [ ] Public gateways are attached to correct zones
- [ ] No explicit `depends_on` statements are needed
- [ ] Resources are created in proper order

---

## Exercise 2: Security Groups with Cross-References (25 minutes)

### Objective
Implement security groups with cross-references and understand how Terraform handles circular dependency prevention.

### Step 2.1: Create Security Groups

Create `02-security-groups.tf`:

```hcl
# =============================================================================
# SECURITY GROUPS WITH CROSS-REFERENCES
# =============================================================================

# Web tier security group
resource "ibm_is_security_group" "web_tier_sg" {
  name = "${var.project_name}-web-tier-sg"
  vpc  = ibm_is_vpc.ecommerce_vpc.id  # Implicit dependency on VPC
  
  tags = [
    "project:${var.project_name}",
    "tier:web",
    "component:security"
  ]
}

# Application tier security group
resource "ibm_is_security_group" "app_tier_sg" {
  name = "${var.project_name}-app-tier-sg"
  vpc  = ibm_is_vpc.ecommerce_vpc.id  # Implicit dependency on VPC
  
  tags = [
    "project:${var.project_name}",
    "tier:application",
    "component:security"
  ]
}

# Database tier security group
resource "ibm_is_security_group" "db_tier_sg" {
  name = "${var.project_name}-db-tier-sg"
  vpc  = ibm_is_vpc.ecommerce_vpc.id  # Implicit dependency on VPC
  
  tags = [
    "project:${var.project_name}",
    "tier:database",
    "component:security"
  ]
}

# Load balancer security group
resource "ibm_is_security_group" "lb_sg" {
  name = "${var.project_name}-lb-sg"
  vpc  = ibm_is_vpc.ecommerce_vpc.id  # Implicit dependency on VPC
  
  tags = [
    "project:${var.project_name}",
    "component:load-balancer",
    "tier:public"
  ]
}

# =============================================================================
# SECURITY GROUP RULES - DEMONSTRATING CROSS-REFERENCES
# =============================================================================

# Load balancer inbound rules
resource "ibm_is_security_group_rule" "lb_inbound_http" {
  group     = ibm_is_security_group.lb_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "lb_inbound_https" {
  group     = ibm_is_security_group.lb_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 443
    port_max = 443
  }
}

# Load balancer to web tier communication
resource "ibm_is_security_group_rule" "lb_to_web" {
  group     = ibm_is_security_group.lb_sg.id
  direction = "outbound"
  remote    = ibm_is_security_group.web_tier_sg.id  # Cross-reference
  
  tcp {
    port_min = 8080
    port_max = 8080
  }
}

# Web tier inbound from load balancer
resource "ibm_is_security_group_rule" "web_from_lb" {
  group     = ibm_is_security_group.web_tier_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.lb_sg.id  # Cross-reference
  
  tcp {
    port_min = 8080
    port_max = 8080
  }
}

# Web tier to application tier communication
resource "ibm_is_security_group_rule" "web_to_app" {
  group     = ibm_is_security_group.web_tier_sg.id
  direction = "outbound"
  remote    = ibm_is_security_group.app_tier_sg.id  # Cross-reference
  
  tcp {
    port_min = 8081
    port_max = 8081
  }
}

# Application tier inbound from web tier
resource "ibm_is_security_group_rule" "app_from_web" {
  group     = ibm_is_security_group.app_tier_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.web_tier_sg.id  # Cross-reference
  
  tcp {
    port_min = 8081
    port_max = 8081
  }
}

# Application tier to database communication
resource "ibm_is_security_group_rule" "app_to_db" {
  group     = ibm_is_security_group.app_tier_sg.id
  direction = "outbound"
  remote    = ibm_is_security_group.db_tier_sg.id  # Cross-reference
  
  tcp {
    port_min = 5432
    port_max = 5432
  }
}

# Database tier inbound from application tier
resource "ibm_is_security_group_rule" "db_from_app" {
  group     = ibm_is_security_group.db_tier_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.app_tier_sg.id  # Cross-reference
  
  tcp {
    port_min = 5432
    port_max = 5432
  }
}

# SSH access for management (all tiers)
resource "ibm_is_security_group_rule" "ssh_access" {
  for_each = {
    web = ibm_is_security_group.web_tier_sg.id
    app = ibm_is_security_group.app_tier_sg.id
    db  = ibm_is_security_group.db_tier_sg.id
  }
  
  group     = each.value
  direction = "inbound"
  remote    = var.management_cidr
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Outbound internet access for updates
resource "ibm_is_security_group_rule" "outbound_internet" {
  for_each = {
    web = ibm_is_security_group.web_tier_sg.id
    app = ibm_is_security_group.app_tier_sg.id
    db  = ibm_is_security_group.db_tier_sg.id
  }
  
  group     = each.value
  direction = "outbound"
  remote    = "0.0.0.0/0"
}
```

### Step 2.2: Add Management Variables

Add to `variables.tf`:

```hcl
variable "management_cidr" {
  description = "CIDR block for management access"
  type        = string
  default     = "10.0.0.0/8"
}
```

### Step 2.3: Test Security Group Dependencies

```bash
# Plan security group changes
terraform plan

# Apply security groups
terraform apply -auto-approve

# Analyze dependency graph
terraform graph | grep -E "(security_group|rule)"

# Verify cross-references work correctly
terraform show | grep -A 3 -B 3 "remote.*security_group"
```

### Validation Checkpoint 2

Verify that:
- [ ] Security groups are created before rules
- [ ] Cross-references between security groups work correctly
- [ ] No circular dependencies are created
- [ ] Rules reference security group IDs properly
- [ ] For_each creates multiple rules efficiently

---

## Exercise 3: Data Sources and Dynamic Discovery (20 minutes)

### Objective
Implement data sources for dynamic infrastructure discovery and demonstrate how they integrate with resource dependencies.

### Step 3.1: Create Data Sources Configuration

Create `03-data-sources.tf`:

```hcl
# =============================================================================
# DATA SOURCES FOR DYNAMIC INFRASTRUCTURE DISCOVERY
# =============================================================================

# Fetch latest Ubuntu image
data "ibm_is_image" "ubuntu_latest" {
  name = "ibm-ubuntu-20-04-minimal-amd64-2"
}

# Fetch available instance profiles
data "ibm_is_instance_profiles" "available_profiles" {}

# Fetch SSH keys for instance access
data "ibm_is_ssh_keys" "available_keys" {}

# Fetch existing VPC (alternative approach for existing infrastructure)
data "ibm_is_vpc" "existing_vpc" {
  count = var.use_existing_vpc ? 1 : 0
  name  = var.existing_vpc_name
}

# Fetch existing subnets (if using existing VPC)
data "ibm_is_subnets" "existing_subnets" {
  count = var.use_existing_vpc ? 1 : 0
}

# Fetch COS service instances for backup storage
data "ibm_resource_instances" "cos_instances" {
  resource_group_id = data.ibm_resource_group.project_rg.id
  service           = "cloud-object-storage"
}

# Fetch monitoring service instances
data "ibm_resource_instances" "monitoring_instances" {
  resource_group_id = data.ibm_resource_group.project_rg.id
  service           = "sysdig-monitor"
}

# =============================================================================
# LOCAL VALUES USING DATA SOURCES
# =============================================================================

locals {
  # Dynamic VPC selection
  vpc_id = var.use_existing_vpc ? data.ibm_is_vpc.existing_vpc[0].id : ibm_is_vpc.ecommerce_vpc.id
  
  # Dynamic subnet selection
  public_subnet_ids = var.use_existing_vpc ? [
    for subnet in data.ibm_is_subnets.existing_subnets[0].subnets :
    subnet.id if can(regex("public", subnet.name))
  ] : ibm_is_subnet.public_subnets[*].id
  
  private_subnet_ids = var.use_existing_vpc ? [
    for subnet in data.ibm_is_subnets.existing_subnets[0].subnets :
    subnet.id if can(regex("private", subnet.name))
  ] : ibm_is_subnet.private_subnets[*].id
  
  database_subnet_ids = var.use_existing_vpc ? [
    for subnet in data.ibm_is_subnets.existing_subnets[0].subnets :
    subnet.id if can(regex("database", subnet.name))
  ] : ibm_is_subnet.database_subnets[*].id
  
  # Dynamic instance profile selection
  web_instance_profile = var.environment == "production" ? "bx2-4x16" : "bx2-2x8"
  app_instance_profile = var.environment == "production" ? "bx2-8x32" : "bx2-4x16"
  db_instance_profile  = var.environment == "production" ? "bx2-16x64" : "bx2-8x32"
  
  # Filter suitable profiles based on requirements
  suitable_web_profiles = [
    for profile in data.ibm_is_instance_profiles.available_profiles.instance_profiles :
    profile.name if profile.vcpu_count >= 2 && profile.memory >= 8
  ]
  
  suitable_app_profiles = [
    for profile in data.ibm_is_instance_profiles.available_profiles.instance_profiles :
    profile.name if profile.vcpu_count >= 4 && profile.memory >= 16
  ]
  
  # SSH key selection
  ssh_key_ids = length(data.ibm_is_ssh_keys.available_keys.keys) > 0 ? 
    [data.ibm_is_ssh_keys.available_keys.keys[0].id] : []
  
  # Monitoring configuration
  monitoring_enabled = length(data.ibm_resource_instances.monitoring_instances.instances) > 0
  
  # Backup storage configuration
  backup_storage_available = length(data.ibm_resource_instances.cos_instances.instances) > 0
  backup_bucket_name = local.backup_storage_available ? 
    "${var.project_name}-backup-${random_string.bucket_suffix.result}" : null
}

# Random string for unique resource naming
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# CONDITIONAL RESOURCES BASED ON DATA SOURCES
# =============================================================================

# Create COS instance if none exists
resource "ibm_resource_instance" "backup_cos" {
  count = local.backup_storage_available ? 0 : 1
  
  name              = "${var.project_name}-backup-cos"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = data.ibm_resource_group.project_rg.id
  
  tags = [
    "project:${var.project_name}",
    "component:backup",
    "service:cos"
  ]
}

# Create backup bucket
resource "ibm_cos_bucket" "backup_bucket" {
  count = var.enable_backup ? 1 : 0
  
  bucket_name          = local.backup_bucket_name
  resource_instance_id = local.backup_storage_available ? 
    data.ibm_resource_instances.cos_instances.instances[0].id :
    ibm_resource_instance.backup_cos[0].id
  region_location = var.region
  storage_class   = "standard"
  
  # Implicit dependency on COS instance
  depends_on = [ibm_resource_instance.backup_cos]
}

# Create monitoring instance if none exists
resource "ibm_resource_instance" "monitoring" {
  count = local.monitoring_enabled ? 0 : 1
  
  name              = "${var.project_name}-monitoring"
  service           = "sysdig-monitor"
  plan              = "graduated-tier"
  location          = var.region
  resource_group_id = data.ibm_resource_group.project_rg.id
  
  tags = [
    "project:${var.project_name}",
    "component:monitoring",
    "service:sysdig"
  ]
}
```

### Step 3.2: Add Data Source Variables

Add to `variables.tf`:

```hcl
variable "use_existing_vpc" {
  description = "Use existing VPC instead of creating new one"
  type        = bool
  default     = false
}

variable "existing_vpc_name" {
  description = "Name of existing VPC to use"
  type        = string
  default     = ""
}

variable "enable_backup" {
  description = "Enable backup storage configuration"
  type        = bool
  default     = true
}
```

### Step 3.3: Test Data Source Integration

```bash
# Plan with data sources
terraform plan

# Apply data source configuration
terraform apply -auto-approve

# Verify data source usage
terraform show | grep -A 5 "data\."

# Check local values computation
terraform console
> local.vpc_id
> local.suitable_web_profiles
> local.monitoring_enabled
```

### Validation Checkpoint 3

Verify that:
- [ ] Data sources fetch information correctly
- [ ] Local values use data source outputs
- [ ] Conditional resources work based on data source results
- [ ] Dynamic subnet selection functions properly
- [ ] Instance profile filtering works correctly

---

## Exercise 4: Complex Multi-Tier Architecture (30 minutes)

### Objective
Build a complete multi-tier architecture demonstrating complex dependency patterns, explicit dependencies, and resource attribute usage.

### Step 4.1: Create Load Balancer

Create `04-load-balancer.tf`:

```hcl
# =============================================================================
# LOAD BALANCER CONFIGURATION
# =============================================================================

# Application load balancer
resource "ibm_is_lb" "web_load_balancer" {
  name    = "${var.project_name}-web-lb"
  subnets = local.public_subnet_ids
  type    = "public"
  
  # Implicit dependency on subnets
  tags = [
    "project:${var.project_name}",
    "component:load-balancer",
    "tier:public"
  ]
}

# Load balancer pool for web servers
resource "ibm_is_lb_pool" "web_pool" {
  lb                 = ibm_is_lb.web_load_balancer.id
  name               = "web-server-pool"
  protocol           = "http"
  algorithm          = "round_robin"
  health_delay       = 60
  health_retries     = 5
  health_timeout     = 30
  health_type        = "http"
  health_monitor_url = "/health"
  
  # Implicit dependency on load balancer
}

# Load balancer listener
resource "ibm_is_lb_listener" "web_listener" {
  lb           = ibm_is_lb.web_load_balancer.id
  port         = 80
  protocol     = "http"
  default_pool = ibm_is_lb_pool.web_pool.id
  
  # Implicit dependencies on load balancer and pool
}

# HTTPS listener (conditional)
resource "ibm_is_lb_listener" "web_https_listener" {
  count = var.enable_https ? 1 : 0
  
  lb           = ibm_is_lb.web_load_balancer.id
  port         = 443
  protocol     = "https"
  default_pool = ibm_is_lb_pool.web_pool.id
  
  certificate_instance = var.ssl_certificate_crn
}
```

### Step 4.2: Create Web Tier Instances

Create `05-web-tier.tf`:

```hcl
# =============================================================================
# WEB TIER INSTANCES
# =============================================================================

# Web server instances
resource "ibm_is_instance" "web_servers" {
  count = var.web_server_count
  
  name    = "${var.project_name}-web-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu_latest.id
  profile = local.web_instance_profile
  
  # Network configuration with implicit dependencies
  vpc  = local.vpc_id
  zone = data.ibm_is_zones.regional_zones.zones[count.index % length(data.ibm_is_zones.regional_zones.zones)]
  
  primary_network_interface {
    subnet          = local.public_subnet_ids[count.index % length(local.public_subnet_ids)]
    security_groups = [ibm_is_security_group.web_tier_sg.id]
  }
  
  # SSH key configuration
  keys = local.ssh_key_ids
  
  # User data for web server setup
  user_data = templatefile("${path.module}/scripts/web-server-setup.sh", {
    app_server_ips = join(",", ibm_is_instance.app_servers[*].primary_network_interface[0].primary_ipv4_address)
    monitoring_key = local.monitoring_enabled ? 
      data.ibm_resource_instances.monitoring_instances.instances[0].id : 
      ibm_resource_instance.monitoring[0].id
  })
  
  # Explicit dependency on application servers for configuration
  depends_on = [ibm_is_instance.app_servers]
  
  tags = [
    "project:${var.project_name}",
    "tier:web",
    "instance:${count.index + 1}"
  ]
}

# Load balancer pool members
resource "ibm_is_lb_pool_member" "web_pool_members" {
  count = length(ibm_is_instance.web_servers)
  
  lb     = ibm_is_lb.web_load_balancer.id
  pool   = ibm_is_lb_pool.web_pool.id
  port   = 8080
  target = ibm_is_instance.web_servers[count.index].primary_network_interface[0].primary_ipv4_address
  
  # Implicit dependencies on load balancer, pool, and instances
}

# Floating IPs for web servers (optional)
resource "ibm_is_floating_ip" "web_server_fips" {
  count = var.enable_floating_ips ? length(ibm_is_instance.web_servers) : 0
  
  name   = "${var.project_name}-web-${count.index + 1}-fip"
  target = ibm_is_instance.web_servers[count.index].primary_network_interface[0].id
  
  # Implicit dependency on instances
}
```

### Step 4.3: Create Application Tier

Create `06-app-tier.tf`:

```hcl
# =============================================================================
# APPLICATION TIER INSTANCES
# =============================================================================

# Application server instances
resource "ibm_is_instance" "app_servers" {
  count = var.app_server_count
  
  name    = "${var.project_name}-app-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu_latest.id
  profile = local.app_instance_profile
  
  # Network configuration
  vpc  = local.vpc_id
  zone = data.ibm_is_zones.regional_zones.zones[count.index % length(data.ibm_is_zones.regional_zones.zones)]
  
  primary_network_interface {
    subnet          = local.private_subnet_ids[count.index % length(local.private_subnet_ids)]
    security_groups = [ibm_is_security_group.app_tier_sg.id]
  }
  
  keys = local.ssh_key_ids
  
  # User data for application server setup
  user_data = templatefile("${path.module}/scripts/app-server-setup.sh", {
    database_endpoint = ibm_database.primary_database.connectionstrings[0].composed
    redis_endpoint    = ibm_database.redis_cache.connectionstrings[0].composed
    backup_bucket     = var.enable_backup ? ibm_cos_bucket.backup_bucket[0].bucket_name : ""
  })
  
  # Explicit dependency on database services
  depends_on = [
    ibm_database.primary_database,
    ibm_database.redis_cache
  ]
  
  tags = [
    "project:${var.project_name}",
    "tier:application",
    "instance:${count.index + 1}"
  ]
}

# Internal load balancer for application tier
resource "ibm_is_lb" "app_internal_lb" {
  name    = "${var.project_name}-app-internal-lb"
  subnets = local.private_subnet_ids
  type    = "private"
  
  tags = [
    "project:${var.project_name}",
    "component:internal-lb",
    "tier:application"
  ]
}

# Application load balancer pool
resource "ibm_is_lb_pool" "app_pool" {
  lb                 = ibm_is_lb.app_internal_lb.id
  name               = "app-server-pool"
  protocol           = "http"
  algorithm          = "least_connections"
  health_delay       = 30
  health_retries     = 3
  health_timeout     = 15
  health_type        = "http"
  health_monitor_url = "/api/health"
}

# Application pool members
resource "ibm_is_lb_pool_member" "app_pool_members" {
  count = length(ibm_is_instance.app_servers)
  
  lb     = ibm_is_lb.app_internal_lb.id
  pool   = ibm_is_lb_pool.app_pool.id
  port   = 8081
  target = ibm_is_instance.app_servers[count.index].primary_network_interface[0].primary_ipv4_address
}

# Application load balancer listener
resource "ibm_is_lb_listener" "app_listener" {
  lb           = ibm_is_lb.app_internal_lb.id
  port         = 8081
  protocol     = "http"
  default_pool = ibm_is_lb_pool.app_pool.id
}
```

### Step 4.4: Create Database Tier

Create `07-database-tier.tf`:

```hcl
# =============================================================================
# DATABASE TIER SERVICES
# =============================================================================

# Primary PostgreSQL database
resource "ibm_database" "primary_database" {
  name     = "${var.project_name}-primary-db"
  service  = "databases-for-postgresql"
  plan     = var.environment == "production" ? "enterprise" : "standard"
  location = var.region
  
  resource_group_id = data.ibm_resource_group.project_rg.id
  
  # Database configuration
  adminpassword = var.database_admin_password
  
  # Network configuration
  service_endpoints = "private"
  
  # Backup configuration
  backup_id = var.restore_from_backup ? var.backup_id : null
  
  # Explicit dependency on network infrastructure
  depends_on = [
    ibm_is_vpc.ecommerce_vpc,
    ibm_is_subnet.database_subnets
  ]
  
  tags = [
    "project:${var.project_name}",
    "component:database",
    "tier:data",
    "type:primary"
  ]
}

# Redis cache for session management
resource "ibm_database" "redis_cache" {
  name     = "${var.project_name}-redis-cache"
  service  = "databases-for-redis"
  plan     = "standard"
  location = var.region
  
  resource_group_id = data.ibm_resource_group.project_rg.id
  
  # Redis configuration
  adminpassword = var.redis_admin_password
  
  service_endpoints = "private"
  
  depends_on = [
    ibm_is_vpc.ecommerce_vpc,
    ibm_is_subnet.database_subnets
  ]
  
  tags = [
    "project:${var.project_name}",
    "component:cache",
    "tier:data",
    "type:redis"
  ]
}

# Read replica for primary database (production only)
resource "ibm_database" "read_replica" {
  count = var.environment == "production" ? 1 : 0
  
  name     = "${var.project_name}-read-replica"
  service  = "databases-for-postgresql"
  plan     = "enterprise"
  location = var.region
  
  resource_group_id = data.ibm_resource_group.project_rg.id
  
  # Point-in-time recovery configuration
  point_in_time_recovery_time = var.replica_recovery_time
  
  # Explicit dependency on primary database
  depends_on = [ibm_database.primary_database]
  
  tags = [
    "project:${var.project_name}",
    "component:database",
    "tier:data",
    "type:replica"
  ]
}

# Virtual Private Endpoint for database access
resource "ibm_is_virtual_endpoint_gateway" "database_vpe" {
  name = "${var.project_name}-database-vpe"
  vpc  = local.vpc_id
  
  target {
    name          = "databases-for-postgresql"
    resource_type = "provider_cloud_service"
  }
  
  # Attach to database subnets
  dynamic "ips" {
    for_each = local.database_subnet_ids
    content {
      subnet = ips.value
      name   = "${var.project_name}-vpe-ip-${ips.key + 1}"
    }
  }
  
  # Explicit dependency on database and network
  depends_on = [
    ibm_database.primary_database,
    ibm_is_subnet.database_subnets
  ]
  
  tags = [
    "project:${var.project_name}",
    "component:vpe",
    "service:database"
  ]
}
```

### Step 4.5: Add Database Variables

Add to `variables.tf`:

```hcl
variable "database_admin_password" {
  description = "Admin password for PostgreSQL database"
  type        = string
  sensitive   = true
  default     = "TerraformLab123!"
  
  validation {
    condition     = length(var.database_admin_password) >= 12
    error_message = "Database password must be at least 12 characters long."
  }
}

variable "redis_admin_password" {
  description = "Admin password for Redis cache"
  type        = string
  sensitive   = true
  default     = "RedisLab123!"
}

variable "enable_https" {
  description = "Enable HTTPS listener on load balancer"
  type        = bool
  default     = false
}

variable "ssl_certificate_crn" {
  description = "CRN of SSL certificate for HTTPS"
  type        = string
  default     = ""
}

variable "enable_floating_ips" {
  description = "Enable floating IPs for web servers"
  type        = bool
  default     = false
}

variable "restore_from_backup" {
  description = "Restore database from backup"
  type        = bool
  default     = false
}

variable "backup_id" {
  description = "Backup ID for database restoration"
  type        = string
  default     = ""
}

variable "replica_recovery_time" {
  description = "Point-in-time recovery time for read replica"
  type        = string
  default     = ""
}
```

### Step 4.6: Create Setup Scripts

Create `scripts/web-server-setup.sh`:

```bash
#!/bin/bash
# Web server setup script

# Update system
apt-get update -y
apt-get install -y nginx nodejs npm

# Configure nginx
cat > /etc/nginx/sites-available/default << EOF
server {
    listen 8080;
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location /health {
        return 200 'OK';
        add_header Content-Type text/plain;
    }
}
EOF

# Start services
systemctl enable nginx
systemctl start nginx

# Configure application servers
echo "APP_SERVERS=${app_server_ips}" >> /etc/environment
echo "MONITORING_KEY=${monitoring_key}" >> /etc/environment

# Install monitoring agent (if enabled)
if [ ! -z "${monitoring_key}" ]; then
    curl -sL https://ibm.biz/install-sysdig-agent | bash -s -- --access_key ${monitoring_key}
fi
```

Create `scripts/app-server-setup.sh`:

```bash
#!/bin/bash
# Application server setup script

# Update system
apt-get update -y
apt-get install -y nodejs npm postgresql-client redis-tools

# Configure environment
echo "DATABASE_URL=${database_endpoint}" >> /etc/environment
echo "REDIS_URL=${redis_endpoint}" >> /etc/environment
echo "BACKUP_BUCKET=${backup_bucket}" >> /etc/environment

# Install application dependencies
npm install -g pm2

# Create application directory
mkdir -p /opt/app
cd /opt/app

# Sample application setup
cat > package.json << EOF
{
  "name": "ecommerce-app",
  "version": "1.0.0",
  "main": "app.js",
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.7.0",
    "redis": "^4.0.0"
  }
}
EOF

npm install

# Start application
pm2 startup
pm2 save
```

### Step 4.7: Test Complete Architecture

```bash
# Validate complete configuration
terraform validate

# Plan full deployment
terraform plan

# Apply complete architecture
terraform apply -auto-approve

# Verify dependency order
terraform graph | dot -Tpng > architecture_dependencies.png

# Check resource creation order
terraform show | grep -E "(created|modified)"
```

### Validation Checkpoint 4

Verify that:
- [ ] Load balancer is created before pool members
- [ ] Instances are created with proper dependencies
- [ ] Database services are available before application servers
- [ ] VPE provides secure database connectivity
- [ ] All tiers communicate through proper security groups
- [ ] Resource attributes are used correctly for cross-references

---

## Exercise 5: Troubleshooting and Optimization (15 minutes)

### Objective
Learn to identify, diagnose, and resolve common dependency issues while optimizing dependency graphs for performance.

### Step 5.1: Analyze Dependency Graph

```bash
# Generate dependency graph
terraform graph > dependency_graph.dot

# Convert to visual format
dot -Tpng dependency_graph.dot > dependency_graph.png

# Analyze graph complexity
terraform graph | wc -l
terraform graph | grep -c "\->"

# Identify potential bottlenecks
terraform graph | grep -E "(ibm_is_vpc|ibm_is_subnet)" | head -10
```

### Step 5.2: Performance Analysis

Create `08-outputs.tf`:

```hcl
# =============================================================================
# OUTPUTS FOR DEPENDENCY ANALYSIS
# =============================================================================

output "dependency_analysis" {
  description = "Analysis of resource dependencies"
  value = {
    # VPC dependencies
    vpc_id = ibm_is_vpc.ecommerce_vpc.id
    vpc_dependents = [
      "subnets: ${length(ibm_is_subnet.public_subnets) + length(ibm_is_subnet.private_subnets) + length(ibm_is_subnet.database_subnets)}",
      "security_groups: 4",
      "instances: ${var.web_server_count + var.app_server_count}",
      "load_balancers: 2"
    ]
    
    # Critical path analysis
    critical_path = [
      "1. VPC creation",
      "2. Subnet creation (parallel)",
      "3. Security group creation (parallel)",
      "4. Database services",
      "5. Application instances",
      "6. Web instances",
      "7. Load balancer configuration"
    ]
    
    # Parallel creation opportunities
    parallel_resources = {
      subnets = "All subnets can be created in parallel"
      security_groups = "All security groups can be created in parallel"
      instances_per_tier = "Instances within each tier can be created in parallel"
      load_balancer_components = "Pool and listener can be created in parallel"
    }
    
    # Optimization recommendations
    optimizations = [
      "Use for_each instead of count for better resource management",
      "Group related resources in modules",
      "Minimize explicit depends_on usage",
      "Use data sources for existing resources"
    ]
  }
}

output "resource_timing" {
  description = "Estimated resource creation timing"
  value = {
    foundation_tier = "2-3 minutes (VPC, subnets, security groups)"
    database_tier = "15-20 minutes (PostgreSQL, Redis)"
    compute_tier = "5-8 minutes (instances, load balancers)"
    total_estimated = "22-31 minutes"
  }
}

output "architecture_endpoints" {
  description = "Key architecture endpoints"
  value = {
    web_load_balancer = ibm_is_lb.web_load_balancer.hostname
    app_internal_lb = ibm_is_lb.app_internal_lb.hostname
    database_endpoint = ibm_database.primary_database.connectionstrings[0].composed
    redis_endpoint = ibm_database.redis_cache.connectionstrings[0].composed
    
    # Instance details
    web_servers = [
      for instance in ibm_is_instance.web_servers :
      {
        name = instance.name
        private_ip = instance.primary_network_interface[0].primary_ipv4_address
        zone = instance.zone
      }
    ]
    
    app_servers = [
      for instance in ibm_is_instance.app_servers :
      {
        name = instance.name
        private_ip = instance.primary_network_interface[0].primary_ipv4_address
        zone = instance.zone
      }
    ]
  }
  sensitive = true
}

output "dependency_validation" {
  description = "Validation of dependency relationships"
  value = {
    vpc_to_subnets = "✓ All subnets reference VPC ID"
    subnets_to_instances = "✓ All instances reference subnet IDs"
    security_groups_cross_ref = "✓ Security group rules cross-reference correctly"
    load_balancer_to_instances = "✓ Load balancer pools reference instance IPs"
    database_to_apps = "✓ Application servers reference database endpoints"
    data_sources_integration = "✓ Data sources provide dynamic configuration"
  }
}
```

### Step 5.3: Dependency Troubleshooting

Create `troubleshooting.md`:

```markdown
# Dependency Troubleshooting Guide

## Common Issues and Solutions

### 1. Circular Dependencies
**Error**: `Error: Cycle: resource1 -> resource2 -> resource1`
**Solution**: 
- Remove unnecessary cross-references
- Use data sources instead of direct references
- Break circular references with explicit depends_on

### 2. Resource Not Found
**Error**: `Error: Reference to undeclared resource`
**Solution**:
- Check resource names and types
- Verify resource is defined before reference
- Use terraform validate to catch syntax errors

### 3. Attribute Not Available
**Error**: `Error: Unsupported attribute for resource`
**Solution**:
- Check Terraform provider documentation
- Verify attribute exists for resource type
- Use terraform show to see available attributes

### 4. Dependency Timeout
**Error**: Resource creation times out waiting for dependency
**Solution**:
- Check if dependency resource is stuck
- Verify network connectivity for dependent resources
- Review resource configuration for errors

## Debugging Commands

```bash
# Validate configuration
terraform validate

# Check dependency graph
terraform graph | grep "resource_name"

# Show resource details
terraform show | grep -A 10 "resource_name"

# Plan with detailed output
terraform plan -detailed-exitcode

# Apply with reduced parallelism
terraform apply -parallelism=2
```

## Performance Optimization

### Best Practices
1. Minimize explicit dependencies
2. Use implicit dependencies when possible
3. Group related resources in modules
4. Optimize for parallel creation
5. Use data sources for existing resources

### Monitoring
- Track resource creation times
- Monitor dependency graph complexity
- Identify bottlenecks in critical path
- Optimize resource ordering
```

### Step 5.4: Test Troubleshooting Scenarios

```bash
# Test dependency validation
terraform plan -detailed-exitcode

# Check for circular dependencies
terraform graph | grep -E "cycle|circular"

# Validate all resources
terraform validate

# Show dependency analysis
terraform apply -auto-approve
terraform output dependency_analysis
terraform output resource_timing
```

### Validation Checkpoint 5

Verify that:
- [ ] Dependency graph is generated successfully
- [ ] No circular dependencies exist
- [ ] Resource creation follows optimal order
- [ ] Performance analysis provides useful insights
- [ ] Troubleshooting guide is comprehensive

---

## Exercise 6: Disaster Recovery Dependencies (Optional - 10 minutes)

### Objective
Implement cross-region dependencies for disaster recovery scenarios.

### Step 6.1: Create DR Configuration

Create `09-disaster-recovery.tf`:

```hcl
# =============================================================================
# DISASTER RECOVERY CONFIGURATION
# =============================================================================

# DR region provider
provider "ibm" {
  alias  = "dr_region"
  region = var.dr_region
}

# DR VPC
resource "ibm_is_vpc" "dr_vpc" {
  count    = var.enable_disaster_recovery ? 1 : 0
  provider = ibm.dr_region
  
  name           = "${var.project_name}-dr-vpc"
  resource_group = data.ibm_resource_group.project_rg.id
  
  tags = [
    "project:${var.project_name}",
    "environment:${var.environment}",
    "tier:disaster-recovery"
  ]
}

# DR database (replica of primary)
resource "ibm_database" "dr_database" {
  count    = var.enable_disaster_recovery ? 1 : 0
  provider = ibm.dr_region
  
  name     = "${var.project_name}-dr-database"
  service  = "databases-for-postgresql"
  plan     = "enterprise"
  location = var.dr_region
  
  resource_group_id = data.ibm_resource_group.project_rg.id
  
  # Point-in-time recovery from primary
  point_in_time_recovery_time = var.dr_recovery_time
  
  # Explicit dependency on primary database
  depends_on = [ibm_database.primary_database]
  
  tags = [
    "project:${var.project_name}",
    "component:database",
    "tier:disaster-recovery"
  ]
}

# Cross-region backup replication
resource "ibm_cos_bucket" "dr_backup_bucket" {
  count = var.enable_disaster_recovery && var.enable_backup ? 1 : 0
  
  bucket_name          = "${var.project_name}-dr-backup-${random_string.bucket_suffix.result}"
  resource_instance_id = local.backup_storage_available ? 
    data.ibm_resource_instances.cos_instances.instances[0].id :
    ibm_resource_instance.backup_cos[0].id
  region_location = var.dr_region
  storage_class   = "standard"
  
  # Cross-region replication rule
  object_versioning {
    enable = true
  }
  
  depends_on = [ibm_cos_bucket.backup_bucket]
}
```

### Step 6.2: Add DR Variables

Add to `variables.tf`:

```hcl
variable "dr_region" {
  description = "Disaster recovery region"
  type        = string
  default     = "us-east"
}

variable "dr_recovery_time" {
  description = "Point-in-time recovery time for DR database"
  type        = string
  default     = ""
}
```

### Step 6.3: Test DR Dependencies

```bash
# Plan DR configuration
terraform plan -var="enable_disaster_recovery=true"

# Apply DR setup
terraform apply -var="enable_disaster_recovery=true" -auto-approve

# Verify cross-region dependencies
terraform show | grep -A 5 "dr_"
```

---

## Lab Summary and Validation

### Final Validation Checklist

Complete the following validation steps:

- [ ] **Foundation Infrastructure**: VPC, subnets, and gateways created with proper implicit dependencies
- [ ] **Security Groups**: Cross-references work without circular dependencies
- [ ] **Data Sources**: Dynamic discovery and conditional resource creation function correctly
- [ ] **Multi-Tier Architecture**: Complex dependencies between web, app, and database tiers work properly
- [ ] **Load Balancers**: Pool members reference instance attributes correctly
- [ ] **Database Services**: VPE provides secure connectivity with proper dependencies
- [ ] **Troubleshooting**: Dependency graph analysis and optimization recommendations are clear
- [ ] **Performance**: Resource creation follows optimal order for parallel execution
- [ ] **Disaster Recovery**: Cross-region dependencies work correctly (if enabled)

### Key Learning Outcomes

Upon completion of this lab, you have:

1. **Mastered Dependency Types**: Successfully implemented both implicit and explicit dependencies
2. **Resource Attribute Expertise**: Used resource attributes for dynamic cross-resource communication
3. **Data Source Proficiency**: Leveraged data sources for flexible, environment-agnostic configurations
4. **Complex Architecture Skills**: Built sophisticated multi-tier architectures with proper dependency management
5. **Troubleshooting Capabilities**: Developed skills to diagnose and resolve dependency issues
6. **Performance Optimization**: Learned to analyze and optimize dependency graphs for efficiency
7. **Enterprise Patterns**: Implemented disaster recovery and cross-region dependency patterns

### Cost Estimation

**Estimated Lab Costs** (running for 2 hours):
- VPC and networking: $0.00 (free tier)
- Compute instances (5 instances): ~$2.50
- Load balancers (2 ALBs): ~$1.00
- PostgreSQL database: ~$3.00
- Redis cache: ~$1.50
- Object storage: ~$0.10
- **Total estimated cost**: ~$8.10

### Cleanup Instructions

```bash
# Destroy all resources
terraform destroy -auto-approve

# Verify cleanup
terraform show

# Remove lab directory
cd ~
rm -rf ~/terraform-labs/lab-8-dependencies
```

### Next Steps

This lab prepares you for:
- **Topic 5**: State Management and Remote Backends
- **Topic 6**: Modules and Code Organization  
- **Topic 7**: Advanced Terraform Features
- **Topic 8**: Production Deployment and Best Practices

The dependency management skills learned here are fundamental for all advanced Terraform practices and enterprise deployments.

---

## Troubleshooting Common Issues

### Issue 1: Circular Dependency Error
```
Error: Cycle: ibm_is_security_group.web_sg -> ibm_is_security_group_rule.web_to_app -> ibm_is_security_group.app_sg -> ibm_is_security_group_rule.app_to_web -> ibm_is_security_group.web_sg
```

**Solution**: Create security groups first, then create rules with explicit dependencies:
```hcl
resource "ibm_is_security_group_rule" "web_to_app" {
  # ... configuration ...
  depends_on = [
    ibm_is_security_group.web_sg,
    ibm_is_security_group.app_sg
  ]
}
```

### Issue 2: Resource Attribute Not Available
```
Error: Unsupported attribute "primary_ipv4_address" for data.ibm_is_instance.web_server
```

**Solution**: Check the correct attribute path in documentation:
```hcl
# Correct attribute reference
instance.primary_network_interface[0].primary_ipv4_address
```

### Issue 3: Data Source Returns Empty Results
```
Error: Invalid index - data source returned no results
```

**Solution**: Add validation and conditional logic:
```hcl
locals {
  ssh_key_ids = length(data.ibm_is_ssh_keys.available_keys.keys) > 0 ? 
    [data.ibm_is_ssh_keys.available_keys.keys[0].id] : []
}
```

### Additional Resources

- [Terraform Dependency Documentation](https://www.terraform.io/docs/language/resources/behavior.html#resource-dependencies)
- [IBM Cloud Provider Documentation](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [Terraform Graph Command](https://www.terraform.io/docs/cli/commands/graph.html)
- [Dependency Troubleshooting Guide](https://learn.hashicorp.com/tutorials/terraform/troubleshooting-workflow)

---

**Lab Complete!** You have successfully mastered resource dependencies and attributes in IBM Cloud Terraform configurations.
