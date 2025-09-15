# Git Collaboration Lab - Main Infrastructure Configuration
# Demonstrates enterprise Git workflows and team collaboration patterns

# =============================================================================
# LOCAL VALUES AND COMPUTED CONFIGURATIONS
# =============================================================================

locals {
  # Environment-specific configuration resolution
  current_environment = var.organization_config.environment
  environment_config = var.environment_overrides[local.current_environment]
  
  # Naming convention implementation
  resource_prefix = "${var.organization_config.name}-${local.current_environment}"
  resource_name_pattern = "${local.resource_prefix}-{service}-{purpose}"
  
  # Resolved configuration with environment overrides
  resolved_config = {
    instance_count = var.feature_flags.enable_cost_optimization ? local.environment_config.instance_count_override : var.infrastructure_config.compute.instance_count
    instance_profile = local.environment_config.instance_profile_override
    security_level = local.environment_config.security_level_override
    monitoring_level = local.environment_config.monitoring_level_override
    budget_limit = local.environment_config.budget_override
  }
  
  # Git workflow metadata
  git_workflow_metadata = {
    workflow_pattern = var.git_workflow_config.workflow_pattern
    branch_protection_enabled = true
    ci_cd_integration = true
    team_collaboration = true
    policy_enforcement = var.security_config.policy_as_code.enabled
  }
  
  # Team and collaboration configuration
  team_metadata = {
    total_teams = length(var.team_configuration.teams)
    total_roles = length(var.team_configuration.roles)
    approval_workflows_enabled = true
    rbac_enabled = var.security_config.access_control.rbac_enabled
  }
  
  # Comprehensive tagging strategy
  common_tags = merge(
    var.organization_config.default_tags,
    var.cost_configuration.cost_allocation_tags,
    {
      "terraform-managed" = "true"
      "lab-exercise" = "git-collaboration"
      "workflow-pattern" = var.git_workflow_config.workflow_pattern
      "environment" = local.current_environment
      "team-count" = tostring(local.team_metadata.total_teams)
      "security-level" = local.resolved_config.security_level
      "cost-center" = var.cost_configuration.cost_center
      "last-updated" = formatdate("YYYY-MM-DD", timestamp())
    }
  )
  
  # Feature flag resolution
  active_features = merge(
    var.feature_flags,
    local.environment_config.feature_overrides
  )

  # Provider health status
  provider_health = {
    primary_region_healthy = true
    secondary_region_healthy = false  # Not deployed in this lab
    dr_region_healthy = false  # Not deployed in this lab
    backend_configured = true
    state_locked = false
    all_providers_healthy = true
    validation_timestamp = timestamp()
  }
}

# =============================================================================
# RANDOM RESOURCES FOR UNIQUE NAMING
# =============================================================================

resource "random_id" "deployment_id" {
  byte_length = 4
  
  keepers = {
    environment = local.current_environment
    workflow_pattern = var.git_workflow_config.workflow_pattern
    team_config_hash = md5(jsonencode(var.team_configuration))
  }
}

resource "random_string" "resource_suffix" {
  length  = 8
  special = false
  upper   = false
  
  keepers = {
    deployment_id = random_id.deployment_id.hex
  }
}

# =============================================================================
# VPC AND NETWORKING INFRASTRUCTURE
# =============================================================================

# VPC for Git collaboration lab environment
resource "ibm_is_vpc" "git_lab_vpc" {
  provider = ibm.primary
  
  name                        = "${local.resource_prefix}-vpc-${random_string.resource_suffix.result}"
  resource_group             = var.resource_group_id
  address_prefix_management  = var.infrastructure_config.networking.address_prefix_management
  
  tags = merge(local.common_tags, {
    "component" = "networking"
    "purpose" = "git-collaboration-lab"
    "vpc-type" = "primary"
  })
}

