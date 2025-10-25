# Setup Guide

This guide covers the **initial setup** of your Solvista Cloud recovery system. You'll create an encrypted recovery bundle and upload it to S3.

---

## Prerequisites

- [ ] Cloud provider account (Hetzner, AWS, etc.)
- [ ] S3-compatible storage bucket
- [ ] Linux/macOS workstation
- [ ] Basic terminal knowledge

---

## Quick Setup

```bash
# 1. Install tools
sudo apt install age awscli

# 2. Generate age key
age-keygen > age-identity.txt
grep "public key:" age-identity.txt | cut -d: -f2 | xargs > .age-pubkey

# 3. Create recovery.yaml with your secrets
# (See example below)

# 4. Encrypt everything
age -e -a -r "$(cat .age-pubkey)" recovery.yaml > recovery.yaml.age
openssl enc -aes-256-cbc -pbkdf2 -salt -in age-identity.txt -out age-identity.enc

# 5. Package infrastructure
tar -czf infra-repo.tar.gz --exclude='.git' --exclude='*.tfstate' --exclude='recovery.yaml' --exclude='age-identity.txt' .

# 6. Upload to S3
aws s3 cp recovery.yaml.age s3://your-bucket/
aws s3 cp age-identity.enc s3://your-bucket/
aws s3 cp infra-repo.tar.gz s3://your-bucket/

# 7. Test recovery (critical!)
# See Recovery Guide
```

---

## Detailed Steps

### 1. Install Tools

```bash
# Ubuntu/Debian
apt-get install age awscli

# Verify openssl (pre-installed)
openssl version

# Install OpenTofu (check for latest version)
wget https://github.com/opentofu/opentofu/releases/download/v1.10.6/tofu_1.10.6_amd64.deb
sudo apt install ./tofu_1.10.6_amd64.deb
tofu version
```

### 2. Generate Master Password

Use a strong diceware passphrase:

```bash
# Install diceware (optional)
pip install diceware

# Generate 8-word passphrase
diceware -n 8

# Example output:
# fossil nephew arctic jungle helmet window plastic thunder
```

**CRITICAL:** This password protects everything. Memorize it and store backup in password manager.

### 3. Generate Age Key

```bash
# Generate age encryption key
age-keygen > age-identity.txt

# Extract public key for convenience
grep "public key:" age-identity.txt | cut -d: -f2 | xargs > .age-pubkey

# View the public key
cat .age-pubkey
# age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
```

### 4. Create recovery.yaml

Create `recovery.yaml` with all your secrets:

```yaml
# Cloud Provider Credentials
hetzner:
  api_token: "YOUR_HETZNER_TOKEN"

# AWS/S3 Credentials
aws:
  access_key_id: "YOUR_AWS_ACCESS_KEY"
  secret_access_key: "YOUR_AWS_SECRET_KEY"
  region: "us-east-1"

# SSH Keys
ssh:
  private_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    YOUR_SSH_PRIVATE_KEY_HERE
    -----END OPENSSH PRIVATE KEY-----
  public_key: "ssh-ed25519 AAAA... your@email.com"

# Application Secrets (optional)
vaultwarden:
  admin_token: "RANDOM_TOKEN_HERE"

gitea:
  admin_password: "STRONG_PASSWORD_HERE"

minio:
  root_user: "admin"
  root_password: "STRONG_PASSWORD_HERE"
```

**Generate secrets:**
```bash
# Random tokens
openssl rand -hex 32

# Strong passwords
diceware -n 6
```

**Generate SSH key (if needed):**
```bash
ssh-keygen -t ed25519 -f ~/.ssh/solvista_key -N ""
cat ~/.ssh/solvista_key      # Copy to recovery.yaml ssh.private_key
cat ~/.ssh/solvista_key.pub  # Copy to recovery.yaml ssh.public_key
```

### 5. Encrypt recovery.yaml

```bash
# Encrypt with age
age -e -a -r "$(cat .age-pubkey)" recovery.yaml > recovery.yaml.age

# Verify
ls -lh recovery.yaml.age
```

### 6. Encrypt age-identity

