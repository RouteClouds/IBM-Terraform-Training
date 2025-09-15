#!/bin/bash
# =============================================================================
# APPLICATION SERVER SETUP SCRIPT
# Resource Dependencies and Attributes Lab - Topic 4.3
# =============================================================================

set -e

# Variables from Terraform template
DATABASE_ENDPOINT="${database_endpoint}"
REDIS_ENDPOINT="${redis_endpoint}"
MONITORING_ENABLED="${monitoring_enabled}"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/app-server-setup.log
}

log "Starting application server setup..."

# Update system packages
log "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install required packages
log "Installing required packages..."
apt-get install -y \
    nodejs \
    npm \
    postgresql-client \
    redis-tools \
    curl \
    wget \
    unzip \
    jq \
    htop \
    net-tools \
    python3 \
    python3-pip

# Install Node.js application dependencies
log "Installing Node.js application..."
mkdir -p /opt/app
cd /opt/app

# Create package.json
cat > package.json << 'EOF'
{
  "name": "dependency-lab-app",
  "version": "1.0.0",
  "description": "Application server for dependency lab",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.8.0",
    "redis": "^4.5.1",
    "cors": "^2.8.5",
    "helmet": "^6.0.1",
    "morgan": "^1.10.0",
    "dotenv": "^16.0.3"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
EOF

# Install npm packages
log "Installing npm packages..."
npm install

# Create application server
log "Creating application server..."
cat > server.js << 'EOF'
const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8081;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Database connection (PostgreSQL)
let pgPool = null;
if (process.env.DATABASE_URL) {
    pgPool = new Pool({
        connectionString: process.env.DATABASE_URL,
        ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
    });
    
    pgPool.on('connect', () => {
        console.log('Connected to PostgreSQL database');
    });
    
    pgPool.on('error', (err) => {
        console.error('PostgreSQL connection error:', err);
    });
}

// Redis connection
let redisClient = null;
if (process.env.REDIS_URL) {
    redisClient = redis.createClient({
        url: process.env.REDIS_URL
    });
    
    redisClient.on('connect', () => {
        console.log('Connected to Redis cache');
    });
    
    redisClient.on('error', (err) => {
        console.error('Redis connection error:', err);
    });
    
    redisClient.connect().catch(console.error);
}

// Health check endpoint
app.get('/api/health', async (req, res) => {
    const health = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        hostname: require('os').hostname(),
        uptime: process.uptime(),
        dependencies: {
            database: 'unknown',
            cache: 'unknown'
        }
    };
    
    // Check database connection
    if (pgPool) {
        try {
            await pgPool.query('SELECT 1');
            health.dependencies.database = 'connected';
        } catch (err) {
            health.dependencies.database = 'error';
            health.status = 'degraded';
        }
    }
    
    // Check Redis connection
    if (redisClient && redisClient.isReady) {
        try {
            await redisClient.ping();
            health.dependencies.cache = 'connected';
        } catch (err) {
            health.dependencies.cache = 'error';
            health.status = 'degraded';
        }
    }
    
    res.json(health);
});

// Dependency information endpoint
app.get('/api/dependencies', (req, res) => {
    res.json({
        dependencies: {
            explicit: [
                'PostgreSQL database must be available before app server starts',
                'Redis cache must be available before app server starts',
                'VPC and subnets must exist before database services'
            ],
            implicit: [
                'App server depends on VPC through subnet reference',
                'App server depends on security groups through network interface',
                'Load balancer pool members depend on app server IP addresses'
            ],
            data_sources: [
                'Ubuntu image discovered dynamically',
                'Instance profiles discovered dynamically',
                'SSH keys discovered dynamically',
                'Resource group discovered by name'
            ],
            attributes_used: [
                'Database connection strings from ibm_database resource',
                'Instance IP addresses for load balancer configuration',
                'VPC ID for security group and subnet creation',
                'Subnet IDs for instance placement'
            ]
        },
        configuration: {
            database_configured: !!process.env.DATABASE_URL,
            cache_configured: !!process.env.REDIS_URL,
            monitoring_enabled: process.env.MONITORING_ENABLED === 'true'
        }
    });
});

// Sample API endpoints
app.get('/api/status', (req, res) => {
    res.json({
        service: 'application-server',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        timestamp: new Date().toISOString()
    });
});

// Database test endpoint
app.get('/api/db-test', async (req, res) => {
    if (!pgPool) {
        return res.status(503).json({ error: 'Database not configured' });
    }
    
    try {
        const result = await pgPool.query('SELECT NOW() as current_time, version() as version');
        res.json({
            status: 'success',
            data: result.rows[0]
        });
    } catch (err) {
        res.status(500).json({
            status: 'error',
            message: err.message
        });
    }
});

