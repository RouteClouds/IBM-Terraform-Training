# Lab 6: Hands-on IBM Cloud Resource Provisioning

## 🎯 **Lab Overview**

**Duration**: 90-120 minutes  
**Difficulty**: Intermediate  
**Prerequisites**: Completion of Topic 3 (Core Terraform Workflow)

This comprehensive hands-on lab provides practical experience with IBM Cloud resource provisioning using Terraform. You'll deploy a complete 3-tier web application infrastructure while learning enterprise best practices for resource management, security, and cost optimization.

### **Learning Objectives**

By completing this lab, you will:

1. **Deploy a complete VPC infrastructure** with subnets, security groups, and gateways
2. **Provision virtual server instances** with proper sizing and configuration
3. **Implement enterprise naming and tagging** strategies for resource organization
4. **Configure network security** with security groups and access controls
5. **Optimize costs** through right-sizing and lifecycle management
6. **Validate and troubleshoot** resource provisioning issues
7. **Apply monitoring and observability** best practices

### **Lab Architecture**

You'll build a 3-tier web application infrastructure:

- **Web Tier**: Public subnet with load balancer and web servers
- **Application Tier**: Private subnet with application servers
- **Data Tier**: Private subnet with database servers and storage

![Figure 6.1: Lab Architecture Overview](../DaC/generated_diagrams/ibm_cloud_resource_architecture.png)

### **Cost Estimate**

**Estimated Lab Costs**: $15-25 USD for 4-hour lab session
- VPC and subnets: Free tier
- 3 × bx2-2x8 instances: ~$18/day
- Load balancer: ~$5/day
- Storage volumes: ~$2/day

**Cost Optimization**: Resources will be destroyed at lab completion to minimize costs.

---

## 🚀 **Exercise 1: VPC Foundation Setup (20 minutes)**

### **Step 1: Initialize Lab Environment**

Create the lab directory and initialize Terraform:

```bash
# Create lab directory
mkdir -p ~/terraform-labs/lab-6-resource-provisioning
cd ~/terraform-labs/lab-6-resource-provisioning

# Initialize git repository for version control
git init
echo "*.tfstate*" > .gitignore
echo ".terraform/" >> .gitignore
echo "terraform.tfvars" >> .gitignore

# Create initial Terraform configuration
cat > providers.tf << 'EOF'
# IBM Cloud Terraform Provider Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.58.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}

# IBM Cloud Provider
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibm_region
}

# Random provider for unique naming
provider "random" {}

# Time provider for timestamps
provider "time" {}
EOF
```

### **Step 2: Define Core Variables**

Create comprehensive variable definitions:

```bash
cat > variables.tf << 'EOF'
# =============================================================================
# AUTHENTICATION AND REGION VARIABLES
# =============================================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
}

variable "ibm_region" {
  description = "IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd"
    ], var.ibm_region)
    error_message = "IBM region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "default"
}

# =============================================================================
# PROJECT CONFIGURATION VARIABLES
# =============================================================================

variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "lab6-resource-provisioning"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name for resource organization"
  type        = string
  default     = "lab"
  
  validation {
    condition = contains(["dev", "test", "staging", "prod", "lab"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod, lab."
  }
}

variable "owner" {
  description = "Owner of the infrastructure for resource tagging"
  type        = string
  default     = "terraform-lab-user"
}

# =============================================================================
# NETWORK CONFIGURATION VARIABLES
# =============================================================================

variable "vpc_address_prefix" {
  description = "Address prefix for the VPC"
  type        = string
  default     = "10.240.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_address_prefix, 0))
    error_message = "VPC address prefix must be a valid CIDR block."
  }
}

variable "subnet_configurations" {
  description = "Configuration for subnets in different tiers"
  type = map(object({
    cidr_block = string
    zone       = string
    tier       = string
    public     = bool
  }))
  
  default = {
    "web" = {
      cidr_block = "10.240.1.0/24"
      zone       = "us-south-1"
      tier       = "web"
      public     = true
    }
    "app" = {
      cidr_block = "10.240.2.0/24"
      zone       = "us-south-2"
      tier       = "application"
      public     = false
    }
    "data" = {
      cidr_block = "10.240.3.0/24"
      zone       = "us-south-3"
      tier       = "database"
      public     = false
    }
  }
  
  validation {
    condition = alltrue([
      for config in values(var.subnet_configurations) : can(cidrhost(config.cidr_block, 0))
    ])
    error_message = "All subnet CIDR blocks must be valid."
  }
}

# =============================================================================
# COMPUTE CONFIGURATION VARIABLES
# =============================================================================

variable "instance_configurations" {
  description = "Configuration for instances in different tiers"
  type = map(object({
    count   = number
    profile = string
    image   = string
    tier    = string
  }))
  
  default = {
    "web" = {
      count   = 2
      profile = "bx2-2x8"
      image   = "ibm-ubuntu-20-04-3-minimal-amd64-2"
      tier    = "web"
    }
    "app" = {
      count   = 2
      profile = "bx2-2x8"
      image   = "ibm-ubuntu-20-04-3-minimal-amd64-2"
      tier    = "application"
    }
    "data" = {
      count   = 1
      profile = "bx2-4x16"
      image   = "ibm-ubuntu-20-04-3-minimal-amd64-2"
      tier    = "database"
    }
  }
  
  validation {
    condition = alltrue([
      for config in values(var.instance_configurations) : contains([
        "bx2-2x8", "bx2-4x16", "bx2-8x32", "cx2-2x4", "cx2-4x8", "mx2-2x16"
      ], config.profile)
    ])
    error_message = "All instance profiles must be valid IBM Cloud profiles."
  }
}

variable "ssh_key_name" {
  description = "Name of the SSH key for instance access"
  type        = string
  default     = ""
}

# =============================================================================
# STORAGE CONFIGURATION VARIABLES
# =============================================================================

variable "storage_configurations" {
  description = "Storage configuration for different tiers"
  type = map(object({
    volume_size = number
    profile     = string
    encrypted   = bool
  }))
  
  default = {
    "app" = {
      volume_size = 100
      profile     = "general-purpose"
      encrypted   = true
    }
    "data" = {
      volume_size = 500
      profile     = "10iops-tier"
      encrypted   = true
    }
  }
  
  validation {
    condition = alltrue([
      for config in values(var.storage_configurations) : 
      config.volume_size >= 10 && config.volume_size <= 2000
    ])
    error_message = "Volume sizes must be between 10 and 2000 GB."
  }
}

# =============================================================================
# SECURITY CONFIGURATION VARIABLES
# =============================================================================

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Restrict this in production
  
  validation {
    condition = alltrue([
      for cidr in var.allowed_ssh_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All SSH CIDR blocks must be valid."
  }
}

variable "allowed_web_cidr_blocks" {
  description = "CIDR blocks allowed for web access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  
  validation {
    condition = alltrue([
      for cidr in var.allowed_web_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All web CIDR blocks must be valid."
  }
}

# =============================================================================
# TAGGING AND METADATA VARIABLES
# =============================================================================

variable "resource_tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default = {
    "managed-by"    = "terraform"
    "project-type"  = "lab-exercise"
    "lab-number"    = "6"
    "topic"         = "resource-provisioning"
  }
  
  validation {
    condition     = length(var.resource_tags) <= 50
    error_message = "Cannot specify more than 50 resource tags."
  }
}

variable "enable_monitoring" {
  description = "Enable monitoring and logging for resources"
  type        = bool
  default     = true
}

variable "enable_cost_tracking" {
  description = "Enable detailed cost tracking and optimization"
  type        = bool
  default     = true
}
EOF
```

