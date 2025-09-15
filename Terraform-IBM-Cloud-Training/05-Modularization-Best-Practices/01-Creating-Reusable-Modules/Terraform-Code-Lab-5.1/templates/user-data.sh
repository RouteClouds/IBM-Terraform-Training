#!/bin/bash
# =============================================================================
# USER DATA SCRIPT FOR COMPUTE INSTANCES
# =============================================================================
# Terraform Code Lab 5.1: Creating Reusable Modules
# This script initializes compute instances with basic configuration and
# enterprise-grade monitoring and security setup.

set -euo pipefail

# =============================================================================
# VARIABLES AND CONFIGURATION
# =============================================================================

HOSTNAME="${hostname}"
ENVIRONMENT="${environment}"
PROJECT="${project}"
INSTANCE_ID="${instance_id}"
LOG_FILE="/var/log/user-data.log"

# Create log file
touch $LOG_FILE
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "==============================================================================" 
echo "Starting user data script execution"
echo "Timestamp: $(date)"
echo "Hostname: $HOSTNAME"
echo "Environment: $ENVIRONMENT"
echo "Project: $PROJECT"
echo "Instance ID: $INSTANCE_ID"
echo "=============================================================================="

# =============================================================================
# SYSTEM UPDATES AND BASIC PACKAGES
# =============================================================================

echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

echo "Installing essential packages..."
apt-get install -y \
    curl \
    wget \
    unzip \
    jq \
    htop \
    tree \
    git \
    vim \
    nano \
    net-tools \
    telnet \
    tcpdump \
    iotop \
    iftop \
    nmap \
    python3 \
    python3-pip \
    nodejs \
    npm \
    docker.io \
    docker-compose

# =============================================================================
# HOSTNAME AND SYSTEM CONFIGURATION
# =============================================================================

echo "Configuring hostname..."
hostnamectl set-hostname $HOSTNAME
echo "127.0.0.1 $HOSTNAME" >> /etc/hosts

echo "Configuring timezone..."
timedatectl set-timezone UTC

echo "Configuring locale..."
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# =============================================================================
# USER CONFIGURATION
# =============================================================================

echo "Creating lab user..."
useradd -m -s /bin/bash labuser
usermod -aG sudo labuser
usermod -aG docker labuser

echo "Configuring SSH for lab user..."
mkdir -p /home/labuser/.ssh
chmod 700 /home/labuser/.ssh
chown labuser:labuser /home/labuser/.ssh

# Copy authorized keys from ubuntu user
if [ -f /home/ubuntu/.ssh/authorized_keys ]; then
    cp /home/ubuntu/.ssh/authorized_keys /home/labuser/.ssh/
    chown labuser:labuser /home/labuser/.ssh/authorized_keys
    chmod 600 /home/labuser/.ssh/authorized_keys
fi

# =============================================================================
# DOCKER CONFIGURATION
# =============================================================================

echo "Configuring Docker..."
systemctl enable docker
systemctl start docker

# Add users to docker group
usermod -aG docker ubuntu
usermod -aG docker labuser

# Configure Docker daemon
cat > /etc/docker/daemon.json << EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2"
}
EOF

systemctl restart docker

# =============================================================================
# MONITORING AND LOGGING SETUP
# =============================================================================

echo "Setting up monitoring and logging..."

# Install and configure rsyslog
apt-get install -y rsyslog
systemctl enable rsyslog
systemctl start rsyslog

# Configure log rotation
cat > /etc/logrotate.d/user-data << EOF
/var/log/user-data.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

# Install CloudWatch agent (if needed)
if [ "$ENVIRONMENT" = "production" ]; then
    echo "Installing monitoring agent for production environment..."
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    dpkg -i amazon-cloudwatch-agent.deb || true
    apt-get install -f -y
fi

# =============================================================================
# SECURITY HARDENING
# =============================================================================

echo "Applying security hardening..."

# Configure firewall
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp

# Disable root login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# Configure fail2ban
apt-get install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Set up automatic security updates
apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades

# =============================================================================
# APPLICATION SETUP
# =============================================================================

echo "Setting up web server..."