```bash
# Encrypt age key with your master password
openssl enc -aes-256-cbc -pbkdf2 -salt -in age-identity.txt -out age-identity.enc

# Enter password: ________ (your diceware passphrase)
# Verifying: ________ (same password)
```

### 7. Package Infrastructure

```bash
# Create tarball of infrastructure code
tar -czf infra-repo.tar.gz \
  --exclude='.git' \
  --exclude='*.tfstate' \
  --exclude='*.tfstate.backup' \
  --exclude='recovery.yaml' \
  --exclude='age-identity.txt' \
  --exclude='.terraform' \
  .

# Verify contents
tar -tzf infra-repo.tar.gz | head
```

### 8. Upload to S3

```bash
# Configure AWS CLI
aws configure
# Or: export AWS_ACCESS_KEY_ID="..." AWS_SECRET_ACCESS_KEY="..."

# Create S3 bucket
RECOVERY_BUCKET="solvista-recovery-$(date +%s)"
aws s3 mb s3://${RECOVERY_BUCKET}

# Enable versioning (recommended)
aws s3api put-bucket-versioning \
  --bucket ${RECOVERY_BUCKET} \
  --versioning-configuration Status=Enabled

# Upload files
aws s3 cp recovery.yaml.age s3://${RECOVERY_BUCKET}/
aws s3 cp age-identity.enc s3://${RECOVERY_BUCKET}/
aws s3 cp infra-repo.tar.gz s3://${RECOVERY_BUCKET}/

# Verify
aws s3 ls s3://${RECOVERY_BUCKET}/
```

### 9. Test Recovery

**CRITICAL: Test before you need it!**

```bash
# Test in clean directory
mkdir ~/recovery-test && cd ~/recovery-test

# Download
aws s3 cp s3://${RECOVERY_BUCKET}/age-identity.enc .
aws s3 cp s3://${RECOVERY_BUCKET}/recovery.yaml.age .

# Decrypt
openssl enc -d -aes-256-cbc -pbkdf2 -in age-identity.enc -out identity.txt
age -d -i identity.txt recovery.yaml.age > test.yaml

# Verify contents
cat test.yaml

# Cleanup
cd .. && rm -rf ~/recovery-test

echo "✓ Recovery test successful!"
```

### 10. Secure Cleanup

```bash
# Delete unencrypted sensitive files
shred -u recovery.yaml age-identity.txt

# Encrypted files are safe to keep locally or delete
# They're already in S3
```

---

## Updating Secrets

When you need to update secrets later:

```bash
# 1. Edit recovery.yaml
vim recovery.yaml

# 2. Re-encrypt (no password needed - uses public key)
age -e -a -r "$(cat .age-pubkey)" recovery.yaml > recovery.yaml.age

# 3. Upload
aws s3 cp recovery.yaml.age s3://${RECOVERY_BUCKET}/

# Note: age-identity.enc stays the same! Don't re-upload it unless you changed your master password
```

---

## Files Overview

**Keep secure (encrypted, in S3):**
- `recovery.yaml.age` - Your secrets
- `age-identity.enc` - Your age key
- `infra-repo.tar.gz` - Your code

**Keep locally (safe):**
- `.age-pubkey` - Public key for encryption
- `age-identity.txt` - Secret key (if you want to skip password for updates)

**Delete after setup:**
- `recovery.yaml` - Unencrypted secrets (shred!)
- `age-identity.txt` - Unless keeping for convenience

---

## Next Steps

1. **Test recovery** - See [Recovery Guide](recovery.md)
2. **Deploy infrastructure** - See [Deployment Guide](deployment.md)
3. **Set up automation** - Automate secret updates
4. **Schedule recovery drills** - Test quarterly

---

## Troubleshooting

### "bad decrypt" from openssl
- Wrong password
- File corrupted
- Different password than encryption

### Age encryption fails
- Check .age-pubkey exists
- Verify age is installed
- Check file permissions

### S3 upload fails
- Verify AWS credentials
- Check bucket name
- Confirm IAM permissions

---

## See Also

- **[Recovery Guide](recovery.md)** - Disaster recovery procedures
- **[Architecture](architecture.md)** - System design
- **[Security](security.md)** - Security best practices
