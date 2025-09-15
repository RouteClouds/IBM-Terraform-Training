#!/bin/bash
# =============================================================================
# COST ESTIMATION SCRIPT
# Resource Dependencies and Attributes Lab - Topic 4.3
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

header() {
    echo -e "\n${PURPLE}==============================================================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}==============================================================================${NC}\n"
}

# Cost calculation functions
calculate_compute_costs() {
    local environment=${1:-"development"}
    
    header "COMPUTE COSTS ANALYSIS"
    
    # Instance pricing (USD per hour - approximate IBM Cloud pricing)
    declare -A instance_pricing
    instance_pricing["bx2-2x8"]=0.096    # 2 vCPU, 8 GB RAM
    instance_pricing["bx2-4x16"]=0.192   # 4 vCPU, 16 GB RAM
    instance_pricing["bx2-8x32"]=0.384   # 8 vCPU, 32 GB RAM
    instance_pricing["bx2-16x64"]=0.768  # 16 vCPU, 64 GB RAM
    
    # Environment-based instance counts
    declare -A env_config
    case $environment in
        "development")
            env_config["web_instances"]=2
            env_config["app_instances"]=3
            env_config["web_profile"]="bx2-2x8"
            env_config["app_profile"]="bx2-4x16"
            ;;
        "staging")
            env_config["web_instances"]=3
            env_config["app_instances"]=5
            env_config["web_profile"]="bx2-4x16"
            env_config["app_profile"]="bx2-8x32"
            ;;
        "production")
            env_config["web_instances"]=5
            env_config["app_instances"]=10
            env_config["web_profile"]="bx2-8x32"
            env_config["app_profile"]="bx2-16x64"
            ;;
        *)
            env_config["web_instances"]=2
            env_config["app_instances"]=3
            env_config["web_profile"]="bx2-2x8"
            env_config["app_profile"]="bx2-4x16"
            ;;
    esac
    
    # Calculate costs
    local web_hourly=$(echo "${instance_pricing[${env_config[web_profile]}]} * ${env_config[web_instances]}" | bc -l)
    local app_hourly=$(echo "${instance_pricing[${env_config[app_profile]}]} * ${env_config[app_instances]}" | bc -l)
    local total_compute_hourly=$(echo "$web_hourly + $app_hourly" | bc -l)
    
    local daily_cost=$(echo "$total_compute_hourly * 24" | bc -l)
    local monthly_cost=$(echo "$daily_cost * 30" | bc -l)
    
    info "Environment: $environment"
    info "Web Tier: ${env_config[web_instances]} x ${env_config[web_profile]} = \$$(printf '%.2f' $web_hourly)/hour"
    info "App Tier: ${env_config[app_instances]} x ${env_config[app_profile]} = \$$(printf '%.2f' $app_hourly)/hour"
    success "Total Compute: \$$(printf '%.2f' $total_compute_hourly)/hour (\$$(printf '%.2f' $monthly_cost)/month)"
    
    echo $monthly_cost
}

calculate_network_costs() {
    header "NETWORK COSTS ANALYSIS"
    
    # VPC and networking costs (approximate)
    local vpc_cost=0.00          # VPC is free
    local subnet_cost=0.00       # Subnets are free
    local sg_cost=0.00          # Security groups are free
    local pgw_cost=45.00        # Public gateway ~$45/month
    local lb_cost=25.00         # Load balancer ~$25/month each
    local vpe_cost=10.00        # VPE ~$10/month
    
    # Calculate total networking costs
    local total_network_monthly=$(echo "$vpc_cost + $subnet_cost + $sg_cost + $pgw_cost + ($lb_cost * 2) + $vpe_cost" | bc -l)
    
    info "VPC: \$$(printf '%.2f' $vpc_cost)/month"
    info "Subnets (9): \$$(printf '%.2f' $subnet_cost)/month"
    info "Security Groups (4): \$$(printf '%.2f' $sg_cost)/month"
    info "Public Gateway: \$$(printf '%.2f' $pgw_cost)/month"
    info "Load Balancers (2): \$$(printf '%.2f' $(echo "$lb_cost * 2" | bc -l))/month"
    info "Virtual Private Endpoint: \$$(printf '%.2f' $vpe_cost)/month"
    success "Total Network: \$$(printf '%.2f' $total_network_monthly)/month"
    
    echo $total_network_monthly
}

