# Enhanced Output Values for Cost Optimization Lab 1.2
# This file defines comprehensive outputs including cost optimization metrics

# VPC Information Outputs
output "vpc_id" {
  description = "ID of the created VPC"
  value       = ibm_is_vpc.cost_optimized_vpc.id
}

output "vpc_name" {
  description = "Name of the created VPC"
  value       = ibm_is_vpc.cost_optimized_vpc.name
}

output "vpc_crn" {
  description = "Cloud Resource Name (CRN) of the VPC"
  value       = ibm_is_vpc.cost_optimized_vpc.crn
}

# Subnet Information Outputs
output "subnet_id" {
  description = "ID of the created subnet"
  value       = ibm_is_subnet.cost_optimized_subnet.id
}

output "subnet_name" {
  description = "Name of the created subnet"
  value       = ibm_is_subnet.cost_optimized_subnet.name
}

output "subnet_cidr" {
  description = "CIDR block of the subnet"
  value       = ibm_is_subnet.cost_optimized_subnet.ipv4_cidr_block
}

# Virtual Server Instance Information
output "vsi_id" {
  description = "ID of the created virtual server instance"
  value       = ibm_is_instance.cost_optimized_vsi.id
}

output "vsi_name" {
  description = "Name of the virtual server instance"
  value       = ibm_is_instance.cost_optimized_vsi.name
}

output "vsi_private_ip" {
  description = "Private IP address of the virtual server instance"
  value       = ibm_is_instance.cost_optimized_vsi.primary_network_interface[0].primary_ipv4_address
}

output "vsi_profile" {
  description = "Profile (size) of the virtual server instance"
  value       = ibm_is_instance.cost_optimized_vsi.profile
}

# Cost Optimization Outputs
output "cost_optimization_features" {
  description = "Enabled cost optimization features"
  value = {
    auto_shutdown_enabled     = var.enable_auto_shutdown
    auto_shutdown_schedule    = var.auto_shutdown_schedule
    auto_startup_schedule     = var.auto_startup_schedule
    reserved_instance_eligible = var.reserved_instance_eligible
    smart_storage_enabled     = var.enable_cos_demo
    monitoring_enabled        = var.enable_monitoring
    cost_center              = var.cost_center
    billing_code             = var.billing_code
  }
}

output "estimated_monthly_costs" {
  description = "Estimated monthly costs breakdown"
  value = {
    vsi_base_cost = var.vsi_profile == "bx2-2x8" ? 73 : (
      var.vsi_profile == "bx2-4x16" ? 146 : (
        var.vsi_profile == "bx2-8x32" ? 292 : 73
      )
    )
    public_gateway_cost = var.create_public_gateway ? 32 : 0
    floating_ip_cost    = var.create_floating_ip ? 3 : 0
    storage_base_cost   = var.enable_cos_demo ? 5 : 0
    monitoring_cost     = var.enable_monitoring ? 0 : 0  # Lite plan is free
    total_base_cost = (
      (var.vsi_profile == "bx2-2x8" ? 73 : (
        var.vsi_profile == "bx2-4x16" ? 146 : (
          var.vsi_profile == "bx2-8x32" ? 292 : 73
        )
      )) +
      (var.create_public_gateway ? 32 : 0) +
      (var.create_floating_ip ? 3 : 0) +
      (var.enable_cos_demo ? 5 : 0)
    )
    currency = "USD"
    note     = "Estimates based on us-south region pricing. Actual costs may vary."
  }
}

