# Disaster Recovery

This guide covers **disaster recovery** - rebuilding your entire infrastructure from scratch using only your encrypted S3 backup and master password.

---

## When to Use This

- Cloud provider account lost/compromised
- Complete infrastructure failure
- Migration to new provider
- Testing recovery procedures (recommended quarterly)

---

## What You Need

- [ ] Your master password (in your head)
- [ ] Access to S3 bucket (or alternative download method)
- [ ] A clean Linux/macOS machine
- [ ] Internet connection

---

## Quick Recovery

```bash
# Install tools
sudo apt install age awscli

# Download from S3
aws s3 cp s3://your-bucket/age-identity.enc .
aws s3 cp s3://your-bucket/recovery.yaml.age .
aws s3 cp s3://your-bucket/infra-repo.tar.gz .

# Decrypt with password
openssl enc -d -aes-256-cbc -pbkdf2 -in age-identity.enc -out age-identity.txt
age -d -i age-identity.txt recovery.yaml.age > recovery.yaml
tar -xzf infra-repo.tar.gz

# Deploy infrastructure
export HCLOUD_TOKEN=$(yq '.hetzner.api_token' recovery.yaml)
cd layer1-core-vm
tofu init && tofu apply
```

---

## Step-by-Step Recovery

### Step 1: Prepare Recovery Machine

Use any Linux/macOS machine:

```bash
# Install age
sudo apt install age

# Verify openssl (pre-installed)
openssl version

# Install OpenTofu
wget https://github.com/opentofu/opentofu/releases/download/v1.10.6/tofu_1.10.6_amd64.deb
sudo apt install ./tofu_1.10.6_amd64.deb
```

### Step 2: Download Recovery Bundle

**Option A: Using AWS CLI**
```bash
# Install AWS CLI
sudo apt install awscli

# Configure credentials (if private bucket)
aws configure
# OR use environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"

# Download files
BUCKET="your-recovery-bucket"
aws s3 cp s3://${BUCKET}/age-identity.enc .
aws s3 cp s3://${BUCKET}/recovery.yaml.age .
aws s3 cp s3://${BUCKET}/infra-repo.tar.gz .
```

**Option B: Public S3 bucket (if configured)**
```bash
# Direct download with curl/wget
curl https://your-bucket.s3.amazonaws.com/age-identity.enc > age-identity.enc
curl https://your-bucket.s3.amazonaws.com/recovery.yaml.age > recovery.yaml.age
curl https://your-bucket.s3.amazonaws.com/infra-repo.tar.gz > infra-repo.tar.gz
```

**Option C: From local backup**
```bash
# If you have USB/external drive backup
cp /media/backup/age-identity.enc .
cp /media/backup/recovery.yaml.age .
cp /media/backup/infra-repo.tar.gz .
```

### Step 3: Decrypt Age Identity

```bash
# Decrypt with your master password
openssl enc -d -aes-256-cbc -pbkdf2 -in age-identity.enc -out age-identity.txt

# Enter password: ________ (your master password)
```

**Troubleshooting:**
- **"bad decrypt"** → Wrong password
- **"unknown option"** → Old openssl version (try without `-pbkdf2`)

### Step 4: Decrypt Secrets

```bash
# Decrypt recovery.yaml
age -d -i age-identity.txt recovery.yaml.age > recovery.yaml

# Verify contents
cat recovery.yaml
```

### Step 5: Extract Infrastructure

```bash
# Extract infrastructure code
tar -xzf infra-repo.tar.gz

# Verify
ls -la
```

You now have:
- `recovery.yaml` - All secrets
- `age-identity.txt` - Age decryption key
- Infrastructure code (extracted from tarball)

### Step 6: Configure Cloud Credentials

```bash
# Export cloud provider credentials from recovery.yaml
export HCLOUD_TOKEN=$(yq '.hetzner.api_token' recovery.yaml)

# Or for AWS
export AWS_ACCESS_KEY_ID=$(yq '.aws.access_key_id' recovery.yaml)
export AWS_SECRET_ACCESS_KEY=$(yq '.aws.secret_access_key' recovery.yaml)

# Setup SSH key
yq '.ssh.private_key' recovery.yaml > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
```

**Note:** Install `yq` if needed:
```bash
sudo wget -O /usr/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/bin/yq
```

### Step 7: Deploy Infrastructure

#### Layer 1: Core VM

```bash
cd layer1-core-vm

# Initialize Tofu
tofu init

# Review plan
tofu plan

# Apply (creates VM)
tofu apply

# Note the VM IP address
tofu output
```

**Time estimate:** ~5 minutes

#### Layer 2: Core Services (Optional)

```bash
# SSH to the VM
ssh root@<vm-ip>

# Copy docker-compose files
# Deploy core services (Gitea, Vaultwarden, MinIO)
cd /opt && docker compose up -d
```

**Time estimate:** ~10 minutes

#### Layer 3: Cloud Infrastructure

```bash
cd layer3-cloud-infra

# Deploy cloud resources
tofu init
tofu apply
```

**Time estimate:** ~15-30 minutes

#### Layer 4: Applications

```bash
cd layer4-apps

# Deploy to Kubernetes/Nomad
kubectl apply -f manifests/
# or
nomad run jobs/
```

**Time estimate:** ~30-60 minutes