// Cache test endpoint
app.get('/api/cache-test', async (req, res) => {
    if (!redisClient || !redisClient.isReady) {
        return res.status(503).json({ error: 'Cache not configured' });
    }
    
    try {
        const testKey = 'test:' + Date.now();
        const testValue = 'Hello from Redis!';
        
        await redisClient.set(testKey, testValue, { EX: 60 });
        const retrievedValue = await redisClient.get(testKey);
        
        res.json({
            status: 'success',
            test_key: testKey,
            stored_value: testValue,
            retrieved_value: retrievedValue,
            match: testValue === retrievedValue
        });
    } catch (err) {
        res.status(500).json({
            status: 'error',
            message: err.message
        });
    }
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        status: 'error',
        message: 'Internal server error'
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        status: 'error',
        message: 'Endpoint not found'
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Application server listening on port ${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/api/health`);
    console.log(`Dependencies: http://localhost:${PORT}/api/dependencies`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
    console.log('Received SIGTERM, shutting down gracefully');
    
    if (pgPool) {
        await pgPool.end();
    }
    
    if (redisClient) {
        await redisClient.quit();
    }
    
    process.exit(0);
});
EOF

# Create environment configuration
log "Creating environment configuration..."
cat > .env << EOF
NODE_ENV=production
PORT=8081
DATABASE_URL=${DATABASE_ENDPOINT}
REDIS_URL=${REDIS_ENDPOINT}
MONITORING_ENABLED=${MONITORING_ENABLED}
EOF

# Create systemd service
log "Creating systemd service..."
cat > /etc/systemd/system/app-server.service << 'EOF'
[Unit]
Description=Dependency Lab Application Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/app
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
EnvironmentFile=/opt/app/.env

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=app-server

[Install]
WantedBy=multi-user.target
EOF

# Install monitoring agent if enabled
if [ "$MONITORING_ENABLED" = "true" ]; then
    log "Installing monitoring agent..."
    mkdir -p /opt/monitoring
    cat > /opt/monitoring/agent.conf << 'EOF'
# Monitoring agent configuration
service_name: app-server
metrics_enabled: true
log_collection: true
custom_metrics:
  - name: database_connections
    type: gauge
  - name: cache_hits
    type: counter
  - name: api_requests
    type: counter
EOF
    log "Monitoring agent configured"
fi

# Create startup script
log "Creating startup script..."
cat > /opt/app-startup.sh << 'EOF'
#!/bin/bash
# Application server startup script

echo "Starting application server..."

# Check database connectivity
if [ ! -z "$DATABASE_ENDPOINT" ]; then
    echo "Testing database connectivity..."
    # Extract host and port from connection string
    DB_HOST=$(echo "$DATABASE_ENDPOINT" | sed -n 's/.*@\([^:]*\):.*/\1/p')
    DB_PORT=$(echo "$DATABASE_ENDPOINT" | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
    
    if [ ! -z "$DB_HOST" ] && [ ! -z "$DB_PORT" ]; then
        if nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; then
            echo "✓ Database $DB_HOST:$DB_PORT is reachable"
        else
            echo "✗ Database $DB_HOST:$DB_PORT is not reachable"
        fi
    fi
fi

# Check Redis connectivity
if [ ! -z "$REDIS_ENDPOINT" ]; then
    echo "Testing Redis connectivity..."
    # Extract host and port from connection string
    REDIS_HOST=$(echo "$REDIS_ENDPOINT" | sed -n 's/.*@\([^:]*\):.*/\1/p')
    REDIS_PORT=$(echo "$REDIS_ENDPOINT" | sed -n 's/.*:\([0-9]*\)/\1/p')
    
    if [ ! -z "$REDIS_HOST" ] && [ ! -z "$REDIS_PORT" ]; then
        if nc -z "$REDIS_HOST" "$REDIS_PORT" 2>/dev/null; then
            echo "✓ Redis $REDIS_HOST:$REDIS_PORT is reachable"
        else
            echo "✗ Redis $REDIS_HOST:$REDIS_PORT is not reachable"
        fi
    fi
fi

# Start the application service
systemctl enable app-server
systemctl start app-server

echo "Application server startup complete"
EOF

chmod +x /opt/app-startup.sh

# Create health check script
cat > /opt/app-health-check.sh << 'EOF'
#!/bin/bash
# Health check script for application server

# Check if service is running
if ! systemctl is-active --quiet app-server; then
    echo "UNHEALTHY: app-server service not running"
    exit 1
fi

# Check if port is listening
if ! nc -z localhost 8081 2>/dev/null; then
    echo "UNHEALTHY: app-server not listening on port 8081"
    exit 1
fi

# Check health endpoint
if ! curl -f http://localhost:8081/api/health > /dev/null 2>&1; then
    echo "UNHEALTHY: health endpoint not responding"
    exit 1
fi

echo "HEALTHY: All checks passed"
exit 0
EOF

chmod +x /opt/app-health-check.sh

# Set up log rotation
log "Configuring log rotation..."
cat > /etc/logrotate.d/app-server << 'EOF'
/var/log/app-server-setup.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

# Start the application
log "Starting application server..."
systemctl daemon-reload
/opt/app-startup.sh

# Wait for service to start
sleep 5

# Final status check
log "Performing final status check..."
systemctl status app-server --no-pager
/opt/app-health-check.sh

log "Application server setup completed successfully!"

# Display summary
cat << 'EOF'

=============================================================================
APPLICATION SERVER SETUP COMPLETE
=============================================================================

Services Started:
- app-server (Node.js application on port 8081)

API Endpoints:
- Health: http://localhost:8081/api/health
- Status: http://localhost:8081/api/status
- Dependencies: http://localhost:8081/api/dependencies
- DB Test: http://localhost:8081/api/db-test
- Cache Test: http://localhost:8081/api/cache-test

Configuration Files:
- Application: /opt/app/server.js
- Environment: /opt/app/.env
- Service: /etc/systemd/system/app-server.service
- Startup script: /opt/app-startup.sh
- Health check: /opt/app-health-check.sh

Logs:
- Setup log: /var/log/app-server-setup.log
- Service logs: journalctl -u app-server

Dependencies Demonstrated:
- Explicit: Database and Redis must be available before app starts
- Implicit: VPC → Subnet → Instance → Application
- Attributes: Database connection strings from Terraform resources

=============================================================================
EOF
