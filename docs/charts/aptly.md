# Aptly Server

Our first in-house helm chart! This chart runs our
[debian repository](http://deb.openswitch.net).

Run these commands from the repository root.

## Deploy

```bash
helm install --name aptly \
  --namespace deb \
  -f charts/aptly/values.yaml \
  charts/aptly
```

## Tear Down

```bash
helm del --purge aptly
```

