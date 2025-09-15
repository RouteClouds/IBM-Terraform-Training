#!/bin/bash

# =============================================================================
# USER DATA SCRIPT FOR VSI INITIALIZATION
# Subtopic 6.2: State Locking and Drift Detection
# Configures VSI for state management demonstration
# =============================================================================

set -euo pipefail

# Template variables (replaced by Terraform)
PROJECT_NAME="${project_name}"
ENVIRONMENT="${environment}"
ENABLE_DRIFT_SIMULATION="${enable_drift_simulation}"

# Logging setup
LOG_FILE="/var/log/user-data.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "Starting VSI initialization for State Locking Lab"
echo "Project: $PROJECT_NAME"
echo "Environment: $ENVIRONMENT"
echo "Drift Simulation: $ENABLE_DRIFT_SIMULATION"
echo "Timestamp: $(date)"

# =============================================================================
# SYSTEM UPDATES AND BASIC PACKAGES
# =============================================================================

echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

echo "Installing basic packages..."
apt-get install -y \
    curl \
    wget \
    jq \
    unzip \
    git \
    htop \
    tree \
    vim \
    nano \
    net-tools \
    dnsutils \
    telnet \
    tcpdump

# =============================================================================
# TERRAFORM INSTALLATION
# =============================================================================

echo "Installing Terraform..."
TERRAFORM_VERSION="1.5.7"
cd /tmp
wget "https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_$${TERRAFORM_VERSION}_linux_amd64.zip"
mv terraform /usr/local/bin/
chmod +x /usr/local/bin/terraform
rm -f "terraform_$${TERRAFORM_VERSION}_linux_amd64.zip"

# Verify installation
terraform version

# =============================================================================
# IBM CLOUD CLI INSTALLATION
# =============================================================================

echo "Installing IBM Cloud CLI..."
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Install required plugins
ibmcloud plugin install vpc-infrastructure
ibmcloud plugin install cloud-object-storage
ibmcloud plugin install cloud-functions

# =============================================================================
# DOCKER INSTALLATION (for containerized applications)
# =============================================================================

echo "Installing Docker..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Start and enable Docker
systemctl start docker
systemctl enable docker

# =============================================================================
# MONITORING AGENT INSTALLATION
# =============================================================================

echo "Installing monitoring tools..."

# Install Node Exporter for Prometheus monitoring
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.6.1.linux-amd64*

# Create systemd service for Node Exporter
cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nobody
Group=nogroup
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

# =============================================================================
# APPLICATION SETUP
# =============================================================================

echo "Setting up application environment..."

# Create application directory
mkdir -p /opt/state-locking-demo
cd /opt/state-locking-demo

# Create demo application
cat > app.py << 'EOF'
#!/usr/bin/env python3
"""
State Locking Demo Application
Demonstrates infrastructure state and provides endpoints for testing
"""

from flask import Flask, jsonify, request
import os
import subprocess
import json
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': 'State Locking Demo Application',
        'project': os.environ.get('PROJECT_NAME', 'unknown'),
        'environment': os.environ.get('ENVIRONMENT', 'unknown'),
        'timestamp': datetime.now().isoformat(),
        'endpoints': [
            '/health',
            '/info',
            '/simulate-drift',
            '/check-locks'
        ]
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/info')
def info():
    return jsonify({
        'hostname': os.uname().nodename,
        'system': os.uname().sysname,
        'release': os.uname().release,
        'project': os.environ.get('PROJECT_NAME', 'unknown'),
        'environment': os.environ.get('ENVIRONMENT', 'unknown'),
        'drift_simulation': os.environ.get('ENABLE_DRIFT_SIMULATION', 'false')
    })

@app.route('/simulate-drift', methods=['POST'])
def simulate_drift():
    if os.environ.get('ENABLE_DRIFT_SIMULATION', 'false').lower() != 'true':
        return jsonify({'error': 'Drift simulation not enabled'}), 403
    
    # Simulate infrastructure drift by modifying a file
    drift_file = '/tmp/infrastructure_drift.json'
    drift_data = {
        'timestamp': datetime.now().isoformat(),
        'type': 'simulated_drift',
        'description': 'Manual infrastructure modification for testing',
        'severity': request.json.get('severity', 3) if request.json else 3
    }
    
    with open(drift_file, 'w') as f:
        json.dump(drift_data, f, indent=2)
    
    return jsonify({
        'message': 'Drift simulation triggered',
        'data': drift_data
    })

