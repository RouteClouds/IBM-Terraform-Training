# =============================================================================
# MAIN CONFIGURATION
# Resource Dependencies and Attributes Lab - Topic 4.3
# =============================================================================

# =============================================================================
# LOCAL VALUES FOR DEPENDENCY MANAGEMENT
# =============================================================================

locals {
  # Environment-based configuration
  environment_config = {
    development = {
      instance_count = 2
      database_plan = "standard"
      monitoring_plan = "lite"
      backup_retention = 7
    }
    staging = {
      instance_count = 3
      database_plan = "standard"
      monitoring_plan = "graduated-tier"
      backup_retention = 30
    }
    production = {
      instance_count = 5
      database_plan = "enterprise"
      monitoring_plan = "graduated-tier"
      backup_retention = 90
    }
  }
  
  # Current environment settings
  current_env = local.environment_config[var.project_configuration.environment.name]
  
  # Dependency optimization settings
  dependency_optimization = {
    enable_parallel_subnets = var.dependency_configuration.optimization_settings.enable_parallel_creation
    enable_parallel_security_groups = var.dependency_configuration.optimization_settings.enable_parallel_creation
    enable_parallel_instances = var.dependency_configuration.optimization_settings.enable_parallel_creation
    max_parallelism = var.dependency_configuration.optimization_settings.max_parallelism
  }
  
  # Resource naming with dependency context
  resource_names = {
    vpc_name = "${var.project_configuration.project_name}-vpc"
    subnet_prefix = "${var.project_configuration.project_name}-subnet"
    sg_prefix = "${var.project_configuration.project_name}-sg"
    instance_prefix = "${var.project_configuration.project_name}-instance"
    lb_prefix = "${var.project_configuration.project_name}-lb"
    db_prefix = "${var.project_configuration.project_name}-db"
  }
  
  # Computed dependency chains
  dependency_chains = {
    foundation = ["vpc", "subnets", "security_groups"]
    compute = ["instances", "load_balancers"]
    data = ["databases", "storage"]
    monitoring = ["logging", "metrics", "alerting"]
  }
  
  # Tag merging with dependency context
  common_tags = merge(var.global_tags, {
    "dependency-lab" = "4.3"
    "deployment-id" = random_string.deployment_id.result
    "deployment-time" = time_static.deployment_time.rfc3339
  })
}

# =============================================================================
# DATA SOURCES FOR DYNAMIC DISCOVERY
# =============================================================================

# Resource group data source
data "ibm_resource_group" "project_rg" {
  name = var.project_configuration.organization.name
}

# Available zones for the primary region
data "ibm_is_zones" "primary_zones" {
  region = var.primary_region
}

# Available zones for secondary region (if multi-region enabled)
data "ibm_is_zones" "secondary_zones" {
  count  = var.feature_flags.enable_multi_region ? 1 : 0
  region = var.secondary_region
}

# Latest Ubuntu image
data "ibm_is_image" "ubuntu_latest" {
  name = "ibm-ubuntu-20-04-minimal-amd64-2"
}

# Available instance profiles
data "ibm_is_instance_profiles" "available_profiles" {}

# SSH keys for instance access
data "ibm_is_ssh_keys" "available_keys" {}

# Existing VPC (conditional data source)
data "ibm_is_vpc" "existing_vpc" {
  count = var.feature_flags.enable_advanced_features ? 1 : 0
  name  = "existing-vpc"
}

# Existing subnets (conditional data source)
data "ibm_is_subnets" "existing_subnets" {
  count = var.feature_flags.enable_advanced_features ? 1 : 0
}

# COS instances for backup (using resource_instance for single instance lookup)
data "ibm_resource_instance" "cos_instance" {
  count             = var.feature_flags.enable_backup ? 1 : 0
  name              = "backup-cos"
  resource_group_id = data.ibm_resource_group.project_rg.id
  service           = "cloud-object-storage"
}

# Monitoring instances (using resource_instance for single instance lookup)
data "ibm_resource_instance" "monitoring_instance" {
  count             = var.feature_flags.enable_monitoring ? 1 : 0
  name              = "monitoring-sysdig"
  resource_group_id = data.ibm_resource_group.project_rg.id
  service           = "sysdig-monitor"
}

# =============================================================================
# FOUNDATION LAYER - VPC AND NETWORKING
# =============================================================================

