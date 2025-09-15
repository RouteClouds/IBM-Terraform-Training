# =============================================================================
# MAIN INFRASTRUCTURE CONFIGURATION
# Subtopic 6.2: State Locking and Drift Detection
# Advanced state management with locking and automated drift detection
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
    "lab:state-locking-drift-detection",
    "cost-center:${var.cost_center}"
  ]
  
  # State locking configuration
  locking_config = {
    enabled           = var.enable_state_locking
    table_name       = var.lock_table_name
    timeout_minutes  = var.lock_timeout_minutes
    retry_attempts   = var.lock_retry_attempts
    retry_delay      = var.lock_retry_delay_seconds
  }
  
  # Drift detection configuration
  drift_config = {
    enabled              = var.enable_drift_detection
    schedule            = var.drift_check_schedule
    alert_channels      = var.drift_alert_channels
    severity_threshold  = var.drift_severity_threshold
    auto_remediation    = var.enable_auto_remediation
    remediation_threshold = var.auto_remediation_threshold
  }
  
  # Notification configuration
  notification_config = {
    slack_webhook    = var.slack_webhook_url
    email_recipients = var.email_recipients
    webhook_endpoints = var.webhook_endpoints
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

# Random ID for lock testing
resource "random_uuid" "lock_test_id" {}

# =============================================================================
# TIME TRACKING FOR DEPLOYMENT
# =============================================================================

# Track deployment time
resource "time_static" "deployment_time" {}

# =============================================================================
# CLOUDANT FOR STATE LOCKING
# =============================================================================

# Cloudant instance for state locking
resource "ibm_resource_instance" "cloudant" {
  count = var.enable_state_locking ? 1 : 0
  
  name              = "${local.name_prefix}-cloudant"
  resource_group_id = data.ibm_resource_group.main.id
  service           = "cloudantnosqldb"
  plan              = var.cloudant_plan
  location          = var.primary_region
  
  # Capacity configuration for standard plan
  dynamic "parameters" {
    for_each = var.cloudant_plan == "standard" ? [1] : []
    content {
      throughput = {
        blocks = var.cloudant_capacity_throughput
      }
    }
  }
  
  tags = concat(local.common_tags, [
    "service:cloudant",
    "purpose:state-locking"
  ])
}

# Service credentials for Cloudant
resource "ibm_resource_key" "cloudant_credentials" {
  count = var.enable_state_locking ? 1 : 0
  
  name                 = "${local.name_prefix}-cloudant-key"
  resource_instance_id = ibm_resource_instance.cloudant[0].id
  role                 = "Manager"
  
  parameters = {
    HMAC = true
  }
}

# Create lock database in Cloudant
resource "http" "create_lock_database" {
  count = var.enable_state_locking ? 1 : 0
  
  url    = "${ibm_resource_instance.cloudant[0].extensions.CLOUDANT_HOST}/${local.locking_config.table_name}"
  method = "PUT"
  
  request_headers = {
    Authorization = "Bearer ${ibm_resource_key.cloudant_credentials[0].credentials.apikey}"
    Content-Type  = "application/json"
  }
  
  depends_on = [ibm_resource_key.cloudant_credentials]
}

# =============================================================================
# NETWORKING INFRASTRUCTURE
# =============================================================================

# VPC for state locking demonstration
resource "ibm_is_vpc" "locking_demo_vpc" {
  name           = "${local.name_prefix}-vpc"
  resource_group = data.ibm_resource_group.main.id
  address_prefix_management = "manual"
  
  tags = concat(local.common_tags, [
    "resource-type:vpc",
    "tier:networking"
  ])
}

# Address prefix for VPC
resource "ibm_is_vpc_address_prefix" "locking_demo_prefix" {
  name = "${local.name_prefix}-address-prefix"
  vpc  = ibm_is_vpc.locking_demo_vpc.id
  zone = local.availability_zone
  cidr = var.vpc_address_prefix
}

# Public gateway for internet access
resource "ibm_is_public_gateway" "locking_demo_gateway" {
  count = var.enable_public_gateway ? 1 : 0
  
  name           = "${local.name_prefix}-gateway"
  vpc            = ibm_is_vpc.locking_demo_vpc.id
  zone           = local.availability_zone
  resource_group = data.ibm_resource_group.main.id
  
  tags = concat(local.common_tags, [
    "resource-type:public-gateway",
    "tier:networking"
  ])
}

# Subnet for compute resources
resource "ibm_is_subnet" "locking_demo_subnet" {
  name                     = "${local.name_prefix}-subnet"
  vpc                      = ibm_is_vpc.locking_demo_vpc.id
  zone                     = local.availability_zone
  ipv4_cidr_block         = var.subnet_address_prefix
  public_gateway          = var.enable_public_gateway ? ibm_is_public_gateway.locking_demo_gateway[0].id : null
  resource_group          = data.ibm_resource_group.main.id
  
  depends_on = [ibm_is_vpc_address_prefix.locking_demo_prefix]
  
  tags = concat(local.common_tags, [
    "resource-type:subnet",
    "tier:networking"
  ])
}

# =============================================================================
# SECURITY GROUPS
# =============================================================================

# Security group for state locking demo
resource "ibm_is_security_group" "locking_demo_sg" {
  name           = "${local.name_prefix}-sg"
  vpc            = ibm_is_vpc.locking_demo_vpc.id
  resource_group = data.ibm_resource_group.main.id
  
  tags = concat(local.common_tags, [
    "resource-type:security-group",
    "tier:security"
  ])
}

# SSH access rule
resource "ibm_is_security_group_rule" "ssh_inbound" {
  group     = ibm_is_security_group.locking_demo_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# HTTP access rule
resource "ibm_is_security_group_rule" "http_inbound" {
  group     = ibm_is_security_group.locking_demo_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 80
    port_max = 80
  }
}

# HTTPS access rule
resource "ibm_is_security_group_rule" "https_inbound" {
  group     = ibm_is_security_group.locking_demo_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 443
    port_max = 443
  }
}