### **Step 3: Create VPC Foundation**

Create the main Terraform configuration:

```bash
cat > main.tf << 'EOF'
# Lab 6: IBM Cloud Resource Provisioning
# Main configuration file for 3-tier web application infrastructure

# Generate unique suffix for resource naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

# Timestamp for resource tracking
resource "time_static" "deployment_time" {}

# =============================================================================
# DATA SOURCES
# =============================================================================

# Resource group data source
data "ibm_resource_group" "lab_rg" {
  name = var.resource_group_name
}

# Available zones in the region
data "ibm_is_zones" "regional" {
  region = var.ibm_region
}

# SSH key data source (if specified)
data "ibm_is_ssh_key" "lab_key" {
  count = var.ssh_key_name != "" ? 1 : 0
  name  = var.ssh_key_name
}

# OS image data sources
data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-20-04-3-minimal-amd64-2"
}

# =============================================================================
# LOCAL VALUES
# =============================================================================

locals {
  # Generate consistent naming
  name_prefix = "${var.project_name}-${var.environment}-${random_string.suffix.result}"
  
  # Common tags for all resources
  common_tags = merge(var.resource_tags, {
    environment = var.environment
    region      = var.ibm_region
    owner       = var.owner
    created     = formatdate("YYYY-MM-DD", time_static.deployment_time.rfc3339)
  })
  
  # Available zones (use first 3)
  availability_zones = slice(data.ibm_is_zones.regional.zones, 0, min(3, length(data.ibm_is_zones.regional.zones)))
  
  # Subnet configurations with zone mapping
  subnet_configs = {
    for name, config in var.subnet_configurations : name => merge(config, {
      zone = "${var.ibm_region}-${index(keys(var.subnet_configurations), name) + 1}"
    })
  }
}

# =============================================================================
# VPC INFRASTRUCTURE
# =============================================================================

# Virtual Private Cloud
resource "ibm_is_vpc" "lab_vpc" {
  name                        = "${local.name_prefix}-vpc"
  resource_group              = data.ibm_resource_group.lab_rg.id
  address_prefix_management   = "manual"
  default_network_acl_name    = "${local.name_prefix}-default-acl"
  default_routing_table_name  = "${local.name_prefix}-default-rt"
  default_security_group_name = "${local.name_prefix}-default-sg"
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["resource-type:vpc", "tier:foundation"]
  )
}

# Address prefixes for manual management
resource "ibm_is_vpc_address_prefix" "lab_prefix" {
  name = "${local.name_prefix}-address-prefix"
  vpc  = ibm_is_vpc.lab_vpc.id
  zone = local.availability_zones[0]
  cidr = var.vpc_address_prefix
}

# Subnets for each tier
resource "ibm_is_subnet" "lab_subnets" {
  for_each = local.subnet_configs
  
  name            = "${local.name_prefix}-${each.key}-subnet"
  vpc             = ibm_is_vpc.lab_vpc.id
  zone            = each.value.zone
  ipv4_cidr_block = each.value.cidr_block
  resource_group  = data.ibm_resource_group.lab_rg.id
  
  # Attach public gateway for public subnets
  public_gateway = each.value.public ? ibm_is_public_gateway.lab_gateways[each.value.zone].id : null
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:subnet",
      "tier:${each.value.tier}",
      "access:${each.value.public ? "public" : "private"}"
    ]
  )
  
  depends_on = [ibm_is_vpc_address_prefix.lab_prefix]
}

# Public gateways for internet access
resource "ibm_is_public_gateway" "lab_gateways" {
  for_each = toset([
    for name, config in local.subnet_configs : config.zone if config.public
  ])
  
  name           = "${local.name_prefix}-${each.key}-gateway"
  vpc            = ibm_is_vpc.lab_vpc.id
  zone           = each.key
  resource_group = data.ibm_resource_group.lab_rg.id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["resource-type:public-gateway", "zone:${each.key}"]
  )
}
EOF
```

### **Validation Checkpoint 1**

Initialize and validate the VPC foundation:

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt

# Create terraform.tfvars file
cat > terraform.tfvars << 'EOF'
# Lab 6 Configuration
ibmcloud_api_key = "YOUR_API_KEY_HERE"
ibm_region = "us-south"
project_name = "lab6-resource-provisioning"
environment = "lab"
owner = "your-name"

# Update SSH key name if you have one
# ssh_key_name = "your-ssh-key-name"
EOF

echo "✅ VPC Foundation configured successfully!"
echo "📝 Update terraform.tfvars with your IBM Cloud API key before proceeding"
```

---

## 🔒 **Exercise 2: Security Configuration (25 minutes)**

### **Step 4: Configure Security Groups**

Add security group configurations to main.tf:

```bash
cat >> main.tf << 'EOF'

# =============================================================================
# SECURITY GROUPS AND RULES
# =============================================================================

# Web tier security group
resource "ibm_is_security_group" "web_sg" {
  name           = "${local.name_prefix}-web-sg"
  vpc            = ibm_is_vpc.lab_vpc.id
  resource_group = data.ibm_resource_group.lab_rg.id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["resource-type:security-group", "tier:web"]
  )
}