# Public gateways for internet connectivity (if enabled)
resource "ibm_is_public_gateway" "git_lab_gateways" {
  provider = ibm.primary
  count    = var.infrastructure_config.networking.enable_public_gateway ? length(var.infrastructure_config.networking.subnets) : 0
  
  name           = "${local.resource_prefix}-pgw-${var.infrastructure_config.networking.subnets[count.index].zone}-${random_string.resource_suffix.result}"
  vpc            = ibm_is_vpc.git_lab_vpc.id
  zone           = var.infrastructure_config.networking.subnets[count.index].zone
  resource_group = var.resource_group_id
  
  tags = merge(local.common_tags, {
    "component" = "networking"
    "purpose" = "internet-connectivity"
    "zone" = var.infrastructure_config.networking.subnets[count.index].zone
  })
}

# Subnets for different team environments
resource "ibm_is_subnet" "git_lab_subnets" {
  provider = ibm.primary
  count    = length(var.infrastructure_config.networking.subnets)
  
  name                     = "${local.resource_prefix}-subnet-${var.infrastructure_config.networking.subnets[count.index].name}-${random_string.resource_suffix.result}"
  vpc                      = ibm_is_vpc.git_lab_vpc.id
  zone                     = var.infrastructure_config.networking.subnets[count.index].zone
  ipv4_cidr_block         = var.infrastructure_config.networking.subnets[count.index].cidr_block
  resource_group          = var.resource_group_id
  
  # Attach public gateway if enabled for this subnet
  public_gateway = (
    var.infrastructure_config.networking.enable_public_gateway && 
    var.infrastructure_config.networking.subnets[count.index].public_gateway_enabled
  ) ? ibm_is_public_gateway.git_lab_gateways[count.index].id : null
  
  tags = merge(local.common_tags, {
    "component" = "networking"
    "purpose" = "team-environment"
    "subnet-type" = var.infrastructure_config.networking.subnets[count.index].name
    "zone" = var.infrastructure_config.networking.subnets[count.index].zone
  })
}

# Security groups for team-based access control
resource "ibm_is_security_group" "git_lab_security_groups" {
  provider = ibm.primary
  count    = length(var.infrastructure_config.networking.security_groups)
  
  name           = "${local.resource_prefix}-sg-${var.infrastructure_config.networking.security_groups[count.index].name}-${random_string.resource_suffix.result}"
  vpc            = ibm_is_vpc.git_lab_vpc.id
  resource_group = var.resource_group_id
  
  tags = merge(local.common_tags, {
    "component" = "security"
    "purpose" = "access-control"
    "security-group-type" = var.infrastructure_config.networking.security_groups[count.index].name
  })
}

# Security group rules for controlled access
resource "ibm_is_security_group_rule" "git_lab_sg_rules" {
  provider = ibm.primary
  count    = sum([for sg in var.infrastructure_config.networking.security_groups : length(sg.rules)])
  
  group     = ibm_is_security_group.git_lab_security_groups[floor(count.index / length(var.infrastructure_config.networking.security_groups[0].rules))].id
  direction = local.flattened_rules[count.index].direction
  
  dynamic "tcp" {
    for_each = local.flattened_rules[count.index].protocol == "tcp" ? [1] : []
    content {
      port_min = local.flattened_rules[count.index].port_min
      port_max = local.flattened_rules[count.index].port_max
    }
  }
  
  dynamic "udp" {
    for_each = local.flattened_rules[count.index].protocol == "udp" ? [1] : []
    content {
      port_min = local.flattened_rules[count.index].port_min
      port_max = local.flattened_rules[count.index].port_max
    }
  }
  
  dynamic "icmp" {
    for_each = local.flattened_rules[count.index].protocol == "icmp" ? [1] : []
    content {
      type = 8
      code = 0
    }
  }
  
  remote = local.flattened_rules[count.index].source_type == "cidr_block" ? local.flattened_rules[count.index].source : null
}

# Flatten security group rules for easier iteration
locals {
  flattened_rules = flatten([
    for sg_idx, sg in var.infrastructure_config.networking.security_groups : [
      for rule_idx, rule in sg.rules : merge(rule, {
        sg_index = sg_idx
        rule_index = rule_idx
      })
    ]
  ])
}

# =============================================================================
# SSH KEY MANAGEMENT FOR TEAM ACCESS
# =============================================================================

