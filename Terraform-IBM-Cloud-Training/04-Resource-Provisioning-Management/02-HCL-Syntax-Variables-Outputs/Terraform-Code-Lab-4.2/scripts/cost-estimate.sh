#!/bin/bash

# =============================================================================
# TERRAFORM COST ESTIMATION SCRIPT
# Advanced HCL Configuration Lab - Topic 4.2
# =============================================================================

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_DIR/cost_estimation.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    log "$message"
}

# Print header
print_header() {
    echo -e "${BLUE}"
    echo "============================================================================="
    echo "  TERRAFORM COST ESTIMATION"
    echo "  Advanced HCL Configuration Lab - Topic 4.2"
    echo "============================================================================="
    echo -e "${NC}"
}

# IBM Cloud pricing (simplified estimates in USD)
declare -A PRICING
PRICING[bx2-2x8]=75      # 2 vCPU, 8 GB RAM
PRICING[bx2-4x16]=150    # 4 vCPU, 16 GB RAM
PRICING[bx2-8x32]=300    # 8 vCPU, 32 GB RAM
PRICING[bx2-16x64]=600   # 16 vCPU, 64 GB RAM

PRICING[general-purpose]=0.10  # Per GB per month
PRICING[10iops-tier]=0.15      # Per GB per month

PRICING[vpc]=0            # VPC is free
PRICING[subnet]=0         # Subnets are free
PRICING[public-gateway]=45    # Per month
PRICING[load-balancer]=65     # Per month

PRICING[monitoring-basic]=30   # Per month
PRICING[monitoring-advanced]=75 # Per month
PRICING[backup-basic]=20      # Per month
PRICING[backup-advanced]=50   # Per month

# Parse terraform.tfvars file
parse_tfvars() {
    local tfvars_file="$1"
    
    if [ ! -f "$tfvars_file" ]; then
        print_status "$YELLOW" "⚠️  No terraform.tfvars file found, using defaults"
        return 1
    fi
    
    print_status "$BLUE" "📋 Parsing configuration from $tfvars_file"
    return 0
}

# Estimate compute costs
estimate_compute_costs() {
    print_status "$CYAN" "💻 Estimating compute costs..."
    
    # Default values (can be overridden by parsing tfvars)
    local web_profile="bx2-2x8"
    local web_instances=1
    local app_profile="bx2-4x16"
    local app_instances=1
    local data_profile="bx2-8x32"
    local data_instances=1
    
    # Calculate costs
    local web_cost=$((${PRICING[$web_profile]} * $web_instances))
    local app_cost=$((${PRICING[$app_profile]} * $app_instances))
    local data_cost=$((${PRICING[$data_profile]} * $data_instances))
    local total_compute=$((web_cost + app_cost + data_cost))
    
    echo "  Web Tier:  $web_instances x $web_profile = \$$web_cost/month"
    echo "  App Tier:  $app_instances x $app_profile = \$$app_cost/month"
    echo "  Data Tier: $data_instances x $data_profile = \$$data_cost/month"
    echo "  Total Compute: \$$total_compute/month"
    
    echo "$total_compute"
}

# Estimate storage costs
estimate_storage_costs() {
    print_status "$CYAN" "💾 Estimating storage costs..."
    
    # Default values
    local root_volume_size=100
    local root_volume_type="general-purpose"
    local data_volume_size=500
    local data_volume_type="10iops-tier"
    local instance_count=3
    
    # Calculate costs
    local root_cost=$(echo "$root_volume_size * ${PRICING[$root_volume_type]} * $instance_count" | bc -l)
    local data_cost=$(echo "$data_volume_size * ${PRICING[$data_volume_type]} * $instance_count" | bc -l)
    local total_storage=$(echo "$root_cost + $data_cost" | bc -l)
    
    printf "  Root Volumes: %d x %dGB x %s = \$%.2f/month\n" $instance_count $root_volume_size $root_volume_type $root_cost
    printf "  Data Volumes: %d x %dGB x %s = \$%.2f/month\n" $instance_count $data_volume_size $data_volume_type $data_cost
    printf "  Total Storage: \$%.2f/month\n" $total_storage
    
    printf "%.0f" $total_storage
}