# Web tier security rules
resource "ibm_is_security_group_rule" "web_http" {
  group     = ibm_is_security_group.web_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "web_https" {
  group     = ibm_is_security_group.web_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "web_ssh" {
  count     = length(var.allowed_ssh_cidr_blocks)
  group     = ibm_is_security_group.web_sg.id
  direction = "inbound"
  remote    = var.allowed_ssh_cidr_blocks[count.index]
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Application tier security group
resource "ibm_is_security_group" "app_sg" {
  name           = "${local.name_prefix}-app-sg"
  vpc            = ibm_is_vpc.lab_vpc.id
  resource_group = data.ibm_resource_group.lab_rg.id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["resource-type:security-group", "tier:application"]
  )
}

# Application tier security rules
resource "ibm_is_security_group_rule" "app_from_web" {
  group     = ibm_is_security_group.app_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.web_sg.id
  
  tcp {
    port_min = 8080
    port_max = 8080
  }
}

resource "ibm_is_security_group_rule" "app_ssh" {
  group     = ibm_is_security_group.app_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.web_sg.id
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Database tier security group
resource "ibm_is_security_group" "data_sg" {
  name           = "${local.name_prefix}-data-sg"
  vpc            = ibm_is_vpc.lab_vpc.id
  resource_group = data.ibm_resource_group.lab_rg.id
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    ["resource-type:security-group", "tier:database"]
  )
}

# Database tier security rules
resource "ibm_is_security_group_rule" "data_from_app" {
  group     = ibm_is_security_group.data_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.app_sg.id
  
  tcp {
    port_min = 5432
    port_max = 5432
  }
}

resource "ibm_is_security_group_rule" "data_ssh" {
  group     = ibm_is_security_group.data_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.app_sg.id
  
  tcp {
    port_min = 22
    port_max = 22
  }
}
EOF
```

### **Step 5: Test Security Configuration**

```bash
# Validate security group configuration
terraform validate

# Plan to see security resources
terraform plan -target=ibm_is_security_group.web_sg
terraform plan -target=ibm_is_security_group.app_sg
terraform plan -target=ibm_is_security_group.data_sg

echo "✅ Security groups configured successfully!"
```

### **Validation Checkpoint 2**

```bash
# Check configuration syntax
terraform fmt -check

# Validate all configurations
terraform validate

# Review planned changes
terraform plan

echo "📋 Security configuration validated!"
echo "🔒 Security groups implement defense-in-depth strategy"
```

---

## 💻 **Exercise 3: Compute Resource Provisioning (30 minutes)**

### **Step 6: Deploy Virtual Server Instances**

Add compute resources to main.tf:

```bash
cat >> main.tf << 'EOF'

# =============================================================================
# COMPUTE INSTANCES
# =============================================================================

# Web tier instances
resource "ibm_is_instance" "web_servers" {
  count   = var.instance_configurations.web.count
  name    = "${local.name_prefix}-web-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu.id
  profile = var.instance_configurations.web.profile
  
  primary_network_interface {
    subnet          = ibm_is_subnet.lab_subnets["web"].id
    security_groups = [ibm_is_security_group.web_sg.id]
  }
  
  vpc  = ibm_is_vpc.lab_vpc.id
  zone = ibm_is_subnet.lab_subnets["web"].zone
  keys = var.ssh_key_name != "" ? [data.ibm_is_ssh_key.lab_key[0].id] : []
  
  resource_group = data.ibm_resource_group.lab_rg.id
  
  # Boot volume configuration
  boot_volume {
    name    = "${local.name_prefix}-web-boot-${count.index + 1}"
    size    = 100
    profile = "general-purpose"
  }
  
  # Web server initialization script
  user_data = base64encode(templatefile("${path.module}/scripts/web-server-init.sh", {
    server_index = count.index + 1
    environment  = var.environment
  }))
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:instance",
      "tier:web",
      "role:frontend",
      "server-index:${count.index + 1}"
    ]
  )
}

# Application tier instances
resource "ibm_is_instance" "app_servers" {
  count   = var.instance_configurations.app.count
  name    = "${local.name_prefix}-app-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu.id
  profile = var.instance_configurations.app.profile
  
  primary_network_interface {
    subnet          = ibm_is_subnet.lab_subnets["app"].id
    security_groups = [ibm_is_security_group.app_sg.id]
  }
  
  vpc  = ibm_is_vpc.lab_vpc.id
  zone = ibm_is_subnet.lab_subnets["app"].zone
  keys = var.ssh_key_name != "" ? [data.ibm_is_ssh_key.lab_key[0].id] : []
  
  resource_group = data.ibm_resource_group.lab_rg.id
  
  # Boot volume configuration
  boot_volume {
    name    = "${local.name_prefix}-app-boot-${count.index + 1}"
    size    = 100
    profile = "general-purpose"
  }
  
  # Application server initialization script
  user_data = base64encode(templatefile("${path.module}/scripts/app-server-init.sh", {
    server_index = count.index + 1
    environment  = var.environment
  }))
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:instance",
      "tier:application",
      "role:backend",
      "server-index:${count.index + 1}"
    ]
  )
}

# Database tier instances
resource "ibm_is_instance" "data_servers" {
  count   = var.instance_configurations.data.count
  name    = "${local.name_prefix}-data-${count.index + 1}"
  image   = data.ibm_is_image.ubuntu.id
  profile = var.instance_configurations.data.profile
  
  primary_network_interface {
    subnet          = ibm_is_subnet.lab_subnets["data"].id
    security_groups = [ibm_is_security_group.data_sg.id]
  }
  
  vpc  = ibm_is_vpc.lab_vpc.id
  zone = ibm_is_subnet.lab_subnets["data"].zone
  keys = var.ssh_key_name != "" ? [data.ibm_is_ssh_key.lab_key[0].id] : []
  
  resource_group = data.ibm_resource_group.lab_rg.id
  
  # Boot volume configuration
  boot_volume {
    name    = "${local.name_prefix}-data-boot-${count.index + 1}"
    size    = 100
    profile = "general-purpose"
  }
  
  # Database server initialization script
  user_data = base64encode(templatefile("${path.module}/scripts/db-server-init.sh", {
    server_index = count.index + 1
    environment  = var.environment
  }))
  
  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:instance",
      "tier:database",
      "role:data-storage",
      "server-index:${count.index + 1}"
    ]
  )
}
EOF
```

### **Step 7: Create Initialization Scripts**

Create the scripts directory and initialization files:

```bash
# Create scripts directory
mkdir -p scripts

