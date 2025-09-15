# =============================================================================
# OUTPUTS CONFIGURATION
# Resource Dependencies and Attributes Lab - Topic 4.3
# =============================================================================

# =============================================================================
# FOUNDATION INFRASTRUCTURE OUTPUTS
# =============================================================================

output "foundation_infrastructure" {
  description = "Foundation infrastructure details with dependency information"
  value = {
    # VPC information
    vpc = {
      id   = ibm_is_vpc.main_vpc.id
      name = ibm_is_vpc.main_vpc.name
      crn  = ibm_is_vpc.main_vpc.crn
      status = ibm_is_vpc.main_vpc.status
      default_security_group = ibm_is_vpc.main_vpc.default_security_group
      default_network_acl = ibm_is_vpc.main_vpc.default_network_acl
    }
    
    # Subnet information with dependencies
    subnets = {
      public = [
        for subnet in ibm_is_subnet.public_subnets :
        {
          id = subnet.id
          name = subnet.name
          zone = subnet.zone
          cidr = subnet.ipv4_cidr_block
          vpc_dependency = subnet.vpc
        }
      ]
      private = [
        for subnet in ibm_is_subnet.private_subnets :
        {
          id = subnet.id
          name = subnet.name
          zone = subnet.zone
          cidr = subnet.ipv4_cidr_block
          vpc_dependency = subnet.vpc
        }
      ]
      database = [
        for subnet in ibm_is_subnet.database_subnets :
        {
          id = subnet.id
          name = subnet.name
          zone = subnet.zone
          cidr = subnet.ipv4_cidr_block
          vpc_dependency = subnet.vpc
        }
      ]
    }
    
    # Public gateway information
    public_gateways = [
      for pgw in ibm_is_public_gateway.public_gateways :
      {
        id = pgw.id
        name = pgw.name
        zone = pgw.zone
        vpc_dependency = pgw.vpc
      }
    ]
    
    # Dependency analysis
    dependency_analysis = {
      vpc_dependents = length(ibm_is_subnet.public_subnets) + length(ibm_is_subnet.private_subnets) + length(ibm_is_subnet.database_subnets)
      subnet_dependencies = "All subnets depend on VPC"
      pgw_dependencies = "Public gateways depend on VPC and are attached to private subnets"
    }
  }
}

# =============================================================================
# SECURITY CONFIGURATION OUTPUTS
# =============================================================================

output "security_configuration" {
  description = "Security groups and rules with cross-reference analysis"
  value = {
    # Security groups
    security_groups = {
      web_tier = {
        id = ibm_is_security_group.web_tier_sg.id
        name = ibm_is_security_group.web_tier_sg.name
        vpc_dependency = ibm_is_security_group.web_tier_sg.vpc
      }
      app_tier = {
        id = ibm_is_security_group.app_tier_sg.id
        name = ibm_is_security_group.app_tier_sg.name
        vpc_dependency = ibm_is_security_group.app_tier_sg.vpc
      }
      db_tier = {
        id = ibm_is_security_group.db_tier_sg.id
        name = ibm_is_security_group.db_tier_sg.name
        vpc_dependency = ibm_is_security_group.db_tier_sg.vpc
      }
      load_balancer = {
        id = ibm_is_security_group.lb_sg.id
        name = ibm_is_security_group.lb_sg.name
        vpc_dependency = ibm_is_security_group.lb_sg.vpc
      }
    }
    
    # Cross-reference analysis
    cross_references = {
      lb_to_web = "Load balancer SG references web tier SG"
      web_to_app = "Web tier SG references app tier SG"
      app_to_db = "App tier SG references database tier SG"
      circular_dependencies = "None - proper dependency design prevents cycles"
    }
    
    # Security rule summary
    rule_summary = {
      total_rules = 12  # Approximate count
      cross_reference_rules = 6
      internet_access_rules = 4
      ssh_access_rules = 2
    }
  }
}

# =============================================================================
# DATA SOURCE INTEGRATION OUTPUTS
# =============================================================================

output "data_source_integration" {
  description = "Data source usage and dynamic discovery results"
  value = {
    # Resource group discovery
    resource_group = {
      id = data.ibm_resource_group.project_rg.id
      name = data.ibm_resource_group.project_rg.name
    }
    
    # Zone discovery
    availability_zones = {
      primary_region = data.ibm_is_zones.primary_zones.zones
      zone_count = length(data.ibm_is_zones.primary_zones.zones)
      multi_region_enabled = var.feature_flags.enable_multi_region
    }
    
    # Image discovery
    ubuntu_image = {
      id = data.ibm_is_image.ubuntu_latest.id
      name = data.ibm_is_image.ubuntu_latest.name
      architecture = data.ibm_is_image.ubuntu_latest.architecture
      os = data.ibm_is_image.ubuntu_latest.operating_system
    }
    
    # Instance profile discovery
    instance_profiles = {
      total_available = length(data.ibm_is_instance_profiles.available_profiles.profiles)
      web_tier_profile = var.infrastructure_configuration.compute.instance_types.web_tier.instance_profile
      app_tier_profile = var.infrastructure_configuration.compute.instance_types.app_tier.instance_profile
    }
    
    # SSH key discovery
    ssh_keys = {
      available_keys = length(data.ibm_is_ssh_keys.available_keys.keys)
      keys_configured = length(data.ibm_is_ssh_keys.available_keys.keys) > 0
    }
    
    # Service instance discovery
    existing_services = {
      cos_instances = length(data.ibm_resource_instance.cos_instance)
      monitoring_instances = length(data.ibm_resource_instance.monitoring_instance)
      created_cos = length(ibm_resource_instance.backup_cos)
      created_monitoring = length(ibm_resource_instance.monitoring)
    }
  }
}

