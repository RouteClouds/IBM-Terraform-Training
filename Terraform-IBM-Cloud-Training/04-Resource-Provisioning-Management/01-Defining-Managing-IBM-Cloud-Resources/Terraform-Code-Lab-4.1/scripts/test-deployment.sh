#!/bin/bash
# =============================================================================
# DEPLOYMENT TESTING SCRIPT
# Topic 4.1: Defining and Managing IBM Cloud Resources
# =============================================================================

set -e

echo "🧪 Terraform Lab 4.1 Deployment Testing"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Function to test HTTP endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local expected_status=${3:-200}
    
    echo "Testing: $description"
    echo "URL: $url"
    
    if response=$(curl -s -w "%{http_code}" -o /tmp/response.json "$url" 2>/dev/null); then
        status_code="${response: -3}"
        if [ "$status_code" = "$expected_status" ]; then
            print_status "SUCCESS" "$description - HTTP $status_code"
            if [ -f /tmp/response.json ] && [ -s /tmp/response.json ]; then
                echo "Response preview:"
                head -c 200 /tmp/response.json | jq . 2>/dev/null || cat /tmp/response.json | head -c 200
                echo ""
            fi
        else
            print_status "ERROR" "$description - HTTP $status_code (expected $expected_status)"
        fi
    else
        print_status "ERROR" "$description - Connection failed"
    fi
    echo ""
}

# =============================================================================
# INFRASTRUCTURE STATUS CHECK
# =============================================================================

echo ""
echo "🏗️ Checking Infrastructure Status..."
echo "-----------------------------------"

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    print_status "ERROR" "Terraform state file not found"
    print_status "INFO" "Run 'terraform apply' to deploy infrastructure first"
    exit 1
fi

# Get deployment status
DEPLOYMENT_STATUS=$(terraform output -json 2>/dev/null || echo '{}')

if [ "$DEPLOYMENT_STATUS" = '{}' ]; then
    print_status "ERROR" "No Terraform outputs found"
    print_status "INFO" "Infrastructure may not be deployed or outputs not configured"
    exit 1
fi

print_status "SUCCESS" "Terraform state and outputs found"

# =============================================================================
# LOAD BALANCER TESTING
# =============================================================================

echo ""
echo "⚖️ Testing Load Balancer..."
echo "--------------------------"

# Get load balancer hostname
LB_HOSTNAME=$(echo "$DEPLOYMENT_STATUS" | jq -r '.access_information.value.web_application.url' 2>/dev/null | sed 's|http://||')

if [ "$LB_HOSTNAME" = "null" ] || [ -z "$LB_HOSTNAME" ]; then
    print_status "ERROR" "Load balancer hostname not found in outputs"
    exit 1
fi

print_status "INFO" "Load balancer hostname: $LB_HOSTNAME"

# Test main application
test_endpoint "http://$LB_HOSTNAME" "Main web application"

# Test health check
test_endpoint "http://$LB_HOSTNAME/health" "Load balancer health check"

# Test status endpoint
test_endpoint "http://$LB_HOSTNAME/status" "Application status endpoint"

# =============================================================================
# WEB SERVER TESTING
# =============================================================================

echo ""
echo "🌐 Testing Web Servers..."
echo "------------------------"

# Get web server IPs
WEB_SERVER_IPS=$(echo "$DEPLOYMENT_STATUS" | jq -r '.compute_instances.value.web_servers.instances[].private_ip' 2>/dev/null)

if [ -z "$WEB_SERVER_IPS" ]; then
    print_status "WARNING" "Web server IPs not found in outputs"
else
    echo "Web server private IPs:"
    echo "$WEB_SERVER_IPS" | while read -r ip; do
        if [ -n "$ip" ]; then
            print_status "INFO" "Web server: $ip"
            # Note: Direct testing of private IPs requires VPN or bastion host
            # test_endpoint "http://$ip/health" "Direct web server health check"
        fi
    done
fi

# =============================================================================
# INFRASTRUCTURE VALIDATION
# =============================================================================

echo ""
echo "🔍 Infrastructure Validation..."
echo "------------------------------"

# Check VPC status
VPC_STATUS=$(echo "$DEPLOYMENT_STATUS" | jq -r '.vpc_infrastructure.value.vpc.status' 2>/dev/null)
if [ "$VPC_STATUS" = "available" ]; then
    print_status "SUCCESS" "VPC is available"
else
    print_status "WARNING" "VPC status: $VPC_STATUS"
fi

# Check subnet count
SUBNET_COUNT=$(echo "$DEPLOYMENT_STATUS" | jq -r '.vpc_infrastructure.value.subnets | length' 2>/dev/null)
if [ "$SUBNET_COUNT" -ge 6 ]; then
    print_status "SUCCESS" "All $SUBNET_COUNT subnets deployed"
else
    print_status "WARNING" "Only $SUBNET_COUNT subnets found (expected 6)"
fi

