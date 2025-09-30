# Git Environment Setup Guide

## Overview
This guide provides step-by-step instructions for updating Git configuration and SSH keys for the IBM Terraform Training project on AWS EC2 instance.

**Current Environment:**
- AWS EC2 Instance: `ubuntu@ip-172-31-31-203`
- Working Directory: `~/Projects/IBM-Terraform-Training`
- GitHub Account: `RouteClouds`
- Target Email: `routesclouds@gmail.com`

---

## 1. Update Git Email Configuration

### 1.1 Update Global Git Configuration
```bash
# Update the global Git email configuration
git config --global user.email "routesclouds@gmail.com"

# Verify the change
git config --global user.email
```

**Expected Output:**
```
routesclouds@gmail.com
```

### 1.2 Update Local Repository Configuration
```bash
# Navigate to your project directory
cd ~/Projects/IBM-Terraform-Training

# Update local repository email configuration
git config user.email "routesclouds@gmail.com"

# Verify local configuration
git config user.email

# Check all Git configuration
git config --list | grep user
```

**Expected Output:**
```
user.name=RouteClouds
user.email=routesclouds@gmail.com
```

---

## 2. Copy SSH Keys from Remote Machine

### 2.1 Identify SSH Keys on Source Machine

Common SSH key files to look for:
- `id_rsa` and `id_rsa.pub` (RSA keys)
- `id_ed25519` and `id_ed25519.pub` (Ed25519 keys - recommended)
- `id_ecdsa` and `id_ecdsa.pub` (ECDSA keys)

### 2.2 SCP Commands for Key Transfer

**Option A: Copy FROM source machine TO current EC2 instance**
```bash
# Copy RSA private key
scp -i /path/to/your-key.pem username@source-machine-ip:~/.ssh/id_rsa ~/.ssh/id_rsa

# Copy RSA public key
scp -i /path/to/your-key.pem username@source-machine-ip:~/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub

# Copy Ed25519 keys (if available)
scp -i /path/to/your-key.pem username@source-machine-ip:~/.ssh/id_ed25519 ~/.ssh/id_ed25519
scp -i /path/to/your-key.pem username@source-machine-ip:~/.ssh/id_ed25519.pub ~/.ssh/id_ed25519.pub
```

**Option B: Copy FROM local machine TO EC2 instance**
```bash
# Run these commands from your local machine
scp -i /path/to/your-ec2-key.pem ~/.ssh/id_rsa ubuntu@ip-172-31-31-203:~/.ssh/id_rsa
scp -i /path/to/your-ec2-key.pem ~/.ssh/id_rsa.pub ubuntu@ip-172-31-31-203:~/.ssh/id_rsa.pub

# For Ed25519 keys
scp -i /path/to/your-ec2-key.pem ~/.ssh/id_ed25519 ubuntu@ip-172-31-31-203:~/.ssh/id_ed25519
scp -i /path/to/your-ec2-key.pem ~/.ssh/id_ed25519.pub ubuntu@ip-172-31-31-203:~/.ssh/id_ed25519.pub
```

### 2.3 Set Proper File Permissions

```bash
# Ensure .ssh directory exists and has correct permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Set permissions for private keys (very restrictive)
chmod 600 ~/.ssh/id_rsa 2>/dev/null || true
chmod 600 ~/.ssh/id_ed25519 2>/dev/null || true

# Set permissions for public keys (readable)
chmod 644 ~/.ssh/id_rsa.pub 2>/dev/null || true
chmod 644 ~/.ssh/id_ed25519.pub 2>/dev/null || true

# Verify permissions
ls -la ~/.ssh/
```

**Expected Output:**
```
total 16
drwx------ 2 ubuntu ubuntu 4096 Sep 15 12:00 .
drwxr-xr-x 5 ubuntu ubuntu 4096 Sep 15 12:00 ..
-rw------- 1 ubuntu ubuntu 1679 Sep 15 12:00 id_rsa
-rw-r--r-- 1 ubuntu ubuntu  401 Sep 15 12:00 id_rsa.pub
```

---

## 3. Verify SSH Key Setup for GitHub

### 3.1 Check SSH Keys
```bash
# List available SSH keys
ls -la ~/.ssh/

# Display public key content
cat ~/.ssh/id_rsa.pub

# For Ed25519 key (if available)
cat ~/.ssh/id_ed25519.pub 2>/dev/null || echo "Ed25519 key not found"
```

### 3.2 Test SSH Connection to GitHub
```bash
# Test SSH connection to GitHub
ssh -T git@github.com

# If you have multiple keys, specify which one to use
ssh -i ~/.ssh/id_rsa -T git@github.com

# For Ed25519 key
ssh -i ~/.ssh/id_ed25519 -T git@github.com 2>/dev/null || echo "Ed25519 key not available"
```

**Expected Output:**
```
Hi RouteClouds! You've successfully authenticated, but GitHub does not provide shell access.
```

### 3.3 Configure SSH for GitHub

Create SSH config file for GitHub:
```bash
# Create or edit SSH config file
nano ~/.ssh/config
```

