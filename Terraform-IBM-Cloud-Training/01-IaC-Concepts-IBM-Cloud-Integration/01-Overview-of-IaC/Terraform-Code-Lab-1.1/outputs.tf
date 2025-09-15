# Output Values for IBM Cloud IaC Training Lab 1.1
# This file defines the output values that will be displayed after Terraform apply

# VPC Information Outputs
output "vpc_id" {
  description = "ID of the created VPC"
  value       = ibm_is_vpc.training_vpc.id
}

output "vpc_name" {
  description = "Name of the created VPC"
  value       = ibm_is_vpc.training_vpc.name
}

output "vpc_crn" {
  description = "Cloud Resource Name (CRN) of the VPC"
  value       = ibm_is_vpc.training_vpc.crn
}

output "vpc_status" {
  description = "Status of the VPC"
  value       = ibm_is_vpc.training_vpc.status
}

output "vpc_default_security_group_id" {
  description = "ID of the default security group for the VPC"
  value       = ibm_is_vpc.training_vpc.default_security_group
}

# Subnet Information Outputs
output "subnet_id" {
  description = "ID of the created subnet"
  value       = ibm_is_subnet.training_subnet.id
}

output "subnet_name" {
  description = "Name of the created subnet"
  value       = ibm_is_subnet.training_subnet.name
}

output "subnet_cidr" {
  description = "CIDR block of the subnet"
  value       = ibm_is_subnet.training_subnet.ipv4_cidr_block
}

output "subnet_zone" {
  description = "Availability zone of the subnet"
  value       = ibm_is_subnet.training_subnet.zone
}

output "subnet_available_ipv4_address_count" {
  description = "Number of available IPv4 addresses in the subnet"
  value       = ibm_is_subnet.training_subnet.available_ipv4_address_count
}

# Public Gateway Information (if created)
output "public_gateway_id" {
  description = "ID of the public gateway (if created)"
  value       = var.create_public_gateway ? ibm_is_public_gateway.training_gateway[0].id : null
}

output "public_gateway_name" {
  description = "Name of the public gateway (if created)"
  value       = var.create_public_gateway ? ibm_is_public_gateway.training_gateway[0].name : null
}

# Security Group Information
output "security_group_id" {
  description = "ID of the custom security group"
  value       = ibm_is_security_group.training_sg.id
}

output "security_group_name" {
  description = "Name of the custom security group"
  value       = ibm_is_security_group.training_sg.name
}

output "security_group_rules" {
  description = "List of security group rules"
  value = [
    for rule in ibm_is_security_group_rule.training_sg_rules : {
      id        = rule.id
      direction = rule.direction
      protocol  = rule.protocol
      remote    = rule.remote
    }
  ]
}

# Virtual Server Instance Information
output "vsi_id" {
  description = "ID of the created virtual server instance"
  value       = ibm_is_instance.training_vsi.id
}

output "vsi_name" {
  description = "Name of the virtual server instance"
  value       = ibm_is_instance.training_vsi.name
}

output "vsi_status" {
  description = "Status of the virtual server instance"
  value       = ibm_is_instance.training_vsi.status
}

output "vsi_profile" {
  description = "Profile (size) of the virtual server instance"
  value       = ibm_is_instance.training_vsi.profile
}

output "vsi_image" {
  description = "Image used for the virtual server instance"
  value       = ibm_is_instance.training_vsi.image
}

output "vsi_zone" {
  description = "Availability zone of the virtual server instance"
  value       = ibm_is_instance.training_vsi.zone
}

output "vsi_vcpu" {
  description = "vCPU configuration of the virtual server instance"
  value = {
    architecture = ibm_is_instance.training_vsi.vcpu[0].architecture
    count        = ibm_is_instance.training_vsi.vcpu[0].count
  }
}

output "vsi_memory" {
  description = "Memory (in GB) of the virtual server instance"
  value       = ibm_is_instance.training_vsi.memory
}