output "potential_savings" {
  description = "Potential cost savings from optimization features"
  value = {
    auto_shutdown_savings_percent = var.enable_auto_shutdown ? 40 : 0
    auto_shutdown_savings_amount = var.enable_auto_shutdown ? (
      (var.vsi_profile == "bx2-2x8" ? 73 : (
        var.vsi_profile == "bx2-4x16" ? 146 : (
          var.vsi_profile == "bx2-8x32" ? 292 : 73
        )
      )) * 0.4
    ) : 0
    
    smart_storage_savings_percent = var.enable_cos_demo ? 30 : 0
    smart_storage_savings_amount  = var.enable_cos_demo ? 1.5 : 0
    
    total_potential_monthly_savings = (
      var.enable_auto_shutdown ? (
        (var.vsi_profile == "bx2-2x8" ? 73 : (
          var.vsi_profile == "bx2-4x16" ? 146 : (
            var.vsi_profile == "bx2-8x32" ? 292 : 73
          )
        )) * 0.4
      ) : 0
    ) + (var.enable_cos_demo ? 1.5 : 0)
    
    annual_savings_estimate = (
      (var.enable_auto_shutdown ? (
        (var.vsi_profile == "bx2-2x8" ? 73 : (
          var.vsi_profile == "bx2-4x16" ? 146 : (
            var.vsi_profile == "bx2-8x32" ? 292 : 73
          )
        )) * 0.4
      ) : 0) + (var.enable_cos_demo ? 1.5 : 0)
    ) * 12
  }
}

# IBM Cloud Service Outputs
output "cos_instance_id" {
  description = "ID of the Cloud Object Storage instance (if created)"
  value       = var.enable_cos_demo ? ibm_resource_instance.cos_instance[0].id : null
}

output "cos_bucket_name" {
  description = "Name of the COS bucket with lifecycle management (if created)"
  value       = var.enable_cos_demo ? ibm_cos_bucket.cost_optimized_bucket[0].bucket_name : null
}

output "monitoring_instance_id" {
  description = "ID of the monitoring instance (if created)"
  value       = var.enable_monitoring ? ibm_resource_instance.monitoring[0].id : null
}

output "activity_tracker_instance_id" {
  description = "ID of the Activity Tracker instance (if created)"
  value       = var.enable_activity_tracker ? ibm_resource_instance.activity_tracker[0].id : null
}

# Cost Allocation and Tagging
output "cost_allocation_tags" {
  description = "Tags applied for cost allocation and tracking"
  value       = local.cost_tags
}

output "all_applied_tags" {
  description = "All tags applied to resources"
  value       = local.all_tags
}

# ROI Analysis Outputs
output "roi_analysis" {
  description = "Return on Investment analysis for IaC implementation"
  value = {
    # Manual process costs (estimated)
    manual_deployment_time_hours = 8
    manual_labor_cost_per_deployment = 8 * 75  # 8 hours * $75/hour
    manual_deployments_per_month = 4
    manual_monthly_labor_cost = 8 * 75 * 4  # $2,400
    
    # IaC process costs (estimated)
    iac_deployment_time_hours = 1
    iac_labor_cost_per_deployment = 1 * 75  # 1 hour * $75/hour
    iac_deployments_per_month = 4
    iac_monthly_labor_cost = 1 * 75 * 4  # $300
    
    # Savings calculation
    monthly_labor_savings = (8 * 75 * 4) - (1 * 75 * 4)  # $2,100
    monthly_infrastructure_savings = var.enable_auto_shutdown ? (
      (var.vsi_profile == "bx2-2x8" ? 73 : (
        var.vsi_profile == "bx2-4x16" ? 146 : (
          var.vsi_profile == "bx2-8x32" ? 292 : 73
        )
      )) * 0.4
    ) : 0
    
    total_monthly_savings = 2100 + (var.enable_auto_shutdown ? (
      (var.vsi_profile == "bx2-2x8" ? 73 : (
        var.vsi_profile == "bx2-4x16" ? 146 : (
          var.vsi_profile == "bx2-8x32" ? 292 : 73
        )
      )) * 0.4
    ) : 0)
    
    annual_savings = (2100 + (var.enable_auto_shutdown ? (
      (var.vsi_profile == "bx2-2x8" ? 73 : (
        var.vsi_profile == "bx2-4x16" ? 146 : (
          var.vsi_profile == "bx2-8x32" ? 292 : 73
        )
      )) * 0.4
    ) : 0)) * 12
    
    roi_percentage = ((2100 + (var.enable_auto_shutdown ? (
      (var.vsi_profile == "bx2-2x8" ? 73 : (
        var.vsi_profile == "bx2-4x16" ? 146 : (
          var.vsi_profile == "bx2-8x32" ? 292 : 73
        )
      )) * 0.4
    ) : 0)) * 12) / (300 * 12) * 100
    
    payback_period_months = (300 * 12) / (2100 + (var.enable_auto_shutdown ? (
      (var.vsi_profile == "bx2-2x8" ? 73 : (
        var.vsi_profile == "bx2-4x16" ? 146 : (
          var.vsi_profile == "bx2-8x32" ? 292 : 73
        )
      )) * 0.4
    ) : 0))
  }
}

