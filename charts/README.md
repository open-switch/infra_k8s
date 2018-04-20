# Helm Charts

We use a combination of public charts and charts we've developed ourselves. Until the need arises, our charts are developed in this repository. If any charts use custom Dockerfiles, look in chart/docker for more information.

## Our Charts

- [Aptly](stable/aptly/)

## Deployments

Here's what's currently deployed, unless otherwise noted. We install one helm instance per namespace, except we combine default/kube-system. Make sure to set the `tiller-namespace` and the `namespace`. Value files found in `values/` contain a base configuration, used in our staging namespace. Apply the production file in `values/prod/` after the base file for a staging deployment.

### Aptly

You'll need a private GPG key to sign the repository.

```bash
export TILLER_NAMESPACE=stg
helm install --namespace $TILLER_NAMESPACE \
  --name aptly \
  stable/aptly \
  -f values/aptly.yaml \
  -f values/prod/aptly.yaml \
  --set aptly.key="$(cat aptly.key)"
```

### Concourse

```bash
export TILLER_NAMESPACE=stg
helm install --namespace $TILLER_NAMESPACE \
  --name concourse \
  stable/concourse \
  -f values/concourse.yaml \
  --set secrets.githubAuthClientId=XXXXXXXXXXXXXXXXXXXX \
  --set secrets.githubAuthClientSecret=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Now you can log in.

```bash
fly -t stg login -n main -c https://concourse.opx.openswitch.net
```

If `rbac.create` is false, explicit permission must be granted for secrets access.

```bash
kubectl create rolebinding prod-concourse-secrets \
  --clusterrole=view \
  --serviceaccount=prod:default \
  --namespace=concourse-prod-main
```

#### Important

Since Concourse uses a StatefulSet for the workers, PVCs need to be deleted manually.

```bash
export TILLER_NAMESPACE=stg
helm del --purge stg-concourse
kubectl -n $TILLER_NAMESPACE delete pvc -l app=concourse-worker
```

# Prometheus Monitoring

```bash
export TILLER_NAMESPACE=monitoring

kubectl create namespace $TILLER_NAMESPACE
cat <<EOF | kubectl create -f-
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: ${TILLER_NAMESPACE}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller-${TILLER_NAMESPACE}
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: ${TILLER_NAMESPACE}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
EOF

helm init --service-account tiller

helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
helm install coreos/prometheus-operator --name prometheus-operator --namespace monitoring
helm install coreos/kube-prometheus --name kube-prometheus --namespace monitoring \
  -f values/prometheus.yaml \
  -f values/prod/prometheus.yaml \
  --set grafana.adminPassword="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```