calculate_database_costs() {
    local environment=${1:-"development"}
    
    header "DATABASE COSTS ANALYSIS"
    
    # Database pricing (approximate IBM Cloud pricing)
    declare -A db_pricing
    db_pricing["standard"]=50.00      # Standard plan ~$50/month
    db_pricing["enterprise"]=200.00   # Enterprise plan ~$200/month
    
    declare -A redis_pricing
    redis_pricing["standard"]=30.00   # Redis standard ~$30/month
    
    # Environment-based database plans
    local db_plan="standard"
    case $environment in
        "production")
            db_plan="enterprise"
            ;;
        *)
            db_plan="standard"
            ;;
    esac
    
    local postgres_cost=${db_pricing[$db_plan]}
    local redis_cost=${redis_pricing["standard"]}
    local total_db_monthly=$(echo "$postgres_cost + $redis_cost" | bc -l)
    
    info "PostgreSQL ($db_plan): \$$(printf '%.2f' $postgres_cost)/month"
    info "Redis (standard): \$$(printf '%.2f' $redis_cost)/month"
    success "Total Database: \$$(printf '%.2f' $total_db_monthly)/month"
    
    echo $total_db_monthly
}

calculate_storage_costs() {
    local environment=${1:-"development"}
    
    header "STORAGE COSTS ANALYSIS"
    
    # Storage pricing (approximate)
    local block_storage_gb=0.10    # $0.10 per GB/month
    local cos_storage_gb=0.023     # $0.023 per GB/month for COS
    
    # Environment-based storage requirements
    declare -A storage_config
    case $environment in
        "development")
            storage_config["total_block_gb"]=1000    # 100GB per instance * 10 instances
            storage_config["cos_gb"]=100
            ;;
        "staging")
            storage_config["total_block_gb"]=1600    # 200GB per instance * 8 instances
            storage_config["cos_gb"]=500
            ;;
        "production")
            storage_config["total_block_gb"]=3000    # 200GB per instance * 15 instances
            storage_config["cos_gb"]=1000
            ;;
        *)
            storage_config["total_block_gb"]=1000
            storage_config["cos_gb"]=100
            ;;
    esac
    
    local block_cost=$(echo "${storage_config[total_block_gb]} * $block_storage_gb" | bc -l)
    local cos_cost=$(echo "${storage_config[cos_gb]} * $cos_storage_gb" | bc -l)
    local total_storage_monthly=$(echo "$block_cost + $cos_cost" | bc -l)
    
    info "Block Storage (${storage_config[total_block_gb]} GB): \$$(printf '%.2f' $block_cost)/month"
    info "Object Storage (${storage_config[cos_gb]} GB): \$$(printf '%.2f' $cos_cost)/month"
    success "Total Storage: \$$(printf '%.2f' $total_storage_monthly)/month"
    
    echo $total_storage_monthly
}

calculate_monitoring_costs() {
    local environment=${1:-"development"}
    
    header "MONITORING COSTS ANALYSIS"
    
    # Monitoring pricing (approximate)
    declare -A monitoring_pricing
    monitoring_pricing["lite"]=0.00        # Lite plan is free
    monitoring_pricing["graduated-tier"]=20.00  # Graduated tier ~$20/month
    
    local monitoring_plan="lite"
    case $environment in
        "staging"|"production")
            monitoring_plan="graduated-tier"
            ;;
        *)
            monitoring_plan="lite"
            ;;
    esac
    
    local monitoring_cost=${monitoring_pricing[$monitoring_plan]}
    
    info "Sysdig Monitoring ($monitoring_plan): \$$(printf '%.2f' $monitoring_cost)/month"
    success "Total Monitoring: \$$(printf '%.2f' $monitoring_cost)/month"
    
    echo $monitoring_cost
}