# Generate SSH key pair for team access (if enabled)
resource "tls_private_key" "git_lab_ssh_key" {
  count = var.infrastructure_config.compute.ssh_key.create_new ? 1 : 0
  
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store private key locally for team access
resource "local_file" "git_lab_private_key" {
  count = var.infrastructure_config.compute.ssh_key.create_new ? 1 : 0
  
  content  = tls_private_key.git_lab_ssh_key[0].private_key_pem
  filename = "${path.module}/generated/${local.resource_prefix}-ssh-key-${random_string.resource_suffix.result}.pem"
  
  file_permission = "0600"
}

# IBM Cloud SSH key resource
resource "ibm_is_ssh_key" "git_lab_ssh_key" {
  provider = ibm.primary
  
  name           = "${local.resource_prefix}-ssh-key-${random_string.resource_suffix.result}"
  public_key     = var.infrastructure_config.compute.ssh_key.create_new ? tls_private_key.git_lab_ssh_key[0].public_key_openssh : file(var.infrastructure_config.compute.ssh_key.public_key_file)
  resource_group = var.resource_group_id
  
  tags = merge(local.common_tags, {
    "component" = "security"
    "purpose" = "team-access"
    "key-type" = "ssh"
  })
}

# =============================================================================
# COMPUTE INSTANCES FOR DEVELOPMENT ENVIRONMENTS
# =============================================================================

# Virtual server instances for team development (if enabled)
resource "ibm_is_instance" "git_lab_instances" {
  provider = ibm.primary
  count    = var.infrastructure_config.compute.create_instances ? local.resolved_config.instance_count : 0
  
  name           = "${local.resource_prefix}-instance-${count.index + 1}-${random_string.resource_suffix.result}"
  image          = data.ibm_is_image.git_lab_image.id
  profile        = local.resolved_config.instance_profile
  resource_group = var.resource_group_id
  
  vpc  = ibm_is_vpc.git_lab_vpc.id
  zone = var.infrastructure_config.networking.subnets[count.index % length(var.infrastructure_config.networking.subnets)].zone
  keys = [ibm_is_ssh_key.git_lab_ssh_key.id]
  
  primary_network_interface {
    subnet          = ibm_is_subnet.git_lab_subnets[count.index % length(ibm_is_subnet.git_lab_subnets)].id
    security_groups = [ibm_is_security_group.git_lab_security_groups[0].id]
  }
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Git Collaboration Lab - Instance Initialization

    # Update system
    apt-get update -y
    apt-get upgrade -y

    # Install essential packages
    apt-get install -y curl wget git jq unzip vim htop tree

    # Install Terraform
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt-get update -y
    apt-get install -y terraform

    # Install IBM Cloud CLI
    curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

    # Create development user
    useradd -m -s /bin/bash developer
    usermod -aG sudo developer

    # Create development directories
    mkdir -p /home/developer/projects
    chown -R developer:developer /home/developer/

    # Create instance info
    cat > /home/developer/instance-info.txt << 'EOFINFO'
Git Collaboration Lab Instance
Environment: ${local.current_environment}
Workflow Pattern: ${var.git_workflow_config.workflow_pattern}
Team Count: ${local.team_metadata.total_teams}
Instance Number: ${count.index + 1}
Setup Date: $(date)
EOFINFO

    chown developer:developer /home/developer/instance-info.txt

    # Set up welcome message
    cat > /etc/motd << 'EOFMOTD'

Welcome to Git Collaboration Lab Instance ${count.index + 1}
Environment: ${local.current_environment} | Workflow: ${var.git_workflow_config.workflow_pattern}

Instance setup completed successfully!
Check /home/developer/instance-info.txt for details.

Happy coding! 🚀

EOFMOTD

    echo "Git Collaboration Lab instance initialization completed" > /var/log/user-data.log
  EOF
  )
  
  tags = merge(local.common_tags, {
    "component" = "compute"
    "purpose" = "development-environment"
    "instance-number" = tostring(count.index + 1)
    "team-assignment" = "shared"
  })
}

