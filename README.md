# OpenSwitch Kubernetes Cluster

## Requirements

* AWS Account
* terraform
* kops
* kubectl
* helm
* vault
* fly

## Cluster Deployment

```bash
## set environment variables for terraform and create kops infrastructure
export TF_VAR_aws_access_key_id=XXXXXXXXXXXXXXXXXXXX
export TF_VAR_aws_secret_access_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
(cd terraform; terraform apply;)

## set cluster variables
export AWS_ACCESS_KEY_ID=$(cd terraform; terraform output -json | jq -r .access_key_id.value)
export AWS_SECRET_ACCESS_KEY=$(cd terraform; terraform output -json | jq -r .secret_access_key.value)
export KOPS_STATE_STORE=s3://$(cd terraform; terraform output -json | jq -r .aws_bucket.value)
export NAME=k8s.openswitch.net
export NODE_SIZE=m4.large
export MASTER_SIZE=m3.medium
export ZONES="us-west-2a,us-west-2b,us-west-2c"

## create cluster
kops create cluster \
  --node-count 3 \
  --zones $ZONES \
  --node-size $NODE_SIZE \
  --master-size $MASTER_SIZE \
  --master-zones $ZONES \
  $NAME

## configure spot price and maximum number of nodes
kops edit ig nodes --name $NAME

## launch cluster
kops update cluster $NAME --yes

## validate cluster
kops validate cluster $NAME

## launch initial services
# helm package manager
helm init
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/

# metrics and dashboard
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.8.1.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.7.0.yaml

# spot termination handler
helm install --name kube-spot-termination-notice-handler \
  --namespace kube-system \
  incubator/kube-spot-termination-notice-handler

# ingress controller and letsencrypt cert manager
helm install stable/nginx-ingress \
  --name nginx-ingress \
  --set controller.stats.enabled=true
helm install stable/kube-lego \
  --name kube-lego \
  -f charts/kube-lego.yml

# get load balancer dns name, then point dns records at it
kubectl --namespace default get services -o wide -w nginx-ingress-nginx-ingress-controller

# open dashboard
kops get secrets kube --type secret -oplaintext | xsel -b
kubectl proxy &
xdg-open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

Congratulations, you now have a k8s cluster with autoscaling spot instances, automatic tls and metrics.

## Concourse Deployment

```bash
# deploy consul and validate
helm install --name consul \
  --namespace concourse \
  -f charts/consul.yml \
  stable/consul
helm test consul

# deploy vault
helm install --name vault \
  --namespace concourse \
  -f charts/vault.yml \
  incubator/vault

# initialize vault
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

# launch vault ui
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
vault write secret/concourse-web-password value=9nkLOgLU0P1Zxfw3cunFIR4onCBF5N4HkmGwOFTIYJNKyjjNhF
export CONCOURSE_UI_PASSWORD="$(vault read -format=json secret/concourse-web-password | jq -r .data.value)"

# deploy concourse
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
helm del --purge concourse && \
kubectl --namespace concourse delete pvc -l app=concourse-worker && \
helm del --purge vault && \
helm del --purge consul && \
kubectl --namespace concourse delete pvc -l component=consul-consul
```