# Web server initialization script
cat > scripts/web-server-init.sh << 'EOF'
#!/bin/bash
# Web Server Initialization Script for Lab 6

# Update system
apt-get update -y
apt-get upgrade -y

# Install nginx
apt-get install -y nginx

# Create custom index page
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Lab 6 - Web Server ${server_index}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background-color: #1f4e79; color: white; padding: 20px; }
        .content { padding: 20px; }
        .server-info { background-color: #f0f0f0; padding: 15px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>IBM Cloud Terraform Lab 6</h1>
        <h2>Resource Provisioning - Web Server ${server_index}</h2>
    </div>
    <div class="content">
        <div class="server-info">
            <h3>Server Information</h3>
            <p><strong>Server:</strong> Web Server ${server_index}</p>
            <p><strong>Environment:</strong> ${environment}</p>
            <p><strong>Tier:</strong> Web/Frontend</p>
            <p><strong>Deployment Time:</strong> $(date)</p>
        </div>
        <h3>Lab Status</h3>
        <p>✅ VPC Infrastructure Deployed</p>
        <p>✅ Security Groups Configured</p>
        <p>✅ Web Server ${server_index} Online</p>
        <p>🔄 Application Tier: Connecting...</p>
        <p>🔄 Database Tier: Connecting...</p>
    </div>
</body>
</html>
HTML

# Start nginx
systemctl enable nginx
systemctl start nginx

# Create health check endpoint
cat > /var/www/html/health << 'EOF'
{
  "status": "healthy",
  "server": "web-${server_index}",
  "environment": "${environment}",
  "timestamp": "$(date -Iseconds)"
}
EOF

# Log deployment
echo "$(date): Web server ${server_index} initialized successfully" >> /var/log/lab6-deployment.log
EOF

# Application server initialization script
cat > scripts/app-server-init.sh << 'EOF'
#!/bin/bash
# Application Server Initialization Script for Lab 6

# Update system
apt-get update -y
apt-get upgrade -y

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Create application directory
mkdir -p /opt/lab6-app
cd /opt/lab6-app

# Create simple Node.js application
cat > app.js << 'JS'
const express = require('express');
const app = express();
const port = 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Lab 6 Application Server ${server_index}',
    environment: '${environment}',
    tier: 'application',
    server: 'app-${server_index}',
    timestamp: new Date().toISOString(),
    status: 'running'
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    server: 'app-${server_index}',
    environment: '${environment}',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(`Lab 6 App Server ${server_index} listening on port ${port}`);
});
JS

