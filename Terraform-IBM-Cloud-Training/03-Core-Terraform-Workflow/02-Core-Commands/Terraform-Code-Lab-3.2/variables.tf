# Core Terraform Commands Lab - Variable Definitions
# Comprehensive variables for command workflow practice

# ============================================================================
# IBM Cloud Authentication and Configuration
# ============================================================================

variable "ibm_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.ibm_api_key) > 20
    error_message = "IBM Cloud API key must be at least 20 characters long."
  }
}

variable "ibm_region" {
  description = "IBM Cloud region for resource deployment"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa",
      "au-syd", "ca-tor", "br-sao", "eu-es"
    ], var.ibm_region)
    error_message = "IBM region must be a valid IBM Cloud region."
  }
}

variable "resource_group_id" {
  description = "IBM Cloud resource group ID (optional)"
  type        = string
  default     = null
}

# ============================================================================
# Project Configuration
# ============================================================================

variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "lab32-core-commands"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 30
    error_message = "Project name must be between 3 and 30 characters."
  }
}

variable "environment" {
  description = "Environment name for resource organization"
  type        = string
  default     = "lab"
  
  validation {
    condition = contains([
      "dev", "development", "test", "testing", "stage", "staging", 
      "prod", "production", "lab", "demo", "sandbox"
    ], var.environment)
    error_message = "Environment must be one of: dev, test, stage, prod, lab, demo, sandbox."
  }
}

variable "owner" {
  description = "Owner email for resource tagging and management"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner))
    error_message = "Owner must be a valid email address."
  }
}

# ============================================================================
# Command Workflow Configuration
# ============================================================================

variable "enable_command_logging" {
  description = "Enable detailed command execution logging"
  type        = bool
  default     = true
}

variable "command_timeout" {
  description = "Timeout for command execution in seconds"
  type        = number
  default     = 300
  
  validation {
    condition     = var.command_timeout >= 60 && var.command_timeout <= 3600
    error_message = "Command timeout must be between 60 and 3600 seconds."
  }
}

variable "enable_plan_validation" {
  description = "Enable plan validation before apply"
  type        = bool
  default     = true
}

variable "auto_approve_destroy" {
  description = "Enable auto-approval for destroy operations (use with caution)"
  type        = bool
  default     = false
}

# ============================================================================
# Infrastructure Configuration
# ============================================================================

variable "vpc_address_prefix" {
  description = "CIDR block for VPC address prefix"
  type        = string
  default     = "10.240.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_address_prefix, 0))
    error_message = "VPC address prefix must be a valid CIDR block."
  }
}

variable "subnet_configurations" {
  description = "Configuration for subnets in different zones"
  type = map(object({
    cidr_block = string
    zone       = string
    public     = bool
  }))
  
  default = {
    "web" = {
      cidr_block = "10.240.1.0/24"
      zone       = "us-south-1"
      public     = true
    }
    "app" = {
      cidr_block = "10.240.2.0/24"
      zone       = "us-south-2"
      public     = false
    }
    "data" = {
      cidr_block = "10.240.3.0/24"
      zone       = "us-south-3"
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

variable "enable_public_gateway" {
  description = "Enable public gateway for internet access"
  type        = bool
  default     = true
}

variable "security_group_rules" {
  description = "Security group rules configuration"
  type = list(object({
    name      = string
    direction = string
    protocol  = string
    port_min  = number
    port_max  = number
    source    = string
  }))
  
  default = [
    {
      name      = "ssh-inbound"
      direction = "inbound"
      protocol  = "tcp"
      port_min  = 22
      port_max  = 22
      source    = "0.0.0.0/0"
    },
    {
      name      = "http-inbound"
      direction = "inbound"
      protocol  = "tcp"
      port_min  = 80
      port_max  = 80
      source    = "0.0.0.0/0"
    },
    {
      name      = "https-inbound"
      direction = "inbound"
      protocol  = "tcp"
      port_min  = 443
      port_max  = 443
      source    = "0.0.0.0/0"
    },
    {
      name      = "all-outbound"
      direction = "outbound"
      protocol  = "all"
      port_min  = 1
      port_max  = 65535
      source    = "0.0.0.0/0"
    }
  ]
}

# ============================================================================
# Testing and Validation Configuration
# ============================================================================

variable "enable_resource_validation" {
  description = "Enable resource validation after deployment"
  type        = bool
  default     = true
}

variable "validation_timeout" {
  description = "Timeout for resource validation in seconds"
  type        = number
  default     = 120
  
  validation {
    condition     = var.validation_timeout >= 30 && var.validation_timeout <= 600
    error_message = "Validation timeout must be between 30 and 600 seconds."
  }
}

variable "enable_cost_estimation" {
  description = "Enable cost estimation calculations"
  type        = bool
  default     = true
}

# ============================================================================
# Tagging and Metadata
# ============================================================================

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
  
  validation {
    condition = alltrue([
      for key, value in var.additional_tags : can(regex("^[a-zA-Z0-9_-]+$", key))
    ])
    error_message = "Tag keys must contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "cost_center" {
  description = "Cost center for billing and resource tracking"
  type        = string
  default     = "training"
  
  validation {
    condition     = length(var.cost_center) >= 2 && length(var.cost_center) <= 20
    error_message = "Cost center must be between 2 and 20 characters."
  }
}

# ============================================================================
# Advanced Configuration
# ============================================================================

variable "enable_monitoring" {
  description = "Enable monitoring and logging for resources"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
  
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention must be between 1 and 365 days."
  }
}

variable "enable_encryption" {
  description = "Enable encryption for supported resources"
  type        = bool
  default     = true
}
