## About
This is the solvista-dev setup. 

## VM
This assumes the VM is already created using opentofu and up and running.

Lookup the ip address in ./iac/output.json

```bash
cd /environments/solvista-dev
ssh -i ./ssh/solvista_id_rsa root@157.90.154.103
```

# First Time Setup

## Install podman

```bash
apt-get update
apt-get install -y podman podman-compose
```

## Setup Deployment
In your vm, create a key for deployment. Inspect the key when created.

```bash
ssh-keygen -t ed25519 -C "vm-deploy"
cat ~/.ssh/id_ed25519.pub
```

Add the key to the github repo's that you want to deploy (in your online account).

## Deploy your app

At this moment deployment of your app is very basic.

### First time deployment

```bash
ssh -i ./ssh/solvista_id_rsa root@157.90.154.103
cd ./apps
mkdir my-app
git init
git rempte add origin 
git pull origin main
```

At this moment, you might need to create a .env file (there will be a .env.example to show the required settings)

Now it is time to start your app
```bash
podman compose up -d
```

