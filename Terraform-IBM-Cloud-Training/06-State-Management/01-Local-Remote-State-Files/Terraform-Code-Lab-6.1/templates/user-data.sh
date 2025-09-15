#!/bin/bash
# =============================================================================
# USER DATA SCRIPT FOR STATE MANAGEMENT DEMONSTRATION
# Subtopic 6.1: Local and Remote State Files
# =============================================================================

# Set up logging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting user data script execution at $(date)"
echo "Project: ${project_name}"
echo "Environment: ${environment}"

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
    git \
    jq \
    htop \
    tree \
    vim \
    nano \
    net-tools \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# =============================================================================
# TERRAFORM INSTALLATION
# =============================================================================

echo "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update -y
apt-get install -y terraform

# Verify Terraform installation
terraform version

# =============================================================================
# IBM CLOUD CLI INSTALLATION
# =============================================================================

echo "Installing IBM Cloud CLI..."
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Verify IBM Cloud CLI installation
ibmcloud version

# =============================================================================
# DOCKER INSTALLATION (OPTIONAL)
# =============================================================================

echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# =============================================================================
# DEVELOPMENT ENVIRONMENT SETUP
# =============================================================================

echo "Setting up development environment..."

# Create project directory structure
mkdir -p /home/ubuntu/terraform-labs
mkdir -p /home/ubuntu/terraform-labs/state-management
mkdir -p /home/ubuntu/terraform-labs/state-management/local-state
mkdir -p /home/ubuntu/terraform-labs/state-management/remote-state
mkdir -p /home/ubuntu/terraform-labs/state-management/backups
mkdir -p /home/ubuntu/terraform-labs/state-management/scripts

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/terraform-labs

# =============================================================================
# STATE MANAGEMENT UTILITIES
# =============================================================================

echo "Creating state management utilities..."

# Create state backup script
cat > /home/ubuntu/terraform-labs/scripts/backup-state.sh << 'EOF'
#!/bin/bash
# Terraform state backup utility

BACKUP_DIR="/home/ubuntu/terraform-labs/state-management/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating state backup in: $BACKUP_DIR"

# Backup state files
if [ -f terraform.tfstate ]; then
    cp terraform.tfstate "$BACKUP_DIR/"
    echo "Local state backed up"
fi

if [ -f terraform.tfstate.backup ]; then
    cp terraform.tfstate.backup "$BACKUP_DIR/"
    echo "State backup file copied"
fi

# Backup configuration
cp *.tf "$BACKUP_DIR/" 2>/dev/null || true
cp terraform.tfvars "$BACKUP_DIR/" 2>/dev/null || true

# Create backup manifest
cat > "$BACKUP_DIR/backup_manifest.json" << EOL
{
  "backup_timestamp": "$(date -Iseconds)",
  "terraform_version": "$(terraform version -json | jq -r '.terraform_version')",
  "working_directory": "$(pwd)",
  "backup_type": "manual"
}
EOL

echo "Backup completed: $BACKUP_DIR"
ls -la "$BACKUP_DIR"
EOF

# Create state validation script
cat > /home/ubuntu/terraform-labs/scripts/validate-state.sh << 'EOF'
#!/bin/bash
# Terraform state validation utility

echo "=== Terraform State Validation ==="
echo "Timestamp: $(date)"

# Check Terraform installation
echo "Terraform version:"
terraform version

# Validate configuration
echo "Validating Terraform configuration..."
terraform validate

# Check state file
if [ -f terraform.tfstate ]; then
    echo "Local state file found"
    echo "State file size: $(du -h terraform.tfstate | cut -f1)"
    echo "Resource count: $(terraform state list | wc -l)"
else
    echo "No local state file found"
fi

# Check for drift
echo "Checking for configuration drift..."
terraform plan -detailed-exitcode
PLAN_EXIT=$?

case $PLAN_EXIT in
    0)
        echo "✅ No changes detected - infrastructure matches configuration"
        ;;
    1)
        echo "❌ Error occurred during planning"
        ;;
    2)
        echo "⚠️  Changes detected - infrastructure drift identified"
        ;;
esac

echo "Validation completed"
EOF

# Create state migration helper
cat > /home/ubuntu/terraform-labs/scripts/migrate-to-remote.sh << 'EOF'
#!/bin/bash
# State migration helper script

echo "=== Terraform State Migration Helper ==="

# Check prerequisites
if [ ! -f terraform.tfstate ]; then
    echo "❌ No local state file found. Run 'terraform apply' first."
    exit 1
fi

if [ ! -f backend.tf ]; then
    echo "❌ No backend.tf file found. Configure remote backend first."
    exit 1
fi

# Create backup
echo "Creating pre-migration backup..."
./backup-state.sh

# Initialize with migration
echo "Initializing remote backend..."
terraform init -migrate-state

echo "Migration completed. Validating..."
terraform plan

echo "✅ State migration helper completed"
EOF

# Make scripts executable
chmod +x /home/ubuntu/terraform-labs/scripts/*.sh

# =============================================================================
# MONITORING AND LOGGING SETUP
# =============================================================================

echo "Setting up monitoring and logging..."

# Install monitoring tools
apt-get install -y htop iotop nethogs

# Create log rotation for user data
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

# =============================================================================
# WELCOME MESSAGE AND DOCUMENTATION
# =============================================================================

echo "Creating welcome documentation..."

cat > /home/ubuntu/README.md << 'EOF'
# Terraform State Management Lab Environment

Welcome to the Terraform State Management lab environment!

## Environment Information
- **Project**: ${project_name}
- **Environment**: ${environment}
- **Setup Date**: $(date)

## Installed Tools
- Terraform (latest)
- IBM Cloud CLI
- Docker
- Git, jq, and development utilities

## Lab Directory Structure
```
/home/ubuntu/terraform-labs/
├── state-management/
│   ├── local-state/     # Local state exercises
│   ├── remote-state/    # Remote state exercises
│   ├── backups/         # State backups
│   └── scripts/         # Utility scripts
└── scripts/             # Global utility scripts
```

## Utility Scripts
- `backup-state.sh`: Create state backups
- `validate-state.sh`: Validate state and check for drift
- `migrate-to-remote.sh`: Helper for state migration

## Getting Started
1. Navigate to the lab directory: `cd terraform-labs/state-management`
2. Follow the lab exercises in order
3. Use utility scripts for state management tasks

## Useful Commands
```bash
# Check Terraform version
terraform version

# Validate configuration
terraform validate

# Check state
terraform state list

# Create backup
./scripts/backup-state.sh

# Validate state
./scripts/validate-state.sh
```

## Support
- Lab documentation: Follow the provided lab guide
- Terraform documentation: https://terraform.io/docs
- IBM Cloud documentation: https://cloud.ibm.com/docs
EOF

# Set ownership for all created files
chown -R ubuntu:ubuntu /home/ubuntu/terraform-labs
chown ubuntu:ubuntu /home/ubuntu/README.md

# =============================================================================
# COMPLETION
# =============================================================================

echo "User data script completed successfully at $(date)"
echo "Environment ready for Terraform state management exercises"

# Create completion marker
touch /var/log/user-data-complete
echo "$(date): User data script completed" >> /var/log/user-data-complete
