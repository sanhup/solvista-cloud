## Solvista Cloud
This is the IaC configuration.

Caution. Don't deploy from templates, use the env specific folders.

## k8s
Will use k8s for most apps.

## Envs vs Template
There is a template folder with the generic steps for creating a Hetzner Env. These are copied to each env before creating the environment.

The installation steps are in the specific enviroment.

## Self Hosted
Everything will be self hosted. Even git, password managers etc.

But because of this we also need backups.
- github for this repo
- s3 storage for backups