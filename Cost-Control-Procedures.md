# Cost Control Procedures - IBM Cloud Terraform Training

## 🎯 **Executive Summary**

This document establishes comprehensive cost control procedures to ensure predictable, controlled spending during IBM Cloud Terraform training while maintaining educational effectiveness and preventing unexpected charges.

**Cost Target**: $50 maximum per student for 4-day training  
**Risk Tolerance**: Zero tolerance for budget overruns  
**Monitoring**: Real-time cost tracking with automated alerts

## 💰 **Cost Framework**

### **Budget Allocation Structure**

#### **Per-Student Budget Breakdown**
```
Total Budget: $50.00 per student
├── Compute Resources: $20.00 (40%)
│   ├── Virtual Server Instances: $15.00
│   └── Container Services: $5.00
├── Storage: $10.00 (20%)
│   ├── Block Storage: $6.00
│   └── Object Storage: $4.00
├── Networking: $8.00 (16%)
│   ├── VPC and Subnets: $3.00
│   ├── Load Balancers: $3.00
│   └── Public IPs: $2.00
├── Security Services: $7.00 (14%)
│   ├── Key Protect: $3.00
│   ├── Activity Tracker: $2.00
│   └── Certificate Manager: $2.00
└── Buffer/Contingency: $5.00 (10%)
    └── Extended learning time: $5.00
```

#### **Daily Budget Targets**
- **Day 1**: $8.00 (Foundation setup)
- **Day 2**: $12.00 (Core resources)
- **Day 3**: $15.00 (Advanced features)
- **Day 4**: $10.00 (Integration and cleanup)
- **Buffer**: $5.00 (Contingency)

### **Cost Control Mechanisms**

#### **1. Preventive Controls**
- **Resource Quotas**: Hard limits on resource creation
- **Service Restrictions**: Limited to training-essential services only
- **Geographic Restrictions**: Single region deployment (us-south)
- **Instance Size Limits**: Maximum VSI size restrictions

#### **2. Detective Controls**
- **Real-time Monitoring**: Continuous cost tracking
- **Automated Alerts**: Threshold-based notifications
- **Daily Reporting**: Cost breakdown by student and lab
- **Anomaly Detection**: Unusual spending pattern identification

#### **3. Corrective Controls**
- **Automated Shutdown**: Scheduled resource deactivation
- **Emergency Stops**: Immediate resource termination capability
- **Cleanup Automation**: Scheduled resource removal
- **Manual Intervention**: Instructor override capabilities

## 🔧 **Implementation Procedures**

### **Pre-Training Setup**

#### **1. Budget Configuration**
```bash
#!/bin/bash
# Set up cost monitoring for training account

# Create budget alert for training account
ibmcloud billing budget-create \
  --name "terraform-training-budget" \
  --amount 50 \
  --currency USD \
  --type COST \
  --time-period MONTHLY \
  --threshold 80 \
  --threshold-type PERCENTAGE

# Configure spending notifications
ibmcloud billing notification-create \
  --budget-id [BUDGET-ID] \
  --threshold 50 \
  --emails "instructor@company.com,admin@company.com"
```

#### **2. Resource Quota Setup**
```hcl
# Terraform configuration for resource quotas
resource "ibm_iam_access_group_policy" "training_quota_policy" {
  access_group_id = ibm_iam_access_group.training_students.id
  roles           = ["Editor"]
  
  resources {
    service = "is"
    attributes = {
      "resource" = "instance"
    }
  }
  
  rule {
    key      = "max_instances"
    operator = "numericLessThanOrEquals"
    value    = ["5"]
  }
}
```

### **During Training Monitoring**

#### **3. Real-Time Cost Tracking**
```bash
#!/bin/bash
# Real-time cost monitoring script (run every 15 minutes)

# Get current spending for all training accounts
for student_id in $(cat student_list.txt); do
  current_cost=$(ibmcloud billing account-usage \
    --account-id "training-student-${student_id}" \
    --output json | jq '.total_cost')
  
  echo "Student ${student_id}: $${current_cost}"
  
  # Alert if over 80% of daily budget
  daily_budget=12.50  # Average daily budget
  if (( $(echo "$current_cost > $daily_budget * 0.8" | bc -l) )); then
    send_alert "Student ${student_id} approaching daily budget limit"
  fi
done
```

