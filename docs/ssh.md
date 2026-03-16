# Setup Guide

This guide covers the **initial setup** of your Solvista Cloud with recovery system.

At this point, we only have a computer with linux (or MacOS / WSL (windows)) and access to this repository.

⚠️ This repository will be part of your recovery bundle later!
⚠️ You can use podman or docker. Both will work.

## Setup SSH
For both VM setup and deployment you need a set of ssh keys.

This key is required when creating the vm machine (opentofu). It is also required when you later want to connect to the server.

You can create it like this:
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

By default, RSA keys are usually:
```bash
~/.ssh/id_rsa        # private key (keep secret!)
~/.ssh/id_rsa.pub    # public key (can share)
```

You can rename these, for example I use solvista_id_rsa.

In opentofu, you set the ssh_public_key variable pointed to this file. This way, on creation, your VM already is prepared for ssh access.

## Connect to the Server

```bash
ssh -i ssh/solvista_id_rsa root@157.90.154.103
```

## Copy files to the Server

```bash
scp -i ssh/solvista_id_rsa <local-file> root@157.90.154.103:<remote-path>
```

