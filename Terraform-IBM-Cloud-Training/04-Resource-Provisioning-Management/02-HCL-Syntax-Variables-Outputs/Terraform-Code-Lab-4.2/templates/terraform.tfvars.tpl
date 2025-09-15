# =============================================================================
# DYNAMIC TERRAFORM VARIABLES TEMPLATE
# Advanced HCL Configuration Lab - Topic 4.2
# Generated dynamically based on configuration
# =============================================================================

# Authentication and Provider Configuration
resource_group_id = "12345678901234567890123456789012"

# Region Configuration
primary_region = "${region}"
secondary_region = "us-east"
disaster_recovery_region = "eu-gb"

# Project Configuration
project_configuration = {
  project_name        = "${project_name}"
  project_code        = "HCL-001"
  project_description = "Advanced HCL Configuration Laboratory - ${environment}"
  project_owner       = "terraform-admin@company.com"
  
  organization = {
    name        = "acme-corp"
    division    = "engineering"
    department  = "platform-engineering"
    cost_center = "eng-001"
    budget_code = "budget-eng-2024"
  }
  
  environment = {
    name        = "${environment}"
    tier        = "%{ if environment == "production" }prod%{ else }${environment}%{ endif }"
    purpose     = "%{ if environment == "production" }production-workload%{ else }training-lab%{ endif }"
    criticality = "%{ if environment == "production" }critical%{ else }%{ if environment == "staging" }high%{ else }low%{ endif }%{ endif }"
  }
  
  compliance = {
    frameworks = %{ if environment == "production" }["sox", "iso27001", "pci-dss"]%{ else }["iso27001"]%{ endif }
    data_classification = "%{ if environment == "production" }confidential%{ else }internal%{ endif }"
    retention_period = %{ if environment == "production" }2555%{ else }90%{ endif }
    audit_required = %{ if environment == "production" }true%{ else }false%{ endif }
  }
  
  technical = {
    architecture_pattern = "multi-tier"
    deployment_model     = "%{ if environment == "production" }hybrid-cloud%{ else }cloud-native%{ endif }"
    scaling_strategy     = "%{ if environment == "production" }auto-scaling%{ else }horizontal%{ endif }"
    backup_strategy      = "%{ if environment == "production" }cross-region%{ else }automated%{ endif }"
  }
}

