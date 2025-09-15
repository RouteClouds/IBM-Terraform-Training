#!/bin/bash
# =============================================================================
# APPLICATION SERVER INITIALIZATION SCRIPT
# Topic 4.1: Defining and Managing IBM Cloud Resources
# =============================================================================

set -e

LOG_FILE="/var/log/terraform-lab-deployment.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "$(date): Starting application server initialization for server ${server_index}"

# System updates
apt-get update -y
apt-get upgrade -y

# Install Node.js and application dependencies
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs build-essential

# Create application directory
mkdir -p /opt/terraform-lab-app
cd /opt/terraform-lab-app

# Create Node.js application
cat > app.js << 'EOF'
const express = require('express');
const os = require('os');
const app = express();
const port = 8080;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    server: 'app-${server_index}',
    environment: '${environment}',
    tier: '${tier}',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    hostname: os.hostname(),
    platform: os.platform(),
    arch: os.arch()
  });
});

// Main API endpoint
app.get('/api/info', (req, res) => {
  res.json({
    message: 'Terraform Lab 4.1 Application Server',
    server: 'app-${server_index}',
    environment: '${environment}',
    tier: '${tier}',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    features: [
      'Multi-tier architecture',
      'Load balancing',
      'Auto-scaling ready',
      'Monitoring enabled'
    ]
  });
});

// Database connection test endpoint
app.get('/api/db-test', (req, res) => {
  res.json({
    database: 'connection-test',
    status: 'simulated',
    server: 'app-${server_index}',
    timestamp: new Date().toISOString()
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App Server ${server_index} listening on port ${port}`);
});
EOF

# Create package.json
cat > package.json << 'EOF'
{
  "name": "terraform-lab-app",
  "version": "1.0.0",
  "description": "Terraform Lab 4.1 Application Server",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# Install dependencies
npm install

# Create systemd service
cat > /etc/systemd/system/terraform-lab-app.service << 'EOF'
[Unit]
Description=Terraform Lab Application Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/terraform-lab-app
ExecStart=/usr/bin/node app.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Configure firewall
ufw --force enable
ufw allow 8080
ufw allow ssh

# Start services
systemctl daemon-reload
systemctl enable terraform-lab-app
systemctl start terraform-lab-app

echo "$(date): Application server ${server_index} initialization completed"
touch /var/log/terraform-lab-init-complete