# Estimate network costs
estimate_network_costs() {
    print_status "$CYAN" "🌐 Estimating network costs..."
    
    local vpc_cost=0
    local subnet_cost=0
    local gateway_cost=${PRICING[public-gateway]}
    local lb_cost=${PRICING[load-balancer]}
    local total_network=$((vpc_cost + subnet_cost + gateway_cost + lb_cost))
    
    echo "  VPC: \$$vpc_cost/month"
    echo "  Subnets: \$$subnet_cost/month"
    echo "  Public Gateway: \$$gateway_cost/month"
    echo "  Load Balancer: \$$lb_cost/month"
    echo "  Total Network: \$$total_network/month"
    
    echo "$total_network"
}

# Estimate monitoring costs
estimate_monitoring_costs() {
    print_status "$CYAN" "📊 Estimating monitoring costs..."
    
    local monitoring_enabled=true
    local monitoring_level="basic"
    
    if [ "$monitoring_enabled" = true ]; then
        local monitoring_cost=${PRICING[monitoring-$monitoring_level]}
        echo "  Monitoring ($monitoring_level): \$$monitoring_cost/month"
        echo "$monitoring_cost"
    else
        echo "  Monitoring: Disabled"
        echo "0"
    fi
}

# Estimate backup costs
estimate_backup_costs() {
    print_status "$CYAN" "💿 Estimating backup costs..."
    
    local backup_enabled=true
    local backup_level="basic"
    
    if [ "$backup_enabled" = true ]; then
        local backup_cost=${PRICING[backup-$backup_level]}
        echo "  Backup ($backup_level): \$$backup_cost/month"
        echo "$backup_cost"
    else
        echo "  Backup: Disabled"
        echo "0"
    fi
}

# Calculate environment-based adjustments
calculate_environment_adjustments() {
    local environment=${1:-"development"}
    local base_cost=$2
    
    print_status "$CYAN" "⚙️  Calculating environment adjustments..."
    
    case $environment in
        "development")
            local adjustment_factor=0.6  # 40% cost reduction for dev
            local adjusted_cost=$(echo "$base_cost * $adjustment_factor" | bc -l)
            printf "  Environment: %s (%.0f%% of base cost)\n" $environment $(echo "$adjustment_factor * 100" | bc -l)
            ;;
        "staging")
            local adjustment_factor=0.8  # 20% cost reduction for staging
            local adjusted_cost=$(echo "$base_cost * $adjustment_factor" | bc -l)
            printf "  Environment: %s (%.0f%% of base cost)\n" $environment $(echo "$adjustment_factor * 100" | bc -l)
            ;;
        "production")
            local adjustment_factor=1.2  # 20% increase for production (redundancy)
            local adjusted_cost=$(echo "$base_cost * $adjustment_factor" | bc -l)
            printf "  Environment: %s (%.0f%% of base cost)\n" $environment $(echo "$adjustment_factor * 100" | bc -l)
            ;;
        *)
            local adjustment_factor=1.0
            local adjusted_cost=$base_cost
            printf "  Environment: %s (no adjustment)\n" $environment
            ;;
    esac
    
    printf "%.0f" $adjusted_cost
}

# Generate cost breakdown
generate_cost_breakdown() {
    print_status "$BLUE" "📊 Generating detailed cost breakdown..."
    
    # Get individual cost components
    local compute_cost=$(estimate_compute_costs)
    local storage_cost=$(estimate_storage_costs)
    local network_cost=$(estimate_network_costs)
    local monitoring_cost=$(estimate_monitoring_costs)
    local backup_cost=$(estimate_backup_costs)
    
    # Calculate base total
    local base_total=$(echo "$compute_cost + $storage_cost + $network_cost + $monitoring_cost + $backup_cost" | bc -l)
    
    # Apply environment adjustments
    local environment="development"  # Default, can be parsed from tfvars
    local adjusted_total=$(calculate_environment_adjustments "$environment" "$base_total")
    
    # Generate JSON report
    local report_file="$PROJECT_DIR/cost_estimate.json"
    
    cat > "$report_file" << EOF
{
  "cost_estimation": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "environment": "$environment",
    "currency": "USD",
    "period": "monthly",
    "breakdown": {
      "compute": $compute_cost,
      "storage": $(printf "%.0f" $storage_cost),
      "network": $network_cost,
      "monitoring": $monitoring_cost,
      "backup": $backup_cost
    },
    "totals": {
      "base_total": $(printf "%.0f" $base_total),
      "environment_adjusted": $(printf "%.0f" $adjusted_total),
      "annual_estimate": $(printf "%.0f" $(echo "$adjusted_total * 12" | bc -l))
    },
    "cost_optimization": {
      "recommendations": [
        "Consider using smaller instance types for development",
        "Enable resource scheduling for non-production environments",
        "Use general-purpose storage for development workloads",
        "Implement auto-scaling to optimize compute costs",
        "Review backup retention policies for cost savings"
      ],
      "potential_savings": {
        "instance_rightsizing": "20-30%",
        "resource_scheduling": "60-70%",
        "storage_optimization": "15-25%",
        "backup_optimization": "30-40%"
      }
    }
  }
}
EOF
    
    print_status "$GREEN" "✅ Cost estimate saved to: $report_file"
}