# Primary VPC - Foundation for all resources
resource "ibm_is_vpc" "main_vpc" {
  name           = local.resource_names.vpc_name
  resource_group = data.ibm_resource_group.project_rg.id
  
  tags = merge(local.common_tags, {
    "tier" = "foundation"
    "component" = "vpc"
  })
}

# Public subnets with implicit VPC dependency
resource "ibm_is_subnet" "public_subnets" {
  count = length(var.infrastructure_configuration.network.subnet_configuration.public_subnets)
  
  name            = "${local.resource_names.subnet_prefix}-public-${count.index + 1}"
  vpc             = ibm_is_vpc.main_vpc.id  # Implicit dependency
  zone            = data.ibm_is_zones.primary_zones.zones[count.index % length(data.ibm_is_zones.primary_zones.zones)]
  ipv4_cidr_block = var.infrastructure_configuration.network.subnet_configuration.public_subnets[count.index]
  
  tags = merge(local.common_tags, {
    "tier" = "public"
    "subnet-type" = "public"
    "zone" = data.ibm_is_zones.primary_zones.zones[count.index % length(data.ibm_is_zones.primary_zones.zones)]
  })
}

# Private subnets with implicit VPC dependency
resource "ibm_is_subnet" "private_subnets" {
  count = length(var.infrastructure_configuration.network.subnet_configuration.private_subnets)
  
  name            = "${local.resource_names.subnet_prefix}-private-${count.index + 1}"
  vpc             = ibm_is_vpc.main_vpc.id  # Implicit dependency
  zone            = data.ibm_is_zones.primary_zones.zones[count.index % length(data.ibm_is_zones.primary_zones.zones)]
  ipv4_cidr_block = var.infrastructure_configuration.network.subnet_configuration.private_subnets[count.index]
  
  tags = merge(local.common_tags, {
    "tier" = "private"
    "subnet-type" = "private"
    "zone" = data.ibm_is_zones.primary_zones.zones[count.index % length(data.ibm_is_zones.primary_zones.zones)]
  })
}

# Database subnets with implicit VPC dependency
resource "ibm_is_subnet" "database_subnets" {
  count = length(var.infrastructure_configuration.network.subnet_configuration.database_subnets)
  
  name            = "${local.resource_names.subnet_prefix}-database-${count.index + 1}"
  vpc             = ibm_is_vpc.main_vpc.id  # Implicit dependency
  zone            = data.ibm_is_zones.primary_zones.zones[count.index % length(data.ibm_is_zones.primary_zones.zones)]
  ipv4_cidr_block = var.infrastructure_configuration.network.subnet_configuration.database_subnets[count.index]
  
  tags = merge(local.common_tags, {
    "tier" = "database"
    "subnet-type" = "database"
    "zone" = data.ibm_is_zones.primary_zones.zones[count.index % length(data.ibm_is_zones.primary_zones.zones)]
  })
}

# Public gateways for NAT functionality
resource "ibm_is_public_gateway" "public_gateways" {
  count = var.infrastructure_configuration.network.enable_nat_gateway ? length(data.ibm_is_zones.primary_zones.zones) : 0
  
  name = "${local.resource_names.vpc_name}-pgw-${count.index + 1}"
  vpc  = ibm_is_vpc.main_vpc.id  # Implicit dependency
  zone = data.ibm_is_zones.primary_zones.zones[count.index]
  
  tags = merge(local.common_tags, {
    "component" = "public-gateway"
    "zone" = data.ibm_is_zones.primary_zones.zones[count.index]
  })
}

# Attach public gateways to private subnets
resource "ibm_is_subnet_public_gateway_attachment" "private_subnet_pgw" {
  count = var.infrastructure_configuration.network.enable_nat_gateway ? length(ibm_is_subnet.private_subnets) : 0
  
  subnet         = ibm_is_subnet.private_subnets[count.index].id  # Implicit dependency
  public_gateway = ibm_is_public_gateway.public_gateways[count.index % length(ibm_is_public_gateway.public_gateways)].id  # Implicit dependency
}

# =============================================================================
# SECURITY GROUPS WITH CROSS-REFERENCES
# =============================================================================

# Web tier security group
resource "ibm_is_security_group" "web_tier_sg" {
  name = "${local.resource_names.sg_prefix}-web-tier"
  vpc  = ibm_is_vpc.main_vpc.id  # Implicit dependency
  
  tags = merge(local.common_tags, {
    "tier" = "web"
    "component" = "security-group"
  })
}

