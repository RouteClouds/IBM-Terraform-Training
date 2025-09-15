# Git Collaboration Lab - Variable Definitions
# Comprehensive variable configuration for enterprise Git workflows and team collaboration

# =============================================================================
# CORE CONFIGURATION VARIABLES
# =============================================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key for authentication and resource management"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.ibmcloud_api_key) > 20
    error_message = "IBM Cloud API key must be a valid key with more than 20 characters."
  }
}

variable "resource_group_id" {
  description = "IBM Cloud resource group ID for organizing and managing resources"
  type        = string
  default     = null
  
  validation {
    condition = var.resource_group_id == null || can(regex("^[a-f0-9]{32}$", var.resource_group_id))
    error_message = "Resource group ID must be a valid 32-character hexadecimal string or null for default."
  }
}

variable "terraform_version_constraint" {
  description = "Terraform version constraint for team consistency and reproducible builds"
  type        = string
  default     = ">= 1.5.0"
  
  validation {
    condition     = can(regex("^[><=~!]+\\s*[0-9]+\\.[0-9]+\\.[0-9]+", var.terraform_version_constraint))
    error_message = "Terraform version constraint must be a valid semantic version constraint."
  }
}

# =============================================================================
# ORGANIZATION AND TEAM CONFIGURATION
# =============================================================================

variable "organization_config" {
  description = "Organization configuration including team structure, governance, and enterprise settings"
  type = object({
    # Basic organization information
    name         = string
    division     = string
    cost_center  = string
    environment  = string
    project_name = string
    
    # Team and ownership information
    owner_team    = string
    contact_email = string
    manager       = string
    
    # Resource group and governance
    resource_group_name = string
    governance_level    = string
    compliance_framework = string
    
    # Default tagging strategy
    default_tags = map(string)
  })
  
  validation {
    condition = can(regex("^[A-Z][a-zA-Z0-9 ]*$", var.organization_config.name))
    error_message = "Organization name must start with uppercase letter and contain only letters, numbers, and spaces."
  }
  
  validation {
    condition = contains(["development", "staging", "production"], var.organization_config.environment)
    error_message = "Environment must be development, staging, or production."
  }
  
  validation {
    condition = can(regex("^CC-[A-Z]{3}-[0-9]{3}$", var.organization_config.cost_center))
    error_message = "Cost center must follow format CC-XXX-000."
  }
  
  validation {
    condition = contains(["basic", "standard", "enterprise"], var.organization_config.governance_level)
    error_message = "Governance level must be basic, standard, or enterprise."
  }
}

variable "team_configuration" {
  description = "Team structure and role-based access control configuration for Git collaboration"
  type = object({
    # Team definitions with roles and responsibilities
    teams = map(object({
      name         = string
      description  = string
      lead         = string
      members      = list(string)
      repositories = list(string)
      permissions  = list(string)
      environments = list(string)
    }))
    
    # Role definitions and permission matrix
    roles = map(object({
      name        = string
      description = string
      permissions = object({
        repository_access   = string
        branch_permissions  = list(string)
        deployment_rights   = list(string)
        review_requirements = string
      })
    }))
    
    # Approval workflow configuration
    approval_workflows = object({
      feature_branch = object({
        required_reviewers = number
        dismiss_stale_reviews = bool
        require_code_owner_reviews = bool
      })
      
      release_branch = object({
        required_reviewers = number
        required_teams = list(string)
        security_review_required = bool
      })
      
      production_deployment = object({
        required_reviewers = number
        required_teams = list(string)
        manual_approval_required = bool
        compliance_check_required = bool
      })
    })
  })
  
  validation {
    condition = length(var.team_configuration.teams) > 0
    error_message = "At least one team must be defined in team configuration."
  }
}

# =============================================================================
# GIT WORKFLOW CONFIGURATION
# =============================================================================