# Image data source for instances
data "ibm_is_image" "git_lab_image" {
  provider = ibm.primary
  name     = var.infrastructure_config.compute.image_name
}

# =============================================================================
# CLOUD OBJECT STORAGE FOR STATE AND ARTIFACTS
# =============================================================================

# Cloud Object Storage instance for state management
resource "ibm_resource_instance" "git_lab_cos" {
  count = var.infrastructure_config.storage.create_cos_bucket ? 1 : 0
  
  name              = "${local.resource_prefix}-cos-${random_string.resource_suffix.result}"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = var.resource_group_id
  
  tags = merge(local.common_tags, {
    "component" = "storage"
    "purpose" = "state-management"
    "service-type" = "cos"
  })
}

# COS bucket for Terraform state storage
resource "ibm_cos_bucket" "git_lab_state_bucket" {
  count = var.infrastructure_config.storage.create_cos_bucket ? 1 : 0
  
  bucket_name          = "${local.resource_prefix}-state-${random_string.resource_suffix.result}"
  resource_instance_id = ibm_resource_instance.git_lab_cos[0].id
  storage_class        = var.infrastructure_config.storage.storage_class
  region_location      = var.regional_configuration.primary_region
  
  # Enable versioning for state file history
  object_versioning {
    enable = var.infrastructure_config.storage.versioning_enabled
  }
  
  # Lifecycle management for cost optimization
  expire_rule {
    rule_id = "delete-old-versions"
    enable  = true
    days    = 90
    prefix  = "terraform-state/"
  }
}

# =============================================================================
# MONITORING AND OBSERVABILITY
# =============================================================================

# Activity Tracker for audit logging (if enabled)
resource "ibm_resource_instance" "git_lab_activity_tracker" {
  count = var.infrastructure_config.monitoring.enable_activity_tracker ? 1 : 0
  
  name              = "${local.resource_prefix}-activity-tracker-${random_string.resource_suffix.result}"
  service           = "logdnaat"
  plan              = "lite"
  location          = var.regional_configuration.primary_region
  resource_group_id = var.resource_group_id
  
  tags = merge(local.common_tags, {
    "component" = "monitoring"
    "purpose" = "audit-logging"
    "service-type" = "activity-tracker"
  })
}

# =============================================================================
# TIME-BASED RESOURCES FOR WORKFLOW SIMULATION
# =============================================================================

# Time delay for simulating deployment workflows
resource "time_sleep" "deployment_simulation" {
  depends_on = [
    ibm_is_vpc.git_lab_vpc,
    ibm_is_subnet.git_lab_subnets,
    ibm_is_security_group.git_lab_security_groups
  ]
  
  create_duration = "30s"
  
  triggers = {
    workflow_pattern = var.git_workflow_config.workflow_pattern
    team_configuration = md5(jsonencode(var.team_configuration))
    deployment_id = random_id.deployment_id.hex
  }
}

# =============================================================================
# NULL RESOURCES FOR WORKFLOW AUTOMATION
# =============================================================================

# Git workflow initialization
resource "null_resource" "git_workflow_setup" {
  depends_on = [time_sleep.deployment_simulation]
  
  triggers = {
    workflow_pattern = var.git_workflow_config.workflow_pattern
    team_config_hash = md5(jsonencode(var.team_configuration))
    cicd_config_hash = md5(jsonencode(var.cicd_pipeline_config))
  }
  
  provisioner "local-exec" {
    command = "echo 'Git workflow ${var.git_workflow_config.workflow_pattern} initialized for ${local.team_metadata.total_teams} teams'"
  }
  
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Git workflow cleanup completed'"
  }
}

# Team collaboration setup
resource "null_resource" "team_collaboration_setup" {
  depends_on = [null_resource.git_workflow_setup]
  
  count = local.team_metadata.total_teams
  
  triggers = {
    team_config = md5(jsonencode(var.team_configuration.teams))
    rbac_enabled = var.security_config.access_control.rbac_enabled
  }
  
  provisioner "local-exec" {
    command = "echo 'Team collaboration configured for team ${count.index + 1}'"
  }
}