# Outbound rule for all traffic
resource "ibm_is_security_group_rule" "all_outbound" {
  group     = ibm_is_security_group.locking_demo_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# =============================================================================
# COMPUTE RESOURCES
# =============================================================================

# Virtual Server Instance for state locking demonstration
resource "ibm_is_instance" "locking_demo_vsi" {
  name           = "${local.name_prefix}-vsi"
  vpc            = ibm_is_vpc.locking_demo_vpc.id
  zone           = local.availability_zone
  profile        = var.vsi_profile
  image          = data.ibm_is_image.ubuntu.id
  keys           = var.ssh_key_name != "" ? [data.ibm_is_ssh_key.existing_key[0].id] : []
  resource_group = data.ibm_resource_group.main.id
  
  # Primary network interface
  primary_network_interface {
    subnet          = ibm_is_subnet.locking_demo_subnet.id
    security_groups = [ibm_is_security_group.locking_demo_sg.id]
  }
  
  # Boot volume configuration
  boot_volume {
    name                             = "${local.name_prefix}-boot-volume"
    delete_volume_on_instance_delete = true
    tags                            = local.common_tags
  }
  
  # User data for initial configuration
  user_data = templatefile("${path.module}/templates/user-data.sh", {
    project_name = var.project_name
    environment  = var.environment
    enable_drift_simulation = var.simulate_drift
  })
  
  tags = concat(local.common_tags, [
    "resource-type:vsi",
    "tier:compute"
  ])
}

# Floating IP for VSI (optional)
resource "ibm_is_floating_ip" "locking_demo_fip" {
  count  = var.enable_floating_ip ? 1 : 0
  name   = "${local.name_prefix}-fip"
  target = ibm_is_instance.locking_demo_vsi.primary_network_interface[0].id
  
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
  name              = "${local.name_prefix}-state-cos"
  resource_group_id = data.ibm_resource_group.main.id
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  
  tags = concat(local.common_tags, [
    "service:cloud-object-storage",
    "purpose:state-backend"
  ])
}

# State storage bucket
resource "ibm_cos_bucket" "state_bucket" {
  bucket_name          = "${local.name_prefix}-state-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.state_cos.id
  region_location      = var.primary_region
  storage_class        = "standard"
  
  # Enable versioning for state history
  object_versioning {
    enable = true
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
      days = 365
    }
  }
}

# Service credentials for state backend access
resource "ibm_resource_key" "state_cos_credentials" {
  name                 = "${local.name_prefix}-state-credentials"
  resource_instance_id = ibm_resource_instance.state_cos.id
  role                 = "Writer"
  
  parameters = {
    HMAC = true
  }
}

# =============================================================================
# CLOUD FUNCTIONS FOR DRIFT DETECTION
# =============================================================================

# Cloud Functions namespace
resource "ibm_function_namespace" "terraform_automation" {
  count = var.enable_cloud_functions ? 1 : 0
  
  name              = var.functions_namespace
  resource_group_id = data.ibm_resource_group.main.id
  location          = var.primary_region
  
  tags = concat(local.common_tags, [
    "service:cloud-functions",
    "purpose:automation"
  ])
}