variable "git_workflow_config" {
  description = "Git workflow patterns and branching strategy configuration"
  type = object({
    # Workflow pattern selection
    workflow_pattern = string
    
    # Branch protection rules
    branch_protection = object({
      main_branch = object({
        required_status_checks = list(string)
        required_reviewers = number
        dismiss_stale_reviews = bool
        enforce_admins = bool
        allow_force_pushes = bool
      })
      
      develop_branch = object({
        required_status_checks = list(string)
        required_reviewers = number
        dismiss_stale_reviews = bool
      })
      
      feature_branches = object({
        naming_pattern = string
        auto_delete_on_merge = bool
        require_linear_history = bool
      })
    })
    
    # Merge strategies and policies
    merge_policies = object({
      default_merge_method = string
      allow_squash_merge = bool
      allow_merge_commit = bool
      allow_rebase_merge = bool
      auto_merge_enabled = bool
    })
    
    # Repository settings
    repository_settings = object({
      default_branch = string
      visibility = string
      has_issues = bool
      has_projects = bool
      has_wiki = bool
      vulnerability_alerts = bool
    })
  })
  
  validation {
    condition = contains(["gitflow", "github-flow", "gitlab-flow", "trunk-based"], var.git_workflow_config.workflow_pattern)
    error_message = "Workflow pattern must be gitflow, github-flow, gitlab-flow, or trunk-based."
  }
  
  validation {
    condition = contains(["merge", "squash", "rebase"], var.git_workflow_config.merge_policies.default_merge_method)
    error_message = "Default merge method must be merge, squash, or rebase."
  }
}

# =============================================================================
# CI/CD PIPELINE CONFIGURATION
# =============================================================================

variable "cicd_pipeline_config" {
  description = "CI/CD pipeline configuration for automated validation and deployment"
  type = object({
    # Pipeline stages and validation
    validation_stages = object({
      syntax_validation = object({
        enabled = bool
        tools = list(string)
        fail_on_error = bool
      })
      
      security_scanning = object({
        enabled = bool
        tools = list(string)
        severity_threshold = string
        fail_on_high = bool
      })
      
      cost_analysis = object({
        enabled = bool
        tools = list(string)
        budget_threshold = number
        alert_on_increase = bool
      })
      
      policy_validation = object({
        enabled = bool
        frameworks = list(string)
        fail_on_violation = bool
      })
    })
    
    # Deployment configuration
    deployment_config = object({
      environments = list(string)
      deployment_strategy = string
      rollback_enabled = bool
      blue_green_enabled = bool
      canary_enabled = bool
    })
    
    # Notification and monitoring
    notifications = object({
      slack_webhook = string
      email_recipients = list(string)
      teams_webhook = string
      notify_on_success = bool
      notify_on_failure = bool
    })
    
    # Pipeline triggers
    triggers = object({
      push_to_main = bool
      push_to_develop = bool
      pull_request = bool
      scheduled_runs = string
      manual_trigger = bool
    })
  })
  
  validation {
    condition = contains(["rolling", "blue-green", "canary", "recreate"], var.cicd_pipeline_config.deployment_config.deployment_strategy)
    error_message = "Deployment strategy must be rolling, blue-green, canary, or recreate."
  }
}

# =============================================================================
# SECURITY AND COMPLIANCE CONFIGURATION
# =============================================================================

variable "security_config" {
  description = "Security and compliance configuration for enterprise governance"
  type = object({
    # Policy as code configuration
    policy_as_code = object({
      enabled = bool
      frameworks = list(string)
      custom_policies = list(string)
      enforcement_level = string
    })
    
    # Secrets management
    secrets_management = object({
      vault_integration = bool
      environment_variables = bool
      sensitive_attributes = bool
      pre_commit_hooks = bool
      secret_scanning = bool
    })
    
    # Compliance frameworks
    compliance = object({
      frameworks = list(string)
      audit_logging = bool
      compliance_reporting = bool
      automated_remediation = bool
    })
    
    # Security scanning configuration
    security_scanning = object({
      static_analysis = bool
      dependency_scanning = bool
      container_scanning = bool
      infrastructure_scanning = bool
      continuous_monitoring = bool
    })
    
    # Access control and authentication
    access_control = object({
      rbac_enabled = bool
      mfa_required = bool
      session_timeout = number
      audit_trail = bool
    })
  })
  
  validation {
    condition = contains(["advisory", "enforcing", "blocking"], var.security_config.policy_as_code.enforcement_level)
    error_message = "Policy enforcement level must be advisory, enforcing, or blocking."
  }
}