# Network Interface Information
output "vsi_primary_network_interface" {
  description = "Primary network interface details of the VSI"
  value = {
    id                = ibm_is_instance.training_vsi.primary_network_interface[0].id
    name              = ibm_is_instance.training_vsi.primary_network_interface[0].name
    primary_ipv4_address = ibm_is_instance.training_vsi.primary_network_interface[0].primary_ipv4_address
    subnet            = ibm_is_instance.training_vsi.primary_network_interface[0].subnet
    security_groups   = ibm_is_instance.training_vsi.primary_network_interface[0].security_groups
  }
}

output "vsi_private_ip" {
  description = "Private IP address of the virtual server instance"
  value       = ibm_is_instance.training_vsi.primary_network_interface[0].primary_ipv4_address
}

# Floating IP Information (if created)
output "floating_ip_id" {
  description = "ID of the floating IP (if created)"
  value       = var.create_floating_ip ? ibm_is_floating_ip.training_fip[0].id : null
}

output "floating_ip_address" {
  description = "Floating IP address (if created)"
  value       = var.create_floating_ip ? ibm_is_floating_ip.training_fip[0].address : null
}

# Boot Volume Information
output "vsi_boot_volume" {
  description = "Boot volume information of the VSI"
  value = {
    id   = ibm_is_instance.training_vsi.boot_volume[0].id
    name = ibm_is_instance.training_vsi.boot_volume[0].name
    size = ibm_is_instance.training_vsi.boot_volume[0].size
  }
}

# Resource Group and Region Information
output "resource_group_id" {
  description = "ID of the resource group used"
  value       = data.ibm_resource_group.training.id
}

output "resource_group_name" {
  description = "Name of the resource group used"
  value       = data.ibm_resource_group.training.name
}

output "region" {
  description = "IBM Cloud region where resources were created"
  value       = var.ibm_region
}

output "available_zones" {
  description = "List of available zones in the region"
  value       = data.ibm_is_zones.regional.zones
}

# Deployment Information
output "deployment_timestamp" {
  description = "Timestamp when the infrastructure was deployed"
  value       = time_static.deployment_time.rfc3339
}

output "random_suffix" {
  description = "Random suffix used for resource naming"
  value       = random_string.suffix.result
}

# Cost and Billing Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost information (informational)"
  value = {
    vsi_profile = var.vsi_profile
    region      = var.ibm_region
    note        = "Actual costs may vary. Check IBM Cloud pricing calculator for current rates."
  }
}

# Connection Information
output "connection_info" {
  description = "Information for connecting to the created infrastructure"
  value = {
    ssh_command = var.vsi_ssh_key_name != "" ? "ssh root@${ibm_is_instance.training_vsi.primary_network_interface[0].primary_ipv4_address}" : "Use IBM Cloud console to access VSI"
    private_ip  = ibm_is_instance.training_vsi.primary_network_interface[0].primary_ipv4_address
    public_ip   = var.create_floating_ip ? ibm_is_floating_ip.training_fip[0].address : "No public IP assigned"
    vpc_name    = ibm_is_vpc.training_vpc.name
    subnet_name = ibm_is_subnet.training_subnet.name
  }
}

# Tags Information
output "applied_tags" {
  description = "Tags applied to the resources"
  value       = local.all_tags
}

# Summary Output for Lab Report
output "lab_summary" {
  description = "Summary of created resources for lab documentation"
  value = {
    vpc = {
      id   = ibm_is_vpc.training_vpc.id
      name = ibm_is_vpc.training_vpc.name
    }
    subnet = {
      id   = ibm_is_subnet.training_subnet.id
      name = ibm_is_subnet.training_subnet.name
      cidr = ibm_is_subnet.training_subnet.ipv4_cidr_block
      zone = ibm_is_subnet.training_subnet.zone
    }
    vsi = {
      id         = ibm_is_instance.training_vsi.id
      name       = ibm_is_instance.training_vsi.name
      profile    = ibm_is_instance.training_vsi.profile
      private_ip = ibm_is_instance.training_vsi.primary_network_interface[0].primary_ipv4_address
      status     = ibm_is_instance.training_vsi.status
    }
    security_group = {
      id   = ibm_is_security_group.training_sg.id
      name = ibm_is_security_group.training_sg.name
    }
    deployment = {
      timestamp = time_static.deployment_time.rfc3339
      region    = var.ibm_region
      project   = var.project_name
      environment = var.environment
    }
  }
}
