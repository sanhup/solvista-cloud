## Setup Github Deployment
In your vm, create a key for github deployment. Inspect the key when created.

```bash
ssh-keygen -t ed25519 -C "hetzner-deploy"
cat ~/.ssh/id_ed25519.pub
```

Add the key github user account (in your online account). Don't use per repo, use your generic user ssh (else you need a new key for each repo)