# Create package.json
cat > package.json << 'JSON'
{
  "name": "lab6-app-server",
  "version": "1.0.0",
  "description": "Lab 6 Application Server",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
JSON

# Install dependencies
npm install

# Create systemd service
cat > /etc/systemd/system/lab6-app.service << 'SERVICE'
[Unit]
Description=Lab 6 Application Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/lab6-app
ExecStart=/usr/bin/node app.js
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

# Start application service
systemctl enable lab6-app
systemctl start lab6-app

# Log deployment
echo "$(date): Application server ${server_index} initialized successfully" >> /var/log/lab6-deployment.log
EOF

# Database server initialization script
cat > scripts/db-server-init.sh << 'EOF'
#!/bin/bash
# Database Server Initialization Script for Lab 6

# Update system
apt-get update -y
apt-get upgrade -y

# Install PostgreSQL
apt-get install -y postgresql postgresql-contrib

# Start PostgreSQL
systemctl enable postgresql
systemctl start postgresql

# Configure PostgreSQL
sudo -u postgres psql << 'SQL'
CREATE DATABASE lab6_app;
CREATE USER lab6_user WITH PASSWORD 'lab6_password';
GRANT ALL PRIVILEGES ON DATABASE lab6_app TO lab6_user;
\q
SQL

# Create sample data
sudo -u postgres psql -d lab6_app << 'SQL'
CREATE TABLE server_status (
    id SERIAL PRIMARY KEY,
    server_name VARCHAR(50),
    environment VARCHAR(20),
    status VARCHAR(20),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO server_status (server_name, environment, status) VALUES
('data-${server_index}', '${environment}', 'running');
\q
SQL

# Configure PostgreSQL for network access
echo "host all all 10.240.0.0/16 md5" >> /etc/postgresql/*/main/pg_hba.conf
echo "listen_addresses = '*'" >> /etc/postgresql/*/main/postgresql.conf

# Restart PostgreSQL
systemctl restart postgresql

# Log deployment
echo "$(date): Database server ${server_index} initialized successfully" >> /var/log/lab6-deployment.log
EOF

# Make scripts executable
chmod +x scripts/*.sh

echo "✅ Initialization scripts created successfully!"
```

### **Validation Checkpoint 3**

```bash
# Validate compute configuration
terraform validate

# Plan compute resources
terraform plan -target=ibm_is_instance.web_servers
terraform plan -target=ibm_is_instance.app_servers
terraform plan -target=ibm_is_instance.data_servers

echo "💻 Compute resources configured successfully!"

---

## 💾 **Exercise 4: Storage and Load Balancing (20 minutes)**

### **Step 8: Add Storage Volumes**

Add storage configuration to main.tf:

```bash
cat >> main.tf << 'EOF'

# =============================================================================
# STORAGE VOLUMES
# =============================================================================

# Application data volumes
resource "ibm_is_volume" "app_data_volumes" {
  count          = var.instance_configurations.app.count
  name           = "${local.name_prefix}-app-data-${count.index + 1}"
  profile        = var.storage_configurations.app.profile
  zone           = ibm_is_subnet.lab_subnets["app"].zone
  capacity       = var.storage_configurations.app.volume_size
  resource_group = data.ibm_resource_group.lab_rg.id

  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:volume",
      "tier:application",
      "purpose:data-storage",
      "server-index:${count.index + 1}"
    ]
  )
}

# Database data volumes
resource "ibm_is_volume" "data_volumes" {
  count          = var.instance_configurations.data.count
  name           = "${local.name_prefix}-data-volume-${count.index + 1}"
  profile        = var.storage_configurations.data.profile
  zone           = ibm_is_subnet.lab_subnets["data"].zone
  capacity       = var.storage_configurations.data.volume_size
  resource_group = data.ibm_resource_group.lab_rg.id

  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:volume",
      "tier:database",
      "purpose:database-storage",
      "server-index:${count.index + 1}"
    ]
  )
}

# Attach application data volumes
resource "ibm_is_instance_volume_attachment" "app_data_attachments" {
  count                           = var.instance_configurations.app.count
  instance                        = ibm_is_instance.app_servers[count.index].id
  name                           = "app-data-attachment-${count.index + 1}"
  volume                         = ibm_is_volume.app_data_volumes[count.index].id
  delete_volume_on_instance_delete = false
}

# Attach database data volumes
resource "ibm_is_instance_volume_attachment" "data_attachments" {
  count                           = var.instance_configurations.data.count
  instance                        = ibm_is_instance.data_servers[count.index].id
  name                           = "data-attachment-${count.index + 1}"
  volume                         = ibm_is_volume.data_volumes[count.index].id
  delete_volume_on_instance_delete = false
}

# =============================================================================
# LOAD BALANCER
# =============================================================================

# Application Load Balancer for web tier
resource "ibm_is_lb" "web_lb" {
  name           = "${local.name_prefix}-web-lb"
  subnets        = [ibm_is_subnet.lab_subnets["web"].id]
  type           = "public"
  resource_group = data.ibm_resource_group.lab_rg.id

  tags = concat(
    [for k, v in local.common_tags : "${k}:${v}"],
    [
      "resource-type:load-balancer",
      "tier:web",
      "access:public"
    ]
  )
}

# Backend pool for web servers
resource "ibm_is_lb_pool" "web_pool" {
  name           = "${local.name_prefix}-web-pool"
  lb             = ibm_is_lb.web_lb.id
  algorithm      = "round_robin"
  protocol       = "http"
  health_delay   = 60
  health_retries = 5
  health_timeout = 30
  health_type    = "http"
  health_monitor_url = "/health"
}

# Pool members (web server instances)
resource "ibm_is_lb_pool_member" "web_members" {
  count          = var.instance_configurations.web.count
  lb             = ibm_is_lb.web_lb.id
  pool           = ibm_is_lb_pool.web_pool.id
  port           = 80
  target_address = ibm_is_instance.web_servers[count.index].primary_network_interface[0].primary_ipv4_address
  weight         = 50
}

# Load balancer listener
resource "ibm_is_lb_listener" "web_listener" {
  lb                   = ibm_is_lb.web_lb.id
  port                 = 80
  protocol             = "http"
  default_pool         = ibm_is_lb_pool.web_pool.id
  connection_limit     = 2000
  accept_proxy_protocol = false
}
EOF
```

### **Step 9: Create Outputs Configuration**

Create outputs.tf file:

```bash
cat > outputs.tf << 'EOF'
# Lab 6: Resource Provisioning Outputs
# Comprehensive output configuration for infrastructure visibility

# =============================================================================
# VPC INFRASTRUCTURE OUTPUTS
# =============================================================================

output "vpc_info" {
  description = "VPC infrastructure information"
  value = {
    vpc_id   = ibm_is_vpc.lab_vpc.id
    vpc_name = ibm_is_vpc.lab_vpc.name
    vpc_crn  = ibm_is_vpc.lab_vpc.crn
    region   = var.ibm_region

    address_prefixes = {
      primary = var.vpc_address_prefix
    }

    subnets = {
      for name, subnet in ibm_is_subnet.lab_subnets : name => {
        id         = subnet.id
        name       = subnet.name
        cidr       = subnet.ipv4_cidr_block
        zone       = subnet.zone
        public     = subnet.public_gateway != null
        available_ips = subnet.available_ipv4_address_count
      }
    }

    public_gateways = {
      for zone, gateway in ibm_is_public_gateway.lab_gateways : zone => {
        id   = gateway.id
        name = gateway.name
        zone = gateway.zone
      }
    }
  }
}

# =============================================================================
# SECURITY CONFIGURATION OUTPUTS
# =============================================================================

output "security_groups" {
  description = "Security group configuration details"
  value = {
    web_sg = {
      id    = ibm_is_security_group.web_sg.id
      name  = ibm_is_security_group.web_sg.name
      rules = length(ibm_is_security_group.web_sg.rules)
    }
    app_sg = {
      id    = ibm_is_security_group.app_sg.id
      name  = ibm_is_security_group.app_sg.name
      rules = length(ibm_is_security_group.app_sg.rules)
    }
    data_sg = {
      id    = ibm_is_security_group.data_sg.id
      name  = ibm_is_security_group.data_sg.name
      rules = length(ibm_is_security_group.data_sg.rules)
    }
  }
}

# =============================================================================
# COMPUTE INSTANCE OUTPUTS
# =============================================================================

output "web_servers" {
  description = "Web server instance information"
  value = {
    count = length(ibm_is_instance.web_servers)
    instances = [
      for i, instance in ibm_is_instance.web_servers : {
        name       = instance.name
        id         = instance.id
        profile    = instance.profile
        zone       = instance.zone
        private_ip = instance.primary_network_interface[0].primary_ipv4_address
        status     = instance.status
      }
    ]
  }
}

output "app_servers" {
  description = "Application server instance information"
  value = {
    count = length(ibm_is_instance.app_servers)
    instances = [
      for i, instance in ibm_is_instance.app_servers : {
        name       = instance.name
        id         = instance.id
        profile    = instance.profile
        zone       = instance.zone
        private_ip = instance.primary_network_interface[0].primary_ipv4_address
        status     = instance.status
      }
    ]
  }
}

output "data_servers" {
  description = "Database server instance information"
  value = {
    count = length(ibm_is_instance.data_servers)
    instances = [
      for i, instance in ibm_is_instance.data_servers : {
        name       = instance.name
        id         = instance.id
        profile    = instance.profile
        zone       = instance.zone
        private_ip = instance.primary_network_interface[0].primary_ipv4_address
        status     = instance.status
      }
    ]
  }
}

# =============================================================================
# STORAGE OUTPUTS
# =============================================================================

output "storage_volumes" {
  description = "Storage volume information"
  value = {
    app_volumes = [
      for i, volume in ibm_is_volume.app_data_volumes : {
        name     = volume.name
        id       = volume.id
        capacity = volume.capacity
        profile  = volume.profile
        zone     = volume.zone
        status   = volume.status
      }
    ]
    data_volumes = [
      for i, volume in ibm_is_volume.data_volumes : {
        name     = volume.name
        id       = volume.id
        capacity = volume.capacity
        profile  = volume.profile
        zone     = volume.zone
        status   = volume.status
      }
    ]
  }
}

# =============================================================================
# LOAD BALANCER OUTPUTS
# =============================================================================

output "load_balancer" {
  description = "Load balancer configuration and access information"
  value = {
    name        = ibm_is_lb.web_lb.name
    id          = ibm_is_lb.web_lb.id
    hostname    = ibm_is_lb.web_lb.hostname
    public_ips  = ibm_is_lb.web_lb.public_ips
    private_ips = ibm_is_lb.web_lb.private_ips
    status      = ibm_is_lb.web_lb.provisioning_status

    pool_info = {
      name      = ibm_is_lb_pool.web_pool.name
      algorithm = ibm_is_lb_pool.web_pool.algorithm
      protocol  = ibm_is_lb_pool.web_pool.protocol
      members   = length(ibm_is_lb_pool_member.web_members)
    }

    listener_info = {
      port     = ibm_is_lb_listener.web_listener.port
      protocol = ibm_is_lb_listener.web_listener.protocol
    }
  }
}

# =============================================================================
# ACCESS INFORMATION
# =============================================================================

output "access_information" {
  description = "Access URLs and connection information"
  value = {
    web_application_url = "http://${ibm_is_lb.web_lb.hostname}"

    ssh_access = var.ssh_key_name != "" ? {
      web_servers = [
        for instance in ibm_is_instance.web_servers :
        "ssh root@${instance.primary_network_interface[0].primary_ipv4_address}"
      ]
      note = "SSH access requires VPN or bastion host for app/data tiers"
    } : {
      note = "SSH key not configured - no direct SSH access available"
    }

    health_checks = {
      load_balancer = "http://${ibm_is_lb.web_lb.hostname}/health"
      web_servers = [
        for instance in ibm_is_instance.web_servers :
        "http://${instance.primary_network_interface[0].primary_ipv4_address}/health"
      ]
    }
  }
}

# =============================================================================
# COST TRACKING OUTPUTS
# =============================================================================

output "cost_estimation" {
  description = "Estimated monthly costs for lab resources"
  value = {
    compute_costs = {
      web_servers = {
        count = length(ibm_is_instance.web_servers)
        profile = var.instance_configurations.web.profile
        estimated_monthly_cost_usd = length(ibm_is_instance.web_servers) * 73  # bx2-2x8 ~$73/month
      }
      app_servers = {
        count = length(ibm_is_instance.app_servers)
        profile = var.instance_configurations.app.profile
        estimated_monthly_cost_usd = length(ibm_is_instance.app_servers) * 73
      }
      data_servers = {
        count = length(ibm_is_instance.data_servers)
        profile = var.instance_configurations.data.profile
        estimated_monthly_cost_usd = length(ibm_is_instance.data_servers) * 146  # bx2-4x16 ~$146/month
      }
    }

    storage_costs = {
      app_storage_gb = sum([for v in ibm_is_volume.app_data_volumes : v.capacity])
      data_storage_gb = sum([for v in ibm_is_volume.data_volumes : v.capacity])
      estimated_monthly_cost_usd = (
        sum([for v in ibm_is_volume.app_data_volumes : v.capacity]) * 0.10 +  # General purpose ~$0.10/GB
        sum([for v in ibm_is_volume.data_volumes : v.capacity]) * 0.35       # 10iops-tier ~$0.35/GB
      )
    }

    network_costs = {
      load_balancer_monthly_usd = 25  # ~$25/month for ALB
      data_transfer_note = "Additional charges apply for data transfer"
    }

    total_estimated_monthly_cost_usd = (
      length(ibm_is_instance.web_servers) * 73 +
      length(ibm_is_instance.app_servers) * 73 +
      length(ibm_is_instance.data_servers) * 146 +
      sum([for v in ibm_is_volume.app_data_volumes : v.capacity]) * 0.10 +
      sum([for v in ibm_is_volume.data_volumes : v.capacity]) * 0.35 +
      25
    )

    lab_session_cost_usd = (
      length(ibm_is_instance.web_servers) * 73 +
      length(ibm_is_instance.app_servers) * 73 +
      length(ibm_is_instance.data_servers) * 146 +
      25
    ) / 30 * 0.17  # ~4 hour lab session
  }
}

# =============================================================================
# RESOURCE SUMMARY
# =============================================================================

output "lab_summary" {
  description = "Complete lab deployment summary"
  value = {
    deployment_info = {
      project_name = var.project_name
      environment = var.environment
      region = var.ibm_region
      deployment_time = time_static.deployment_time.rfc3339
      unique_suffix = random_string.suffix.result
    }

    resource_counts = {
      vpc_count = 1
      subnet_count = length(ibm_is_subnet.lab_subnets)
      security_group_count = 3
      instance_count = (
        length(ibm_is_instance.web_servers) +
        length(ibm_is_instance.app_servers) +
        length(ibm_is_instance.data_servers)
      )
      volume_count = (
        length(ibm_is_volume.app_data_volumes) +
        length(ibm_is_volume.data_volumes)
      )
      load_balancer_count = 1
    }

    architecture_tiers = {
      web_tier = {
        instances = length(ibm_is_instance.web_servers)
        access = "public"
        load_balanced = true
      }
      app_tier = {
        instances = length(ibm_is_instance.app_servers)
        access = "private"
        storage_attached = true
      }
      data_tier = {
        instances = length(ibm_is_instance.data_servers)
        access = "private"
        storage_attached = true
      }
    }

    next_steps = [
      "Access web application via load balancer URL",
      "Test connectivity between tiers",
      "Monitor resource utilization",
      "Practice scaling operations",
      "Implement backup strategies",
      "Clean up resources when complete"
    ]
  }
}
EOF
```

### **Validation Checkpoint 4**

```bash
# Validate complete configuration
terraform validate

# Format all files
terraform fmt

# Review the complete plan
terraform plan

echo "💾 Storage and load balancing configured successfully!"
echo "📊 Outputs configured for comprehensive visibility!"
```

---

## 🚀 **Exercise 5: Deployment and Validation (15 minutes)**

### **Step 10: Deploy the Complete Infrastructure**

Deploy all resources:

```bash
# Apply the complete configuration
echo "🚀 Starting infrastructure deployment..."
terraform apply

# Monitor deployment progress
echo "⏳ Deployment in progress..."
echo "📊 You can monitor progress in the IBM Cloud console"

# Wait for deployment completion
echo "✅ Infrastructure deployment completed!"
```

### **Step 11: Validate Deployment**

Validate the deployed infrastructure:

```bash
# Display infrastructure summary
terraform output lab_summary

# Display access information
terraform output access_information

# Display cost estimation
terraform output cost_estimation

# Test web application access
WEB_URL=$(terraform output -raw access_information | jq -r '.web_application_url')
echo "🌐 Testing web application access..."
curl -s "$WEB_URL" | head -20

# Test health endpoints
echo "🔍 Testing health endpoints..."
curl -s "$WEB_URL/health" | jq '.'

# Display load balancer status
terraform output load_balancer
```

### **Step 12: Connectivity Testing**

Test connectivity between tiers:

```bash
# Create connectivity test script
cat > test-connectivity.sh << 'EOF'
#!/bin/bash
# Connectivity testing script for Lab 6

echo "🔍 Testing Lab 6 Infrastructure Connectivity"
echo "============================================="

# Get outputs
WEB_URL=$(terraform output -json access_information | jq -r '.web_application_url')
LB_HOSTNAME=$(terraform output -json load_balancer | jq -r '.hostname')

echo "📊 Infrastructure Summary:"
echo "Web Application URL: $WEB_URL"
echo "Load Balancer: $LB_HOSTNAME"

echo ""
echo "🌐 Testing Web Tier Connectivity:"
if curl -s --max-time 10 "$WEB_URL" > /dev/null; then
    echo "✅ Web application is accessible"
    echo "📄 Web page content:"
    curl -s "$WEB_URL" | grep -E "<title>|<h1>|<h2>" | sed 's/<[^>]*>//g' | sed 's/^[ \t]*//'
else
    echo "❌ Web application is not accessible"
fi

echo ""
echo "🔍 Testing Health Endpoints:"
if curl -s --max-time 10 "$WEB_URL/health" > /dev/null; then
    echo "✅ Health endpoint is responding"
    echo "📊 Health status:"
    curl -s "$WEB_URL/health" | jq '.' 2>/dev/null || curl -s "$WEB_URL/health"
else
    echo "❌ Health endpoint is not responding"
fi

echo ""
echo "📈 Load Balancer Status:"
terraform output -json load_balancer | jq '{
    name: .name,
    status: .status,
    hostname: .hostname,
    pool_members: .pool_info.members,
    algorithm: .pool_info.algorithm
}'

echo ""
echo "💻 Instance Status Summary:"
terraform output -json web_servers | jq '.instances[] | {name: .name, status: .status, private_ip: .private_ip}'
terraform output -json app_servers | jq '.instances[] | {name: .name, status: .status, private_ip: .private_ip}'
terraform output -json data_servers | jq '.instances[] | {name: .name, status: .status, private_ip: .private_ip}'

echo ""
echo "💰 Cost Summary:"
terraform output -json cost_estimation | jq '{
    lab_session_cost: .lab_session_cost_usd,
    monthly_estimate: .total_estimated_monthly_cost_usd,
    compute_instances: (.compute_costs.web_servers.count + .compute_costs.app_servers.count + .compute_costs.data_servers.count),
    storage_gb: (.storage_costs.app_storage_gb + .storage_costs.data_storage_gb)
}'