# =============================================================================
# REGIONAL AND ENVIRONMENT CONFIGURATION
# =============================================================================

variable "regional_configuration" {
  description = "Multi-region configuration for disaster recovery and high availability"
  type = object({
    # Primary region configuration
    primary_region = string
    primary_zones = list(string)
    
    # Secondary region for staging and backup
    secondary_region = string
    secondary_zones = list(string)
    
    # Disaster recovery region
    dr_region = string
    dr_zones = list(string)
    
    # Cross-region replication settings
    cross_region_replication = object({
      enabled = bool
      replication_frequency = string
      backup_retention_days = number
    })
    
    # Network connectivity between regions
    inter_region_connectivity = object({
      vpn_enabled = bool
      direct_link = bool
      transit_gateway = bool
    })
  })
  
  validation {
    condition = contains([
      "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "jp-osa", 
      "au-syd", "ca-tor", "br-sao"
    ], var.regional_configuration.primary_region)
    error_message = "Primary region must be a valid IBM Cloud region."
  }
  
  validation {
    condition = var.regional_configuration.primary_region != var.regional_configuration.secondary_region
    error_message = "Primary and secondary regions must be different."
  }
}

# =============================================================================
# COST MANAGEMENT AND BUDGET CONFIGURATION
# =============================================================================

variable "cost_configuration" {
  description = "Cost management, budget tracking, and optimization configuration"
  type = object({
    # Budget and cost limits
    monthly_budget_limit = number
    cost_center = string
    billing_account_id = string
    
    # Cost allocation and tagging
    cost_allocation_tags = map(string)
    department_allocation = map(number)
    project_allocation = map(number)
    
    # Cost monitoring and alerts
    cost_alerts = object({
      enabled = bool
      thresholds = list(number)
      notification_channels = list(string)
      automated_actions = list(string)
    })
    
    # Cost optimization settings
    optimization = object({
      auto_scaling_enabled = bool
      scheduled_shutdown = bool
      right_sizing_enabled = bool
      reserved_instances = bool
      spot_instances = bool
    })
    
    # Budget enforcement
    budget_enforcement = object({
      hard_limits = bool
      approval_required_above = number
      automatic_shutdown = bool
      notification_escalation = bool
    })
  })
  
  validation {
    condition = var.cost_configuration.monthly_budget_limit > 0
    error_message = "Monthly budget limit must be greater than 0."
  }
  
  validation {
    condition = length(var.cost_configuration.cost_allocation_tags) > 0
    error_message = "At least one cost allocation tag must be specified."
  }
}

# =============================================================================
# INFRASTRUCTURE CONFIGURATION
# =============================================================================

variable "infrastructure_config" {
  description = "Infrastructure configuration for Git collaboration lab environment"
  type = object({
    # VPC and networking configuration
    networking = object({
      vpc_name = string
      address_prefix_management = string
      enable_public_gateway = bool

      subnets = list(object({
        name = string
        zone = string
        cidr_block = string
        public_gateway_enabled = bool
      }))

      security_groups = list(object({
        name = string
        description = string
        rules = list(object({
          direction = string
          protocol = string
          port_min = number
          port_max = number
          source_type = string
          source = string
        }))
      }))
    })

    # Compute configuration for development environments
    compute = object({
      create_instances = bool
      instance_count = number
      instance_profile = string
      image_name = string

      ssh_key = object({
        create_new = bool
        key_name = string
        public_key_file = string
      })
    })

    # Storage configuration
    storage = object({
      create_cos_bucket = bool
      bucket_name = string
      storage_class = string
      versioning_enabled = bool

      backup_configuration = object({
        enabled = bool
        frequency = string
        retention_days = number
      })
    })

    # Monitoring and observability
    monitoring = object({
      enable_activity_tracker = bool
      enable_log_analysis = bool
      enable_monitoring = bool

      log_retention_days = number
      metrics_retention_days = number

      alerting = object({
        enabled = bool
        notification_channels = list(string)
        alert_thresholds = map(number)
      })
    })
  })

  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.infrastructure_config.networking.vpc_name))
    error_message = "VPC name must follow naming convention: lowercase, start with letter, alphanumeric and hyphens only."
  }

  validation {
    condition = var.infrastructure_config.compute.instance_count >= 0 && var.infrastructure_config.compute.instance_count <= 10
    error_message = "Instance count must be between 0 and 10."
  }
}

