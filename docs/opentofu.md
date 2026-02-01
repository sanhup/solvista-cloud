# Infra Setup using OpenTofu
The Hetzner env is setup using opentofu. You don't need to, you can also manually create a VM in hetzner.

### Open Tofu Install
On mac you can install it:
```bash
brew install opentofu
```

On debian/ubuntu you can lookup the latest version in github and download. Example for 1.10.6.
```bash
wget https://github.com/opentofu/opentofu/releases/download/v1.10.6/tofu_1.10.6_amd64.deb
sudo apt install ./tofu_1.10.6_amd64.deb
```

### S3 for tfstate
The state will be stored in a s3 bucket. Create it in Hetzner.

bucket name: solvista-dev-tfstate
region: fsn1 (falkenstein)

This will give the url: fsn1.your-objectstorage.com

Next you will need to create credentials for this bucket in Hetzner (go to security -> s3 credentials). Store them safely, they will only be visible once.

### Init Tofu (first time)
```bash
export AWS_ACCESS_KEY_ID="your-hetzner-access-key"
export AWS_SECRET_ACCESS_KEY="your-hetzner-secret-key"
tofu init
```

### Run Tofu
This wil initialize open tofu. When you are ready, you can apply the changes against your cloud and store outputs in a json.

```bash
cd iac
export AWS_ACCESS_KEY_ID="your-hetzner-access-key"
export AWS_SECRET_ACCESS_KEY="your-hetzner-secret-key"
tofu plan
tofu apply -json > output.json
```

## VM Access
This assumes the VM is already created using opentofu and up and running.

Lookup the ip address in ./iac/output.json

```bash
cd .
ssh -i ./ssh/solvista_id_rsa root@157.90.154.103
```