# Infrastructure Configuration
infrastructure_configuration = {
  network = {
    vpc_cidr_blocks = ["${vpc_cidr}"]
    subnet_configuration = {
      public_subnets   = ${jsonencode(public_subnets)}
      private_subnets  = ${jsonencode(private_subnets)}
      database_subnets = ["10.0.100.0/24", "10.0.200.0/24"%{ if environment == "production" }, "10.0.300.0/24"%{ endif }]
    }
    enable_flow_logs   = %{ if environment == "production" }true%{ else }false%{ endif }
    enable_nat_gateway = true
    dns_configuration = {
      enable_dns_hostnames = true
      enable_dns_support   = true
      custom_dns_servers   = %{ if environment == "production" }["161.26.0.10", "161.26.0.11"]%{ else }["8.8.8.8", "8.8.4.4"]%{ endif }
    }
  }
  
  compute = {
    instance_types = {
      web_tier = {
        instance_profile  = "%{ if environment == "production" }bx2-4x16%{ else }%{ if environment == "staging" }bx2-2x8%{ else }bx2-2x8%{ endif }%{ endif }"
        min_instances    = %{ if environment == "production" }3%{ else }1%{ endif }
        max_instances    = %{ if environment == "production" }10%{ else }%{ if environment == "staging" }3%{ else }2%{ endif }%{ endif }
        desired_instances = %{ if environment == "production" }5%{ else }%{ if environment == "staging" }2%{ else }1%{ endif }%{ endif }
      }
      app_tier = {
        instance_profile  = "%{ if environment == "production" }bx2-8x32%{ elif environment == "staging" }bx2-4x16%{ else }bx2-2x8%{ endif }"
        min_instances    = %{ if environment == "production" }3%{ else }1%{ endif }
        max_instances    = %{ if environment == "production" }15%{ elif environment == "staging" }5%{ else }2%{ endif }
        desired_instances = %{ if environment == "production" }5%{ elif environment == "staging" }2%{ else }1%{ endif }
      }
      data_tier = {
        instance_profile  = "%{ if environment == "production" }bx2-16x64%{ elif environment == "staging" }bx2-8x32%{ else }bx2-4x16%{ endif }"
        min_instances    = %{ if environment == "production" }2%{ else }1%{ endif }
        max_instances    = %{ if environment == "production" }3%{ else }1%{ endif }
        desired_instances = %{ if environment == "production" }2%{ else }1%{ endif }
      }
    }
    auto_scaling = {
      enabled               = %{ if environment == "production" }true%{ else }false%{ endif }
      scale_up_threshold    = 70
      scale_down_threshold  = 30
      scale_up_adjustment   = %{ if environment == "production" }2%{ else }1%{ endif }
      scale_down_adjustment = 1
    }
  }
  
  storage = {
    volume_types = {
      root_volume = {
        size_gb     = %{ if environment == "production" }200%{ elif environment == "staging" }100%{ else }50%{ endif }
        volume_type = "%{ if environment == "production" }10iops-tier%{ else }general-purpose%{ endif }"
        encrypted   = true
      }
      data_volume = {
        size_gb     = %{ if environment == "production" }2000%{ elif environment == "staging" }500%{ else }100%{ endif }
        volume_type = "%{ if environment == "production" }10iops-tier%{ else }general-purpose%{ endif }"
        encrypted   = true
      }
    }
    backup_configuration = {
      enabled           = true
      retention_days    = %{ if environment == "production" }90%{ elif environment == "staging" }30%{ else }7%{ endif }
      backup_schedule   = "daily"
      cross_region_copy = %{ if environment == "production" }true%{ else }false%{ endif }
    }
  }
  
  security = {
    encryption = {
      at_rest_enabled       = true
      in_transit_enabled    = true
      key_management        = "%{ if environment == "production" }customer%{ else }ibm%{ endif }"
      customer_managed_keys = %{ if environment == "production" }true%{ else }false%{ endif }
    }
    access_control = {
      enable_iam_roles = true
      enable_mfa      = %{ if environment == "production" }true%{ else }false%{ endif }
      session_timeout = %{ if environment == "production" }1800%{ else }3600%{ endif }
      password_policy = {
        min_length        = %{ if environment == "production" }16%{ elif environment == "staging" }12%{ else }8%{ endif }
        require_symbols   = %{ if environment == "production" }true%{ else }false%{ endif }
        require_numbers   = true
        require_uppercase = true
        require_lowercase = true
      }
    }
  }
  
  monitoring = {
    enabled = ${enable_monitoring}
    metrics = {
      detailed_monitoring = %{ if environment == "production" }true%{ else }false%{ endif }
      custom_metrics     = %{ if environment == "production" }true%{ else }false%{ endif }
      retention_days     = %{ if environment == "production" }365%{ elif environment == "staging" }90%{ else }7%{ endif }
    }
    logging = {
      application_logs = true
      system_logs     = true
      audit_logs      = %{ if environment == "production" }true%{ else }false%{ endif }
      log_retention   = %{ if environment == "production" }365%{ elif environment == "staging" }90%{ else }7%{ endif }
    }
    alerting = {
      enabled = %{ if environment == "production" }true%{ else }false%{ endif }
      notification_channels = %{ if environment == "production" }["email", "slack", "pagerduty"]%{ elif environment == "staging" }["email", "slack"]%{ else }[]%{ endif }
      alert_thresholds = {
        cpu_utilization    = %{ if environment == "production" }70%{ elif environment == "staging" }80%{ else }90%{ endif }
        memory_utilization = %{ if environment == "production" }75%{ elif environment == "staging" }85%{ else }90%{ endif }
        disk_utilization   = %{ if environment == "production" }80%{ elif environment == "staging" }90%{ else }95%{ endif }
        network_throughput = %{ if environment == "production" }800%{ else }1000%{ endif }
      }
    }
  }
}

