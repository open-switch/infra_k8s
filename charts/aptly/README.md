# Aptly Chart

Use Helm to deploy `aptly` in a kubernetes cluster. To run this chart you need to have a kubernetes cluster and helm installed and configured properly.

First, export your GPG key.

```bash
gpg --armor --export-secret-keys > aptly.key
```

This key will be used to sign the repository. Let's deploy the chart.

```bash
helm install \
  --name aptly \
  --namespace deb \
  -f values.yaml \
  --set aptly.key="$(cat aptly.key)" \
  .
```

Check NOTES.txt for helpful commands.

## Initial Worklog

```bash
# after copying the 2.0, 2.1, and 2.2 packages to /pkg in the pod...
cd /pkg

aptly repo create -comment="OpenSwitch jessie" -distribution=jessie -component=main opx-jessie
aptly repo add opx-jessie 2.0
aptly snapshot create 2.0 from repo opx-jessie
aptly publish snapshot -distribution=2.0 2.0 filesystem:public:

aptly repo add opx-jessie 2.1
aptly snapshot create 2.1 from repo opx-jessie
aptly publish snapshot -distribution=2.1 2.1 filesystem:public:
aptly publish snapshot -distribution=aloha 2.1 filesystem:public:

opx_jessie="jessie_$(date '+%F')"
aptly snapshot create "$opx_jessie" from repo opx-jessie
aptly publish snapshot -distribution=jessie "$opx_jessie" filesystem:public:

aptly repo create -comment="OpenSwitch unstable" -distribution=unstable -component=main opx-unstable
aptly repo create -comment="OpenSwitch testing" -distribution=testing -component=main opx-testing
aptly repo create -comment="OpenSwitch stable" -distribution=stable -component=main opx-stable

aptly repo add opx-unstable 2.2
aptly repo copy opx-unstable opx-testing Name
aptly repo copy opx-testing opx-stable Name

aptly publish repo opx-unstable filesystem:public:
aptly publish repo opx-testing filesystem:public:
aptly publish repo opx-stable filesystem:public:

aptly snapshot create 2.2 from repo opx-stable
aptly publish snapshot -distribution=2.2 2.2 filesystem:public:
```

To update:

```bash
aptly publish update unstable filesystem:public:
aptly publish update testing filesystem:public:
aptly publish update stable filesystem:public:
```
