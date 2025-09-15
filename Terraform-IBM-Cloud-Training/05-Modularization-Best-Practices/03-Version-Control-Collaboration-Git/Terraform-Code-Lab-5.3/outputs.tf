# Git Collaboration Lab - Output Definitions
# Comprehensive outputs for integration, monitoring, and team collaboration

# =============================================================================
# INFRASTRUCTURE INTEGRATION OUTPUTS
# =============================================================================

output "infrastructure_summary" {
  description = "Complete infrastructure summary for Git collaboration lab environment"
  value = {
    # VPC and networking information
    networking = {
      vpc_id   = ibm_is_vpc.git_lab_vpc.id
      vpc_name = ibm_is_vpc.git_lab_vpc.name
      vpc_crn  = ibm_is_vpc.git_lab_vpc.crn
      
      subnets = {
        for idx, subnet in ibm_is_subnet.git_lab_subnets : subnet.zone => {
          id         = subnet.id
          name       = subnet.name
          cidr_block = subnet.ipv4_cidr_block
          zone       = subnet.zone
          public_gateway_attached = subnet.public_gateway != null
        }
      }
      
      security_groups = {
        for idx, sg in ibm_is_security_group.git_lab_security_groups : sg.name => {
          id   = sg.id
          name = sg.name
          vpc  = sg.vpc
        }
      }
      
      public_gateways = var.infrastructure_config.networking.enable_public_gateway ? {
        for idx, gw in ibm_is_public_gateway.git_lab_gateways : gw.zone => {
          id   = gw.id
          name = gw.name
          zone = gw.zone
        }
      } : {}
    }
    
    # Compute resources
    compute = var.infrastructure_config.compute.create_instances ? {
      instances = {
        for idx, instance in ibm_is_instance.git_lab_instances : instance.name => {
          id               = instance.id
          name             = instance.name
          profile          = instance.profile
          zone             = instance.zone
          primary_ipv4     = instance.primary_network_interface[0].primary_ipv4_address
          status           = instance.status
        }
      }
      
      ssh_key = {
        id         = ibm_is_ssh_key.git_lab_ssh_key.id
        name       = ibm_is_ssh_key.git_lab_ssh_key.name
        fingerprint = ibm_is_ssh_key.git_lab_ssh_key.fingerprint
        private_key_file = var.infrastructure_config.compute.ssh_key.create_new ? local_file.git_lab_private_key[0].filename : null
      }
    } : {}
    
    # Storage resources
    storage = var.infrastructure_config.storage.create_cos_bucket ? {
      cos_instance = {
        id   = ibm_resource_instance.git_lab_cos[0].id
        name = ibm_resource_instance.git_lab_cos[0].name
        crn  = ibm_resource_instance.git_lab_cos[0].crn
      }
      
      state_bucket = {
        name         = ibm_cos_bucket.git_lab_state_bucket[0].bucket_name
        region       = ibm_cos_bucket.git_lab_state_bucket[0].region_location
        storage_class = ibm_cos_bucket.git_lab_state_bucket[0].storage_class
        versioning   = ibm_cos_bucket.git_lab_state_bucket[0].object_versioning[0].enable
      }
    } : {}
  }
  
  sensitive = false
}

output "git_workflow_configuration" {
  description = "Git workflow and collaboration configuration details"
  value = {
    # Workflow pattern and settings
    workflow_pattern = var.git_workflow_config.workflow_pattern
    
    branch_protection = {
      main_branch = {
        required_status_checks = var.git_workflow_config.branch_protection.main_branch.required_status_checks
        required_reviewers     = var.git_workflow_config.branch_protection.main_branch.required_reviewers
        dismiss_stale_reviews  = var.git_workflow_config.branch_protection.main_branch.dismiss_stale_reviews
        enforce_admins        = var.git_workflow_config.branch_protection.main_branch.enforce_admins
      }
      
      develop_branch = {
        required_status_checks = var.git_workflow_config.branch_protection.develop_branch.required_status_checks
        required_reviewers     = var.git_workflow_config.branch_protection.develop_branch.required_reviewers
        dismiss_stale_reviews  = var.git_workflow_config.branch_protection.develop_branch.dismiss_stale_reviews
      }
      
      feature_branches = {
        naming_pattern        = var.git_workflow_config.branch_protection.feature_branches.naming_pattern
        auto_delete_on_merge  = var.git_workflow_config.branch_protection.feature_branches.auto_delete_on_merge
        require_linear_history = var.git_workflow_config.branch_protection.feature_branches.require_linear_history
      }
    }
    
    merge_policies = var.git_workflow_config.merge_policies
    repository_settings = var.git_workflow_config.repository_settings
    
    # Workflow metadata
    metadata = local.git_workflow_metadata
  }
  
  sensitive = false
}