**SSH Config Content:**
```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes

# Alternative for Ed25519 key (uncomment if using Ed25519):
# Host github.com
#     HostName github.com
#     User git
#     IdentityFile ~/.ssh/id_ed25519
#     IdentitiesOnly yes
```

```bash
# Set proper permissions for SSH config
chmod 600 ~/.ssh/config
```

### 3.4 Add SSH Key to SSH Agent
```bash
# Start SSH agent
eval "$(ssh-agent -s)"

# Add your SSH key to the agent
ssh-add ~/.ssh/id_rsa

# For Ed25519 key
ssh-add ~/.ssh/id_ed25519 2>/dev/null || echo "Ed25519 key not available"

# List keys in agent
ssh-add -l
```

---

## 4. Verify Git and SSH Integration

### 4.1 Test Git Operations
```bash
# Navigate to your project
cd ~/Projects/IBM-Terraform-Training

# Test Git fetch (should work without password prompt)
git fetch origin

# Check Git status
git status

# Test remote connection
git remote -v
```

**Expected Output:**
```
origin  git@github.com:RouteClouds/IBM-Terraform-Training.git (fetch)
origin  git@github.com:RouteClouds/IBM-Terraform-Training.git (push)
```

### 4.2 Verify GitHub Authentication
```bash
# Test cloning a repository (verification test)
cd /tmp
git clone git@github.com:RouteClouds/IBM-Terraform-Training.git test-clone
rm -rf test-clone

# Return to your project
cd ~/Projects/IBM-Terraform-Training
```

---

## 5. Alternative: Generate New SSH Keys

If copying existing SSH keys fails, generate new ones:

### 5.1 Generate New SSH Key
```bash
# Generate new Ed25519 SSH key (recommended)
ssh-keygen -t ed25519 -C "routesclouds@gmail.com" -f ~/.ssh/id_ed25519

# OR generate RSA key (if Ed25519 not supported)
ssh-keygen -t rsa -b 4096 -C "routesclouds@gmail.com" -f ~/.ssh/id_rsa

# Display the public key to add to GitHub
cat ~/.ssh/id_ed25519.pub
# OR
cat ~/.ssh/id_rsa.pub
```

### 5.2 Add Public Key to GitHub
1. Go to GitHub.com → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Title: `AWS EC2 - IBM Terraform Training`
4. Paste the public key content
5. Click "Add SSH key"

---

## 6. Troubleshooting

### 6.1 Debug SSH Connection Issues
```bash
# Verbose SSH connection test
ssh -vT git@github.com

# Check SSH agent
ssh-add -l

# Test with specific key
ssh -i ~/.ssh/id_rsa -vT git@github.com

# Check SSH config
cat ~/.ssh/config
```

### 6.2 Git Configuration Verification
```bash
# Check all Git configuration
git config --list

# Check repository-specific configuration
git config --local --list

# Check global configuration
git config --global --list

# Check current user configuration
git config user.name
git config user.email
```

### 6.3 Common Issues and Solutions

**Issue: Permission denied (publickey)**
```bash
# Check key permissions
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

**Issue: SSH key not recognized**
```bash
# Add key to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
ssh-add -l
```

**Issue: Wrong email in commits**
```bash
# Update email and re-commit if needed
git config user.email "routesclouds@gmail.com"
git commit --amend --author="RouteClouds <routesclouds@gmail.com>"
```

---

## 7. Quick Setup Commands Summary

Execute these commands in sequence:

```bash
# 1. Update Git email configuration
git config --global user.email "routesclouds@gmail.com"
cd ~/Projects/IBM-Terraform-Training
git config user.email "routesclouds@gmail.com"

# 2. Set up SSH directory and permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 3. Copy SSH keys (adjust source path as needed)
# scp -i /path/to/key.pem source:~/.ssh/id_rsa ~/.ssh/id_rsa
# scp -i /path/to/key.pem source:~/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub

# 4. Set SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# 5. Test GitHub connection
ssh -T git@github.com

# 6. Verify Git operations
git fetch origin
git status
git remote -v
```

---

## 8. Verification Checklist

- [ ] Git email updated to `routesclouds@gmail.com`
- [ ] SSH keys copied and permissions set correctly
- [ ] SSH connection to GitHub successful
- [ ] Git fetch/push operations work without password
- [ ] Repository remote URLs use SSH format (`git@github.com:...`)

---

## Notes

- **Security**: Never share private SSH keys or commit them to repositories
- **Backup**: Keep a backup of your SSH keys in a secure location
- **Multiple Keys**: Use SSH config file to manage multiple keys for different services
- **Key Rotation**: Regularly rotate SSH keys for security best practices

**Environment Details:**
- AWS EC2 Instance: `ubuntu@ip-172-31-31-203`
- Project Path: `~/Projects/IBM-Terraform-Training`
- GitHub Repository: `git@github.com:RouteClouds/IBM-Terraform-Training.git`
- Updated Email: `routesclouds@gmail.com`