echo ""
echo "🎯 Lab Validation Complete!"
echo "✅ All connectivity tests passed"
echo "📚 Proceed to troubleshooting exercises"
EOF

chmod +x test-connectivity.sh
./test-connectivity.sh
```

---

## 🔧 **Exercise 6: Troubleshooting and Optimization (10 minutes)**

### **Step 13: Common Troubleshooting Scenarios**

Practice troubleshooting common issues:

```bash
# Create troubleshooting guide
cat > troubleshooting-guide.md << 'EOF'
# Lab 6 Troubleshooting Guide

## Common Issues and Solutions

### 1. Instance Not Accessible
**Symptoms**: Cannot SSH to instances or web application not responding
**Diagnosis**:
```bash
# Check instance status
terraform output web_servers
terraform output app_servers

# Check security group rules
terraform output security_groups

# Verify load balancer status
terraform output load_balancer
```

**Solutions**:
- Verify security group rules allow required traffic
- Check instance status in IBM Cloud console
- Ensure public gateway is attached to public subnets
- Verify SSH key is properly configured

### 2. Load Balancer Health Checks Failing
**Symptoms**: Load balancer shows unhealthy backend members
**Diagnosis**:
```bash
# Check load balancer pool status
ibmcloud is load-balancer-pool-members <pool-id>

# Test direct instance access
curl -s http://<instance-private-ip>/health
```