output "team_collaboration_details" {
  description = "Team structure and collaboration configuration"
  value = {
    # Team structure
    teams = {
      for team_name, team in var.team_configuration.teams : team_name => {
        name         = team.name
        description  = team.description
        lead         = team.lead
        member_count = length(team.members)
        repositories = team.repositories
        permissions  = team.permissions
        environments = team.environments
      }
    }
    
    # Role definitions
    roles = {
      for role_name, role in var.team_configuration.roles : role_name => {
        name        = role.name
        description = role.description
        permissions = role.permissions
      }
    }
    
    # Approval workflows
    approval_workflows = var.team_configuration.approval_workflows
    
    # Team metadata
    metadata = local.team_metadata
    
    # RBAC configuration
    rbac = {
      enabled = var.security_config.access_control.rbac_enabled
      mfa_required = var.security_config.access_control.mfa_required
      session_timeout = var.security_config.access_control.session_timeout
      audit_trail = var.security_config.access_control.audit_trail
    }
  }
  
  sensitive = false
}

output "cicd_pipeline_configuration" {
  description = "CI/CD pipeline configuration and automation details"
  value = {
    # Validation stages
    validation_stages = var.cicd_pipeline_config.validation_stages
    
    # Deployment configuration
    deployment = {
      environments = var.cicd_pipeline_config.deployment_config.environments
      strategy     = var.cicd_pipeline_config.deployment_config.deployment_strategy
      rollback_enabled = var.cicd_pipeline_config.deployment_config.rollback_enabled
      blue_green_enabled = var.cicd_pipeline_config.deployment_config.blue_green_enabled
      canary_enabled = var.cicd_pipeline_config.deployment_config.canary_enabled
    }
    
    # Pipeline triggers
    triggers = var.cicd_pipeline_config.triggers
    
    # Notification configuration
    notifications = {
      slack_enabled = var.cicd_pipeline_config.notifications.slack_webhook != ""
      email_enabled = length(var.cicd_pipeline_config.notifications.email_recipients) > 0
      teams_enabled = var.cicd_pipeline_config.notifications.teams_webhook != ""
      notify_on_success = var.cicd_pipeline_config.notifications.notify_on_success
      notify_on_failure = var.cicd_pipeline_config.notifications.notify_on_failure
    }
    
    # Pipeline status
    status = {
      configured = true
      validation_enabled = var.cicd_pipeline_config.validation_stages.syntax_validation.enabled
      security_scanning_enabled = var.cicd_pipeline_config.validation_stages.security_scanning.enabled
      cost_analysis_enabled = var.cicd_pipeline_config.validation_stages.cost_analysis.enabled
      policy_validation_enabled = var.cicd_pipeline_config.validation_stages.policy_validation.enabled
    }
  }
  
  sensitive = false
}

output "security_compliance_status" {
  description = "Security and compliance configuration status"
  value = {
    # Policy as code
    policy_as_code = {
      enabled = var.security_config.policy_as_code.enabled
      frameworks = var.security_config.policy_as_code.frameworks
      enforcement_level = var.security_config.policy_as_code.enforcement_level
      custom_policies_count = length(var.security_config.policy_as_code.custom_policies)
    }
    
    # Secrets management
    secrets_management = {
      vault_integration = var.security_config.secrets_management.vault_integration
      environment_variables = var.security_config.secrets_management.environment_variables
      sensitive_attributes = var.security_config.secrets_management.sensitive_attributes
      pre_commit_hooks = var.security_config.secrets_management.pre_commit_hooks
      secret_scanning = var.security_config.secrets_management.secret_scanning
    }
    
    # Compliance frameworks
    compliance = {
      frameworks = var.security_config.compliance.frameworks
      audit_logging = var.security_config.compliance.audit_logging
      compliance_reporting = var.security_config.compliance.compliance_reporting
      automated_remediation = var.security_config.compliance.automated_remediation
    }
    
    # Security scanning
    security_scanning = var.security_config.security_scanning
    
    # Overall security score
    security_score = {
      policy_enforcement = var.security_config.policy_as_code.enabled ? 25 : 0
      secrets_protection = var.security_config.secrets_management.secret_scanning ? 25 : 0
      compliance_coverage = length(var.security_config.compliance.frameworks) * 10
      scanning_coverage = var.security_config.security_scanning.static_analysis ? 25 : 0
      total_score = (
        (var.security_config.policy_as_code.enabled ? 25 : 0) +
        (var.security_config.secrets_management.secret_scanning ? 25 : 0) +
        (length(var.security_config.compliance.frameworks) * 10) +
        (var.security_config.security_scanning.static_analysis ? 25 : 0)
      )
    }
  }
  
  sensitive = false
}