generate_cost_breakdown() {
    local environment=${1:-"development"}
    
    header "COMPREHENSIVE COST BREAKDOWN - $environment"
    
    log "Calculating costs for $environment environment..."
    
    # Calculate individual components
    local compute_cost=$(calculate_compute_costs $environment)
    local network_cost=$(calculate_network_costs)
    local database_cost=$(calculate_database_costs $environment)
    local storage_cost=$(calculate_storage_costs $environment)
    local monitoring_cost=$(calculate_monitoring_costs $environment)
    
    # Calculate totals
    local total_monthly=$(echo "$compute_cost + $network_cost + $database_cost + $storage_cost + $monitoring_cost" | bc -l)
    local total_daily=$(echo "$total_monthly / 30" | bc -l)
    local total_hourly=$(echo "$total_daily / 24" | bc -l)
    
    # Calculate annual costs
    local total_annual=$(echo "$total_monthly * 12" | bc -l)
    
    header "COST SUMMARY - $environment"
    
    printf "%-20s %15s %15s\n" "Component" "Monthly" "Annual"
    printf "%-20s %15s %15s\n" "--------" "-------" "------"
    printf "%-20s %15s %15s\n" "Compute" "\$$(printf '%.2f' $compute_cost)" "\$$(printf '%.2f' $(echo "$compute_cost * 12" | bc -l))"
    printf "%-20s %15s %15s\n" "Network" "\$$(printf '%.2f' $network_cost)" "\$$(printf '%.2f' $(echo "$network_cost * 12" | bc -l))"
    printf "%-20s %15s %15s\n" "Database" "\$$(printf '%.2f' $database_cost)" "\$$(printf '%.2f' $(echo "$database_cost * 12" | bc -l))"
    printf "%-20s %15s %15s\n" "Storage" "\$$(printf '%.2f' $storage_cost)" "\$$(printf '%.2f' $(echo "$storage_cost * 12" | bc -l))"
    printf "%-20s %15s %15s\n" "Monitoring" "\$$(printf '%.2f' $monitoring_cost)" "\$$(printf '%.2f' $(echo "$monitoring_cost * 12" | bc -l))"
    printf "%-20s %15s %15s\n" "--------" "-------" "------"
    printf "%-20s %15s %15s\n" "TOTAL" "\$$(printf '%.2f' $total_monthly)" "\$$(printf '%.2f' $total_annual)"
    
    echo ""
    info "Hourly Cost: \$$(printf '%.2f' $total_hourly)"
    info "Daily Cost: \$$(printf '%.2f' $total_daily)"
    success "Monthly Cost: \$$(printf '%.2f' $total_monthly)"
    success "Annual Cost: \$$(printf '%.2f' $total_annual)"
}

generate_cost_optimization_recommendations() {
    header "COST OPTIMIZATION RECOMMENDATIONS"
    
    echo -e "${CYAN}💡 Cost Optimization Strategies:${NC}\n"
    
    echo "1. **Right-sizing Instances**"
    echo "   - Monitor CPU and memory utilization"
    echo "   - Scale down over-provisioned instances"
    echo "   - Use auto-scaling to match demand"
    echo ""
    
    echo "2. **Reserved Instances**"
    echo "   - Consider reserved instances for production workloads"
    echo "   - Potential savings: 20-40% for 1-year commitments"
    echo "   - Best for predictable, steady-state workloads"
    echo ""
    
    echo "3. **Storage Optimization**"
    echo "   - Use appropriate storage tiers"
    echo "   - Implement lifecycle policies for object storage"
    echo "   - Regular cleanup of unused volumes"
    echo ""
    
    echo "4. **Network Optimization**"
    echo "   - Optimize data transfer patterns"
    echo "   - Use private endpoints where possible"
    echo "   - Consider CDN for static content"
    echo ""
    
    echo "5. **Database Optimization**"
    echo "   - Right-size database instances"
    echo "   - Use read replicas for read-heavy workloads"
    echo "   - Implement connection pooling"
    echo ""
    
    echo "6. **Monitoring and Alerting**"
    echo "   - Set up cost alerts and budgets"
    echo "   - Regular cost reviews and optimization"
    echo "   - Use cost allocation tags"
    echo ""
    
    echo "7. **Development Environment Optimization**"
    echo "   - Auto-shutdown for development environments"
    echo "   - Smaller instance sizes for testing"
    echo "   - Shared development resources"
}