# Application tier security group
resource "ibm_is_security_group" "app_tier_sg" {
  name = "${local.resource_names.sg_prefix}-app-tier"
  vpc  = ibm_is_vpc.main_vpc.id  # Implicit dependency
  
  tags = merge(local.common_tags, {
    "tier" = "application"
    "component" = "security-group"
  })
}

# Database tier security group
resource "ibm_is_security_group" "db_tier_sg" {
  name = "${local.resource_names.sg_prefix}-db-tier"
  vpc  = ibm_is_vpc.main_vpc.id  # Implicit dependency
  
  tags = merge(local.common_tags, {
    "tier" = "database"
    "component" = "security-group"
  })
}

# Load balancer security group
resource "ibm_is_security_group" "lb_sg" {
  name = "${local.resource_names.sg_prefix}-load-balancer"
  vpc  = ibm_is_vpc.main_vpc.id  # Implicit dependency
  
  tags = merge(local.common_tags, {
    "component" = "load-balancer"
    "tier" = "public"
  })
}

# =============================================================================
# SECURITY GROUP RULES WITH CROSS-REFERENCES
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

# Load balancer to web tier (cross-reference)
resource "ibm_is_security_group_rule" "lb_to_web" {
  group     = ibm_is_security_group.lb_sg.id
  direction = "outbound"
  remote    = ibm_is_security_group.web_tier_sg.id  # Cross-reference
  
  tcp {
    port_min = 8080
    port_max = 8080
  }
}

# Web tier from load balancer (cross-reference)
resource "ibm_is_security_group_rule" "web_from_lb" {
  group     = ibm_is_security_group.web_tier_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.lb_sg.id  # Cross-reference
  
  tcp {
    port_min = 8080
    port_max = 8080
  }
}

# Web tier to application tier (cross-reference)
resource "ibm_is_security_group_rule" "web_to_app" {
  group     = ibm_is_security_group.web_tier_sg.id
  direction = "outbound"
  remote    = ibm_is_security_group.app_tier_sg.id  # Cross-reference
  
  tcp {
    port_min = 8081
    port_max = 8081
  }
}

# Application tier from web tier (cross-reference)
resource "ibm_is_security_group_rule" "app_from_web" {
  group     = ibm_is_security_group.app_tier_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.web_tier_sg.id  # Cross-reference
  
  tcp {
    port_min = 8081
    port_max = 8081
  }
}

# Application tier to database (cross-reference)
resource "ibm_is_security_group_rule" "app_to_db" {
  group     = ibm_is_security_group.app_tier_sg.id
  direction = "outbound"
  remote    = ibm_is_security_group.db_tier_sg.id  # Cross-reference
  
  tcp {
    port_min = 5432
    port_max = 5432
  }
}

# Database tier from application tier (cross-reference)
resource "ibm_is_security_group_rule" "db_from_app" {
  group     = ibm_is_security_group.db_tier_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.app_tier_sg.id  # Cross-reference
  
  tcp {
    port_min = 5432
    port_max = 5432
  }
}

