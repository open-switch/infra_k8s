# Cluster Deployment

We use `kops` for deploying our cluster. The following features/services/charts are used.

- three masters, one per az
- three nodes, one per az
- nodes use spot instances with spot termination handler
- tiller
- dashboard and heapster
- nginx-ingress controller with kube-lego

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

