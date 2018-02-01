# Tools

Most of these are available through your package manager. Those that aren't are
single binaries which can be downloaded directly.

- [aptly](https://aptly.info)
- [fly](https://concourse.ci/fly-cli.html) - for concourse
- [helm](https://helm.sh/)
- [kops](https://github.com/kubernetes/kops)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [terraform](https://www.terraform.io/)
- [vault](https://www.vaultproject.io/)

## Packages to Install

The following tools do not need to be installed by your package manager.

- Aptly: `kubectl exec` into the `aptly-server` pod for direct control
- Fly: download directly from our [Concourse
  instance](https://concourse.k8s.openswitch.net/)

### macOS

We use [homebrew](https://brew.sh).

```bash
brew install \
  kops \
  kubectl \
  kubernetes-helm \
  terraform \
  vault \
```

### Arch Linux

We use [trizen](https://github.com/trizen/trizen).

```bash
trizen -S \
  kops-bin \
  kubectl-bin \
  kubernetes-helm-bin \
  terraform \
  vault-bin
```

