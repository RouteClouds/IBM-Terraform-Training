#!/bin/bash
# =============================================================================
# WEB SERVER SETUP SCRIPT
# Resource Dependencies and Attributes Lab - Topic 4.3
# =============================================================================

set -e

# Variables from Terraform template
APP_SERVER_IPS="${app_server_ips}"
MONITORING_ENABLED="${monitoring_enabled}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/web-server-setup.log
}

log "Starting web server setup..."

# Update system packages
log "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install required packages
log "Installing required packages..."
apt-get install -y \
    nginx \
    nodejs \
    npm \
    curl \
    wget \
    unzip \
    jq \
    htop \
    net-tools

# Configure nginx
log "Configuring nginx..."
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;
    
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    
    server_name _;
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Main application proxy
    location / {
        proxy_pass http://app_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Connection settings
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
    }
    
    # Static assets
    location /static/ {
        alias /var/www/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /var/www/html;
    }
}
EOF

# Configure upstream servers based on app server IPs
log "Configuring upstream servers..."
if [ ! -z "$APP_SERVER_IPS" ]; then
    cat > /etc/nginx/conf.d/upstream.conf << EOF
upstream app_backend {
    least_conn;
    
EOF
    
    # Add each app server IP to upstream
    IFS=',' read -ra ADDR <<< "$APP_SERVER_IPS"
    for ip in "${ADDR[@]}"; do
        echo "    server $ip:8081 max_fails=3 fail_timeout=30s;" >> /etc/nginx/conf.d/upstream.conf
        log "Added app server: $ip:8081"
    done
    
    echo "}" >> /etc/nginx/conf.d/upstream.conf
else
    log "Warning: No app server IPs provided, using localhost"
    cat > /etc/nginx/conf.d/upstream.conf << 'EOF'
upstream app_backend {
    server 127.0.0.1:3000;
}
EOF
fi

# Create web content
log "Creating web content..."
mkdir -p /var/www/html
mkdir -p /var/www/static

cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dependency Lab - Web Tier</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #0f62fe; border-bottom: 2px solid #0f62fe; padding-bottom: 10px; margin-bottom: 20px; }
        .status { padding: 10px; border-radius: 4px; margin: 10px 0; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        .dependency { background: #fff3cd; color: #856404; border: 1px solid #ffeaa7; padding: 15px; margin: 10px 0; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">Resource Dependencies Lab - Web Tier</h1>
        
        <div class="status success">
            <strong>✓ Web Server Status:</strong> Running and healthy
        </div>
        
        <div class="status info">
            <strong>Server Information:</strong><br>
            Hostname: <span id="hostname">Loading...</span><br>
            IP Address: <span id="ip">Loading...</span><br>
            Timestamp: <span id="timestamp">Loading...</span>
        </div>
        
        <div class="dependency">
            <h3>Dependency Relationships Demonstrated:</h3>
            <ul>
                <li><strong>Implicit Dependencies:</strong> Web server depends on VPC, subnets, and security groups through resource attribute references</li>
                <li><strong>Explicit Dependencies:</strong> Web server explicitly depends on application servers for configuration</li>
                <li><strong>Cross-References:</strong> Security group rules reference other security groups</li>
                <li><strong>Resource Attributes:</strong> Load balancer pool members use instance IP addresses</li>
                <li><strong>Data Sources:</strong> Configuration uses dynamically discovered images and profiles</li>
            </ul>
        </div>
        
        <div class="status info">
            <strong>Application Server Connections:</strong>
            <div id="app-servers">Loading...</div>
        </div>
    </div>
    
    <script>
        // Update dynamic content
        document.getElementById('hostname').textContent = window.location.hostname;
        document.getElementById('ip').textContent = window.location.host;
        document.getElementById('timestamp').textContent = new Date().toISOString();
        
        // Show app server connections
        const appServers = '$APP_SERVER_IPS'.split(',').filter(ip => ip.trim());
        const appServerDiv = document.getElementById('app-servers');
        if (appServers.length > 0) {
            appServerDiv.innerHTML = appServers.map(ip => 
                `<div style="margin: 5px 0;">→ App Server: ${ip.trim()}:8081</div>`
            ).join('');
        } else {
            appServerDiv.innerHTML = '<div>No app servers configured</div>';
        }
    </script>
</body>
</html>
EOF

# Create 404 page
cat > /var/www/html/404.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>404 Not Found</title></head>
<body>
<h1>404 Not Found</h1>
<p>The requested resource was not found on this server.</p>
<p><a href="/">Return to home page</a></p>
</body>
</html>
EOF

# Test nginx configuration
log "Testing nginx configuration..."
nginx -t

# Enable and start nginx
log "Starting nginx service..."
systemctl enable nginx
systemctl restart nginx

# Install monitoring agent if enabled
if [ "$MONITORING_ENABLED" = "true" ]; then
    log "Installing monitoring agent..."
    # Note: In a real environment, you would install the actual monitoring agent
    # For this lab, we'll just create a placeholder
    mkdir -p /opt/monitoring
    cat > /opt/monitoring/agent.conf << 'EOF'
# Monitoring agent configuration
service_name: web-server
metrics_enabled: true
log_collection: true
EOF
    log "Monitoring agent configured"
fi

# Create startup script
log "Creating startup script..."
cat > /opt/web-startup.sh << 'EOF'
#!/bin/bash
# Web server startup script

# Check nginx status
if ! systemctl is-active --quiet nginx; then
    echo "Starting nginx..."
    systemctl start nginx
fi

# Check app server connectivity
echo "Checking app server connectivity..."
APP_IPS="$APP_SERVER_IPS"
if [ ! -z "$APP_IPS" ]; then
    IFS=',' read -ra ADDR <<< "$APP_IPS"
    for ip in "${ADDR[@]}"; do
        if nc -z "$ip" 8081 2>/dev/null; then
            echo "✓ App server $ip:8081 is reachable"
        else
            echo "✗ App server $ip:8081 is not reachable"
        fi
    done
fi

echo "Web server startup complete"
EOF

chmod +x /opt/web-startup.sh

# Run startup script
log "Running startup script..."
/opt/web-startup.sh

# Create health check script
cat > /opt/health-check.sh << 'EOF'
#!/bin/bash
# Health check script for load balancer

# Check nginx process
if ! pgrep nginx > /dev/null; then
    echo "UNHEALTHY: nginx not running"
    exit 1
fi

# Check nginx response
if ! curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "UNHEALTHY: nginx not responding"
    exit 1
fi

echo "HEALTHY: All checks passed"
exit 0
EOF

chmod +x /opt/health-check.sh

# Set up log rotation
log "Configuring log rotation..."
cat > /etc/logrotate.d/web-server << 'EOF'
/var/log/web-server-setup.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

# Final status check
log "Performing final status check..."
systemctl status nginx --no-pager
/opt/health-check.sh

log "Web server setup completed successfully!"

# Display summary
cat << 'EOF'

=============================================================================
WEB SERVER SETUP COMPLETE
=============================================================================

Services Started:
- nginx (listening on port 8080)

Health Check:
- Available at: http://localhost:8080/health

Configuration Files:
- nginx config: /etc/nginx/sites-available/default
- upstream config: /etc/nginx/conf.d/upstream.conf
- startup script: /opt/web-startup.sh
- health check: /opt/health-check.sh

Logs:
- Setup log: /var/log/web-server-setup.log
- nginx logs: /var/log/nginx/

Dependencies Demonstrated:
- Implicit: VPC → Subnet → Instance
- Explicit: App Servers → Web Server configuration
- Attributes: Instance IPs used in upstream configuration

=============================================================================
EOF