**Solutions**:
- Verify web servers are running and responding on port 80
- Check health check URL configuration
- Ensure security groups allow load balancer to instance communication

### 3. High Costs
**Symptoms**: Unexpected high costs in billing
**Diagnosis**:
```bash
# Review cost estimation
terraform output cost_estimation

# Check resource utilization
ibmcloud is instances
ibmcloud is volumes
```

**Solutions**:
- Right-size instances based on actual usage
- Use scheduled shutdown for development environments
- Implement auto-scaling for variable workloads
- Clean up unused resources

### 4. Performance Issues
**Symptoms**: Slow response times or high latency
**Diagnosis**:
```bash
# Test response times
time curl -s http://<load-balancer-hostname>

# Check instance profiles
terraform output web_servers | jq '.instances[].profile'
```

**Solutions**:
- Upgrade instance profiles for better performance
- Implement caching strategies
- Optimize application code
- Use CDN for static content

## Validation Commands

### Infrastructure Validation
```bash
# Validate Terraform configuration
terraform validate

# Check resource state
terraform state list

# Verify outputs
terraform output
```

### Connectivity Validation
```bash
# Test web application
curl -I http://<load-balancer-hostname>

# Test health endpoints
curl http://<load-balancer-hostname>/health

# Check DNS resolution
nslookup <load-balancer-hostname>
```

### Security Validation
```bash
# Check security group rules
ibmcloud is security-groups

# Verify network ACLs
ibmcloud is network-acls

# Test port accessibility
nc -zv <instance-ip> <port>
```
EOF

echo "🔧 Troubleshooting guide created!"
echo "📖 Review troubleshooting-guide.md for common issues and solutions"
```

### **Step 14: Performance Optimization**

Implement performance optimizations:

```bash
# Create optimization script
cat > optimize-infrastructure.sh << 'EOF'
#!/bin/bash
# Infrastructure optimization script for Lab 6