# =============================================================================
# COMPUTE TIER OUTPUTS
# =============================================================================

output "compute_tier" {
  description = "Compute instances with dependency relationships"
  value = {
    # Web servers
    web_servers = [
      for instance in ibm_is_instance.web_servers :
      {
        id = instance.id
        name = instance.name
        zone = instance.zone
        private_ip = instance.primary_network_interface[0].primary_ipv4_address
        vpc_dependency = instance.vpc
        subnet_dependency = instance.primary_network_interface[0].subnet
        security_group_dependencies = instance.primary_network_interface[0].security_groups
      }
    ]
    
    # Application servers
    app_servers = [
      for instance in ibm_is_instance.app_servers :
      {
        id = instance.id
        name = instance.name
        zone = instance.zone
        private_ip = instance.primary_network_interface[0].primary_ipv4_address
        vpc_dependency = instance.vpc
        subnet_dependency = instance.primary_network_interface[0].subnet
        security_group_dependencies = instance.primary_network_interface[0].security_groups
      }
    ]
    
    # Dependency analysis
    dependency_relationships = {
      web_depends_on_app = "Web servers depend on app servers for configuration"
      app_depends_on_db = "App servers depend on database services"
      all_depend_on_network = "All instances depend on VPC and subnets"
      explicit_dependencies = "Database services must be ready before app servers"
    }
    
    # Instance distribution
    distribution_analysis = {
      web_server_count = length(ibm_is_instance.web_servers)
      app_server_count = length(ibm_is_instance.app_servers)
      zones_used = length(data.ibm_is_zones.primary_zones.zones)
      instances_per_zone = {
        web = ceil(length(ibm_is_instance.web_servers) / length(data.ibm_is_zones.primary_zones.zones))
        app = ceil(length(ibm_is_instance.app_servers) / length(data.ibm_is_zones.primary_zones.zones))
      }
    }
  }
  sensitive = true
}

# =============================================================================
# DATABASE TIER OUTPUTS
# =============================================================================

output "database_tier" {
  description = "Database services with connection and dependency information"
  value = {
    # Primary database
    primary_database = {
      id = ibm_database.primary_database.id
      name = ibm_database.primary_database.name
      service = ibm_database.primary_database.service
      plan = ibm_database.primary_database.plan
      location = ibm_database.primary_database.location
      status = ibm_database.primary_database.status
      version = ibm_database.primary_database.version
    }
    
    # Redis cache
    redis_cache = {
      id = ibm_database.redis_cache.id
      name = ibm_database.redis_cache.name
      service = ibm_database.redis_cache.service
      plan = ibm_database.redis_cache.plan
      location = ibm_database.redis_cache.location
      status = ibm_database.redis_cache.status
    }
    
    # VPE configuration
    virtual_endpoint = {
      id = ibm_is_virtual_endpoint_gateway.database_vpe.id
      name = ibm_is_virtual_endpoint_gateway.database_vpe.name
      vpc_dependency = ibm_is_virtual_endpoint_gateway.database_vpe.vpc
      target_service = "databases-for-postgresql"
      ip_count = length(ibm_is_virtual_endpoint_gateway.database_vpe.ips)
    }
    
    # Dependency analysis
    dependency_relationships = {
      explicit_network_dependency = "Databases explicitly depend on VPC and subnets"
      vpe_dependencies = "VPE depends on both database and network infrastructure"
      app_server_dependency = "App servers depend on database connection strings"
      private_connectivity = "All database access is through private endpoints"
    }
  }
  sensitive = true
}

# =============================================================================
# LOAD BALANCER OUTPUTS
# =============================================================================