# Feature Flags
feature_flags = {
  enable_multi_region      = %{ if environment == "production" }true%{ elif environment == "staging" }true%{ else }false%{ endif }
  enable_disaster_recovery = %{ if environment == "production" }true%{ else }false%{ endif }
  enable_auto_scaling      = %{ if environment == "production" }true%{ elif environment == "staging" }true%{ else }false%{ endif }
  enable_monitoring        = ${enable_monitoring}
  enable_backup           = ${enable_backup}
  enable_advanced_features = %{ if environment == "production" }true%{ elif environment == "staging" }true%{ else }false%{ endif }
  enable_cost_optimization = %{ if environment == "production" }false%{ else }true%{ endif }
  enable_security_scanning = %{ if environment == "production" }true%{ elif environment == "staging" }true%{ else }false%{ endif }
  enable_compliance_checks = %{ if environment == "production" }true%{ elif environment == "staging" }true%{ else }false%{ endif }
  enable_performance_tuning = %{ if environment == "production" }true%{ else }false%{ endif }
  enable_debug_mode          = %{ if environment == "production" }false%{ else }true%{ endif }
  enable_provider_validation = true
  enable_resource_validation = true
  enable_output_validation   = true
}

# Global Tags
global_tags = {
  "managed-by"      = "terraform"
  "lab-name"        = "hcl-advanced-4.2"
  "created-by"      = "terraform-training"
  "purpose"         = "%{ if environment == "production" }production%{ else }education%{ endif }"
  "cost-tracking"   = "%{ if environment == "production" }production-budget%{ else }training-budget%{ endif }"
  "environment"     = "${environment}"
  "auto-shutdown"   = "%{ if environment == "production" }disabled%{ else }enabled%{ endif }"
  "backup-required" = "%{ if environment == "production" }comprehensive%{ elif environment == "staging" }standard%{ else }basic%{ endif }"
}

# Advanced Configuration
advanced_configuration = {
  performance = {
    enable_performance_mode = %{ if environment == "production" }true%{ else }false%{ endif }
    cpu_optimization       = "%{ if environment == "production" }performance%{ else }cost%{ endif }"
    memory_optimization    = "%{ if environment == "production" }performance%{ else }cost%{ endif }"
    network_optimization   = "%{ if environment == "production" }performance%{ else }balanced%{ endif }"
    storage_optimization   = "%{ if environment == "production" }performance%{ else }cost%{ endif }"
  }
  
  cost_optimization = {
    enable_cost_controls = %{ if environment == "production" }false%{ else }true%{ endif }
    budget_alerts       = true
    resource_scheduling = {
      enable_scheduling = %{ if environment == "production" }false%{ else }true%{ endif }
      start_schedule   = "08:00"
      stop_schedule    = "18:00"
      timezone        = "UTC"
    }
    rightsizing = {
      enable_rightsizing = %{ if environment == "production" }false%{ else }true%{ endif }
      analysis_period   = %{ if environment == "production" }30%{ else }7%{ endif }
      threshold_cpu     = %{ if environment == "production" }30%{ else }10%{ endif }
      threshold_memory  = %{ if environment == "production" }40%{ else }20%{ endif }
    }
  }
  
  operations = {
    maintenance_window = {
      enabled     = true
      day_of_week = "%{ if environment == "production" }sunday%{ else }saturday%{ endif }"
      start_time  = "02:00"
      duration    = %{ if environment == "production" }4%{ else }2%{ endif }
    }
    change_management = {
      require_approval = %{ if environment == "production" }true%{ else }false%{ endif }
      approval_timeout = %{ if environment == "production" }24%{ else }1%{ endif }
      rollback_enabled = true
    }
    incident_response = {
      enable_auto_response  = %{ if environment == "production" }true%{ else }false%{ endif }
      escalation_timeout   = %{ if environment == "production" }30%{ else }60%{ endif }
      notification_channels = %{ if environment == "production" }["email", "slack", "pagerduty"]%{ elif environment == "staging" }["email", "slack"]%{ else }["email"]%{ endif }
    }
  }
}
