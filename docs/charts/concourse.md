# Concourse

Our CD service.

Run these commands from the repository root.

## Deploy

```bash
mkdir -p charts/concourse-keys
ssh-keygen -t rsa -f charts/concourse-keys/host_key -N '' -C concourse
ssh-keygen -t rsa -f charts/concourse-keys/session_signing_key -N '' -C concourse
ssh-keygen -t rsa -f charts/concourse-keys/worker_key -N '' -C concourse

cat << EOF > concourse.credentialManager.yml
concourse:
  githubAuthClientId: XXXXXXXXXXXXXXXXXXXX
  githubAuthClientSecret: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
credentialManager:
  vault:
    clientToken: $(jq -r .auth.client_token vault.concourse.token)
EOF

helm install --name concourse \
  --namespace concourse \
  -f charts/concourse.yml \
  -f concourse.credentialManager.yml \
  --set concourse.password="$CONCOURSE_UI_PASSWORD" \
  --set concourse.hostKey="$(cat charts/concourse-keys/host_key)" \
  --set concourse.hostKeyPub="$(cat charts/concourse-keys/host_key.pub)" \
  --set concourse.sessionSigningKey="$(cat charts/concourse-keys/session_signing_key)" \
  --set concourse.workerKey="$(cat charts/concourse-keys/worker_key)" \
  --set concourse.workerKeyPub="$(cat charts/concourse-keys/worker_key.pub)" \
  stable/concourse
```

After a short wait, try [concourse.k8s.openswitch.net](https://concourse.k8s.openswitch.net).

## Tear Down

```bash
helm del --purge concourse
kubectl --namespace concourse delete pvc -l app=concourse-worker
```

