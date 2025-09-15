#!/bin/bash
# =============================================================================
# WEB SERVER INITIALIZATION SCRIPT
# Topic 4.1: Defining and Managing IBM Cloud Resources
# =============================================================================
# 
# This script initializes web server instances with nginx and basic monitoring.
# It's called via user_data during instance provisioning.
# 
# Template variables:
# - server_index: Server instance number
# - environment: Deployment environment
# - tier: Infrastructure tier (web)
# =============================================================================

set -e  # Exit on any error

# =============================================================================
# LOGGING SETUP
# =============================================================================

# Create log file for deployment tracking
LOG_FILE="/var/log/terraform-lab-deployment.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "$(date): Starting web server initialization for server ${server_index}"
echo "Environment: ${environment}"
echo "Tier: ${tier}"

# =============================================================================
# SYSTEM UPDATES AND BASIC PACKAGES
# =============================================================================

echo "$(date): Updating system packages..."
apt-get update -y
apt-get upgrade -y

echo "$(date): Installing essential packages..."
apt-get install -y \
    curl \
    wget \
    unzip \
    htop \
    jq \
    net-tools \
    nginx \
    ufw \
    fail2ban \
    logrotate

# =============================================================================
# NGINX WEB SERVER CONFIGURATION
# =============================================================================

echo "$(date): Configuring nginx web server..."

# Create custom nginx configuration
cat > /etc/nginx/sites-available/terraform-lab << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    
    server_name _;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Main location
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Status endpoint
    location /status {
        access_log off;
        return 200 '{"status":"ok","server":"web-${server_index}","environment":"${environment}","timestamp":"'$(date -Iseconds)'"}';
        add_header Content-Type application/json;
    }
    
    # Nginx status (for monitoring)
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        allow 10.0.0.0/8;
        deny all;
    }
}
EOF

# Enable the site
ln -sf /etc/nginx/sites-available/terraform-lab /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
nginx -t

# =============================================================================
# CUSTOM WEB CONTENT
# =============================================================================

echo "$(date): Creating custom web content..."

