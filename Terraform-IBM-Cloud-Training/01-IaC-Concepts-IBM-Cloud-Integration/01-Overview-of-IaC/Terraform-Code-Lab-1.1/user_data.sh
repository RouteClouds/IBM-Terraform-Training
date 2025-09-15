#!/bin/bash
# User Data Script for IBM Cloud IaC Training Lab 1.1
# This script runs during the initial boot of the virtual server instance

# Set hostname
hostnamectl set-hostname ${hostname}

# Update system packages
apt-get update -y

# Install essential packages
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    tree \
    jq \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Create a welcome message
cat > /etc/motd << 'EOF'
================================================================================
  Welcome to IBM Cloud IaC Training Lab 1.1
  
  This virtual server instance was created using Infrastructure as Code (IaC)
  with Terraform and IBM Cloud Provider.
  
  Instance Details:
  - Hostname: ${hostname}
  - Created: $(date)
  - Purpose: IaC Training and Demonstration
  
  Useful Commands:
  - Check system info: hostnamectl
  - View network config: ip addr show
  - Check disk usage: df -h
  - View running processes: htop
  
  Happy Learning!
================================================================================
EOF

# Create a simple info script
cat > /usr/local/bin/lab-info << 'EOF'
#!/bin/bash
echo "=== IBM Cloud IaC Training Lab Information ==="
echo "Hostname: $(hostname)"
echo "Private IP: $(hostname -I | awk '{print $1}')"
echo "OS Version: $(lsb_release -d | cut -f2)"
echo "Uptime: $(uptime -p)"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}') used"
echo "Memory Usage: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "CPU Info: $(nproc) cores"
echo "=== End Lab Information ==="
EOF

chmod +x /usr/local/bin/lab-info

# Create a simple web server for testing (optional)
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>IaC Training Lab 1.1</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #1f70c1; }
        .info { background-color: #e3f2fd; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .success { color: #4caf50; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 IBM Cloud IaC Training Lab 1.1</h1>
        <div class="success">✅ Infrastructure as Code deployment successful!</div>
        
        <div class="info">
            <h3>Instance Information</h3>
            <p><strong>Hostname:</strong> ${hostname}</p>
            <p><strong>Created:</strong> $(date)</p>
            <p><strong>Purpose:</strong> Infrastructure as Code Training</p>
        </div>
        
        <h3>What was created with IaC?</h3>
        <ul>
            <li>Virtual Private Cloud (VPC)</li>
            <li>Subnet with proper CIDR configuration</li>
            <li>Security Group with custom rules</li>
            <li>Virtual Server Instance (this server)</li>
            <li>Public Gateway for internet access</li>
        </ul>
        
        <h3>Key IaC Benefits Demonstrated</h3>
        <ul>
            <li>🔄 <strong>Reproducibility:</strong> This exact infrastructure can be recreated anywhere</li>
            <li>📝 <strong>Version Control:</strong> All infrastructure is defined in code</li>
            <li>⚡ <strong>Speed:</strong> Automated deployment vs manual clicking</li>
            <li>🛡️ <strong>Consistency:</strong> No human errors in configuration</li>
            <li>📊 <strong>Documentation:</strong> Code serves as living documentation</li>
        </ul>
        
        <p><em>This page was automatically generated during instance provisioning using Terraform user_data.</em></p>
    </div>
</body>
</html>
EOF

# Install and start a simple web server (nginx)
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# Log the completion
echo "$(date): User data script completed successfully" >> /var/log/user-data.log

# Create a completion marker
touch /tmp/user-data-complete