# =============================================================================
# FEATURE FLAGS AND EXPERIMENTAL SETTINGS
# =============================================================================

variable "feature_flags" {
  description = "Feature flags for enabling/disabling functionality and experimental features"
  type = object({
    # Git workflow features
    enable_advanced_workflows = bool
    enable_automated_merging = bool
    enable_dependency_updates = bool

    # CI/CD features
    enable_parallel_builds = bool
    enable_canary_deployments = bool
    enable_automated_rollbacks = bool

    # Security features
    enable_advanced_scanning = bool
    enable_policy_enforcement = bool
    enable_compliance_automation = bool

    # Monitoring features
    enable_advanced_monitoring = bool
    enable_predictive_analytics = bool
    enable_automated_remediation = bool

    # Cost optimization features
    enable_cost_optimization = bool
    enable_resource_scheduling = bool
    enable_budget_enforcement = bool

    # Experimental features
    experimental_features = map(bool)
  })

  default = {
    enable_advanced_workflows = true
    enable_automated_merging = false
    enable_dependency_updates = true
    enable_parallel_builds = true
    enable_canary_deployments = false
    enable_automated_rollbacks = true
    enable_advanced_scanning = true
    enable_policy_enforcement = true
    enable_compliance_automation = true
    enable_advanced_monitoring = true
    enable_predictive_analytics = false
    enable_automated_remediation = false
    enable_cost_optimization = true
    enable_resource_scheduling = true
    enable_budget_enforcement = true
    experimental_features = {}
  }
}

# =============================================================================
# ENVIRONMENT-SPECIFIC OVERRIDES
# =============================================================================

variable "environment_overrides" {
  description = "Environment-specific configuration overrides for different deployment stages"
  type = map(object({
    # Resource scaling overrides
    instance_count_override = number
    instance_profile_override = string

    # Security overrides
    security_level_override = string
    compliance_override = bool

    # Monitoring overrides
    monitoring_level_override = string
    log_retention_override = number

    # Cost overrides
    budget_override = number
    cost_alerts_override = bool

    # Feature flag overrides
    feature_overrides = map(bool)
  }))

  default = {
    development = {
      instance_count_override = 1
      instance_profile_override = "bx2-2x8"
      security_level_override = "basic"
      compliance_override = false
      monitoring_level_override = "basic"
      log_retention_override = 7
      budget_override = 500
      cost_alerts_override = true
      feature_overrides = {
        enable_advanced_scanning = false
        enable_compliance_automation = false
      }
    }

    staging = {
      instance_count_override = 2
      instance_profile_override = "bx2-4x16"
      security_level_override = "standard"
      compliance_override = true
      monitoring_level_override = "standard"
      log_retention_override = 30
      budget_override = 2000
      cost_alerts_override = true
      feature_overrides = {
        enable_advanced_scanning = true
        enable_compliance_automation = true
      }
    }

    production = {
      instance_count_override = 3
      instance_profile_override = "bx2-8x32"
      security_level_override = "enterprise"
      compliance_override = true
      monitoring_level_override = "enterprise"
      log_retention_override = 90
      budget_override = 10000
      cost_alerts_override = true
      feature_overrides = {
        enable_advanced_scanning = true
        enable_compliance_automation = true
        enable_automated_rollbacks = true
      }
    }
  }
}