generate_cost_comparison() {
    header "ENVIRONMENT COST COMPARISON"
    
    log "Generating cost comparison across environments..."
    
    # Calculate costs for all environments
    local dev_cost=$(calculate_compute_costs "development")
    local dev_network=$(calculate_network_costs)
    local dev_db=$(calculate_database_costs "development")
    local dev_storage=$(calculate_storage_costs "development")
    local dev_monitoring=$(calculate_monitoring_costs "development")
    local dev_total=$(echo "$dev_cost + $dev_network + $dev_db + $dev_storage + $dev_monitoring" | bc -l)
    
    local staging_cost=$(calculate_compute_costs "staging")
    local staging_db=$(calculate_database_costs "staging")
    local staging_storage=$(calculate_storage_costs "staging")
    local staging_monitoring=$(calculate_monitoring_costs "staging")
    local staging_total=$(echo "$staging_cost + $dev_network + $staging_db + $staging_storage + $staging_monitoring" | bc -l)
    
    local prod_cost=$(calculate_compute_costs "production")
    local prod_db=$(calculate_database_costs "production")
    local prod_storage=$(calculate_storage_costs "production")
    local prod_monitoring=$(calculate_monitoring_costs "production")
    local prod_total=$(echo "$prod_cost + $dev_network + $prod_db + $prod_storage + $prod_monitoring" | bc -l)
    
    printf "%-15s %15s %15s %15s\n" "Environment" "Development" "Staging" "Production"
    printf "%-15s %15s %15s %15s\n" "-----------" "-----------" "-------" "----------"
    printf "%-15s %15s %15s %15s\n" "Monthly Cost" "\$$(printf '%.2f' $dev_total)" "\$$(printf '%.2f' $staging_total)" "\$$(printf '%.2f' $prod_total)"
    printf "%-15s %15s %15s %15s\n" "Annual Cost" "\$$(printf '%.2f' $(echo "$dev_total * 12" | bc -l))" "\$$(printf '%.2f' $(echo "$staging_total * 12" | bc -l))" "\$$(printf '%.2f' $(echo "$prod_total * 12" | bc -l))"
    
    echo ""
    local total_all_envs=$(echo "$dev_total + $staging_total + $prod_total" | bc -l)
    success "Total Monthly Cost (All Environments): \$$(printf '%.2f' $total_all_envs)"
    success "Total Annual Cost (All Environments): \$$(printf '%.2f' $(echo "$total_all_envs * 12" | bc -l))"
}

# Main execution
main() {
    local environment=${1:-"development"}
    
    header "IBM CLOUD COST ESTIMATION TOOL"
    
    log "Starting cost analysis for Resource Dependencies Lab..."
    
    # Check for bc calculator
    if ! command -v bc &> /dev/null; then
        error "bc calculator is required but not installed"
        info "Install with: sudo apt-get install bc"
        exit 1
    fi
    
    # Generate cost breakdown for specified environment
    generate_cost_breakdown $environment
    
    # Generate comparison across environments
    generate_cost_comparison
    
    # Generate optimization recommendations
    generate_cost_optimization_recommendations
    
    header "COST ANALYSIS COMPLETE"
    
    success "Cost estimation completed successfully!"
    info "Estimates are based on IBM Cloud pricing as of 2024"
    warning "Actual costs may vary based on usage patterns and pricing changes"
    
    echo -e "\n${CYAN}Usage Examples:${NC}"
    echo "  ./cost-estimate.sh development"
    echo "  ./cost-estimate.sh staging"
    echo "  ./cost-estimate.sh production"
}

# Run main function
main "$@"
