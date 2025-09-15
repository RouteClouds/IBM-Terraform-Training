# =============================================================================
# SIMPLE TERRAFORM VARIABLES TEMPLATE
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
    tier        = "${environment}"
    purpose     = "training-lab"
    criticality = "low"
  }
  
  compliance = {
    frameworks          = ["iso27001"]
    data_classification = "internal"
    retention_period    = 90
    audit_required      = false
  }
  
  technical = {
    architecture_pattern = "multi-tier"
    deployment_model     = "cloud-native"
    scaling_strategy     = "horizontal"
    backup_strategy      = "automated"
  }
}

# Infrastructure Configuration
infrastructure_configuration = {
  network = {
    vpc_cidr_blocks = ["${vpc_cidr}"]
    subnet_configuration = {
      public_subnets   = ${jsonencode(public_subnets)}
      private_subnets  = ${jsonencode(private_subnets)}
      database_subnets = ["10.0.100.0/24", "10.0.200.0/24"]
    }
    enable_flow_logs   = false
    enable_nat_gateway = true
    dns_configuration = {
      enable_dns_hostnames = true
      enable_dns_support   = true
      custom_dns_servers   = ["8.8.8.8", "8.8.4.4"]
    }
  }
  
  compute = {
    instance_types = {
      web_tier = {
        instance_profile  = "bx2-2x8"
        min_instances    = 1
        max_instances    = 2
        desired_instances = 1
      }
      app_tier = {
        instance_profile  = "bx2-2x8"
        min_instances    = 1
        max_instances    = 2
        desired_instances = 1
      }
      data_tier = {
        instance_profile  = "bx2-4x16"
        min_instances    = 1
        max_instances    = 1
        desired_instances = 1
      }
    }
    auto_scaling = {
      enabled               = false
      scale_up_threshold    = 70
      scale_down_threshold  = 30
      scale_up_adjustment   = 1
      scale_down_adjustment = 1
    }
  }
  
  storage = {
    volume_types = {
      root_volume = {
        size_gb     = 50
        volume_type = "general-purpose"
        encrypted   = true
      }
      data_volume = {
        size_gb     = 100
        volume_type = "general-purpose"
        encrypted   = true
      }
    }
    backup_configuration = {
      enabled           = true
      retention_days    = 7
      backup_schedule   = "daily"
      cross_region_copy = false
    }
  }
  
  security = {
    encryption = {
      at_rest_enabled       = true
      in_transit_enabled    = true
      key_management        = "ibm"
      customer_managed_keys = false
    }
    access_control = {
      enable_iam_roles = true
      enable_mfa      = false
      session_timeout = 3600
      password_policy = {
        min_length        = 8
        require_symbols   = false
        require_numbers   = true
        require_uppercase = true
        require_lowercase = true
      }
    }
  }
  
  monitoring = {
    enabled = ${enable_monitoring}
    metrics = {
      detailed_monitoring = false
      custom_metrics     = false
      retention_days     = 7
    }
    logging = {
      application_logs = true
      system_logs     = true
      audit_logs      = false
      log_retention   = 7
    }
    alerting = {
      enabled = false
      notification_channels = []
      alert_thresholds = {
        cpu_utilization    = 90
        memory_utilization = 90
        disk_utilization   = 95
        network_throughput = 1000
      }
    }
  }
}

# Feature Flags
feature_flags = {
  enable_multi_region      = false
  enable_disaster_recovery = false
  enable_auto_scaling      = false
  enable_monitoring        = ${enable_monitoring}
  enable_backup           = ${enable_backup}
  enable_advanced_features = false
  enable_cost_optimization = true
  enable_security_scanning = false
  enable_compliance_checks = false
  enable_performance_tuning = false
  enable_debug_mode          = true
  enable_provider_validation = true
  enable_resource_validation = true
  enable_output_validation   = true
}

# Global Tags
global_tags = {
  "managed-by"      = "terraform"
  "lab-name"        = "hcl-advanced-4.2"
  "created-by"      = "terraform-training"
  "purpose"         = "education"
  "cost-tracking"   = "training-budget"
  "environment"     = "${environment}"
  "auto-shutdown"   = "enabled"
  "backup-required" = "basic"
}

# Advanced Configuration
advanced_configuration = {
  performance = {
    enable_performance_mode = false
    cpu_optimization       = "cost"
    memory_optimization    = "cost"
    network_optimization   = "balanced"
    storage_optimization   = "cost"
  }
  
  cost_optimization = {
    enable_cost_controls = true
    budget_alerts       = true
    resource_scheduling = {
      enable_scheduling = true
      start_schedule   = "08:00"
      stop_schedule    = "18:00"
      timezone        = "UTC"
    }
    rightsizing = {
      enable_rightsizing = true
      analysis_period   = 7
      threshold_cpu     = 10
      threshold_memory  = 20
    }
  }
  
  operations = {
    maintenance_window = {
      enabled     = true
      day_of_week = "saturday"
      start_time  = "02:00"
      duration    = 2
    }
    change_management = {
      require_approval = false
      approval_timeout = 1
      rollback_enabled = true
    }
    incident_response = {
      enable_auto_response  = false
      escalation_timeout   = 60
      notification_channels = ["email"]
    }
  }
}
