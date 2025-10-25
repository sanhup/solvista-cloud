# Architecture

Solvista Cloud is designed with disaster recovery as the foundational principle. Every architectural decision supports the goal of complete infrastructure recovery from a single master password.

---

## Design Principles

### 1. Recovery-First
All infrastructure must be rebuildable from:
- S3-stored encrypted secrets
- S3-stored infrastructure code
- One master password

### 2. Separation of Concerns
- **Code** (unencrypted, version-controlled, auditable)
- **Secrets** (encrypted, never in version control)
- **State** (ephemeral, rebuildable from code + secrets)

### 3. Standard Tools Only
- No proprietary software
- No vendor-specific features
- Prefer widely-available open-source tools
- Minimize dependencies

### 4. Provider Independence
Infrastructure should be portable across cloud providers with minimal changes.

---

## System Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Recovery Storage (S3)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ infra-repo   │  │ recovery     │  │ age-identity │  │
│  │ .tar.gz      │  │ .yaml.age    │  │ .enc         │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ↓
              ┌────────────────────────┐
              │   Master Password      │
              │  (in your head only)   │
              └────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                  Decryption Process                     │
│                                                         │
│  Password → age-identity.enc → age-identity.txt        │
│              ↓                                          │
│  age-identity.txt → recovery.yaml.age → recovery.yaml  │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│              Infrastructure Deployment                  │
│                                                         │
│  Layer 1: Core VM (Hetzner/AWS/etc)                    │
│  Layer 2: Core Services (Docker Compose)               │
│  Layer 3: Cloud Infrastructure (Tofu/Terraform)        │
│  Layer 4: Applications (Kubernetes/Nomad)              │
└─────────────────────────────────────────────────────────┘
```

---

## Infrastructure Layers

### Layer 1: Core VM Provisioning

**Purpose:** Bootstrap a single VM that serves as the foundation

**Technology:** OpenTofu/Terraform

**What it creates:**
- Single compute instance
- Basic networking (firewall, SSH access)
- Initial storage volumes

**Outputs:**
- VM public IP address
- SSH access details

**Recovery time:** ~5 minutes

---

### Layer 2: Core Services

**Purpose:** Self-hosted critical services for the platform

**Technology:** Docker Compose

**Services:**
- **Gitea** - Git repository hosting (for IaC and scripts)
- **Vaultwarden** - Password/secrets management
- **MinIO** - S3-compatible object storage
- **Caddy** - Reverse proxy with automatic TLS
- **Restic** - Encrypted backups

**Why Docker Compose?**
- Simple, minimal dependencies
- Easy to backup and restore
- Runs on a single VM
- No orchestration complexity

**Recovery time:** ~10 minutes (after Layer 1)

---

### Layer 3: Cloud Infrastructure

**Purpose:** Scalable cloud resources

**Technology:** OpenTofu/Terraform

**What it creates:**
- Virtual networks and subnets
- Load balancers
- Additional compute instances
- Block storage volumes
- Firewall rules
- DNS records

**Provider examples:**
- Hetzner Cloud
- AWS
- DigitalOcean
- Any Terraform-supported provider

**Recovery time:** ~15-30 minutes (after Layer 2)

---

### Layer 4: Application Layer

**Purpose:** Production applications and workloads

**Technology:** Kubernetes/Nomad/Docker Swarm

**What runs here:**
- Production applications
- Databases
- Microservices
- CI/CD pipelines
- Development environments

**Recovery time:** ~30-60 minutes (after Layer 3)

---

## Encryption Architecture

### Two-Layer Encryption Model

```
┌─────────────────────────────────────┐
│      Layer 1: Secret Storage        │
│                                     │
│  recovery.yaml (plaintext)          │
│    ├─ Cloud API tokens              │
│    ├─ SSH private keys              │
│    ├─ Application secrets           │
│    └─ S3 credentials                │
│           ↓ (age encryption)        │
│  recovery.yaml.age (encrypted)      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│      Layer 2: Key Protection        │
│                                     │
│  age-identity.txt (age secret key)  │
│           ↓ (openssl encryption)    │
│  age-identity.enc (encrypted)       │
│           ↓                         │
│  Protected by master password       │
└─────────────────────────────────────┘
```

### Why Two Layers?

**Benefits:**
- Standard age encryption for secrets (portable, well-tested)
- Standard openssl for password-based encryption (universal)
- No plugins or special tools required
- Works on any Unix-like system

**Security:**
- Master password never stored anywhere
- Age key encrypted at rest
- Secrets double-encrypted (via age key which is itself encrypted)
- PBKDF2 key derivation for password (via openssl)

---

## Data Flow

### Initial Setup

```
1. Generate age key pair
   age-keygen → age-identity.txt + public key