# Install and configure nginx
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# Create custom index page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IBM Cloud Terraform Lab - $HOSTNAME</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f4; }
        .container { background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { color: #0f62fe; border-bottom: 2px solid #0f62fe; padding-bottom: 10px; }
        .info { margin: 20px 0; }
        .label { font-weight: bold; color: #393939; }
        .value { color: #161616; }
        .status { padding: 5px 10px; border-radius: 4px; display: inline-block; margin: 5px 0; }
        .success { background-color: #24a148; color: white; }
        .info-status { background-color: #0f62fe; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">IBM Cloud Terraform Training Lab</h1>
        <h2>Topic 5.1: Creating Reusable Modules</h2>
        
        <div class="info">
            <div><span class="label">Hostname:</span> <span class="value">$HOSTNAME</span></div>
            <div><span class="label">Environment:</span> <span class="value">$ENVIRONMENT</span></div>
            <div><span class="label">Project:</span> <span class="value">$PROJECT</span></div>
            <div><span class="label">Instance ID:</span> <span class="value">$INSTANCE_ID</span></div>
            <div><span class="label">Deployment Time:</span> <span class="value">$(date)</span></div>
        </div>
        
        <div class="info">
            <div class="status success">✓ Instance Initialized</div>
            <div class="status success">✓ Web Server Running</div>
            <div class="status success">✓ Security Configured</div>
            <div class="status info-status">ℹ Module Lab Ready</div>
        </div>
        
        <div class="info">
            <h3>System Information</h3>
            <div><span class="label">OS:</span> <span class="value">$(lsb_release -d | cut -f2)</span></div>
            <div><span class="label">Kernel:</span> <span class="value">$(uname -r)</span></div>
            <div><span class="label">Architecture:</span> <span class="value">$(uname -m)</span></div>
            <div><span class="label">Uptime:</span> <span class="value">$(uptime -p)</span></div>
        </div>
        
        <div class="info">
            <h3>Network Information</h3>
            <div><span class="label">Private IP:</span> <span class="value">$(hostname -I | awk '{print $1}')</span></div>
            <div><span class="label">Public IP:</span> <span class="value">$(curl -s ifconfig.me || echo "Not available")</span></div>
        </div>
        
        <div class="info">
            <h3>Services Status</h3>
            <div><span class="label">Docker:</span> <span class="value">$(systemctl is-active docker)</span></div>
            <div><span class="label">SSH:</span> <span class="value">$(systemctl is-active ssh)</span></div>
            <div><span class="label">UFW:</span> <span class="value">$(systemctl is-active ufw)</span></div>
            <div><span class="label">Nginx:</span> <span class="value">$(systemctl is-active nginx)</span></div>
        </div>
    </div>
</body>
</html>
EOF

# =============================================================================
# TERRAFORM AND DEVELOPMENT TOOLS
# =============================================================================

echo "Installing development tools..."

# Install Terraform
TERRAFORM_VERSION="1.5.7"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install IBM Cloud CLI
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# =============================================================================
# ENVIRONMENT VARIABLES AND PROFILES
# =============================================================================

echo "Configuring environment variables..."

# Create environment file
cat > /etc/environment << EOF
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
HOSTNAME="$HOSTNAME"
ENVIRONMENT="$ENVIRONMENT"
PROJECT="$PROJECT"
INSTANCE_ID="$INSTANCE_ID"
TZ="UTC"
EOF

# Configure bash profile for all users
cat > /etc/profile.d/lab-environment.sh << EOF
#!/bin/bash
# Lab environment configuration

export HOSTNAME="$HOSTNAME"
export ENVIRONMENT="$ENVIRONMENT"
export PROJECT="$PROJECT"
export INSTANCE_ID="$INSTANCE_ID"

# Terraform configuration
export TF_LOG_PATH="/var/log/terraform.log"
export TF_INPUT=false

# IBM Cloud CLI configuration
export IBMCLOUD_COLOR=true
export IBMCLOUD_VERSION_CHECK=false

# Aliases for convenience
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias tf='terraform'
alias ic='ibmcloud'

# Custom prompt
export PS1='\[\033[01;32m\]\u@$HOSTNAME\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOF

chmod +x /etc/profile.d/lab-environment.sh

# =============================================================================
# HEALTH CHECKS AND VALIDATION
# =============================================================================

echo "Running health checks..."

# Create health check script
cat > /usr/local/bin/health-check.sh << EOF
#!/bin/bash
# Health check script for lab instance

echo "=== Health Check Report ==="
echo "Timestamp: \$(date)"
echo "Hostname: \$(hostname)"
echo ""

echo "=== System Status ==="
echo "Uptime: \$(uptime -p)"
echo "Load Average: \$(uptime | awk -F'load average:' '{print \$2}')"
echo "Memory Usage: \$(free -h | grep Mem | awk '{print \$3 "/" \$2}')"
echo "Disk Usage: \$(df -h / | tail -1 | awk '{print \$3 "/" \$2 " (" \$5 ")"}')"
echo ""

echo "=== Service Status ==="
services=("docker" "nginx" "ssh" "ufw")
for service in "\${services[@]}"; do
    status=\$(systemctl is-active \$service)
    echo "\$service: \$status"
done
echo ""

echo "=== Network Status ==="
echo "Private IP: \$(hostname -I | awk '{print \$1}')"
echo "Public IP: \$(curl -s --max-time 5 ifconfig.me || echo 'Not available')"
echo "DNS Resolution: \$(nslookup google.com > /dev/null 2>&1 && echo 'OK' || echo 'Failed')"
echo ""

echo "=== Application Status ==="
echo "Web Server: \$(curl -s -o /dev/null -w '%{http_code}' http://localhost/ || echo 'Failed')"
echo "Docker: \$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo 'Failed')"
echo "Terraform: \$(terraform version -json 2>/dev/null | jq -r '.terraform_version' || echo 'Failed')"
echo ""

echo "=== Security Status ==="
echo "UFW Status: \$(ufw status | head -1)"
echo "Fail2ban: \$(systemctl is-active fail2ban)"
echo "SSH Config: \$(grep -E '^(PermitRootLogin|PasswordAuthentication)' /etc/ssh/sshd_config | tr '\n' ' ')"
echo ""

echo "=== End Health Check ==="
EOF

chmod +x /usr/local/bin/health-check.sh

# Run initial health check
/usr/local/bin/health-check.sh

# =============================================================================
# CLEANUP AND FINALIZATION
# =============================================================================

echo "Cleaning up..."

# Clean package cache
apt-get autoremove -y
apt-get autoclean

# Clear bash history
history -c

# Update locate database
updatedb

# =============================================================================
# COMPLETION
# =============================================================================

echo "=============================================================================="
echo "User data script execution completed successfully"
echo "Timestamp: $(date)"
echo "Instance is ready for Terraform module development and testing"
echo "=============================================================================="

# Create completion marker
touch /var/log/user-data-complete
echo "$(date): User data script completed successfully" > /var/log/user-data-complete

# Send completion signal (if monitoring is enabled)
if [ "$ENVIRONMENT" = "production" ]; then
    curl -X POST -H "Content-Type: application/json" \
         -d "{\"instance_id\":\"$INSTANCE_ID\",\"status\":\"ready\",\"timestamp\":\"$(date -Iseconds)\"}" \
         "https://monitoring.example.com/api/v1/instance-ready" || true
fi

exit 0