---

## Total Recovery Time

| Scenario | Time | Notes |
|----------|------|-------|
| **Minimal** (Layer 1 only) | ~15 min | Core VM + manual config |
| **Core Services** (Layers 1-2) | ~30 min | VM + Docker services |
| **Full Infrastructure** (Layers 1-3) | ~1 hour | All cloud resources |
| **Complete** (All layers) | ~2 hours | Including applications |

---

## Recovery Scenarios

### Scenario 1: Lost Cloud Provider Account

**Situation:** Hetzner account suspended/deleted

**Solution:**
1. Create account with new provider (AWS, DigitalOcean, etc.)
2. Update cloud provider credentials in recovery.yaml
3. Update layer1-core-vm configuration for new provider
4. Deploy from scratch

**Changes needed:**
- Cloud provider API tokens
- Provider-specific Tofu configuration
- Possibly region/zone settings

### Scenario 2: Complete Infrastructure Deleted

**Situation:** Accidentally deleted all resources

**Solution:**
1. Download recovery bundle from S3 (still intact)
2. Decrypt secrets
3. Re-run `tofu apply` to recreate everything

**Time:** ~1-2 hours

### Scenario 3: S3 Bucket Lost

**Situation:** S3 bucket deleted or inaccessible

**Solution:**
- Restore from local backup (if available)
- If no backup: Cannot recover ❌

**Prevention:**
- Keep local encrypted copies
- Use S3 versioning
- Multi-region replication

### Scenario 4: Forgotten Master Password

**Situation:** Cannot remember password

**Solution:**
- Try password manager backup
- If using Shamir's Secret Sharing, reconstruct password
- Otherwise: Cannot recover ❌

**Prevention:**
- Store password in secure password manager
- Consider Shamir's Secret Sharing
- Paper backup of encrypted files

---

## Testing Recovery

**Run recovery drills quarterly:**

```bash
# Create isolated test environment
mkdir ~/recovery-drill-$(date +%Y%m%d)
cd ~/recovery-drill-$(date +%Y%m%d)

# Download and decrypt (test your password!)
aws s3 cp s3://${BUCKET}/age-identity.enc .
openssl enc -d -aes-256-cbc -pbkdf2 -in age-identity.enc -out test-identity.txt

# Verify decryption worked
cat test-identity.txt

# Clean up
cd .. && rm -rf recovery-drill-*
```

**Checklist:**
- [ ] Can download from S3
- [ ] Remember master password
- [ ] Can decrypt age-identity.enc
- [ ] Can decrypt recovery.yaml.age
- [ ] Secrets are current and valid
- [ ] Infrastructure code is up-to-date

---

## Emergency Contacts

If you need help during recovery:

1. **Check docs:** [Troubleshooting Guide](troubleshooting.md)
2. **Verify S3 access:** Ensure bucket exists and is accessible
3. **Test password:** Try decrypting on different machine
4. **Check backups:** Look for local encrypted copies

---

## Post-Recovery

After successful recovery:

1. **Update secrets** - Rotate compromised credentials
2. **Verify backups** - Ensure new infrastructure is backing up
3. **Test applications** - Confirm all services are working
4. **Update documentation** - Note any changes or issues
5. **Create new recovery bundle** - With updated secrets

---

## Recovery Checklist

```
Phase 1: Preparation
[ ] Recovery machine ready (Linux/macOS)
[ ] Tools installed (age, openssl, tofu)
[ ] S3 access configured
[ ] Master password ready

Phase 2: Decryption
[ ] Downloaded age-identity.enc
[ ] Downloaded recovery.yaml.age
[ ] Downloaded infra-repo.tar.gz
[ ] Decrypted age-identity.txt
[ ] Decrypted recovery.yaml
[ ] Extracted infrastructure code

Phase 3: Deployment
[ ] Cloud credentials configured
[ ] SSH keys set up
[ ] Layer 1 deployed (VM)
[ ] Layer 2 deployed (optional)
[ ] Layer 3 deployed (cloud infra)
[ ] Layer 4 deployed (apps)

Phase 4: Verification
[ ] Can access infrastructure
[ ] Services are running
[ ] Data restored (if applicable)
[ ] Backups configured
[ ] Monitoring active

Phase 5: Post-Recovery
[ ] Rotated compromised credentials
[ ] Updated recovery bundle
[ ] Documented issues/changes
[ ] Tested new infrastructure
```

---

## Troubleshooting

### Cannot decrypt age-identity.enc
**Problem:** "bad decrypt" error

**Solutions:**
- Verify password (try password manager backup)
- Check file integrity (re-download from S3)
- Try without `-pbkdf2` flag (older openssl versions)
- Verify file wasn't corrupted during transfer

### Cannot access S3 bucket
**Problem:** Access denied or bucket not found

**Solutions:**
- Verify bucket name
- Check AWS credentials
- Ensure bucket still exists
- Try alternative download method (local backup)

### Tofu/Terraform errors
**Problem:** Resource creation fails

**Solutions:**
- Check cloud provider credentials
- Verify API tokens are valid
- Review quota limits
- Check region availability

---

## See Also

- **[Setup Guide](setup.md)** - Creating recovery bundles
- **[Architecture](architecture.md)** - System design
- **[Security](security.md)** - Security considerations
