# from opx-build/scripts/opx_build
debian_repos = \
  opx-logging \
  opx-common-utils \
  opx-cps \
  opx-base-model \
  opx-db-sql \
  opx-sai-api \
  opx-sai-vm \
  opx-nas-common \
  opx-nas-linux \
  opx-nas-ndi-api \
  opx-nas-ndi \
  opx-nas-acl \
  opx-nas-interface \
  opx-nas-l2 \
  opx-nas-l3 \
  opx-nas-qos \
  opx-nas-daemon \
  opx-platform-config \
  opx-sdi-sys \
  opx-pas \
  opx-tmpctl \
  opx-tools \
  opx-alarm

$(debian_repos):
	fly -t concourse set-pipeline -n -c ci/debian.pipeline.yml -p $@ -v repo=$@ -v dist=testing
	fly -t concourse unpause-pipeline -p $@
	fly -t concourse expose-pipeline -p $@

all: $(debian_repos)