# Drift detection function
resource "ibm_function_action" "drift_detection" {
  count = var.enable_drift_detection && var.enable_cloud_functions ? 1 : 0
  
  name      = "${local.name_prefix}-drift-detection"
  namespace = ibm_function_namespace.terraform_automation[0].name
  
  exec {
    kind = "nodejs:18"
    code = file("${path.module}/templates/drift-detection.js")
  }
  
  limits {
    memory  = var.function_memory_limit
    timeout = var.function_timeout
  }
  
  parameters = jsonencode({
    terraform_workspace = var.project_name
    severity_threshold  = var.drift_severity_threshold
    auto_remediation   = var.enable_auto_remediation
    slack_webhook      = var.slack_webhook_url
    email_recipients   = var.email_recipients
  })
}

# Scheduled trigger for drift detection
resource "ibm_function_trigger" "drift_schedule" {
  count = var.enable_drift_detection && var.enable_cloud_functions ? 1 : 0
  
  name      = "${local.name_prefix}-drift-schedule"
  namespace = ibm_function_namespace.terraform_automation[0].name
  
  feed = [
    {
      name = "alarm"
      parameters = jsonencode({
        cron = var.drift_check_schedule
        trigger_payload = jsonencode({
          workspace_path = "/tmp/terraform"
          project_name   = var.project_name
        })
      })
    }
  ]
}

# Rule to connect trigger to function
resource "ibm_function_rule" "drift_detection_rule" {
  count = var.enable_drift_detection && var.enable_cloud_functions ? 1 : 0
  
  name         = "${local.name_prefix}-drift-rule"
  namespace    = ibm_function_namespace.terraform_automation[0].name
  trigger_name = ibm_function_trigger.drift_schedule[0].name
  action_name  = ibm_function_action.drift_detection[0].name
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
  plan              = var.monitoring_plan
  location          = var.primary_region
  
  tags = concat(local.common_tags, [
    "service:monitoring",
    "purpose:infrastructure-monitoring"
  ])
}

# =============================================================================
# TESTING AND SIMULATION RESOURCES
# =============================================================================

# Test resource for drift simulation
resource "ibm_is_security_group" "drift_test_sg" {
  count = var.simulate_drift ? 1 : 0
  
  name           = "${local.name_prefix}-drift-test-sg"
  vpc            = ibm_is_vpc.locking_demo_vpc.id
  resource_group = data.ibm_resource_group.main.id
  
  tags = concat(local.common_tags, [
    "resource-type:security-group",
    "purpose:drift-testing"
  ])
}

# Test rule for drift simulation
resource "ibm_is_security_group_rule" "drift_test_rule" {
  count = var.simulate_drift ? 1 : 0
  
  group     = ibm_is_security_group.drift_test_sg[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 8080
    port_max = 8080
  }
}

# =============================================================================
# LOCAL FILE GENERATION
# =============================================================================

# Generate backend configuration with locking
resource "local_file" "backend_config_with_locking" {
  count = var.enable_state_locking ? 1 : 0
  
  filename = "${path.module}/generated_backend_with_locking.tf"
  content = templatefile("${path.module}/templates/backend-with-locking.tf.tpl", {
    bucket_name       = ibm_cos_bucket.state_bucket.bucket_name
    region           = var.primary_region
    endpoint         = ibm_cos_bucket.state_bucket.s3_endpoint_public
    dynamodb_table   = local.locking_config.table_name
    dynamodb_endpoint = ibm_resource_instance.cloudant[0].extensions.CLOUDANT_HOST
    lock_timeout     = "${local.locking_config.timeout_minutes}m"
    max_retries      = local.locking_config.retry_attempts
    retry_delay      = "${local.locking_config.retry_delay}s"
  })
  
  file_permission = "0644"
}

# Generate drift detection configuration
resource "local_file" "drift_detection_config" {
  count = var.enable_drift_detection ? 1 : 0
  
  filename = "${path.module}/drift_detection_config.json"
  content = jsonencode({
    enabled              = local.drift_config.enabled
    schedule            = local.drift_config.schedule
    alert_channels      = local.drift_config.alert_channels
    severity_threshold  = local.drift_config.severity_threshold
    auto_remediation    = local.drift_config.auto_remediation
    remediation_threshold = local.drift_config.remediation_threshold
    notification_config = local.notification_config
  })
  
  file_permission = "0644"
}