@app.route('/check-locks')
def check_locks():
    # Simulate lock checking (in real scenario, this would query Cloudant)
    return jsonify({
        'locks': [
            {
                'id': 'terraform-state-bucket/infrastructure/terraform.tfstate',
                'holder': 'user@example.com',
                'created': '2024-09-14T10:30:00Z',
                'operation': 'apply'
            }
        ],
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)
EOF

# Install Python and Flask
apt-get install -y python3 python3-pip
pip3 install flask

# Create systemd service for demo app
cat > /etc/systemd/system/state-demo.service << EOF
[Unit]
Description=State Locking Demo Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/state-locking-demo
Environment=PROJECT_NAME=$PROJECT_NAME
Environment=ENVIRONMENT=$ENVIRONMENT
Environment=ENABLE_DRIFT_SIMULATION=$ENABLE_DRIFT_SIMULATION
ExecStart=/usr/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start state-demo
systemctl enable state-demo

# =============================================================================
# NGINX SETUP (reverse proxy)
# =============================================================================

echo "Setting up Nginx..."
apt-get install -y nginx

# Configure Nginx as reverse proxy
cat > /etc/nginx/sites-available/state-demo << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        proxy_pass http://127.0.0.1:8080/health;
        access_log off;
    }
}
EOF

# Enable site and restart Nginx
ln -sf /etc/nginx/sites-available/state-demo /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
systemctl enable nginx

# =============================================================================
# DRIFT SIMULATION SETUP
# =============================================================================

if [[ "$ENABLE_DRIFT_SIMULATION" == "true" ]]; then
    echo "Setting up drift simulation..."
    
    # Create drift simulation script
    cat > /opt/state-locking-demo/simulate_drift.sh << 'EOF'
#!/bin/bash
# Drift simulation script
# Modifies infrastructure to trigger drift detection

echo "Simulating infrastructure drift..."

# Create a file that represents infrastructure change
cat > /tmp/simulated_infrastructure_change.json << EOL
{
    "timestamp": "$(date -Iseconds)",
    "change_type": "security_group_rule_added",
    "description": "Manually added security group rule outside Terraform",
    "severity": 4,
    "resource_type": "security_group",
    "action": "add_rule",
    "details": {
        "port": 9090,
        "protocol": "tcp",
        "source": "0.0.0.0/0"
    }
}
EOL

echo "Drift simulation completed. Check /tmp/simulated_infrastructure_change.json"
EOF

    chmod +x /opt/state-locking-demo/simulate_drift.sh
    
    # Create cron job for periodic drift simulation (for testing)
    echo "0 */4 * * * ubuntu /opt/state-locking-demo/simulate_drift.sh" >> /etc/crontab
fi

# =============================================================================
# FIREWALL CONFIGURATION
# =============================================================================

echo "Configuring firewall..."
ufw --force enable
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 8080  # Demo application
ufw allow 9100  # Node Exporter

# =============================================================================
# CLEANUP AND FINALIZATION
# =============================================================================

echo "Cleaning up..."
apt-get autoremove -y
apt-get autoclean

# Set ownership
chown -R ubuntu:ubuntu /opt/state-locking-demo

# Create completion marker
touch /var/log/user-data-complete

echo "VSI initialization completed successfully!"
echo "Services running:"
echo "  - Demo application: http://localhost:8080"
echo "  - Nginx proxy: http://localhost:80"
echo "  - Node Exporter: http://localhost:9100"
echo "  - Docker: $(docker --version)"
echo "  - Terraform: $(terraform version --short)"

# Display final status
systemctl status state-demo --no-pager
systemctl status nginx --no-pager
systemctl status node_exporter --no-pager

echo "User data script execution completed at $(date)"