# Create main index page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terraform Lab 4.1 - Web Server ${server_index}</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #1f4e79 0%, #4589ff 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            text-align: center;
            padding: 40px 0;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            margin-bottom: 30px;
        }
        .content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .card {
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        .status-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        .status-item {
            background: rgba(255, 255, 255, 0.2);
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }
        .status-ok { border-left: 4px solid #24a148; }
        .status-info { border-left: 4px solid #4589ff; }
        .footer {
            text-align: center;
            padding: 20px;
            background: rgba(0, 0, 0, 0.2);
            border-radius: 10px;
        }
        h1, h2, h3 { margin-top: 0; }
        .timestamp { font-family: monospace; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 IBM Cloud Terraform Lab 4.1</h1>
            <h2>Resource Provisioning & Management</h2>
            <h3>Web Server ${server_index} - ${environment} Environment</h3>
        </div>
        
        <div class="content">
            <div class="card">
                <h3>📊 Server Information</h3>
                <p><strong>Server:</strong> Web Server ${server_index}</p>
                <p><strong>Environment:</strong> ${environment}</p>
                <p><strong>Tier:</strong> ${tier}</p>
                <p><strong>Deployment Time:</strong> <span class="timestamp">$(date)</span></p>
                <p><strong>Instance Profile:</strong> bx2-2x8 (2 vCPU, 8 GB RAM)</p>
                <p><strong>Operating System:</strong> Ubuntu 20.04 LTS</p>
            </div>
            
            <div class="card">
                <h3>✅ Infrastructure Status</h3>
                <div class="status-grid">
                    <div class="status-item status-ok">
                        <strong>VPC</strong><br>Deployed
                    </div>
                    <div class="status-item status-ok">
                        <strong>Subnets</strong><br>Multi-Zone
                    </div>
                    <div class="status-item status-ok">
                        <strong>Security</strong><br>Configured
                    </div>
                    <div class="status-item status-ok">
                        <strong>Web Server</strong><br>Online
                    </div>
                    <div class="status-item status-info">
                        <strong>Load Balancer</strong><br>Active
                    </div>
                    <div class="status-item status-info">
                        <strong>Monitoring</strong><br>Enabled
                    </div>
                </div>
            </div>
            
            <div class="card">
                <h3>🔗 Quick Links</h3>
                <p><a href="/health" style="color: #4589ff;">Health Check</a></p>
                <p><a href="/status" style="color: #4589ff;">Server Status</a></p>
                <p><a href="/nginx_status" style="color: #4589ff;">Nginx Status</a></p>
            </div>
            
            <div class="card">
                <h3>🏗️ Architecture Overview</h3>
                <p>This web server is part of a 3-tier architecture:</p>
                <ul>
                    <li><strong>Web Tier:</strong> Load-balanced nginx servers (public)</li>
                    <li><strong>App Tier:</strong> Application servers (private)</li>
                    <li><strong>Data Tier:</strong> Database servers (private)</li>
                </ul>
                <p>Deployed using Infrastructure as Code with Terraform.</p>
            </div>
        </div>
        
        <div class="footer">
            <p>🎓 <strong>IBM Cloud Terraform Training Program</strong></p>
            <p>Topic 4.1: Defining and Managing IBM Cloud Resources</p>
            <p class="timestamp">Generated: $(date -Iseconds)</p>
        </div>
    </div>
</body>
</html>
EOF

# Create health check endpoint
cat > /var/www/html/health.json << 'EOF'
{
  "status": "healthy",
  "server": "web-${server_index}",
  "environment": "${environment}",
  "tier": "${tier}",
  "timestamp": "$(date -Iseconds)",
  "uptime": "$(uptime -p)",
  "load": "$(uptime | awk -F'load average:' '{print $2}')",
  "memory": "$(free -h | awk '/^Mem:/ {print $3 "/" $2}')",
  "disk": "$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
}
EOF

# =============================================================================
# FIREWALL CONFIGURATION
# =============================================================================

echo "$(date): Configuring firewall..."

# Configure UFW firewall
ufw --force enable
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (port 22)
ufw allow ssh

# Allow HTTP (port 80)
ufw allow http

# Allow HTTPS (port 443)
ufw allow https

# =============================================================================
# MONITORING AND LOGGING
# =============================================================================

echo "$(date): Setting up monitoring and logging..."

# Configure log rotation for application logs
cat > /etc/logrotate.d/terraform-lab << 'EOF'
/var/log/terraform-lab-deployment.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

# Create monitoring script
cat > /usr/local/bin/server-monitor.sh << 'EOF'
#!/bin/bash
# Simple monitoring script for web server

LOG_FILE="/var/log/server-monitor.log"

# Function to log with timestamp
log_message() {
    echo "$(date -Iseconds): $1" >> $LOG_FILE
}

# Check nginx status
if systemctl is-active --quiet nginx; then
    log_message "nginx: running"
else
    log_message "nginx: stopped - attempting restart"
    systemctl restart nginx
fi

# Check disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    log_message "WARNING: Disk usage is ${DISK_USAGE}%"
fi

# Check memory usage
MEMORY_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ $MEMORY_USAGE -gt 80 ]; then
    log_message "WARNING: Memory usage is ${MEMORY_USAGE}%"
fi

log_message "Health check completed - disk: ${DISK_USAGE}%, memory: ${MEMORY_USAGE}%"
EOF

chmod +x /usr/local/bin/server-monitor.sh

# Add monitoring to crontab
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/server-monitor.sh") | crontab -

# =============================================================================
# SERVICE STARTUP
# =============================================================================

echo "$(date): Starting services..."

# Enable and start nginx
systemctl enable nginx
systemctl start nginx

# Enable and start fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# =============================================================================
# COMPLETION
# =============================================================================

echo "$(date): Web server ${server_index} initialization completed successfully"
echo "$(date): Server is ready to serve traffic"
echo "$(date): Health check available at: http://$(hostname -I | awk '{print $1}')/health"

# Create completion marker
touch /var/log/terraform-lab-init-complete

# Final status check
systemctl status nginx --no-pager
systemctl status fail2ban --no-pager

echo "$(date): Web server ${server_index} deployment summary:"
echo "  - Nginx web server: running"
echo "  - Firewall: configured and active"
echo "  - Monitoring: enabled"
echo "  - Health checks: available"
echo "  - Security: fail2ban active"
echo "  - Environment: ${environment}"
echo "  - Tier: ${tier}"