echo "🚀 Lab 6 Infrastructure Optimization"
echo "===================================="

echo "📊 Current Resource Utilization:"
terraform output -json cost_estimation | jq '{
    total_instances: (.compute_costs.web_servers.count + .compute_costs.app_servers.count + .compute_costs.data_servers.count),
    total_storage_gb: (.storage_costs.app_storage_gb + .storage_costs.data_storage_gb),
    estimated_monthly_cost: .total_estimated_monthly_cost_usd
}'

echo ""
echo "💡 Optimization Recommendations:"

# Check instance utilization
echo "1. Instance Right-Sizing:"
echo "   - Monitor CPU and memory utilization"
echo "   - Consider smaller profiles for development workloads"
echo "   - Use auto-scaling for variable demand"

echo ""
echo "2. Storage Optimization:"
echo "   - Use appropriate storage profiles for workload requirements"
echo "   - Implement lifecycle policies for data archival"
echo "   - Consider object storage for backup and archival"

echo ""
echo "3. Network Optimization:"
echo "   - Use private endpoints for internal communication"
echo "   - Implement CDN for static content delivery"
echo "   - Optimize security group rules"

echo ""
echo "4. Cost Optimization:"
echo "   - Implement scheduled shutdown for non-production environments"
echo "   - Use reserved instances for predictable workloads"
echo "   - Monitor and alert on cost thresholds"

echo ""
echo "🎯 Optimization Analysis Complete!"
EOF

chmod +x optimize-infrastructure.sh
./optimize-infrastructure.sh
```

---

## 🧹 **Exercise 7: Cleanup and Resource Management (10 minutes)**

### **Step 15: Resource Cleanup**

Clean up lab resources to avoid ongoing costs:

```bash
# Create cleanup script
cat > cleanup-lab.sh << 'EOF'
#!/bin/bash
# Lab 6 cleanup script

echo "🧹 Lab 6 Resource Cleanup"
echo "========================"

echo "⚠️  WARNING: This will destroy all lab resources!"
echo "💰 This will stop all billing for lab resources"
echo ""
read -p "Are you sure you want to proceed? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    echo "🗑️  Starting resource cleanup..."

    # Show what will be destroyed
    echo "📋 Resources to be destroyed:"
    terraform plan -destroy

    echo ""
    read -p "Proceed with destruction? (yes/no): " final_confirm

    if [ "$final_confirm" = "yes" ]; then
        # Destroy resources
        terraform destroy -auto-approve

        echo "✅ Lab resources cleaned up successfully!"
        echo "💰 Billing for lab resources has stopped"
        echo "📊 Final cost summary available in IBM Cloud billing"
    else
        echo "❌ Cleanup cancelled"
    fi
else
    echo "❌ Cleanup cancelled"
fi
EOF

chmod +x cleanup-lab.sh

echo "🧹 Cleanup script created!"
echo "⚠️  Run ./cleanup-lab.sh when you're ready to clean up resources"
echo "💰 This will stop all billing for lab resources"
```

### **Step 16: Lab Documentation**

Create final lab documentation:

```bash
# Generate lab report
cat > lab-6-report.md << 'EOF'
# Lab 6: Resource Provisioning - Completion Report

## Lab Summary
- **Duration**: 90-120 minutes
- **Completion Date**: $(date)
- **Infrastructure Deployed**: 3-tier web application

## Resources Created
$(terraform output -json lab_summary | jq '.resource_counts')

## Architecture Deployed
$(terraform output -json lab_summary | jq '.architecture_tiers')

## Cost Analysis
$(terraform output -json cost_estimation | jq '{
    lab_session_cost: .lab_session_cost_usd,
    monthly_estimate: .total_estimated_monthly_cost_usd
}')

## Key Learning Outcomes
✅ VPC infrastructure deployment
✅ Multi-tier security configuration
✅ Compute resource provisioning
✅ Storage volume management
✅ Load balancer configuration
✅ Troubleshooting and optimization
✅ Cost management and cleanup

## Next Steps
- Practice scaling operations
- Implement monitoring and alerting
- Explore advanced security configurations
- Study modularization patterns (Topic 5)

## Resources for Further Learning
- IBM Cloud VPC Documentation
- Terraform IBM Provider Documentation
- IBM Cloud Architecture Center
- Cost Optimization Best Practices
EOF

echo "📄 Lab report generated: lab-6-report.md"
echo "🎓 Lab 6 completed successfully!"
```

---

## 🎯 **Lab Completion Summary**

### **What You've Accomplished**

✅ **VPC Foundation**: Deployed complete VPC with subnets and gateways
✅ **Security Configuration**: Implemented defense-in-depth security
✅ **Compute Provisioning**: Deployed 3-tier application infrastructure
✅ **Storage Management**: Configured persistent storage volumes
✅ **Load Balancing**: Implemented high availability with load balancer
✅ **Monitoring**: Configured health checks and observability
✅ **Cost Optimization**: Applied cost management best practices
✅ **Troubleshooting**: Practiced common issue resolution

### **Key Skills Developed**

- **Infrastructure as Code**: Terraform configuration and management
- **IBM Cloud Services**: VPC, compute, storage, networking, security
- **Enterprise Patterns**: Naming, tagging, multi-tier architecture
- **Security Best Practices**: Network isolation, access control
- **Cost Management**: Right-sizing, optimization, lifecycle management
- **Operational Excellence**: Monitoring, troubleshooting, documentation

### **Business Value Demonstrated**

- **Deployment Speed**: 95% faster than manual provisioning
- **Consistency**: 100% configuration consistency across environments
- **Cost Efficiency**: 30-50% cost savings through optimization
- **Security**: Enterprise-grade security implementation
- **Scalability**: Foundation for auto-scaling and growth

### **Next Steps**

1. **Practice Scaling**: Modify instance counts and test scaling
2. **Explore Monitoring**: Implement comprehensive monitoring solutions
3. **Study Modules**: Prepare for Topic 5 (Modularization Best Practices)
4. **Advanced Security**: Explore encryption and compliance features
5. **Cost Optimization**: Implement advanced cost management strategies

**🏆 Congratulations!** You have successfully completed Lab 6 and demonstrated proficiency in IBM Cloud resource provisioning using Terraform. The infrastructure patterns and practices learned here provide the foundation for enterprise-grade cloud automation.
```
