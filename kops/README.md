# Cluster Deployment

## Operator State

Kops stores state in s3. Let's automate that.

```bash
export TF_VAR_aws_access_key_id=XXXXXXXXXXXXXXXXXXXX
export TF_VAR_aws_secret_access_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export TF_VAR_aws_bucket="opx-openswitch-net-kops-state-store"

### IMPORTANT for initial deployment###
# Comment out the terraform backend section in terraform/terraform.tf so that
# the configuration bucket can be created first.
### IMPORTANT for initial deployment###
(cd terraform; terraform init;)
(cd terraform; terraform apply;)

# Now uncomment that backend section, and rerun init to move state into s3
(cd terraform; terraform init;)
```

## Deploy Cluster

Now that our Kops infrastructure is in place, we can deploy the cluster. Make sure to customize the values below to your liking.

```bash
## set cluster variables
export NAME=opx.openswitch.net
export NODE_SIZE=m4.xlarge
export MASTER_SIZE=m4.large
export ZONES="us-west-2a"
export AWS_ACCESS_KEY_ID=$(cd terraform; terraform output -json | jq -r .access_key_id.value)
export AWS_SECRET_ACCESS_KEY=$(cd terraform; terraform output -json | jq -r .secret_access_key.value)
export KOPS_STATE_STORE=s3://$(cd terraform; terraform output -json | jq -r .aws_bucket.value)

kops create cluster \
  --node-count 2 \
  --zones $ZONES \
  --node-size $NODE_SIZE \
  --master-size $MASTER_SIZE \
  --master-zones $ZONES \
  --networking canal \
  --name $NAME

## We can make some adjustments here for scaling/price/os.
kops edit ig nodes --name $NAME
# Change min/max size to desired
# Add 'maxPrice: "0.08"' under machineType (adjust for instance size)
# Change jessie to stretch

# launch cluster
kops update cluster $NAME --yes

# validate cluster
kops validate cluster $NAME
```

Once validated, we can make an admin account for ourselves and a ClusterRole.

```bash
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $USER
  namespace: kube-system
EOF

cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $USER
subjects:
- kind: ServiceAccount
  name: $USER
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
EOF

# Get token for logging in
TOKEN="$(kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep $USER | awk '{print $1}') | grep token: | awk '{print $2}')"
```

## Initial Services

We can install some basic services now.

### Helm

Helm gives us the ability to install prepackaged k8s applications (charts) onto our cluster. We use charts for all deployments.

```bash
kubectl create serviceaccount tiller --namespace kube-system
cat <<EOF | kubectl create -f -
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: tiller-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ""
EOF
helm init --service-account tiller
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

### Dashboard with Metrics

This dashboard, for cluster administrators, can be used to manage and monitor every aspect of the cluster. All information in the dashboard can also be found using the `kubectl` command.

```bash
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.8.1.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.7.0.yaml
```

To access the dashboard, start a proxy and use your login token.

```bash
# start the proxy
kubectl proxy

# use $TOKEN to log in
```

Now the [dashboard](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/) can be accessed.

### Ingress with LetsEncrypt

These charts in tandem handle all external traffic into the cluster. Since only ports 443 and 80 are allowed by default, an example custom rule is shown.

```bash
helm install stable/nginx-ingress \
  --name nginx-ingress \
  --namespace default \
  --set rbac.create=true \
  --set rbac.serviceAccountName=ingress-nginx \
  --set controller.stats.enabled=true \
  --set controller.metrics.enabled=true \
  --set tcp.29418="gerrit/gerrit:29418"
helm install stable/kube-lego \
  --name kube-lego \
  --namespace default \
  -f kube-lego.yaml
```

After the load balancer has been deployed, the EXTERNAL-IP can be retrieved.

```bash
kubectl -n default get services -o wide -w nginx-ingress-controller
```

Set DNS records to point to this load balancer.

