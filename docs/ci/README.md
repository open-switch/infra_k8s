# Concourse CI/CD

https://concourse.ci/

Concourse is a container-based CI/CD server. We build our own [generic CI/CD
docker image](https://hub.docker.com/r/opxhub/concourse/).

## Debian Pipeline

Our [debian pipeline](../../concourse/ci/debian.pipeline.yml) is a
parameterized pipline suitable for any OPX debian package. The `Makefile` is
used to fill parameters. Simply run `make opx-logging` to create/update the
`opx-logging` pipeline.

This pipeline runs on two triggers.

### New Commit Trigger

On every commit to the `master` branch, a pipeline instance is triggered. This
builds the package and publishes it to the unstable distribution on
[Bintray](https://bintray.com/open-switch/opx-apt). The package version is
amended with `+git$(date +%Y%m%d).$(git rev-parse --short HEAD)`.

### New Tag Trigger

On every `debian/*` tag to the `master` branch, a pipeline instance is
triggered. This builds the package and publishes it to the testing
distribution on [Bintray](https://bintray.com/open-switch/opx-apt).

## opx-build Pipeline

We have a second pipeline used for building and delivering our [package build
docker image](https://hub.docker.com/r/opxhub/build/). For every commit, an
image for each distribution is built and published.

