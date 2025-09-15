# =============================================================================
# IBM CLOUD AUTHENTICATION AND CONFIGURATION VARIABLES
# Lab 3.1: Directory Structure and Configuration Files
# =============================================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication. Obtain from https://cloud.ibm.com/iam/apikeys"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.ibmcloud_api_key) > 20
    error_message = "IBM Cloud API key must be a valid key with more than 20 characters."
  }
}

variable "ibm_region" {
  description = "IBM Cloud region for resource deployment. Choose based on your location and compliance requirements."
  type        = string
  default     = "us-south"
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "eu-es",
      "jp-tok", "jp-osa", "au-syd", "br-sao", "ca-tor"
    ], var.ibm_region)
    error_message = "IBM region must be a valid IBM Cloud region. See https://cloud.ibm.com/docs/overview?topic=overview-locations for available regions."
  }
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group. Must exist in your account."
  type        = string
  default     = "default"
  
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name cannot be empty."
  }
}

# =============================================================================
# PROJECT CONFIGURATION VARIABLES
# =============================================================================

variable "project_name" {
  description = "Name of the project for resource naming and tagging. Used as prefix for all resources."
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 20
    error_message = "Project name must be between 3 and 20 characters long."
  }
}

variable "environment" {
  description = "Environment name for resource organization and lifecycle management."
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "staging", "prod", "production"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod, production."
  }
}

variable "owner" {
  description = "Owner of the infrastructure (email address or team name) for resource tagging and accountability."
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner)) || can(regex("^[a-zA-Z0-9-_\\s]+$", var.owner))
    error_message = "Owner must be a valid email address or team name."
  }
}

variable "cost_center" {
  description = "Cost center or department code for billing and resource allocation tracking."
  type        = string
  default     = "engineering"
  
  validation {
    condition     = length(var.cost_center) > 0
    error_message = "Cost center cannot be empty."
  }
}

# =============================================================================
# NETWORK CONFIGURATION VARIABLES
# =============================================================================

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC. Must not overlap with existing networks."
  type        = string
  default     = "10.240.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR notation."
  }
  
  validation {
    condition     = tonumber(split("/", var.vpc_cidr_block)[1]) <= 16
    error_message = "VPC CIDR block must have a prefix length of /16 or larger (smaller number)."
  }
}

variable "subnet_cidr_blocks" {
  description = "List of CIDR blocks for subnets. Must be within the VPC CIDR block."
  type        = list(string)
  default     = ["10.240.1.0/24", "10.240.2.0/24", "10.240.3.0/24"]
  
  validation {
    condition     = length(var.subnet_cidr_blocks) >= 1 && length(var.subnet_cidr_blocks) <= 10
    error_message = "Must specify between 1 and 10 subnet CIDR blocks."
  }
  
  validation {
    condition     = alltrue([for cidr in var.subnet_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "All subnet CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "enable_public_gateway" {
  description = "Enable public gateway for internet access from private subnets."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs for network monitoring and security analysis."
  type        = bool
  default     = false
}

# =============================================================================
# SECURITY CONFIGURATION VARIABLES
# =============================================================================

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed for SSH access. Use ['0.0.0.0/0'] for open access (not recommended for production)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
  
  validation {
    condition     = alltrue([for cidr in var.allowed_ssh_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "All SSH CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "allowed_http_cidr_blocks" {
  description = "List of CIDR blocks allowed for HTTP access."
  type        = list(string)
  default     = ["0.0.0.0/0"]
  
  validation {
    condition     = alltrue([for cidr in var.allowed_http_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "All HTTP CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "enable_security_group_logging" {
  description = "Enable logging for security group rules for compliance and monitoring."
  type        = bool
  default     = false
}

# =============================================================================
# TAGGING AND METADATA VARIABLES
# =============================================================================

variable "resource_tags" {
  description = "Map of tags to apply to all resources for organization and cost tracking."
  type        = map(string)
  default = {
    "managed-by"    = "terraform"
    "project-type"  = "infrastructure-automation"
    "training-lab"  = "directory-structure"
  }
  
  validation {
    condition     = length(var.resource_tags) <= 50
    error_message = "Cannot specify more than 50 resource tags."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring and logging for all resources."
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Number of days to retain backups and snapshots."
  type        = number
  default     = 7
  
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention days must be between 1 and 365."
  }
}

# =============================================================================
# ADVANCED CONFIGURATION VARIABLES
# =============================================================================

variable "availability_zones" {
  description = "List of availability zones to use for resource distribution. If empty, will use all zones in the region."
  type        = list(string)
  default     = []
  
  validation {
    condition     = length(var.availability_zones) <= 3
    error_message = "Cannot specify more than 3 availability zones."
  }
}

variable "enable_classic_access" {
  description = "Enable classic infrastructure access for hybrid connectivity."
  type        = bool
  default     = false
}

variable "dns_servers" {
  description = "List of custom DNS servers for the VPC. If empty, will use IBM Cloud default DNS."
  type        = list(string)
  default     = []
  
  validation {
    condition     = length(var.dns_servers) <= 3
    error_message = "Cannot specify more than 3 DNS servers."
  }
}
