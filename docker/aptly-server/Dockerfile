FROM nginx:mainline
LABEL maintainer="ops-dev@lists.openswitch.net"

RUN apt-get update && apt-get install -y gnupg \
 && echo "deb http://repo.aptly.info/ squeeze main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keys.gnupg.net --recv-keys 9E3E53F19C7DE460

RUN apt-get update && apt-get install -y \
    aptly \
    curl \
    graphviz \
    gnupg \
    vim \
    wget \
 && rm -rf /var/lib/apt/lists/*

COPY aptly.conf /etc/aptly.conf
COPY bash_profile /root/.bash_profile
COPY index.html /usr/share/nginx/index.html
COPY init.sh /init

# we copy then link into /usr/share/nginx/html/ to save the file in case a
# persistent volume is mounted at /usr/share/nginx/html/
RUN ln -sf /usr/share/nginx/index.html /usr/share/nginx/html/index.html

EXPOSE 80
EXPOSE 8080

CMD ["/init"]
