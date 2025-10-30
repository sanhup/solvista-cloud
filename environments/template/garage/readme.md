
Run docker compose to setup.
```bash
podman exec garage /garage status
```
For our test deployment, we are have only one node with zone named dc1 and a capacity of 1G, though the capacity is ignored for a single node deployment and can be changed later when adding new nodes.
```bash
podman exec garage /garage layout assign -z dc1 -c 1G <node_id>
```
where <node_id> corresponds to the identifier of the node shown by garage status (first column). You can enter simply a prefix of that identifier. For instance here you could write just garage layout assign -z dc1 -c 1G 563e.

Example:
```bash
podman exec garage /garage layout assign -z dc1 -c 1G 4e1ba2ba2f5cd25e
podman exec garage /garage layout apply --version 1

podman exec garage /garage bucket create recovery-bucket
podman exec garage /garage bucket list
podman exec garage /garage bucket info recovery-bucket

podman exec garage /garage key create recovery-api-key

## id: GK21225d83fe2e03c261de9c9a
## name: recovery-api-key
## secret: a5d055c11a4ea2788891e297e4976a563361cc326beef8e58906fde9278c29ca

podman exec garage /garage key info recovery-api-key

podman exec garage /garage bucket allow --read --write --owner recovery-bucket --key recovery-api-key
podman exec garage /garage bucket info recovery-bucket
```


In order to connect filestash:
id / secret
region: garage
http://garage:3900