output "cost_management_analysis" {
  description = "Cost management and budget analysis"
  value = {
    # Budget configuration
    budget = {
      monthly_limit = var.cost_configuration.monthly_budget_limit
      cost_center = var.cost_configuration.cost_center
      billing_account = var.cost_configuration.billing_account_id
    }
    
    # Cost allocation
    allocation = {
      tags = var.cost_configuration.cost_allocation_tags
      department_allocation = var.cost_configuration.department_allocation
      project_allocation = var.cost_configuration.project_allocation
    }
    
    # Cost alerts and monitoring
    alerts = var.cost_configuration.cost_alerts
    
    # Optimization settings
    optimization = var.cost_configuration.optimization
    
    # Budget enforcement
    enforcement = var.cost_configuration.budget_enforcement
    
    # Estimated costs (simplified calculation)
    estimated_costs = {
      vpc_cost = 0.00  # VPC is free
      subnet_cost = length(ibm_is_subnet.git_lab_subnets) * 0.00  # Subnets are free
      public_gateway_cost = var.infrastructure_config.networking.enable_public_gateway ? length(ibm_is_public_gateway.git_lab_gateways) * 45.00 : 0.00
      instance_cost = var.infrastructure_config.compute.create_instances ? local.resolved_config.instance_count * 50.00 : 0.00  # Estimated monthly cost per instance
      cos_cost = var.infrastructure_config.storage.create_cos_bucket ? 25.00 : 0.00  # Estimated COS cost
      monitoring_cost = var.infrastructure_config.monitoring.enable_activity_tracker ? 15.00 : 0.00
      
      total_monthly_estimate = (
        (var.infrastructure_config.networking.enable_public_gateway ? length(var.infrastructure_config.networking.subnets) * 45.00 : 0.00) +
        (var.infrastructure_config.compute.create_instances ? local.resolved_config.instance_count * 50.00 : 0.00) +
        (var.infrastructure_config.storage.create_cos_bucket ? 25.00 : 0.00) +
        (var.infrastructure_config.monitoring.enable_activity_tracker ? 15.00 : 0.00)
      )
    }
    
    # Budget utilization
    budget_utilization = {
      estimated_usage_percent = (
        (var.infrastructure_config.networking.enable_public_gateway ? length(var.infrastructure_config.networking.subnets) * 45.00 : 0.00) +
        (var.infrastructure_config.compute.create_instances ? local.resolved_config.instance_count * 50.00 : 0.00) +
        (var.infrastructure_config.storage.create_cos_bucket ? 25.00 : 0.00) +
        (var.infrastructure_config.monitoring.enable_activity_tracker ? 15.00 : 0.00)
      ) / var.cost_configuration.monthly_budget_limit * 100
      
      within_budget = (
        (var.infrastructure_config.networking.enable_public_gateway ? length(var.infrastructure_config.networking.subnets) * 45.00 : 0.00) +
        (var.infrastructure_config.compute.create_instances ? local.resolved_config.instance_count * 50.00 : 0.00) +
        (var.infrastructure_config.storage.create_cos_bucket ? 25.00 : 0.00) +
        (var.infrastructure_config.monitoring.enable_activity_tracker ? 15.00 : 0.00)
      ) <= var.cost_configuration.monthly_budget_limit
    }
  }
  
  sensitive = false
}

output "regional_deployment_status" {
  description = "Multi-region deployment configuration and status"
  value = {
    # Regional configuration
    regions = {
      primary = {
        region = var.regional_configuration.primary_region
        zones = var.regional_configuration.primary_zones
        deployed = true
      }
      
      secondary = {
        region = var.regional_configuration.secondary_region
        zones = var.regional_configuration.secondary_zones
        deployed = false  # Not deployed in this lab
      }
      
      dr = {
        region = var.regional_configuration.dr_region
        zones = var.regional_configuration.dr_zones
        deployed = false  # Not deployed in this lab
      }
    }
    
    # Cross-region configuration
    cross_region = var.regional_configuration.cross_region_replication
    
    # Inter-region connectivity
    connectivity = var.regional_configuration.inter_region_connectivity
    
    # Deployment metadata
    deployment_metadata = {
      deployment_id = random_id.deployment_id.hex
      resource_suffix = random_string.resource_suffix.result
      deployment_timestamp = timestamp()
      environment = local.current_environment
    }
  }
  
  sensitive = false
}

