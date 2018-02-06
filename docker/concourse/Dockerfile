FROM opxhub/build
LABEL maintainer="ops-dev@lists.openswitch.net"

RUN apt-get update && apt-get install -y \
    curl \
    jq \
 && rm -rf /var/lib/apt/lists/*

Add https://github.com/concourse/concourse/releases/download/v3.8.0/fly_linux_amd64 /usr/bin/fly
RUN chmod +x /usr/bin/fly

RUN echo "deb http://repo.aptly.info/ squeeze main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460 \
 && apt-get update \
 && apt-get install -y aptly

RUN pip install awscli

COPY aptly.conf /etc/aptly.conf

WORKDIR /mnt
CMD [ "bash" ]