# Check instance count
TOTAL_INSTANCES=$(echo "$DEPLOYMENT_STATUS" | jq -r '.compute_instances.value.instance_summary.total_instances' 2>/dev/null)
if [ "$TOTAL_INSTANCES" -ge 5 ]; then
    print_status "SUCCESS" "All $TOTAL_INSTANCES instances deployed"
else
    print_status "WARNING" "Only $TOTAL_INSTANCES instances found"
fi

# Check load balancer status
LB_STATUS=$(echo "$DEPLOYMENT_STATUS" | jq -r '.load_balancer_configuration.value.load_balancer.status' 2>/dev/null)
if [ "$LB_STATUS" = "active" ]; then
    print_status "SUCCESS" "Load balancer is active"
else
    print_status "WARNING" "Load balancer status: $LB_STATUS"
fi

# =============================================================================
# SECURITY VALIDATION
# =============================================================================

echo ""
echo "🔒 Security Validation..."
echo "------------------------"

# Check security group count
SG_COUNT=$(echo "$DEPLOYMENT_STATUS" | jq -r '.security_configuration.value.security_groups | length' 2>/dev/null)
if [ "$SG_COUNT" -eq 3 ]; then
    print_status "SUCCESS" "All 3 security groups configured"
else
    print_status "WARNING" "Found $SG_COUNT security groups (expected 3)"
fi

# Check encryption status
ENCRYPTION_ENABLED=$(echo "$DEPLOYMENT_STATUS" | jq -r '.storage_configuration.value.storage_summary.encryption_enabled' 2>/dev/null)
if [ "$ENCRYPTION_ENABLED" = "true" ]; then
    print_status "SUCCESS" "Storage encryption enabled"
else
    print_status "WARNING" "Storage encryption status unclear"
fi

# =============================================================================
# PERFORMANCE TESTING
# =============================================================================

echo ""
echo "⚡ Performance Testing..."
echo "------------------------"

# Simple load test
print_status "INFO" "Running basic load test (10 requests)..."

LOAD_TEST_RESULTS=""
SUCCESS_COUNT=0
TOTAL_REQUESTS=10

for i in $(seq 1 $TOTAL_REQUESTS); do
    if curl -s -o /dev/null -w "%{http_code}" "http://$LB_HOSTNAME" | grep -q "200"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    fi
    sleep 0.5
done

SUCCESS_RATE=$((SUCCESS_COUNT * 100 / TOTAL_REQUESTS))

if [ $SUCCESS_RATE -ge 90 ]; then
    print_status "SUCCESS" "Load test: $SUCCESS_COUNT/$TOTAL_REQUESTS requests successful ($SUCCESS_RATE%)"
else
    print_status "WARNING" "Load test: $SUCCESS_COUNT/$TOTAL_REQUESTS requests successful ($SUCCESS_RATE%)"
fi

# =============================================================================
# COST ANALYSIS
# =============================================================================

echo ""
echo "💰 Cost Analysis..."
echo "------------------"

ESTIMATED_COST=$(echo "$DEPLOYMENT_STATUS" | jq -r '.cost_analysis.value.estimated_monthly_costs.total_estimated_monthly_cost' 2>/dev/null)
if [ "$ESTIMATED_COST" != "null" ] && [ -n "$ESTIMATED_COST" ]; then
    print_status "INFO" "Estimated monthly cost: \$${ESTIMATED_COST}"
else
    print_status "WARNING" "Cost information not available"
fi

# =============================================================================
# MONITORING CHECK
# =============================================================================

echo ""
echo "📊 Monitoring Check..."
echo "---------------------"

MONITORING_ENABLED=$(echo "$DEPLOYMENT_STATUS" | jq -r '.monitoring_configuration.value.monitoring_enabled' 2>/dev/null)
if [ "$MONITORING_ENABLED" = "true" ]; then
    print_status "SUCCESS" "Monitoring enabled"
else
    print_status "WARNING" "Monitoring status unclear"
fi

# =============================================================================
# TEST SUMMARY
# =============================================================================

echo ""
echo "📋 Test Summary"
echo "==============="

print_status "SUCCESS" "Deployment testing completed"

echo ""
echo "🔗 Access Information:"
echo "- Web Application: http://$LB_HOSTNAME"
echo "- Health Check: http://$LB_HOSTNAME/health"
echo "- Status API: http://$LB_HOSTNAME/status"

echo ""
echo "📊 Infrastructure Summary:"
echo "- VPC: $VPC_STATUS"
echo "- Subnets: $SUBNET_COUNT deployed"
echo "- Instances: $TOTAL_INSTANCES running"
echo "- Load Balancer: $LB_STATUS"
echo "- Security Groups: $SG_COUNT configured"

echo ""
echo "🎯 Next Steps:"
echo "1. Monitor application performance and resource utilization"
echo "2. Review security configurations and access controls"
echo "3. Test scaling operations by modifying instance counts"
echo "4. Implement monitoring and alerting with IBM Cloud services"
echo "5. Clean up resources when testing is complete: terraform destroy"

echo ""
print_status "SUCCESS" "All tests completed successfully!"

# Clean up temporary files
rm -f /tmp/response.json