#### **4. Automated Alerts System**
```python
#!/usr/bin/env python3
# Cost alert system for training monitoring

import json
import requests
from datetime import datetime

def check_student_costs():
    """Monitor student costs and send alerts"""
    
    # Cost thresholds
    DAILY_BUDGET = 12.50
    TOTAL_BUDGET = 50.00
    
    # Alert thresholds
    WARNING_THRESHOLD = 0.75  # 75%
    CRITICAL_THRESHOLD = 0.90  # 90%
    
    for student in get_student_list():
        current_cost = get_student_cost(student['id'])
        
        # Calculate percentage of budget used
        daily_percentage = current_cost / DAILY_BUDGET
        total_percentage = current_cost / TOTAL_BUDGET
        
        # Send alerts based on thresholds
        if daily_percentage >= CRITICAL_THRESHOLD:
            send_critical_alert(student, current_cost, DAILY_BUDGET)
        elif daily_percentage >= WARNING_THRESHOLD:
            send_warning_alert(student, current_cost, DAILY_BUDGET)

def send_critical_alert(student, cost, budget):
    """Send critical cost alert to instructors"""
    message = f"""
    CRITICAL: Student {student['name']} cost alert
    Current spending: ${cost:.2f}
    Daily budget: ${budget:.2f}
    Percentage used: {(cost/budget)*100:.1f}%
    Action required: Immediate intervention needed
    """
    send_slack_alert(message, channel="#training-alerts")
    send_email_alert(message, "instructor@company.com")
```

### **Automated Cleanup Procedures**

#### **5. Scheduled Resource Cleanup**
```bash
#!/bin/bash
# Automated cleanup script (runs every 4 hours)

# Function to cleanup student resources
cleanup_student_resources() {
    local student_id=$1
    local resource_group="terraform-training-student-${student_id}"
    
    echo "Cleaning up resources for student: ${student_id}"
    
    # Stop all running VSI instances
    ibmcloud is instances \
      --resource-group-name "${resource_group}" \
      --output json | \
      jq -r '.[] | select(.status=="running") | .id' | \
      while read instance_id; do
        echo "Stopping instance: ${instance_id}"
        ibmcloud is instance-stop "${instance_id}"
      done
    
    # Remove temporary resources older than 24 hours
    ibmcloud resource search \
      "tags:temporary AND resource_group_name:${resource_group}" \
      --output json | \
      jq -r '.items[] | select(.created_at < "'$(date -d '24 hours ago' -I)'") | .crn' | \
      while read resource_crn; do
        echo "Removing temporary resource: ${resource_crn}"
        ibmcloud resource service-instance-delete "${resource_crn}" --force
      done
}

# Cleanup all student environments
for student_id in $(cat student_list.txt); do
    cleanup_student_resources "${student_id}"
done
```

#### **6. End-of-Day Shutdown**
```bash
#!/bin/bash
# End-of-day shutdown script (runs at 6 PM daily)

# Shutdown all compute resources to prevent overnight charges
for student_id in $(cat student_list.txt); do
    resource_group="terraform-training-student-${student_id}"
    
    # Stop all VSI instances
    ibmcloud is instances \
      --resource-group-name "${resource_group}" \
      --output json | \
      jq -r '.[] | .id' | \
      xargs -I {} ibmcloud is instance-stop {}
    
    # Suspend container services
    ibmcloud ks clusters \
      --resource-group "${resource_group}" \
      --output json | \
      jq -r '.[] | .id' | \
      xargs -I {} ibmcloud ks cluster-config {} --admin
done

echo "All compute resources stopped for cost control"
```

## 📊 **Monitoring and Reporting**

### **Daily Cost Reports**