output "feature_flags_status" {
  description = "Feature flags and experimental settings status"
  value = {
    # Current feature flag settings
    current_flags = var.feature_flags
    
    # Environment-specific overrides
    environment_overrides = local.environment_config.feature_overrides
    
    # Resolved active features
    active_features = local.active_features
    
    # Feature categories
    categories = {
      git_workflow_features = {
        advanced_workflows = local.active_features.enable_advanced_workflows
        automated_merging = local.active_features.enable_automated_merging
        dependency_updates = local.active_features.enable_dependency_updates
      }
      
      cicd_features = {
        parallel_builds = local.active_features.enable_parallel_builds
        canary_deployments = local.active_features.enable_canary_deployments
        automated_rollbacks = local.active_features.enable_automated_rollbacks
      }
      
      security_features = {
        advanced_scanning = local.active_features.enable_advanced_scanning
        policy_enforcement = local.active_features.enable_policy_enforcement
        compliance_automation = local.active_features.enable_compliance_automation
      }
      
      monitoring_features = {
        advanced_monitoring = local.active_features.enable_advanced_monitoring
        predictive_analytics = local.active_features.enable_predictive_analytics
        automated_remediation = local.active_features.enable_automated_remediation
      }
      
      cost_features = {
        cost_optimization = local.active_features.enable_cost_optimization
        resource_scheduling = local.active_features.enable_resource_scheduling
        budget_enforcement = local.active_features.enable_budget_enforcement
      }
    }
    
    # Experimental features
    experimental = local.active_features.experimental_features
  }
  
  sensitive = false
}

output "operational_metadata" {
  description = "Operational information for management and monitoring"
  value = {
    # Deployment information
    deployment_info = {
      deployment_id = random_id.deployment_id.hex
      resource_suffix = random_string.resource_suffix.result
      deployment_timestamp = timestamp()
      terraform_version = var.terraform_version_constraint
      environment = local.current_environment
      workflow_pattern = var.git_workflow_config.workflow_pattern
    }

    # Resource inventory
    resource_inventory = {
      vpc_count = 1
      subnet_count = length(ibm_is_subnet.git_lab_subnets)
      security_group_count = length(ibm_is_security_group.git_lab_security_groups)
      instance_count = var.infrastructure_config.compute.create_instances ? local.resolved_config.instance_count : 0
      cos_instance_count = var.infrastructure_config.storage.create_cos_bucket ? 1 : 0
      monitoring_service_count = var.infrastructure_config.monitoring.enable_activity_tracker ? 1 : 0
    }

    # Configuration metadata
    configuration_metadata = {
      total_teams = local.team_metadata.total_teams
      total_roles = local.team_metadata.total_roles
      security_level = local.resolved_config.security_level
      monitoring_level = local.resolved_config.monitoring_level
      budget_limit = local.resolved_config.budget_limit
    }

    # Naming convention
    naming_convention = {
      pattern = local.resource_name_pattern
      prefix = local.resource_prefix
      organization = var.organization_config.name
      environment = local.current_environment
    }

    # Tags applied
    applied_tags = local.common_tags
  }

  sensitive = false
}

output "integration_endpoints" {
  description = "Integration endpoints for external systems and modules"
  value = {
    # VPC integration
    vpc_integration = {
      vpc_id = ibm_is_vpc.git_lab_vpc.id
      vpc_crn = ibm_is_vpc.git_lab_vpc.crn
      default_security_group_id = ibm_is_vpc.git_lab_vpc.default_security_group
      default_network_acl_id = ibm_is_vpc.git_lab_vpc.default_network_acl
    }

    # Subnet integration
    subnet_integration = {
      subnet_ids = [for subnet in ibm_is_subnet.git_lab_subnets : subnet.id]
      subnet_cidrs = [for subnet in ibm_is_subnet.git_lab_subnets : subnet.ipv4_cidr_block]
      availability_zones = [for subnet in ibm_is_subnet.git_lab_subnets : subnet.zone]
    }

    # Security group integration
    security_group_integration = {
      security_group_ids = [for sg in ibm_is_security_group.git_lab_security_groups : sg.id]
      security_group_names = [for sg in ibm_is_security_group.git_lab_security_groups : sg.name]
    }

    # SSH key integration
    ssh_key_integration = {
      ssh_key_id = ibm_is_ssh_key.git_lab_ssh_key.id
      ssh_key_name = ibm_is_ssh_key.git_lab_ssh_key.name
      ssh_key_fingerprint = ibm_is_ssh_key.git_lab_ssh_key.fingerprint
    }

    # Storage integration
    storage_integration = var.infrastructure_config.storage.create_cos_bucket ? {
      cos_instance_id = ibm_resource_instance.git_lab_cos[0].id
      cos_instance_crn = ibm_resource_instance.git_lab_cos[0].crn
      state_bucket_name = ibm_cos_bucket.git_lab_state_bucket[0].bucket_name
      state_bucket_region = ibm_cos_bucket.git_lab_state_bucket[0].region_location
    } : {}

    # Monitoring integration
    monitoring_integration = var.infrastructure_config.monitoring.enable_activity_tracker ? {
      activity_tracker_id = ibm_resource_instance.git_lab_activity_tracker[0].id
      activity_tracker_crn = ibm_resource_instance.git_lab_activity_tracker[0].crn
    } : {}
  }

  sensitive = false
}
