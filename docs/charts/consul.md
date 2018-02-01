# Consul

Consul is the backend for our secret manager, Vault.

Run these commands from the repository root.

## Deploy

```bash
# deploy
helm install --name consul \
  --namespace concourse \
  -f charts/consul.yml \
  stable/consul

# validate
helm test consul
```

## Tear down

```bash
helm del --purge consul
kubectl --namespace concourse delete pvc -l component=consul-consul
```

