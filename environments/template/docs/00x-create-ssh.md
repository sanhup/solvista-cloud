# Setup SSH

Before start the ssh keys need to be created.

Remember, these are not in git, so you need to share between your devs.

```bash
cd ./environments/<env-name>/iac/ssh
ssh-keygen -t rsa -b 4096 -C "solvista" -f id_rsa
```