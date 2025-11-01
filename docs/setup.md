# Setup Guide

This guide covers the **initial setup** of your Solvista Cloud with recovery system. We'll create an encrypted recovery bundle and upload it to S3. Everything will be self-hosted.

At this point, we only have a computer with linux (or MacOS / WSL (windows)) and access to this repository.

⚠️ This repository will be part of your recovery bundle later!
⚠️ You can use podman or docker. Both will work.


## Simple Security Commands
We can use some simple security commands to generate random keys etc. For diceware you need a python venv
```bash
python3 -m venv venv
. ./venv/bin/activate
pip3 install diceware
```

Simple commands:
```bash
openssl rand -base64 32
openssl rand -hex 32
diceware -n 8
```
## Setup SSH
On your local machine you should have a ssh key. This key is used when creating the vm machine (opentofu)

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

## Connect using SSH

```bash
ssh -i ./ssh/solvista_id_rsa root@157.90.154.103
```