#### **7. Automated Daily Reports**
```bash
#!/bin/bash
# Generate daily cost report

# Create daily cost summary
cat > daily_cost_report.html << EOF
<html>
<head><title>Daily Training Cost Report - $(date)</title></head>
<body>
<h1>IBM Cloud Terraform Training - Daily Cost Report</h1>
<h2>Date: $(date)</h2>

<table border="1">
<tr><th>Student ID</th><th>Daily Cost</th><th>Total Cost</th><th>Budget %</th><th>Status</th></tr>
EOF

total_cost=0
student_count=0

for student_id in $(cat student_list.txt); do
    daily_cost=$(get_daily_cost "${student_id}")
    total_cost_student=$(get_total_cost "${student_id}")
    budget_percentage=$(echo "scale=1; ${total_cost_student} / 50 * 100" | bc)
    
    # Determine status
    if (( $(echo "$budget_percentage > 90" | bc -l) )); then
        status="CRITICAL"
    elif (( $(echo "$budget_percentage > 75" | bc -l) )); then
        status="WARNING"
    else
        status="OK"
    fi
    
    echo "<tr><td>${student_id}</td><td>\$${daily_cost}</td><td>\$${total_cost_student}</td><td>${budget_percentage}%</td><td>${status}</td></tr>" >> daily_cost_report.html
    
    total_cost=$(echo "${total_cost} + ${total_cost_student}" | bc)
    student_count=$((student_count + 1))
done

average_cost=$(echo "scale=2; ${total_cost} / ${student_count}" | bc)

cat >> daily_cost_report.html << EOF
</table>

<h3>Summary</h3>
<p>Total Students: ${student_count}</p>
<p>Total Cost: \$${total_cost}</p>
<p>Average Cost per Student: \$${average_cost}</p>
<p>Budget Utilization: $(echo "scale=1; ${average_cost} / 50 * 100" | bc)%</p>

</body>
</html>
EOF

# Email report to instructors
mail -s "Daily Training Cost Report" -a "Content-Type: text/html" \
  instructor@company.com < daily_cost_report.html
```

### **Emergency Procedures**

#### **8. Emergency Cost Control**
```bash
#!/bin/bash
# Emergency cost control - immediate resource shutdown

emergency_shutdown() {
    echo "EMERGENCY: Initiating immediate cost control measures"
    
    # Stop all training resources immediately
    for student_id in $(cat student_list.txt); do
        resource_group="terraform-training-student-${student_id}"
        
        # Emergency stop all instances
        ibmcloud is instances \
          --resource-group-name "${resource_group}" \
          --output json | \
          jq -r '.[] | .id' | \
          xargs -I {} ibmcloud is instance-stop {} --force
        
        # Delete all temporary resources
        ibmcloud resource search \
          "tags:temporary AND resource_group_name:${resource_group}" \
          --output json | \
          jq -r '.items[] | .crn' | \
          xargs -I {} ibmcloud resource service-instance-delete {} --force
    done
    
    # Send emergency notification
    send_emergency_alert "Emergency cost control activated - all training resources stopped"
}

# Trigger emergency shutdown if total cost exceeds threshold
total_training_cost=$(calculate_total_training_cost)
emergency_threshold=2500  # $2500 for 50 students

if (( $(echo "$total_training_cost > $emergency_threshold" | bc -l) )); then
    emergency_shutdown
fi
```

## 📋 **Cost Control Checklist**

### **Pre-Training Setup**
- [ ] Budget alerts configured for all student accounts
- [ ] Resource quotas implemented and tested
- [ ] Monitoring scripts deployed and scheduled
- [ ] Emergency procedures documented and tested
- [ ] Instructor notification systems configured

### **Daily Operations**
- [ ] Morning cost report reviewed
- [ ] Real-time monitoring active
- [ ] Student cost alerts monitored
- [ ] End-of-day shutdown executed
- [ ] Daily cleanup procedures completed

### **Post-Training Cleanup**
- [ ] All student resources inventoried
- [ ] Final cost report generated
- [ ] Unused resources removed
- [ ] Student accounts deactivated
- [ ] Cost optimization recommendations documented

## 🚨 **Alert Thresholds**

### **Notification Levels**
- **INFO (50% budget)**: Daily email summary
- **WARNING (75% budget)**: Immediate email + Slack alert
- **CRITICAL (90% budget)**: Phone call + immediate intervention
- **EMERGENCY (100% budget)**: Automatic resource shutdown

### **Response Times**
- **WARNING alerts**: 15 minutes response time
- **CRITICAL alerts**: 5 minutes response time
- **EMERGENCY situations**: Immediate automated response

---

**Responsibility**: All instructors must monitor cost alerts and respond according to established procedures. Students are responsible for following resource cleanup guidelines provided in lab exercises.