# SSH access for management
resource "ibm_is_security_group_rule" "ssh_access" {
  for_each = {
    web = ibm_is_security_group.web_tier_sg.id
    app = ibm_is_security_group.app_tier_sg.id
    db  = ibm_is_security_group.db_tier_sg.id
  }
  
  group     = each.value
  direction = "inbound"
  remote    = "10.0.0.0/8"
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Outbound internet access
resource "ibm_is_security_group_rule" "outbound_internet" {
  for_each = {
    web = ibm_is_security_group.web_tier_sg.id
    app = ibm_is_security_group.app_tier_sg.id
    db  = ibm_is_security_group.db_tier_sg.id
    lb  = ibm_is_security_group.lb_sg.id
  }
  
  group     = each.value
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# =============================================================================
# CONDITIONAL RESOURCES BASED ON DATA SOURCES
# =============================================================================

# Create COS instance if none exists
resource "ibm_resource_instance" "backup_cos" {
  count = var.feature_flags.enable_backup && length(data.ibm_resource_instance.cos_instance) == 0 ? 1 : 0

  name              = "${var.project_configuration.project_name}-backup-cos"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = data.ibm_resource_group.project_rg.id

  tags = merge(local.common_tags, {
    "component" = "backup"
    "service" = "cos"
  })
}

# Create monitoring instance if none exists
resource "ibm_resource_instance" "monitoring" {
  count = var.feature_flags.enable_monitoring && length(data.ibm_resource_instance.monitoring_instance) == 0 ? 1 : 0

  name              = "${var.project_configuration.project_name}-monitoring"
  service           = "sysdig-monitor"
  plan              = local.current_env.monitoring_plan
  location          = var.primary_region
  resource_group_id = data.ibm_resource_group.project_rg.id

  tags = merge(local.common_tags, {
    "component" = "monitoring"
    "service" = "sysdig"
  })
}

# =============================================================================
# DATABASE TIER WITH EXPLICIT DEPENDENCIES
# =============================================================================

# Primary PostgreSQL database
resource "ibm_database" "primary_database" {
  name     = "${local.resource_names.db_prefix}-primary"
  service  = "databases-for-postgresql"
  plan     = local.current_env.database_plan
  location = var.primary_region

  resource_group_id = data.ibm_resource_group.project_rg.id

  # Database configuration
  adminpassword = "TerraformLabPassword123"

  # Network configuration
  service_endpoints = "private"

  # Explicit dependency on network infrastructure
  depends_on = [
    ibm_is_vpc.main_vpc,
    ibm_is_subnet.database_subnets
  ]

  tags = merge(local.common_tags, {
    "component" = "database"
    "tier" = "data"
    "type" = "primary"
  })
}

# Redis cache for session management
resource "ibm_database" "redis_cache" {
  name     = "${local.resource_names.db_prefix}-redis"
  service  = "databases-for-redis"
  plan     = "standard"
  location = var.primary_region

  resource_group_id = data.ibm_resource_group.project_rg.id

  # Redis configuration
  adminpassword = "RedisLabPassword123"

  service_endpoints = "private"

  # Explicit dependency on network infrastructure
  depends_on = [
    ibm_is_vpc.main_vpc,
    ibm_is_subnet.database_subnets
  ]

  tags = merge(local.common_tags, {
    "component" = "cache"
    "tier" = "data"
    "type" = "redis"
  })
}

# Virtual Private Endpoint for database access
resource "ibm_is_virtual_endpoint_gateway" "database_vpe" {
  name = "${var.project_configuration.project_name}-database-vpe"
  vpc  = ibm_is_vpc.main_vpc.id

  target {
    name          = "databases-for-postgresql"
    resource_type = "provider_cloud_service"
  }

  # Attach to database subnets
  dynamic "ips" {
    for_each = ibm_is_subnet.database_subnets
    content {
      subnet = ips.value.id
      name   = "${var.project_configuration.project_name}-vpe-ip-${ips.key + 1}"
    }
  }

  # Explicit dependency on database and network
  depends_on = [
    ibm_database.primary_database,
    ibm_is_subnet.database_subnets
  ]

  tags = merge(local.common_tags, {
    "component" = "vpe"
    "service" = "database"
  })
}

# =============================================================================
# COMPUTE TIER WITH COMPLEX DEPENDENCIES
# =============================================================================

# Web tier instances
resource "ibm_is_instance" "web_servers" {
  count = local.current_env.instance_count

  name    = "${local.resource_names.instance_prefix}-web-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu_latest.id
  profile = var.infrastructure_configuration.compute.instance_types.web_tier.instance_profile

  # Network configuration with implicit dependencies
  vpc  = ibm_is_vpc.main_vpc.id
  zone = data.ibm_is_zones.primary_zones.zones[count.index % length(data.ibm_is_zones.primary_zones.zones)]

  primary_network_interface {
    subnet          = ibm_is_subnet.public_subnets[count.index % length(ibm_is_subnet.public_subnets)].id
    security_groups = [ibm_is_security_group.web_tier_sg.id]
  }

  # SSH key configuration
  keys = length(data.ibm_is_ssh_keys.available_keys.keys) > 0 ? [data.ibm_is_ssh_keys.available_keys.keys[0].id] : []

  # User data with dependency on application servers
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Setting up web server..."
    echo "App server IPs: ${join(",", ibm_is_instance.app_servers[*].primary_network_interface[0].primary_ipv4_address)}"
    echo "Monitoring: ${var.feature_flags.enable_monitoring}"

    # Install nginx
    apt-get update -y
    apt-get install -y nginx

    # Configure nginx for port 8080
    cat > /etc/nginx/sites-available/default << 'EOL'
server {
    listen 8080 default_server;
    location /health {
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    location / {
        proxy_pass http://backend;
    }
}

upstream backend {
    %{ for ip in ibm_is_instance.app_servers[*].primary_network_interface[0].primary_ipv4_address ~}
    server ${ip}:8081;
    %{ endfor ~}
}
EOL

    # Start nginx
    systemctl enable nginx
    systemctl restart nginx

    echo "Web server setup complete"
  EOF
  )

  # Explicit dependency on application servers for configuration
  depends_on = [ibm_is_instance.app_servers]

  tags = merge(local.common_tags, {
    "tier" = "web"
    "instance" = "${count.index + 1}"
  })
}

# Application tier instances
resource "ibm_is_instance" "app_servers" {
  count = var.infrastructure_configuration.compute.instance_types.app_tier.desired_instances

  name    = "${local.resource_names.instance_prefix}-app-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu_latest.id
  profile = var.infrastructure_configuration.compute.instance_types.app_tier.instance_profile

  # Network configuration
  vpc  = ibm_is_vpc.main_vpc.id
  zone = data.ibm_is_zones.primary_zones.zones[count.index % length(data.ibm_is_zones.primary_zones.zones)]

  primary_network_interface {
    subnet          = ibm_is_subnet.private_subnets[count.index % length(ibm_is_subnet.private_subnets)].id
    security_groups = [ibm_is_security_group.app_tier_sg.id]
  }

  keys = length(data.ibm_is_ssh_keys.available_keys.keys) > 0 ? [data.ibm_is_ssh_keys.available_keys.keys[0].id] : []

  # User data with database connection information
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Setting up application server..."
    echo "Database: ${ibm_database.primary_database.name}"
    echo "Redis: ${ibm_database.redis_cache.name}"
    echo "Monitoring: ${var.feature_flags.enable_monitoring}"

    # Install Node.js and dependencies
    apt-get update -y
    apt-get install -y nodejs npm

    # Create application directory
    mkdir -p /opt/app
    cd /opt/app

    # Create simple Node.js app
    cat > server.js << 'EOL'
const express = require('express');
const app = express();
const PORT = 8081;

app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log('App server listening on port ' + PORT);
});
EOL

    # Install express
    npm init -y
    npm install express

    # Start the application
    node server.js &

    echo "Application server setup complete"
  EOF
  )

  # Explicit dependency on database services
  depends_on = [
    ibm_database.primary_database,
    ibm_database.redis_cache
  ]

  tags = merge(local.common_tags, {
    "tier" = "application"
    "instance" = "${count.index + 1}"
  })
}