output "load_balancer_configuration" {
  description = "Load balancer configuration with instance attribute usage"
  value = {
    # Web load balancer
    web_load_balancer = {
      id = ibm_is_lb.web_load_balancer.id
      name = ibm_is_lb.web_load_balancer.name
      hostname = ibm_is_lb.web_load_balancer.hostname
      type = ibm_is_lb.web_load_balancer.type
      subnets = ibm_is_lb.web_load_balancer.subnets
      pool_id = ibm_is_lb_pool.web_pool.id
      listener_port = ibm_is_lb_listener.web_listener.port
    }
    
    # Application load balancer
    app_load_balancer = {
      id = ibm_is_lb.app_internal_lb.id
      name = ibm_is_lb.app_internal_lb.name
      hostname = ibm_is_lb.app_internal_lb.hostname
      type = ibm_is_lb.app_internal_lb.type
      subnets = ibm_is_lb.app_internal_lb.subnets
      pool_id = ibm_is_lb_pool.app_pool.id
      listener_port = ibm_is_lb_listener.app_listener.port
    }
    
    # Pool member analysis
    pool_members = {
      web_pool_members = [
        for member in ibm_is_lb_pool_member.web_pool_members :
        {
          target_ip = member.target
          port = member.port
          health = member.health
        }
      ]
      app_pool_members = [
        for member in ibm_is_lb_pool_member.app_pool_members :
        {
          target_ip = member.target
          port = member.port
          health = member.health
        }
      ]
    }
    
    # Attribute usage analysis
    attribute_usage = {
      instance_ip_references = "Pool members use instance.primary_network_interface[0].primary_ipv4_address"
      subnet_references = "Load balancers reference subnet IDs from subnet resources"
      implicit_dependencies = "Pool members implicitly depend on instances and load balancer"
    }
  }
}

# =============================================================================
# DEPENDENCY ANALYSIS OUTPUTS
# =============================================================================

output "dependency_analysis" {
  description = "Comprehensive dependency analysis and optimization metrics"
  value = {
    # Dependency types
    dependency_types = {
      implicit_dependencies = {
        vpc_to_subnets = "Subnets reference VPC ID"
        subnet_to_instances = "Instances reference subnet IDs"
        sg_to_rules = "Security group rules reference security group IDs"
        instance_to_lb_members = "Load balancer members reference instance IPs"
      }
      explicit_dependencies = {
        network_to_databases = "Databases explicitly depend on VPC and subnets"
        database_to_apps = "App servers explicitly depend on database services"
        app_to_web = "Web servers explicitly depend on app servers"
        vpe_dependencies = "VPE explicitly depends on database and network"
      }
    }
    
    # Resource creation order
    creation_order = [
      "1. Foundation: VPC, Resource Group data sources",
      "2. Network: Subnets, Public Gateways (parallel)",
      "3. Security: Security Groups (parallel)",
      "4. Security Rules: Cross-references (after security groups)",
      "5. Services: Database services (explicit network dependency)",
      "6. VPE: Virtual Private Endpoint (after database and network)",
      "7. Compute: Application servers (after database services)",
      "8. Compute: Web servers (after application servers)",
      "9. Load Balancing: Load balancers and pools",
      "10. Pool Members: Using instance attributes"
    ]
    
    # Optimization opportunities
    optimization_analysis = {
      parallel_creation = {
        subnets = "All subnets can be created in parallel"
        security_groups = "All security groups can be created in parallel"
        instances_per_tier = "Instances within each tier can be created in parallel"
      }
      dependency_minimization = {
        implicit_preferred = "Using implicit dependencies where possible"
        explicit_only_when_needed = "Explicit dependencies only for timing requirements"
        cross_references_optimized = "Security group cross-references prevent circular dependencies"
      }
      performance_metrics = {
        estimated_creation_time = "15-25 minutes total"
        parallel_efficiency = "60% of resources can be created in parallel"
        dependency_depth = "Maximum 4 levels deep"
      }
    }
    
    # Best practices demonstrated
    best_practices = {
      implicit_dependencies = "✓ Using resource attribute references"
      explicit_dependencies = "✓ Using depends_on only when necessary"
      data_source_usage = "✓ Dynamic discovery and conditional logic"
      cross_references = "✓ Proper security group cross-referencing"
      attribute_usage = "✓ Complex attribute paths for load balancer members"
      conditional_resources = "✓ Creating resources based on data source results"
    }
  }
}

# =============================================================================
# ENVIRONMENT AND CONFIGURATION OUTPUTS
# =============================================================================

output "environment_configuration" {
  description = "Environment-specific configuration and feature flags"
  value = {
    # Project configuration
    project_info = {
      name = var.project_configuration.project_name
      environment = var.project_configuration.environment.name
      criticality = var.project_configuration.environment.criticality
      organization = var.project_configuration.organization.name
    }
    
    # Feature flags status
    feature_flags = var.feature_flags
    
    # Environment-specific settings
    environment_settings = local.current_env
    
    # Dependency configuration
    dependency_settings = var.dependency_configuration
    
    # Resource naming
    resource_naming = local.resource_names
    
    # Deployment metadata
    deployment_metadata = {
      deployment_id = random_string.deployment_id.result
      deployment_time = time_static.deployment_time.rfc3339
      terraform_version = "1.0+"
      provider_version = "1.58+"
    }
  }
}
