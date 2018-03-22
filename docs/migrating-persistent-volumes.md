# Migrating Persistent Volumes

To keep data persistent even after deleting a helm release or moving between clusters, set the persistent volume's reclaim policy to "Retain" in the EC2 dasboard. This will prevent the persistent volume from being deleted when the release is deleted.

To reuse this volume in a future installation, follow these steps:

1. If the volume did not come from Kubernetes (such as from a snapshot), make sure to add the tag `KubernetesCluster=opx.openswitch.net` where `opx.openswitch.net` is the name of the cluster.
2. Delete the persistent volume from Kubernetes. The underlying storage will not be deleted.
3. Substitiute the volume ID and other values below and apply the two files to add the volume and claim it.
4. If using a helm chart, set the existing claim to the name you use.

Here's an example PV and PVC for Aptly.

```bash
export TILLER_NAMESPACE=stg
cat <<EOF | kubectl -n $TILLER_NAMESPACE create -f-
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: ${TILLER_NAMESPACE}-aptly
spec:
  awsElasticBlockStore:
    fsType: "ext4"
    volumeID: "vol-XXXXXXXXXXXXXXXXX"
  storageClassName: gp2
  capacity:
    storage: 200Gi
  accessModes:
    - ReadWriteOnce
  claimRef:
    namespace: $TILLER_NAMESPACE
    name: aptly
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: aptly
spec:
  storageClassName: gp2
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200Gi
EOF
```

