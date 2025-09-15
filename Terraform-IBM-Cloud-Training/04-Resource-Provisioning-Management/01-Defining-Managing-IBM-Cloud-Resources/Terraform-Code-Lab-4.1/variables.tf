# =============================================================================
# TERRAFORM VARIABLES CONFIGURATION
# Topic 4.1: Defining and Managing IBM Cloud Resources
# =============================================================================

# =============================================================================
# AUTHENTICATION AND REGION VARIABLES
# =============================================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication and resource management"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.ibmcloud_api_key) > 0
    error_message = "IBM Cloud API key must be provided and cannot be empty."
  }
}

variable "ibm_region" {
  description = "Primary IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd",
      "jp-osa", "br-sao", "ca-tor", "eu-fr2"
    ], var.ibm_region)
    error_message = "IBM region must be a valid IBM Cloud region with VPC support."
  }
}

variable "secondary_region" {
  description = "Secondary IBM Cloud region for disaster recovery and multi-region deployment"
  type        = string
  default     = "us-east"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd",
      "jp-osa", "br-sao", "ca-tor", "eu-fr2"
    ], var.secondary_region)
    error_message = "Secondary region must be a valid IBM Cloud region with VPC support."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group for organizing resources"
  type        = string
  default     = "default"
  
  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 40
    error_message = "Resource group name must be between 1 and 40 characters."
  }
}

# =============================================================================
# PROJECT AND ENVIRONMENT CONFIGURATION
# =============================================================================

variable "project_name" {
  description = "Name of the project for resource naming and organization"
  type        = string
  default     = "terraform-lab-41"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name)) && length(var.project_name) <= 30
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens, and be 30 characters or less."
  }
}

variable "environment" {
  description = "Environment name for resource organization and lifecycle management"
  type        = string
  default     = "development"
  
  validation {
    condition = contains(["development", "staging", "production", "test", "demo"], var.environment)
    error_message = "Environment must be one of: development, staging, production, test, demo."
  }
}

variable "owner" {
  description = "Owner of the infrastructure for resource tagging and accountability"
  type        = string
  default     = "terraform-training"
  
  validation {
    condition     = length(var.owner) > 0 && length(var.owner) <= 50
    error_message = "Owner must be specified and be 50 characters or less."
  }
}

variable "cost_center" {
  description = "Cost center for billing and resource allocation tracking"
  type        = string
  default     = "training-lab"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cost_center))
    error_message = "Cost center must contain only lowercase letters, numbers, and hyphens."
  }
}

# =============================================================================
# NETWORK CONFIGURATION VARIABLES
# =============================================================================

variable "vpc_address_prefix" {
  description = "CIDR block for the VPC address space"
  type        = string
  default     = "10.240.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_address_prefix, 0))
    error_message = "VPC address prefix must be a valid CIDR block."
  }
  
  validation {
    condition     = tonumber(split("/", var.vpc_address_prefix)[1]) <= 18
    error_message = "VPC address prefix must be /18 or larger to accommodate multiple subnets."
  }
}

variable "subnet_configurations" {
  description = "Configuration for subnets across different tiers and availability zones"
  type = map(object({
    cidr_block    = string
    zone_offset   = number
    tier          = string
    public_access = bool
    description   = string
  }))
  
  default = {
    "web-tier-1" = {
      cidr_block    = "10.240.1.0/24"
      zone_offset   = 1
      tier          = "web"
      public_access = true
      description   = "Web tier subnet in zone 1 with public access"
    }
    "web-tier-2" = {
      cidr_block    = "10.240.2.0/24"
      zone_offset   = 2
      tier          = "web"
      public_access = true
      description   = "Web tier subnet in zone 2 with public access"
    }
    "app-tier-1" = {
      cidr_block    = "10.240.11.0/24"
      zone_offset   = 1
      tier          = "application"
      public_access = false
      description   = "Application tier subnet in zone 1 (private)"
    }
    "app-tier-2" = {
      cidr_block    = "10.240.12.0/24"
      zone_offset   = 2
      tier          = "application"
      public_access = false
      description   = "Application tier subnet in zone 2 (private)"
    }
    "data-tier-1" = {
      cidr_block    = "10.240.21.0/24"
      zone_offset   = 1
      tier          = "database"
      public_access = false
      description   = "Database tier subnet in zone 1 (private)"
    }
    "data-tier-2" = {
      cidr_block    = "10.240.22.0/24"
      zone_offset   = 2
      tier          = "database"
      public_access = false
      description   = "Database tier subnet in zone 2 (private)"
    }
  }
  
  validation {
    condition = alltrue([
      for config in values(var.subnet_configurations) : can(cidrhost(config.cidr_block, 0))
    ])
    error_message = "All subnet CIDR blocks must be valid."
  }
  
  validation {
    condition = alltrue([
      for config in values(var.subnet_configurations) : contains(["web", "application", "database", "management"], config.tier)
    ])
    error_message = "All subnet tiers must be one of: web, application, database, management."
  }
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs for network monitoring and security analysis"
  type        = bool
  default     = true
}

