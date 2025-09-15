#!/bin/bash
# =============================================================================
# ENVIRONMENT SETUP SCRIPT
# Subtopic 6.1: Local and Remote State Files
# Automated environment setup for state management lab
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# =============================================================================
# CONFIGURATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LAB_NAME="state-management-lab"

# =============================================================================
# SETUP FUNCTIONS
# =============================================================================

check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check for required commands
    local required_commands=("terraform" "jq" "curl")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error "Required command not found: $cmd"
            exit 1
        fi
        success "Found required command: $cmd"
    done
    
    # Check Terraform version
    local tf_version=$(terraform version -json | jq -r '.terraform_version')
    success "Terraform version: $tf_version"
    
    # Check for IBM Cloud CLI (optional)
    if command -v ibmcloud &> /dev/null; then
        success "IBM Cloud CLI found"
    else
        warning "IBM Cloud CLI not found (optional for this lab)"
    fi
}

setup_directory_structure() {
    log "Setting up directory structure..."
    
    # Create lab directories
    local directories=(
        "exercises"
        "exercises/01-local-state"
        "exercises/02-remote-backend"
        "exercises/03-state-migration"
        "exercises/04-team-collaboration"
        "exercises/05-monitoring"
        "backups"
        "logs"
        "generated"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$PROJECT_DIR/$dir"
        success "Created directory: $dir"
    done
    
    # Set permissions
    chmod 755 "$PROJECT_DIR"/exercises/*
    chmod 755 "$PROJECT_DIR"/scripts/*
}

create_configuration_files() {
    log "Creating configuration files..."
    
    # Copy terraform.tfvars.example if terraform.tfvars doesn't exist
    if [[ ! -f "$PROJECT_DIR/terraform.tfvars" ]]; then
        if [[ -f "$PROJECT_DIR/terraform.tfvars.example" ]]; then
            cp "$PROJECT_DIR/terraform.tfvars.example" "$PROJECT_DIR/terraform.tfvars"
            success "Created terraform.tfvars from example"
            warning "Please edit terraform.tfvars with your IBM Cloud API key"
        else
            error "terraform.tfvars.example not found"
        fi
    else
        success "terraform.tfvars already exists"
    fi
    
    # Create .gitignore if it doesn't exist
    if [[ ! -f "$PROJECT_DIR/.gitignore" ]]; then
        cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# Terraform files
*.tfstate
*.tfstate.*
*.tfplan
*.tfplan.*
.terraform/
.terraform.lock.hcl

# Sensitive files
terraform.tfvars
*.pem
*.key

# Generated files
generated_backend.tf
team_access_guide.md

# Logs
*.log
logs/

# Backups
backups/

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db
EOF
        success "Created .gitignore file"
    else
        success ".gitignore already exists"
    fi
}

setup_exercise_templates() {
    log "Setting up exercise templates..."
    
    # Exercise 1: Local State Analysis
    cat > "$PROJECT_DIR/exercises/01-local-state/README.md" << 'EOF'
# Exercise 1: Local State Analysis

## Objective
Understand local state file structure and limitations.

## Steps
1. Initialize Terraform with local backend
2. Deploy basic infrastructure
3. Analyze state file structure
4. Identify local state limitations

## Commands
```bash
terraform init
terraform plan
terraform apply
terraform state list
terraform state show <resource>
```

## Expected Outcomes
- Local state file created
- Infrastructure deployed
- State structure understood
- Limitations identified
EOF

    # Exercise 2: Remote Backend Setup
    cat > "$PROJECT_DIR/exercises/02-remote-backend/README.md" << 'EOF'
# Exercise 2: Remote Backend Setup

## Objective
Configure IBM Cloud Object Storage as Terraform backend.

## Steps
1. Enable remote state in configuration
2. Create COS instance and bucket
3. Configure backend credentials
4. Test backend connectivity

## Commands
```bash
# Update terraform.tfvars
enable_remote_state = true

terraform apply
terraform output state_backend_info
```

## Expected Outcomes
- COS instance created
- State bucket configured
- Backend credentials generated
- Remote backend ready
EOF

    # Exercise 3: State Migration
    cat > "$PROJECT_DIR/exercises/03-state-migration/README.md" << 'EOF'
# Exercise 3: State Migration

## Objective
Migrate from local to remote state backend.

## Steps
1. Backup existing local state
2. Configure remote backend
3. Migrate state to remote backend
4. Validate migration success

## Commands
```bash
./scripts/backup-state.sh
# Uncomment backend configuration in providers.tf
terraform init -migrate-state
terraform plan
```

## Expected Outcomes
- Local state backed up
- State migrated to remote backend
- No infrastructure changes
- Remote state operational
EOF

    # Exercise 4: Team Collaboration
    cat > "$PROJECT_DIR/exercises/04-team-collaboration/README.md" << 'EOF'
# Exercise 4: Team Collaboration

## Objective
Configure team access and collaboration workflows.

## Steps
1. Enable team access features
2. Configure role-based permissions
3. Test team member access
4. Implement workflow procedures

## Commands
```bash
# Update terraform.tfvars
enable_team_access = true
team_members = ["developer@company.com"]

terraform apply
terraform output team_access_info
```

## Expected Outcomes
- Team access configured
- Role-based permissions set
- Access credentials generated
- Workflow documentation created
EOF

    # Exercise 5: Monitoring and Validation
    cat > "$PROJECT_DIR/exercises/05-monitoring/README.md" << 'EOF'
# Exercise 5: Monitoring and Validation

## Objective
Implement monitoring and validation for state management.

## Steps
1. Enable Activity Tracker
2. Configure monitoring alerts
3. Test state validation
4. Review audit logs

## Commands
```bash
./scripts/validate-terraform.sh
terraform output monitoring_info
```

## Expected Outcomes
- Activity Tracker configured
- Monitoring operational
- Validation procedures tested
- Audit logs accessible
EOF

    success "Exercise templates created"
}

create_helper_scripts() {
    log "Creating helper scripts..."
    
    # State backup script
    cat > "$PROJECT_DIR/scripts/backup-state.sh" << 'EOF'
#!/bin/bash
# State backup utility

BACKUP_DIR="../backups/$(date +%Y%m%d_%H%M%S)"
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

echo "Backup completed: $BACKUP_DIR"
EOF

    # State validation script
    cat > "$PROJECT_DIR/scripts/validate-state.sh" << 'EOF'
#!/bin/bash
# State validation utility

echo "=== Terraform State Validation ==="
echo "Timestamp: $(date)"

# Validate configuration
terraform validate

# Check state
if [ -f terraform.tfstate ]; then
    echo "Local state file found"
    echo "Resource count: $(terraform state list | wc -l)"
else
    echo "No local state file found"
fi

# Check for drift
terraform plan -detailed-exitcode
PLAN_EXIT=$?

case $PLAN_EXIT in
    0) echo "✅ No changes detected" ;;
    1) echo "❌ Error occurred" ;;
    2) echo "⚠️  Changes detected" ;;
esac
EOF

    # Migration helper script
    cat > "$PROJECT_DIR/scripts/migrate-to-remote.sh" << 'EOF'
#!/bin/bash
# State migration helper

echo "=== State Migration Helper ==="

# Check prerequisites
if [ ! -f terraform.tfstate ]; then
    echo "❌ No local state file found"
    exit 1
fi

# Create backup
echo "Creating backup..."
./backup-state.sh

# Initialize with migration
echo "Migrating to remote backend..."
terraform init -migrate-state

echo "✅ Migration completed"
EOF

    # Make scripts executable
    chmod +x "$PROJECT_DIR"/scripts/*.sh
    success "Helper scripts created and made executable"
}

initialize_terraform() {
    log "Initializing Terraform..."
    
    cd "$PROJECT_DIR"
    
    # Initialize Terraform
    if terraform init; then
        success "Terraform initialized successfully"
    else
        error "Terraform initialization failed"
        exit 1
    fi
    
    # Validate configuration
    if terraform validate; then
        success "Configuration validation passed"
    else
        error "Configuration validation failed"
        exit 1
    fi
}

create_documentation() {
    log "Creating documentation..."
    
    # Create comprehensive README
    cat > "$PROJECT_DIR/README.md" << 'EOF'
# Terraform State Management Lab
## Subtopic 6.1: Local and Remote State Files

### Overview
This lab demonstrates Terraform state management patterns using IBM Cloud infrastructure.

### Lab Structure
```
├── exercises/           # Lab exercises
├── scripts/            # Utility scripts
├── templates/          # Configuration templates
├── backups/            # State backups
├── logs/               # Log files
└── generated/          # Generated files
```

### Prerequisites
- IBM Cloud account with API key
- Terraform 1.5.0+
- Basic understanding of Terraform concepts

### Getting Started
1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Configure your IBM Cloud API key
3. Run `./scripts/setup-environment.sh`
4. Follow exercises in order

### Exercises
1. **Local State Analysis**: Understand local state structure
2. **Remote Backend Setup**: Configure IBM COS backend
3. **State Migration**: Migrate from local to remote
4. **Team Collaboration**: Configure team access
5. **Monitoring**: Implement monitoring and validation

### Utility Scripts
- `setup-environment.sh`: Environment setup
- `validate-terraform.sh`: Comprehensive validation
- `backup-state.sh`: Create state backups
- `validate-state.sh`: Quick state validation
- `migrate-to-remote.sh`: Migration helper

### Support
- Review exercise README files
- Check logs/ directory for troubleshooting
- Use validation scripts for verification

### Cost Management
- Monitor resource usage
- Use lite plans where available
- Clean up resources after lab completion
EOF

    success "Documentation created"
}

# =============================================================================
# MAIN SETUP EXECUTION
# =============================================================================

main() {
    log "Starting environment setup for $LAB_NAME..."
    echo "=============================================="
    
    local setup_functions=(
        "check_prerequisites"
        "setup_directory_structure"
        "create_configuration_files"
        "setup_exercise_templates"
        "create_helper_scripts"
        "initialize_terraform"
        "create_documentation"
    )
    
    for func in "${setup_functions[@]}"; do
        echo ""
        $func
    done
    
    echo ""
    echo "=============================================="
    success "Environment setup completed successfully!"
    
    log "Next steps:"
    echo "1. Edit terraform.tfvars with your IBM Cloud API key"
    echo "2. Review the README.md file"
    echo "3. Start with Exercise 1 in exercises/01-local-state/"
    echo "4. Use ./scripts/validate-terraform.sh to validate your setup"
    
    log "Lab environment is ready for Terraform state management exercises!"
}

# Run main setup
main "$@"