# =============================================================================
# LOAD BALANCER WITH INSTANCE DEPENDENCIES
# =============================================================================

# Public load balancer for web tier
resource "ibm_is_lb" "web_load_balancer" {
  name    = "${local.resource_names.lb_prefix}-web"
  subnets = ibm_is_subnet.public_subnets[*].id
  type    = "public"

  tags = merge(local.common_tags, {
    "component" = "load-balancer"
    "tier" = "public"
  })
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
}

# Load balancer pool members using instance attributes
resource "ibm_is_lb_pool_member" "web_pool_members" {
  count = length(ibm_is_instance.web_servers)

  lb               = ibm_is_lb.web_load_balancer.id
  pool             = ibm_is_lb_pool.web_pool.id
  port             = 8080
  target_address   = ibm_is_instance.web_servers[count.index].primary_network_interface[0].primary_ipv4_address

  # Implicit dependencies on load balancer, pool, and instances
}

# Load balancer listener
resource "ibm_is_lb_listener" "web_listener" {
  lb           = ibm_is_lb.web_load_balancer.id
  port         = 80
  protocol     = "http"
  default_pool = ibm_is_lb_pool.web_pool.id
}

# Internal load balancer for application tier
resource "ibm_is_lb" "app_internal_lb" {
  name    = "${local.resource_names.lb_prefix}-app-internal"
  subnets = ibm_is_subnet.private_subnets[*].id
  type    = "private"

  tags = merge(local.common_tags, {
    "component" = "internal-lb"
    "tier" = "application"
  })
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

# Application pool members using instance attributes
resource "ibm_is_lb_pool_member" "app_pool_members" {
  count = length(ibm_is_instance.app_servers)

  lb               = ibm_is_lb.app_internal_lb.id
  pool             = ibm_is_lb_pool.app_pool.id
  port             = 8081
  target_address   = ibm_is_instance.app_servers[count.index].primary_network_interface[0].primary_ipv4_address
}

# Application load balancer listener
resource "ibm_is_lb_listener" "app_listener" {
  lb           = ibm_is_lb.app_internal_lb.id
  port         = 8081
  protocol     = "http"
  default_pool = ibm_is_lb_pool.app_pool.id
}
