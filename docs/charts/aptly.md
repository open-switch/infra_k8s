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

## Helpful Commands

Fetch all Bintray packages.
```bash
wget -e robots=off -A deb -m -p -E -k -K -np https://dell-networking.bintray.com/opx-apt/pool
wget -e robots=off -A deb,dsc,gz,build -m -p -E -k -K -np https://dl.bintray.com/open-switch/opx-apt/pool
```

