#!/bin/bash
# =============================================================================
# DATABASE SERVER INITIALIZATION SCRIPT
# Topic 4.1: Defining and Managing IBM Cloud Resources
# =============================================================================

set -e

LOG_FILE="/var/log/terraform-lab-deployment.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "$(date): Starting database server initialization for server ${server_index}"

# System updates
apt-get update -y
apt-get upgrade -y

# Install PostgreSQL
apt-get install -y postgresql postgresql-contrib

# Start PostgreSQL
systemctl enable postgresql
systemctl start postgresql

# Configure PostgreSQL
sudo -u postgres psql << 'EOF'
CREATE DATABASE terraform_lab;
CREATE USER lab_user WITH PASSWORD 'lab_password_2024';
GRANT ALL PRIVILEGES ON DATABASE terraform_lab TO lab_user;

-- Create sample tables
\c terraform_lab;

CREATE TABLE server_status (
    id SERIAL PRIMARY KEY,
    server_name VARCHAR(50),
    environment VARCHAR(20),
    tier VARCHAR(20),
    status VARCHAR(20),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE application_metrics (
    id SERIAL PRIMARY KEY,
    metric_name VARCHAR(100),
    metric_value DECIMAL(10,2),
    server_name VARCHAR(50),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO server_status (server_name, environment, tier, status) VALUES
('db-${server_index}', '${environment}', '${tier}', 'running');

INSERT INTO application_metrics (metric_name, metric_value, server_name) VALUES
('cpu_usage', 15.5, 'db-${server_index}'),
('memory_usage', 45.2, 'db-${server_index}'),
('disk_usage', 25.8, 'db-${server_index}');

\q
EOF

# Configure PostgreSQL for network access
echo "host all all 10.240.0.0/16 md5" >> /etc/postgresql/*/main/pg_hba.conf
echo "listen_addresses = '*'" >> /etc/postgresql/*/main/postgresql.conf

# Configure firewall
ufw --force enable
ufw allow 5432
ufw allow ssh

# Restart PostgreSQL
systemctl restart postgresql

# Create health check script
cat > /usr/local/bin/db-health-check.sh << 'EOF'
#!/bin/bash
# Database health check script

DB_STATUS=$(sudo -u postgres psql -c "SELECT 1;" 2>/dev/null | grep -c "1 row" || echo "0")

if [ "$DB_STATUS" = "1" ]; then
    echo '{"status":"healthy","database":"postgresql","server":"db-${server_index}","timestamp":"'$(date -Iseconds)'"}'
else
    echo '{"status":"unhealthy","database":"postgresql","server":"db-${server_index}","timestamp":"'$(date -Iseconds)'"}'
fi
EOF

chmod +x /usr/local/bin/db-health-check.sh

echo "$(date): Database server ${server_index} initialization completed"
touch /var/log/terraform-lab-init-complete