2. Create secrets file
   manually → recovery.yaml

3. Encrypt secrets with age
   recovery.yaml + age pubkey → recovery.yaml.age

4. Encrypt age key with password
   age-identity.txt + password → age-identity.enc

5. Upload to S3
   recovery.yaml.age, age-identity.enc, infra-repo.tar.gz → S3
```

### Recovery Flow

```
1. Download from S3
   S3 → recovery.yaml.age, age-identity.enc, infra-repo.tar.gz

2. Decrypt age key
   age-identity.enc + password → age-identity.txt

3. Decrypt secrets
   recovery.yaml.age + age-identity.txt → recovery.yaml

4. Deploy infrastructure
   recovery.yaml + infra code → running infrastructure
```

---

## Environment Structure

```
environments/
├── production/
│   ├── layer1-core-vm/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── layer2-core-services/
│   │   └── docker-compose.yml
│   ├── layer3-cloud-infra/
│   │   └── *.tf
│   └── layer4-apps/
│       └── k8s-manifests/
├── staging/
│   └── (similar structure)
└── development/
    └── (similar structure)
```

Each environment has:
- Its own recovery bundle in S3
- Separate cloud credentials
- Independent infrastructure state

---

## Security Model

### Threat Model

**Protected against:**
- ✅ Lost infrastructure (cloud account compromised/closed)
- ✅ Forgotten credentials
- ✅ Provider shutdown
- ✅ Accidental deletion
- ✅ Ransomware (if backups are offline)

**NOT protected against:**
- ❌ Compromised master password
- ❌ Attacker with both S3 access AND master password
- ❌ Malicious code in infrastructure repository

### Trust Boundaries

```
Untrusted:
  - Cloud provider
  - S3 storage
  - Infrastructure code (public)

Trusted:
  - Your master password
  - Encryption tools (age, openssl)
  - Your local machine (during setup)

Semi-trusted:
  - Recovery laptop (during disaster recovery)
```

---

## Scalability Considerations

### Single-VM Core (Layer 2)

**Advantages:**
- Simple backup/restore
- No distributed system complexity
- Low cost
- Fast recovery

**Limitations:**
- Single point of failure
- Limited scalability
- No high availability

**When to scale beyond:**
- Need for HA password manager
- Git repository becomes critical
- Multiple team members

**Scaling path:**
- Keep Layer 2 simple for recovery
- Run production versions of services in Layer 4
- Layer 2 becomes "recovery-only" core

---

## Dependencies

### Required Tools (Recovery)
- `age` - Encryption/decryption
- `openssl` - Password-based encryption
- `tar` - Archive extraction
- `aws` CLI or `curl` - S3 download
- `tofu` or `terraform` - Infrastructure provisioning

### Required Tools (Operations)
- `docker` + `docker compose` - Core services
- `kubectl` or `nomad` - Application orchestration
- `git` - Version control
- `yq` or `jq` - YAML/JSON processing

All tools are:
- Open source
- Widely available
- Well-documented
- Actively maintained

---

## Disaster Recovery Scenarios

### Scenario 1: Cloud Provider Account Lost
1. Create new account with any provider
2. Download recovery bundle from S3
3. Decrypt with master password
4. Update cloud credentials in recovery.yaml
5. Deploy Layer 1-4 to new provider

**Recovery time:** 1-2 hours

### Scenario 2: Lost Master Password
❌ **Cannot recover** - this is the security trade-off

**Mitigations:**
- Use strong password manager for master password
- Paper backup of encrypted recovery bundle
- Shamir's Secret Sharing for master password

### Scenario 3: S3 Bucket Deleted
- Restore from local backup of encrypted files
- Re-upload to new S3 bucket
- Update recovery scripts with new bucket name

**Prevention:**
- Keep local copies of recovery bundle
- Use S3 versioning
- Enable S3 MFA delete

### Scenario 4: Complete Amnesia (No Passwords)
If you have paper backups of encrypted files but lost passwords:
- Try to recover master password from memory/password manager
- If using Shamir's Secret Sharing, reconstruct password
- Otherwise: ❌ Cannot recover

---

## Future Enhancements

Potential improvements (maintaining recovery-first principle):

1. **Multi-region S3 replication** - Automatic cross-region backup
2. **Shamir's Secret Sharing** - Split master password across trustees
3. **Hardware security key** - YubiKey for second factor
4. **Automated testing** - Regular recovery drills
5. **Backup verification** - Cryptographic proofs of backup integrity

---

## Next Steps

- **Setup:** See [Setup Guide](setup.md)
- **Security:** Read [Security](security.md)
- **Recovery:** Practice with [Recovery](recovery.md)
