# Docker Images

This directory contains docker images used by the OpenSwitch Kubernetes cluster.

## Aptly Server

Aptly requires a GPG key for signing. It is not Aptly's job to create this key. Provide it via the `APTLY_KEY` environment variable.

You can export the key like this:

```bash
gpg --export-secret-keys --armor > key
```
