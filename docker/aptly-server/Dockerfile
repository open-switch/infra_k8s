FROM nginx:mainline
LABEL maintainer="ops-dev@lists.openswitch.net"

RUN echo "deb http://repo.aptly.info/ squeeze main" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y gnupg \
 && apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460 \
 && apt-get update \
 && apt-get install -y aptly graphviz \
 && rm -rf /var/lib/apt/lists/*

COPY index.html /usr/share/nginx/index.html
RUN ln -sf /usr/share/nginx/index.html /usr/share/nginx/html/index.html
COPY aptly.conf /etc/aptly.conf
COPY init.sh /init

EXPOSE 80
EXPOSE 8080

CMD ["/init"]
