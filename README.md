# Solvista Cloud

**One Password. Total Recovery.**

A recovery-first infrastructure platform where your entire cloud environment can be rebuilt from:
- An S3 bucket
- One master password
- Standard tools (`age`, `openssl`, `tofu`)

---

## Quick Start

```bash
# In a disaster scenario, rebuild everything with:
aws s3 cp s3://bucket/age-identity.enc .
aws s3 cp s3://bucket/recovery.yaml.age .
aws s3 cp s3://bucket/infra-repo.tar.gz .

openssl enc -d -aes-256-cbc -pbkdf2 -in age-identity.enc -out age-identity.txt
age -d -i age-identity.txt recovery.yaml.age > recovery.yaml
tar -xzf infra-repo.tar.gz

cd layer1-core-vm && tofu apply
```

That's it. Your infrastructure is recovered.

---

## Documentation

📚 **[Complete Documentation](docs/README.md)**

### Essential Reading

- **[Architecture](docs/architecture.md)** - System design and philosophy
- **[Setup Guide](docs/setup.md)** - Initial setup instructions
- **[Recovery](docs/recovery.md)** - Disaster recovery procedures
- **[Security](docs/security.md)** - Security best practices

### Quick Links

- [Requirements](docs/requirements.md) - System requirements
- [Configuration](docs/configuration.md) - Environment configuration
- [Deployment](docs/deployment.md) - Deploying infrastructure
- [Troubleshooting](docs/troubleshooting.md) - Common issues

---

## Core Philosophy

### Recovery-First Design
Everything can be rebuilt from encrypted backups + one password. No complex secret management, no key distribution, just simple recovery.

### Standard Tools Only
Uses `age` (encryption), `openssl` (password-based encryption), and `tofu` (infrastructure). All open-source, widely-available, and portable.

### Provider Independent
Deploy to any cloud provider (Hetzner, AWS, DigitalOcean, etc.). Your infrastructure is portable.

### Transparent Infrastructure
Infrastructure code is unencrypted and auditable. Only secrets are encrypted.

---

## What's in S3

```
s3://your-recovery-bucket/
├── infra-repo.tar.gz       # Your infrastructure code (unencrypted)
├── recovery.yaml.age       # All secrets (encrypted with age)
└── age-identity.enc        # Age key (encrypted with your password)
```

Your password → age key → secrets. Simple.

---

## Architecture

```
Master Password (in your head)
       ↓
age-identity.enc (in S3)
       ↓
age-identity.txt (decrypted locally)
       ↓
recovery.yaml.age (in S3)
       ↓
recovery.yaml (all your secrets)
       ↓
Infrastructure Deployment (tofu apply)
```

**Layers:**
1. **Layer 1:** Core VM (single VM foundation)
2. **Layer 2:** Core services (Docker Compose - Gitea, Vaultwarden, MinIO)
3. **Layer 3:** Cloud infrastructure (networks, compute, storage)
4. **Layer 4:** Applications (Kubernetes/Nomad workloads)

See **[Architecture](docs/architecture.md)** for details.

---

## Getting Started

### New Users

1. Read **[Architecture](docs/architecture.md)** to understand the system
2. Follow **[Setup Guide](docs/setup.md)** to create your recovery bundle
3. Deploy infrastructure with **[Deployment Guide](docs/deployment.md)**
4. Practice recovery with **[Recovery Guide](docs/recovery.md)**

### Existing Infrastructure

Migrating from an existing setup? See **[Migration Guide](docs/migration.md)**.

---

## Security

- ✅ All secrets encrypted at rest (age encryption)
- ✅ Master password never stored (only in your head)
- ✅ Standard encryption tools (age + openssl)
- ✅ Two-layer encryption (password → age key → secrets)
- ✅ Works on any Unix-like system

See **[Security Guide](docs/security.md)** for threat model and best practices.

---

## Requirements

**Minimum:**
- Linux/macOS workstation
- Cloud provider account
- S3-compatible storage
- `age`, `openssl`, `tofu`

**For production:**
- Secure password manager (for master password backup)
- Regular recovery testing
- Multiple S3 regions (optional)

See **[Requirements](docs/requirements.md)** for complete details.

---

## Contributing

This is a personal infrastructure project, but you're welcome to:
- Fork and adapt for your own use
- Report bugs or issues
- Suggest improvements

---

## License

[Specify your license here]

---

## Support

- **Documentation:** [docs/README.md](docs/README.md)
- **Issues:** Report bugs in GitHub issues
- **Questions:** Check [Troubleshooting](docs/troubleshooting.md)

---

## Why Solvista Cloud?

Traditional infrastructure platforms require managing dozens of secrets, credentials, and keys across multiple systems. When disaster strikes, you're scrambling to find backups, remember passwords, and piece together your infrastructure.

Solvista Cloud inverts this model: **one password unlocks everything**. Your infrastructure code, secrets, and deployment procedures are all recoverable from S3 storage. No vendor lock-in. No complex secret management. Just simple, reliable recovery.

Perfect for:
- Personal projects requiring disaster recovery
- Small teams wanting infrastructure portability
- Anyone tired of complex secret management
- Learning Infrastructure-as-Code with a clear recovery strategy

---

**Get started:** [Setup Guide](docs/setup.md)
