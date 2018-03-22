# Aptly Helm Chart

[Aptly](https://aptly.info) is a Debian package repository manager.

## TL;DR;

```console
$ helm install stable/aptly
```

## Introduction

This chart bootstraps an [Aptly](https://aptly.info) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites Details

* Kubernetes 1.6 (for `pod affinity` support)
* PV support on underlying infrastructure (if persistence is required)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/aptly
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes nearly all the Kubernetes components associated with the chart and deletes the release.