# Connection and Access Information
output "connection_info" {
  description = "Information for connecting to the created infrastructure"
  value = {
    ssh_command = var.vsi_ssh_key_name != "" ? "ssh root@${ibm_is_instance.cost_optimized_vsi.primary_network_interface[0].primary_ipv4_address}" : "Use IBM Cloud console to access VSI"
    private_ip  = ibm_is_instance.cost_optimized_vsi.primary_network_interface[0].primary_ipv4_address
    public_ip   = var.create_floating_ip ? ibm_is_floating_ip.cost_optimized_fip[0].address : "No public IP assigned"
    vpc_name    = ibm_is_vpc.cost_optimized_vpc.name
    subnet_name = ibm_is_subnet.cost_optimized_subnet.name
    region      = var.ibm_region
    zone        = local.subnet_zone
  }
}

# Lab Summary for Documentation
output "lab_summary" {
  description = "Comprehensive summary for lab documentation and reporting"
  value = {
    deployment_info = {
      timestamp   = time_static.deployment_time.rfc3339
      region      = var.ibm_region
      zone        = local.subnet_zone
      project     = var.project_name
      environment = var.environment
      cost_center = var.cost_center
      owner       = var.owner
    }
    
    resources_created = {
      vpc_id                    = ibm_is_vpc.cost_optimized_vpc.id
      subnet_id                 = ibm_is_subnet.cost_optimized_subnet.id
      vsi_id                    = ibm_is_instance.cost_optimized_vsi.id
      cos_instance_id           = var.enable_cos_demo ? ibm_resource_instance.cos_instance[0].id : null
      monitoring_instance_id    = var.enable_monitoring ? ibm_resource_instance.monitoring[0].id : null
      activity_tracker_id       = var.enable_activity_tracker ? ibm_resource_instance.activity_tracker[0].id : null
    }
    
    cost_optimization_summary = {
      features_enabled = [
        var.enable_auto_shutdown ? "Auto-shutdown scheduling" : null,
        var.enable_cos_demo ? "Smart storage with lifecycle management" : null,
        var.reserved_instance_eligible ? "Reserved instance eligibility" : null,
        var.enable_monitoring ? "Operational monitoring" : null,
        var.enable_activity_tracker ? "Compliance tracking" : null
      ]
      
      estimated_monthly_savings = var.enable_auto_shutdown ? (
        (var.vsi_profile == "bx2-2x8" ? 73 : (
          var.vsi_profile == "bx2-4x16" ? 146 : (
            var.vsi_profile == "bx2-8x32" ? 292 : 73
          )
        )) * 0.4
      ) + (var.enable_cos_demo ? 1.5 : 0) : (var.enable_cos_demo ? 1.5 : 0)
      
      roi_percentage = ((2100 + (var.enable_auto_shutdown ? (
        (var.vsi_profile == "bx2-2x8" ? 73 : (
          var.vsi_profile == "bx2-4x16" ? 146 : (
            var.vsi_profile == "bx2-8x32" ? 292 : 73
          )
        )) * 0.4
      ) : 0)) * 12) / (300 * 12) * 100
    }
    
    ibm_cloud_benefits = [
      "Native Terraform integration through Schematics",
      "Built-in cost tracking and optimization",
      "Enterprise-grade security and compliance",
      "Seamless multi-service integration",
      "Global infrastructure with local data residency"
    ]
  }
}
