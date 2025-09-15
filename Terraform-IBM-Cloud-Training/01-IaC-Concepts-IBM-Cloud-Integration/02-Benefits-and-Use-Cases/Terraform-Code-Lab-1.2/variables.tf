# Enhanced Variables for Cost Optimization Lab 1.2
# This file extends the basic variables with cost optimization and IBM Cloud specific features

# IBM Cloud Authentication and Region Configuration
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.ibmcloud_api_key) > 0
    error_message = "IBM Cloud API key must not be empty."
  }
}

variable "ibm_region" {
  description = "IBM Cloud region where resources will be created"
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd", "jp-osa", "br-sao", "ca-tor"
    ], var.ibm_region)
    error_message = "IBM region must be a valid IBM Cloud region."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group to use for organizing resources"
  type        = string
  default     = "default"
}

# Project and Environment Configuration
variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "iac-cost-optimization"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod) for resource organization"
  type        = string
  default     = "lab"
  
  validation {
    condition = contains([
      "dev", "staging", "prod", "lab", "test"
    ], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, lab, test."
  }
}

variable "owner" {
  description = "Owner of the resources for tracking and billing purposes"
  type        = string
  default     = "training-participant"
}

# Cost Optimization Configuration
variable "cost_center" {
  description = "Cost center for billing and chargeback purposes"
  type        = string
  default     = "training-lab"
}

variable "billing_code" {
  description = "Billing code for cost allocation"
  type        = string
  default     = "TRAIN-001"
}

variable "enable_cost_optimization" {
  description = "Enable cost optimization features"
  type        = bool
  default     = true
}

variable "enable_auto_shutdown" {
  description = "Enable automatic shutdown scheduling for cost savings"
  type        = bool
  default     = true
}

variable "auto_shutdown_schedule" {
  description = "Cron schedule for automatic shutdown (format: minute hour day month weekday)"
  type        = string
  default     = "0 18 * * 1-5"  # 6 PM weekdays
  
  validation {
    condition     = can(regex("^[0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+$", var.auto_shutdown_schedule))
    error_message = "Auto shutdown schedule must be a valid cron expression."
  }
}

variable "auto_startup_schedule" {
  description = "Cron schedule for automatic startup (format: minute hour day month weekday)"
  type        = string
  default     = "0 8 * * 1-5"   # 8 AM weekdays
  
  validation {
    condition     = can(regex("^[0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+$", var.auto_startup_schedule))
    error_message = "Auto startup schedule must be a valid cron expression."
  }
}

variable "reserved_instance_eligible" {
  description = "Mark resources as eligible for reserved instance pricing"
  type        = bool
  default     = true
}

# VPC Configuration Variables
variable "vpc_name" {
  description = "Name of the VPC to be created"
  type        = string
  default     = ""  # Will be auto-generated if empty
}

variable "vpc_address_prefix_management" {
  description = "Address prefix management for the VPC (auto or manual)"
  type        = string
  default     = "auto"
  
  validation {
    condition = contains([
      "auto", "manual"
    ], var.vpc_address_prefix_management)
    error_message = "VPC address prefix management must be either 'auto' or 'manual'."
  }
}

variable "vpc_classic_access" {
  description = "Enable classic infrastructure access for the VPC"
  type        = bool
  default     = false
}

# Subnet Configuration Variables
variable "subnet_name" {
  description = "Name of the subnet to be created"
  type        = string
  default     = ""  # Will be auto-generated if empty
}

variable "subnet_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = ""  # Will be auto-generated based on region
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.240.0.0/24"
  
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid IPv4 CIDR block."
  }
}

variable "subnet_public_gateway" {
  description = "Enable public gateway for the subnet"
  type        = bool
  default     = true
}

# Virtual Server Instance Configuration
variable "vsi_name" {
  description = "Name of the virtual server instance"
  type        = string
  default     = ""  # Will be auto-generated if empty
}

variable "vsi_image_name" {
  description = "Name of the OS image for the virtual server instance"
  type        = string
  default     = "ibm-ubuntu-20-04-3-minimal-amd64-2"
}

variable "vsi_profile" {
  description = "Profile (size) of the virtual server instance"
  type        = string
  default     = "bx2-2x8"
  
  validation {
    condition = contains([
      "bx2-2x8", "bx2-4x16", "bx2-8x32", "cx2-2x4", "cx2-4x8", "mx2-2x16"
    ], var.vsi_profile)
    error_message = "VSI profile must be a valid IBM Cloud instance profile."
  }
}

variable "vsi_ssh_key_name" {
  description = "Name of the SSH key to use for VSI access (must exist in IBM Cloud)"
  type        = string
  default     = ""  # Optional - if empty, password authentication will be used
}

variable "boot_volume_size" {
  description = "Size of the boot volume in GB"
  type        = number
  default     = 100
  
  validation {
    condition     = var.boot_volume_size >= 25 && var.boot_volume_size <= 250
    error_message = "Boot volume size must be between 25 and 250 GB."
  }
}

# Security Group Configuration
variable "security_group_rules" {
  description = "List of security group rules to apply"
  type = list(object({
    direction   = string
    ip_version  = string
    protocol    = string
    port_min    = optional(number)
    port_max    = optional(number)
    remote      = string
    description = optional(string)
  }))
  
  default = [
    {
      direction   = "inbound"
      ip_version  = "ipv4"
      protocol    = "tcp"
      port_min    = 22
      port_max    = 22
      remote      = "0.0.0.0/0"
      description = "Allow SSH access"
    },
    {
      direction   = "inbound"
      ip_version  = "ipv4"
      protocol    = "icmp"
      remote      = "0.0.0.0/0"
      description = "Allow ICMP (ping)"
    },
    {
      direction   = "outbound"
      ip_version  = "ipv4"
      protocol    = "all"
      remote      = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  ]
}

# Resource Tagging
variable "tags" {
  description = "List of tags to apply to all resources"
  type        = list(string)
  default     = ["iac-training", "terraform", "lab-1.2", "cost-optimization"]
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Cost and Resource Management
variable "auto_delete_volume" {
  description = "Automatically delete boot volume when VSI is deleted"
  type        = bool
  default     = true
}

variable "volume_encryption_key" {
  description = "CRN of the encryption key for volume encryption (optional)"
  type        = string
  default     = ""
}

# IBM Cloud Service Enablement
variable "enable_cos_demo" {
  description = "Enable Cloud Object Storage for cost optimization demonstration"
  type        = bool
  default     = true
}

variable "enable_key_protect" {
  description = "Enable Key Protect for security benefits demonstration"
  type        = bool
  default     = false  # Set to false to avoid additional costs
}

variable "enable_monitoring" {
  description = "Enable monitoring for operational efficiency demonstration"
  type        = bool
  default     = true
}

variable "enable_activity_tracker" {
  description = "Enable Activity Tracker for compliance demonstration"
  type        = bool
  default     = true
}

variable "enable_data_expiration" {
  description = "Enable automatic data expiration in COS for cost optimization"
  type        = bool
  default     = false  # Set to false for training data preservation
}

# Development and Testing Options
variable "create_public_gateway" {
  description = "Create a public gateway for internet access"
  type        = bool
  default     = true
}

variable "create_floating_ip" {
  description = "Create a floating IP for the VSI"
  type        = bool
  default     = false
}

variable "enable_ip_spoofing" {
  description = "Enable IP spoofing for the VSI network interface"
  type        = bool
  default     = false
}

# Data sources for SSH key (if specified)
data "ibm_is_ssh_key" "training_key" {
  count = var.vsi_ssh_key_name != "" ? 1 : 0
  name  = var.vsi_ssh_key_name
}
