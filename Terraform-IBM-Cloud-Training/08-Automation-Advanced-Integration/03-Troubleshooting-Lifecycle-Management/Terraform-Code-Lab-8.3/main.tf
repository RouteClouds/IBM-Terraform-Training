# Main Infrastructure for Topic 8.3: Troubleshooting & Lifecycle Management
# Comprehensive troubleshooting, monitoring, and operational excellence environment

# ============================================================================
# MONITORING AND OBSERVABILITY INFRASTRUCTURE
# ============================================================================

# Activity Tracker for comprehensive audit logging and troubleshooting
resource "ibm_resource_instance" "activity_tracker" {
  name              = "${local.name_prefix}-activity-tracker-${random_string.suffix.result}"
  service           = "logdnaat"
  plan              = "standard"
  location          = var.ibm_region
  resource_group_id = data.ibm_resource_group.group.id
  
  parameters = {
    "default_receiver" = true
    "archive"         = true
    "retention"       = tostring(var.log_retention_days)
    "service_endpoints" = var.private_endpoints_enabled ? "private" : "public"
  }
  
  tags = local.common_tags
  
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
  
  depends_on = [time_sleep.resource_creation_delay]
}

# Log Analysis for centralized logging and troubleshooting
resource "ibm_resource_instance" "log_analysis" {
  name              = "${local.name_prefix}-log-analysis-${random_string.suffix.result}"
  service           = "logdna"
  plan              = "standard"
  location          = var.ibm_region
  resource_group_id = data.ibm_resource_group.group.id
  
  parameters = {
    "service_endpoints" = var.private_endpoints_enabled ? "private" : "public"
    "archive"          = true
    "retention"        = tostring(var.log_retention_days)
    "default_receiver" = true
  }
  
  tags = local.common_tags
  
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# Monitoring service for performance metrics and alerting
resource "ibm_resource_instance" "monitoring" {
  name              = "${local.name_prefix}-monitoring-${random_string.suffix.result}"
  service           = "sysdig-monitor"
  plan              = "graduated-tier"
  location          = var.ibm_region
  resource_group_id = data.ibm_resource_group.group.id
  
  parameters = {
    "default_receiver" = true
    "service_endpoints" = var.private_endpoints_enabled ? "private" : "public"
  }
  
  tags = local.common_tags
  
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# Event Streams for real-time analytics and event processing
resource "ibm_resource_instance" "event_streams" {
  count = var.monitoring_enabled ? 1 : 0
  
  name              = "${local.name_prefix}-event-streams-${random_string.suffix.result}"
  service           = "messagehub"
  plan              = "standard"
  location          = var.ibm_region
  resource_group_id = data.ibm_resource_group.group.id
  
  parameters = {
    "service_endpoints" = var.private_endpoints_enabled ? "private" : "public"
    "throughput"       = "150"
    "storage_size"     = "2048"
  }
  
  tags = local.common_tags
  
  timeouts {
    create = "20m"
    update = "20m"
    delete = "20m"
  }
}

# ============================================================================
# CLOUD FUNCTIONS FOR AUTOMATION AND SELF-HEALING
# ============================================================================

# Function namespace for troubleshooting and automation functions
resource "ibm_function_namespace" "troubleshooting" {
  name              = "${local.name_prefix}-troubleshooting-${random_string.suffix.result}"
  resource_group_id = data.ibm_resource_group.group.id
  
  tags = local.common_tags
}

# Advanced diagnostic function for comprehensive health checks
resource "ibm_function_action" "advanced_diagnostics" {
  name      = "advanced-diagnostics"
  namespace = ibm_function_namespace.troubleshooting.name
  
  exec {
    kind = "nodejs:18"
    code = base64encode(templatefile("${path.module}/scripts/advanced-diagnostics.js", {
      troubleshooting_config = jsonencode(local.troubleshooting_config)
      monitoring_config     = jsonencode(local.monitoring_config)
    }))
  }
  
  limits {
    timeout = 300000  # 5 minutes
    memory  = 512
  }
  
  user_defined_parameters = {
    "ibmcloud_api_key"      = var.ibmcloud_api_key
    "resource_group_id"     = data.ibm_resource_group.group.id
    "session_id"            = random_uuid.session.result
    "debug_enabled"         = tostring(var.debug_enabled)
    "monitoring_enabled"    = tostring(var.monitoring_enabled)
  }
  
  user_defined_annotations = {
    "web-export"  = "true"
    "description" = "Advanced diagnostic and health check function"
    "version"     = "1.0.0"
  }
  
  depends_on = [ibm_function_namespace.troubleshooting]
}

# Performance monitoring function for metrics collection and analysis
resource "ibm_function_action" "performance_monitor" {
  name      = "performance-monitor"
  namespace = ibm_function_namespace.troubleshooting.name
  
  exec {
    kind = "python:3.9"
    code = base64encode(templatefile("${path.module}/scripts/performance-monitor.py", {
      performance_config = jsonencode(local.performance_config)
      monitoring_config  = jsonencode(local.monitoring_config)
    }))
  }
  
  limits {
    timeout = 300000  # 5 minutes
    memory  = 1024
  }
  
  user_defined_parameters = {
    "session_id"              = random_uuid.session.result
    "monitoring_interval"     = tostring(var.health_check_interval * 60)  # Convert to seconds
    "alert_threshold_cpu"     = tostring(var.alert_threshold_cpu)
    "alert_threshold_memory"  = tostring(var.alert_threshold_memory)
    "performance_target"      = tostring(var.slo_performance_target)
  }
  
  user_defined_annotations = {
    "web-export"  = "true"
    "description" = "Performance monitoring and metrics collection"
    "version"     = "1.0.0"
  }
}

# Self-healing function for automated remediation
resource "ibm_function_action" "self_healing" {
  count = var.self_healing_enabled ? 1 : 0
  
  name      = "self-healing"
  namespace = ibm_function_namespace.troubleshooting.name
  
  exec {
    kind = "python:3.9"
    code = base64encode(templatefile("${path.module}/scripts/self-healing.py", {
      self_healing_config = jsonencode(local.self_healing_config)
      operational_config  = jsonencode(local.operational_config)
    }))
  }
  
  limits {
    timeout = 900000  # 15 minutes
    memory  = 2048
  }
  
  user_defined_parameters = {
    "ibmcloud_api_key"       = var.ibmcloud_api_key
    "resource_group_id"      = data.ibm_resource_group.group.id
    "remediation_timeout"    = tostring(var.remediation_timeout * 60)  # Convert to seconds
    "escalation_threshold"   = tostring(var.escalation_threshold)
    "auto_recovery_enabled"  = tostring(var.auto_recovery_enabled)
    "notification_channels"  = jsonencode(var.notification_channels)
  }
  
  user_defined_annotations = {
    "web-export"  = "true"
    "description" = "Self-healing infrastructure automation"
    "version"     = "1.0.0"
  }
}

# Performance optimization function for resource right-sizing
resource "ibm_function_action" "performance_optimizer" {
  count = var.performance_optimization_enabled ? 1 : 0
  
  name      = "performance-optimizer"
  namespace = ibm_function_namespace.troubleshooting.name
  
  exec {
    kind = "python:3.9"
    code = base64encode(templatefile("${path.module}/scripts/performance-optimizer.py", {
      performance_config = jsonencode(local.performance_config)
      cost_config       = jsonencode({
        budget_limit              = var.budget_limit
        cost_optimization_enabled = var.cost_optimization_enabled
        resource_cleanup_enabled  = var.resource_cleanup_enabled
      })
    }))
  }
  
  limits {
    timeout = 900000  # 15 minutes
    memory  = 2048
  }
  
  user_defined_parameters = {
    "ibmcloud_api_key"         = var.ibmcloud_api_key
    "parallel_operations"      = tostring(var.parallel_operations)
    "batch_size"              = tostring(var.batch_size)
    "timeout_multiplier"      = tostring(var.timeout_multiplier)
    "cost_optimization_enabled" = tostring(var.cost_optimization_enabled)
  }
  
  user_defined_annotations = {
    "web-export"  = "true"
    "description" = "Performance optimization and resource right-sizing"
    "version"     = "1.0.0"
  }
}

# ============================================================================
# AUTOMATION TRIGGERS AND SCHEDULES
# ============================================================================

# Health check trigger for regular monitoring
resource "ibm_function_trigger" "health_check_schedule" {
  name      = "health-check-schedule"
  namespace = ibm_function_namespace.troubleshooting.name
  
  feed {
    name = "/whisk.system/alarms/alarm"
    parameters = {
      "cron"    = "*/${var.health_check_interval} * * * *"  # Every N minutes
      "trigger_payload" = jsonencode({
        "action" = "health_check"
        "source" = "scheduled_trigger"
      })
    }
  }
}

# Performance monitoring trigger
resource "ibm_function_trigger" "performance_monitoring_schedule" {
  name      = "performance-monitoring-schedule"
  namespace = ibm_function_namespace.troubleshooting.name
  
  feed {
    name = "/whisk.system/alarms/alarm"
    parameters = {
      "cron"    = "*/5 * * * *"  # Every 5 minutes
      "trigger_payload" = jsonencode({
        "action" = "performance_monitoring"
        "source" = "scheduled_trigger"
      })
    }
  }
}

# Self-healing trigger (if enabled)
resource "ibm_function_trigger" "self_healing_schedule" {
  count = var.self_healing_enabled ? 1 : 0
  
  name      = "self-healing-schedule"
  namespace = ibm_function_namespace.troubleshooting.name
  
  feed {
    name = "/whisk.system/alarms/alarm"
    parameters = {
      "cron"    = "*/10 * * * *"  # Every 10 minutes
      "trigger_payload" = jsonencode({
        "action" = "self_healing_check"
        "source" = "scheduled_trigger"
      })
    }
  }
}

# Performance optimization trigger (if enabled)
resource "ibm_function_trigger" "optimization_schedule" {
  count = var.performance_optimization_enabled ? 1 : 0
  
  name      = "optimization-schedule"
  namespace = ibm_function_namespace.troubleshooting.name
  
  feed {
    name = "/whisk.system/alarms/alarm"
    parameters = {
      "cron"    = "0 2 * * *"  # Daily at 2 AM
      "trigger_payload" = jsonencode({
        "action" = "performance_optimization"
        "source" = "scheduled_trigger"
      })
    }
  }
}

# ============================================================================
# AUTOMATION RULES CONNECTING TRIGGERS AND ACTIONS
# ============================================================================

# Health check automation rule
resource "ibm_function_rule" "health_check_automation" {
  name      = "health-check-automation"
  namespace = ibm_function_namespace.troubleshooting.name
  
  trigger = ibm_function_trigger.health_check_schedule.name
  action  = ibm_function_action.advanced_diagnostics.name
  
  status = "active"
}

# Performance monitoring automation rule
resource "ibm_function_rule" "performance_monitoring_automation" {
  name      = "performance-monitoring-automation"
  namespace = ibm_function_namespace.troubleshooting.name
  
  trigger = ibm_function_trigger.performance_monitoring_schedule.name
  action  = ibm_function_action.performance_monitor.name
  
  status = "active"
}

# Self-healing automation rule (if enabled)
resource "ibm_function_rule" "self_healing_automation" {
  count = var.self_healing_enabled ? 1 : 0
  
  name      = "self-healing-automation"
  namespace = ibm_function_namespace.troubleshooting.name
  
  trigger = ibm_function_trigger.self_healing_schedule[0].name
  action  = ibm_function_action.self_healing[0].name
  
  status = "active"
}

# Performance optimization automation rule (if enabled)
resource "ibm_function_rule" "optimization_automation" {
  count = var.performance_optimization_enabled ? 1 : 0
  
  name      = "optimization-automation"
  namespace = ibm_function_namespace.troubleshooting.name
  
  trigger = ibm_function_trigger.optimization_schedule[0].name
  action  = ibm_function_action.performance_optimizer[0].name
  
  status = "active"
}

# ============================================================================
# IAM ACCESS MANAGEMENT FOR TROUBLESHOOTING TEAM
# ============================================================================

# Access group for troubleshooting and operations team
resource "ibm_iam_access_group" "troubleshooting_team" {
  name        = "${local.name_prefix}-troubleshooting-team"
  description = "Access group for troubleshooting and operations team members"
  
  tags = local.common_tags
}

# Policy for monitoring and observability services access
resource "ibm_iam_access_group_policy" "monitoring_access" {
  access_group_id = ibm_iam_access_group.troubleshooting_team.id
  
  roles = ["Viewer", "Operator"]
  
  resources {
    service           = "logdnaat"
    resource_group_id = data.ibm_resource_group.group.id
  }
}

# Policy for log analysis access
resource "ibm_iam_access_group_policy" "log_analysis_access" {
  access_group_id = ibm_iam_access_group.troubleshooting_team.id
  
  roles = ["Viewer", "Operator"]
  
  resources {
    service           = "logdna"
    resource_group_id = data.ibm_resource_group.group.id
  }
}

# Policy for Cloud Functions access
resource "ibm_iam_access_group_policy" "functions_access" {
  access_group_id = ibm_iam_access_group.troubleshooting_team.id
  
  roles = ["Viewer", "Invoker"]
  
  resources {
    service           = "functions"
    resource_group_id = data.ibm_resource_group.group.id
  }
}
