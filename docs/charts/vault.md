# Vault

Vault acts as the secret manager for Concourse.

Run these commands from the repository root.

## Deploy

```bash
# deploy
helm install --name vault \
  --namespace concourse \
  -f charts/vault.yml \
  incubator/vault

# initialize
kubectl --namespace concourse port-forward $(kubectl get pods --namespace concourse -l "app=vault" -o jsonpath="{.items[0].metadata.name}") 8200 &
export VAULT_ADDR=http://127.0.0.1:8200
vault status
vault init | tee vault.root.token
chmod 0600 vault.root.token
for k in $(grep 'Unseal Key' vault.root.token | head -3 | awk '{print $4}'); do vault unseal $k; done
echo "$(grep 'Initial Root Token' vault.root.token | awk '{print $4}')" | vault auth -

# enable github auth for vault
# https://www.vaultproject.io/docs/auth/github.html#generate-a-github-personal-access-token
vault auth-enable github
vault write auth/github/config organization=open-switch
vault policy-write github charts/vault-github-policy.hcl
vault write auth/github/map/teams/concourse value=github

# deploy vault ui
git clone https://github.com/djenriquez/vault-ui
helm install --name vault-ui \
  --namespace concourse \
  -f charts/vault-ui.yml \
  vault-ui/charts/vault-ui/kubernetes/chart/vault-ui
rm -rf vault-ui

# add concourse mount to vault
vault mount -path=/concourse -description="Secrets for concourse pipelines" generic
vault policy-write policy-concourse charts/vault-concourse-policy.hcl
vault token-create --policy=policy-concourse -period="600h" -format=json | tee vault.concourse.token
chmod 0600 vault.concourse.token

# create web password for default concourse user and write to vault
vault write secret/concourse-web-password value=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export CONCOURSE_UI_PASSWORD="$(vault read -format=json secret/concourse-web-password | jq -r .data.value)"
```

## Tear Down

```bash
helm del --purge vault
```

