# You can create the resources like this:

# One time
```bash
cd ./environments/<env-name>/iac

# one time:
tofu init
# or
tofu init --upgrade
```



```bash
cd ./environments/<env-name>/iac
tofu apply
tofu output -json > outputs.json
```