# =============================================================================
# COMPUTE CONFIGURATION VARIABLES
# =============================================================================

variable "instance_configurations" {
  description = "Configuration for virtual server instances across different tiers"
  type = map(object({
    count           = number
    profile         = string
    image_name      = string
    tier            = string
    boot_volume_size = number
    enable_monitoring = bool
    user_data_template = string
  }))
  
  default = {
    "web-servers" = {
      count           = 2
      profile         = "bx2-2x8"
      image_name      = "ibm-ubuntu-20-04-3-minimal-amd64-2"
      tier            = "web"
      boot_volume_size = 100
      enable_monitoring = true
      user_data_template = "web-server-init.sh"
    }
    "app-servers" = {
      count           = 2
      profile         = "bx2-4x16"
      image_name      = "ibm-ubuntu-20-04-3-minimal-amd64-2"
      tier            = "application"
      boot_volume_size = 100
      enable_monitoring = true
      user_data_template = "app-server-init.sh"
    }
    "db-servers" = {
      count           = 1
      profile         = "bx2-8x32"
      image_name      = "ibm-ubuntu-20-04-3-minimal-amd64-2"
      tier            = "database"
      boot_volume_size = 200
      enable_monitoring = true
      user_data_template = "db-server-init.sh"
    }
  }
  
  validation {
    condition = alltrue([
      for config in values(var.instance_configurations) : contains([
        "bx2-2x8", "bx2-4x16", "bx2-8x32", "bx2-16x64",
        "cx2-2x4", "cx2-4x8", "cx2-8x16", "cx2-16x32",
        "mx2-2x16", "mx2-4x32", "mx2-8x64", "mx2-16x128"
      ], config.profile)
    ])
    error_message = "All instance profiles must be valid IBM Cloud VPC profiles."
  }
  
  validation {
    condition = alltrue([
      for config in values(var.instance_configurations) : 
      config.count >= 0 && config.count <= 10
    ])
    error_message = "Instance count must be between 0 and 10 for lab environments."
  }
}

variable "ssh_key_name" {
  description = "Name of the SSH key for instance access (must exist in IBM Cloud)"
  type        = string
  default     = ""
  
  validation {
    condition     = var.ssh_key_name == "" || length(var.ssh_key_name) > 0
    error_message = "SSH key name must be empty or a valid key name."
  }
}

# =============================================================================
# STORAGE CONFIGURATION VARIABLES
# =============================================================================

variable "storage_configurations" {
  description = "Storage volume configurations for different tiers and use cases"
  type = map(object({
    volume_size_gb = number
    profile        = string
    encrypted      = bool
    tier           = string
    backup_enabled = bool
  }))
  
  default = {
    "app-data" = {
      volume_size_gb = 100
      profile        = "general-purpose"
      encrypted      = true
      tier           = "application"
      backup_enabled = true
    }
    "db-data" = {
      volume_size_gb = 500
      profile        = "10iops-tier"
      encrypted      = true
      tier           = "database"
      backup_enabled = true
    }
    "shared-storage" = {
      volume_size_gb = 250
      profile        = "5iops-tier"
      encrypted      = true
      tier           = "shared"
      backup_enabled = true
    }
  }
  
  validation {
    condition = alltrue([
      for config in values(var.storage_configurations) : 
      config.volume_size_gb >= 10 && config.volume_size_gb <= 2000
    ])
    error_message = "Volume sizes must be between 10 and 2000 GB."
  }
  
  validation {
    condition = alltrue([
      for config in values(var.storage_configurations) : contains([
        "general-purpose", "5iops-tier", "10iops-tier", "custom"
      ], config.profile)
    ])
    error_message = "Storage profiles must be valid IBM Cloud block storage profiles."
  }
}

# =============================================================================
# SECURITY CONFIGURATION VARIABLES
# =============================================================================

