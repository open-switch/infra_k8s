# Helm and Namespaces

For Helm, releases transcend namespaces. We don't like that. So we install a Tiller pod in each namespace we use (except for default and kube-system, of which we only use the default Tiller namespace). We'll also need a role for each namespace to limit Tiller's reach. Here's how to set that up.

```bash
export TILLER_NAMESPACE=stg
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
```

Now we can create the Tiller pod.

```bash
export TILLER_NAMESPACE=stg
helm init --service-account tiller
```

Make sure to export `TILLER_NAMESPACE` when using helm now.

