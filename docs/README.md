# Solvista Cloud Documentation

Welcome to Solvista Cloud - a recovery-first infrastructure platform where everything can be rebuilt from S3 + one master password.

---

## Quick Start

New to Solvista Cloud? Start here:

1. **[Architecture](architecture.md)** - Understand the system design and philosophy
2. **[Setup Guide](setup.md)** - Initial setup and configuration
3. **[Recovery](recovery.md)** - Disaster recovery procedures
4. **[Security](security.md)** - Security considerations and best practices

---

## Documentation Index

### Core Concepts

- **[Architecture](architecture.md)** - System architecture, design principles, and infrastructure layers
- **[Recovery](recovery.md)** - Complete disaster recovery procedures using age + openssl
- **[Security](security.md)** - Encryption strategy, password management, and security best practices

### Getting Started

- **[Setup Guide](setup.md)** - Step-by-step initial setup instructions
- **[Requirements](requirements.md)** - System requirements and dependencies
- **[Configuration](configuration.md)** - Environment configuration and customization

### Operations

- **[Deployment](deployment.md)** - Deploying infrastructure and applications
- **[Maintenance](maintenance.md)** - Regular maintenance tasks and updates
- **[Monitoring](monitoring.md)** - Monitoring and alerting setup
- **[Backup & Restore](backup-restore.md)** - Backup procedures and restore operations

### Advanced Topics

- **[Multi-Environment Setup](multi-environment.md)** - Managing multiple environments (dev, staging, prod)
- **[Automation](automation.md)** - CI/CD pipelines and automation scripts
- **[Troubleshooting](troubleshooting.md)** - Common issues and solutions
- **[Migration](migration.md)** - Migrating between cloud providers

---

## Core Philosophy

Solvista Cloud is built around these principles:

### 1. Recovery-First Design
Everything starts with disaster recovery. The entire infrastructure can be rebuilt from:
- An S3 bucket (or any S3-compatible storage)
- Your master password
- Standard tools (`age`, `openssl`, `tofu`)

### 2. Minimal Dependencies
- No proprietary tools
- No vendor lock-in
- Standard, widely-available encryption tools
- Infrastructure-as-Code for everything

### 3. One Password, Total Recovery
All secrets derive from a single master password using a two-layer encryption:
```
Master Password → Age Key → Infrastructure Secrets
```

### 4. Transparent Infrastructure
- Infrastructure code is stored unencrypted (no secrets in code)
- Anyone can audit the infrastructure design
- Secrets are separated from configuration

---

## What's Stored in S3

```
s3://your-recovery-bucket/
├── infra-repo.tar.gz       # Infrastructure-as-Code (unencrypted)
├── recovery.yaml.age       # Encrypted secrets (cloud tokens, SSH keys, etc.)
└── age-identity.enc        # Encrypted age key (protected by your password)
```

---

## Quick Recovery Summary

In a disaster scenario, you can rebuild everything with these steps:

```bash
# 1. Download recovery files
aws s3 cp s3://bucket/age-identity.enc .
aws s3 cp s3://bucket/recovery.yaml.age .
aws s3 cp s3://bucket/infra-repo.tar.gz .

# 2. Decrypt with your master password
openssl enc -d -aes-256-cbc -pbkdf2 -in age-identity.enc -out age-identity.txt
age -d -i age-identity.txt recovery.yaml.age > recovery.yaml
tar -xzf infra-repo.tar.gz

# 3. Deploy infrastructure
cd layer1-core-vm
tofu init && tofu apply
```

See **[Recovery](recovery.md)** for complete details.

---

## Architecture Overview

The platform is organized into modular layers:

**Infrastructure Layers:**
- **Layer 1:** Core VM provisioning (OpenTofu/Terraform)
- **Layer 2:** Core services (Docker Compose - Gitea, Vaultwarden, MinIO)
- **Layer 3:** Cloud infrastructure (Networks, storage, compute)
- **Layer 4:** Application layer (Kubernetes/Nomad workloads)

See **[Architecture](architecture.md)** for detailed design.

---

## Support & Contributing

- **Issues:** Report bugs or request features in the repository issues
- **Questions:** Check [Troubleshooting](troubleshooting.md) first
- **Contributing:** This is a personal infrastructure project, but feel free to fork and adapt

---

## License

[Specify your license here]

---

## Next Steps

- **New users:** Read [Architecture](architecture.md), then follow the [Setup Guide](setup.md)
- **Setting up recovery:** See [Recovery](recovery.md) and [Security](security.md)
- **Deploying:** Check [Deployment](deployment.md) and [Configuration](configuration.md)