# Display cost summary
display_cost_summary() {
    print_status "$BLUE" "💰 Cost Summary"
    echo "============================================================================="
    
    # Read from generated report
    local report_file="$PROJECT_DIR/cost_estimate.json"
    
    if [ -f "$report_file" ] && command -v jq &> /dev/null; then
        local compute=$(jq -r '.cost_estimation.breakdown.compute' "$report_file")
        local storage=$(jq -r '.cost_estimation.breakdown.storage' "$report_file")
        local network=$(jq -r '.cost_estimation.breakdown.network' "$report_file")
        local monitoring=$(jq -r '.cost_estimation.breakdown.monitoring' "$report_file")
        local backup=$(jq -r '.cost_estimation.breakdown.backup' "$report_file")
        local total=$(jq -r '.cost_estimation.totals.environment_adjusted' "$report_file")
        local annual=$(jq -r '.cost_estimation.totals.annual_estimate' "$report_file")
        
        printf "  Compute:    \$%s/month\n" "$compute"
        printf "  Storage:    \$%s/month\n" "$storage"
        printf "  Network:    \$%s/month\n" "$network"
        printf "  Monitoring: \$%s/month\n" "$monitoring"
        printf "  Backup:     \$%s/month\n" "$backup"
        echo "  ----------------------------------------"
        printf "  Monthly Total: \$%s\n" "$total"
        printf "  Annual Total:  \$%s\n" "$annual"
    else
        print_status "$YELLOW" "⚠️  Could not read cost report or jq not available"
    fi
    
    echo "============================================================================="
}

# Show cost optimization recommendations
show_recommendations() {
    print_status "$BLUE" "💡 Cost Optimization Recommendations"
    echo "============================================================================="
    
    echo "  1. Environment-based Sizing:"
    echo "     • Use smaller instances for development/testing"
    echo "     • Implement auto-scaling for production workloads"
    echo ""
    echo "  2. Resource Scheduling:"
    echo "     • Auto-stop development resources outside business hours"
    echo "     • Use scheduled scaling for predictable workloads"
    echo ""
    echo "  3. Storage Optimization:"
    echo "     • Use general-purpose storage for non-critical workloads"
    echo "     • Implement lifecycle policies for backup retention"
    echo ""
    echo "  4. Monitoring and Alerting:"
    echo "     • Set up cost alerts and budgets"
    echo "     • Monitor resource utilization for rightsizing"
    echo ""
    echo "  5. Reserved Instances:"
    echo "     • Consider reserved instances for production workloads"
    echo "     • Evaluate long-term commitments for cost savings"
    
    echo "============================================================================="
}

# Main execution
main() {
    print_header
    
    # Initialize log file
    echo "Cost estimation started at $(date)" > "$LOG_FILE"
    
    # Check for bc calculator
    if ! command -v bc &> /dev/null; then
        print_status "$RED" "❌ bc calculator not found. Please install bc for cost calculations."
        exit 1
    fi
    
    # Parse configuration if available
    parse_tfvars "$PROJECT_DIR/terraform.tfvars" || true
    
    # Generate cost breakdown
    generate_cost_breakdown
    
    # Display results
    display_cost_summary
    show_recommendations
    
    print_status "$GREEN" "🎉 Cost estimation completed!"
    print_status "$BLUE" "📋 Check cost_estimation.log for detailed results"
    print_status "$BLUE" "📊 Review cost_estimate.json for detailed breakdown"
}

# Error handling
trap 'print_status "$RED" "❌ Cost estimation failed with error on line $LINENO"' ERR

# Execute main function
main "$@"