variable "security_configurations" {
  description = "Security settings for network access control and compliance"
  type = object({
    allowed_ssh_cidr_blocks    = list(string)
    allowed_web_cidr_blocks    = list(string)
    enable_network_acls        = bool
    enable_security_monitoring = bool
    compliance_framework       = string
    encryption_key_management  = string
  })
  
  default = {
    allowed_ssh_cidr_blocks    = ["0.0.0.0/0"]  # Restrict in production
    allowed_web_cidr_blocks    = ["0.0.0.0/0"]
    enable_network_acls        = true
    enable_security_monitoring = true
    compliance_framework       = "general"
    encryption_key_management  = "provider-managed"
  }
  
  validation {
    condition = alltrue([
      for cidr in var.security_configurations.allowed_ssh_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All SSH CIDR blocks must be valid."
  }
  
  validation {
    condition = contains(["general", "hipaa", "sox", "pci-dss"], var.security_configurations.compliance_framework)
    error_message = "Compliance framework must be one of: general, hipaa, sox, pci-dss."
  }
}

# =============================================================================
# LOAD BALANCER CONFIGURATION VARIABLES
# =============================================================================

variable "load_balancer_configuration" {
  description = "Application Load Balancer configuration for high availability"
  type = object({
    type                = string
    algorithm          = string
    health_check_url   = string
    health_check_interval = number
    session_persistence = bool
    ssl_certificate_crn = string
  })
  
  default = {
    type                = "public"
    algorithm          = "round_robin"
    health_check_url   = "/health"
    health_check_interval = 60
    session_persistence = false
    ssl_certificate_crn = ""
  }
  
  validation {
    condition = contains(["public", "private"], var.load_balancer_configuration.type)
    error_message = "Load balancer type must be either 'public' or 'private'."
  }
  
  validation {
    condition = contains(["round_robin", "weighted_round_robin", "least_connections"], var.load_balancer_configuration.algorithm)
    error_message = "Load balancer algorithm must be valid."
  }
}

# =============================================================================
# MONITORING AND OBSERVABILITY VARIABLES
# =============================================================================

variable "monitoring_configuration" {
  description = "Monitoring and observability configuration for infrastructure visibility"
  type = object({
    enable_platform_metrics = bool
    enable_platform_logs   = bool
    log_retention_days     = number
    metrics_retention_days = number
    alert_notification_channels = list(string)
  })
  
  default = {
    enable_platform_metrics = true
    enable_platform_logs   = true
    log_retention_days     = 30
    metrics_retention_days = 90
    alert_notification_channels = []
  }
  
  validation {
    condition = var.monitoring_configuration.log_retention_days >= 7 && var.monitoring_configuration.log_retention_days <= 365
    error_message = "Log retention must be between 7 and 365 days."
  }
}

# =============================================================================
# COST OPTIMIZATION VARIABLES
# =============================================================================

variable "cost_optimization" {
  description = "Cost optimization settings for efficient resource utilization"
  type = object({
    enable_auto_scaling     = bool
    enable_scheduled_scaling = bool
    min_instances_per_tier  = number
    max_instances_per_tier  = number
    scale_down_schedule     = string
    scale_up_schedule       = string
  })
  
  default = {
    enable_auto_scaling     = false  # Disabled for lab environment
    enable_scheduled_scaling = false
    min_instances_per_tier  = 1
    max_instances_per_tier  = 5
    scale_down_schedule     = "0 18 * * 1-5"  # 6 PM weekdays
    scale_up_schedule       = "0 8 * * 1-5"   # 8 AM weekdays
  }
  
  validation {
    condition = var.cost_optimization.min_instances_per_tier <= var.cost_optimization.max_instances_per_tier
    error_message = "Minimum instances must be less than or equal to maximum instances."
  }
}

# =============================================================================
# TAGGING AND METADATA VARIABLES
# =============================================================================

variable "resource_tags" {
  description = "Map of tags to apply to all resources for organization and cost tracking"
  type        = map(string)
  default = {
    "managed-by"      = "terraform"
    "project-type"    = "training-lab"
    "topic"           = "4.1-resource-provisioning"
    "learning-path"   = "ibm-cloud-terraform"
    "auto-cleanup"    = "enabled"
  }
  
  validation {
    condition     = length(var.resource_tags) <= 50
    error_message = "Cannot specify more than 50 resource tags."
  }
  
  validation {
    condition = alltrue([
      for key in keys(var.resource_tags) : can(regex("^[a-zA-Z0-9-_]+$", key))
    ])
    error_message = "Tag keys must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring and logging for all resources"
  type        = bool
  default     = true
}

variable "enable_cost_tracking" {
  description = "Enable detailed cost tracking and optimization features"
  type        = bool
  default     = true
}
