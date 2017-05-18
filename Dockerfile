FROM phusion/baseimage:0.9.21
MAINTAINER WangYan <i@wangyan.org>

# Setup Nginx
RUN set -xe && \
    apt-get update && \
    apt-get install -y curl wget unzip git ca-certificates --no-install-recommends && \
    curl -O "http://nginx.org/keys/nginx_signing.key" && \
    apt-key add nginx_signing.key && \
    rm -f nginx_signing.key && \
    echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
            ca-certificates \
            nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \

    # Nginx config
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak && \
    mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak && \
    mkdir -p /etc/nginx/sites-enabled /var/www/html && \

    # Nginx Runit
    mkdir -p /etc/service/nginx && \
    echo '#!/bin/sh' >> /etc/service/nginx/run && \
    echo 'exec 2>&1' >> /etc/service/nginx/run && \
    echo 'exec nginx -g "daemon off;"' >> /etc/service/nginx/run && \
    chmod +x /etc/service/nginx/run

    COPY nginx/nginx.conf /etc/nginx/nginx.conf
    COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Setup Node
ENV NODE_VERSION 6.10.3
RUN set -xe && \
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" && \
    tar -zxf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
    rm -f node-v$NODE_VERSION-linux-x64.tar.gz && \
    npm install -g yarn pm2 && \
    npm cache clean && rm -rf /tmp/npm*

# Setup Ghost
ENV GHOST_SOURCE /var/lib/ghost
ENV GHOST_CONTENT /opt/ghost

WORKDIR $GHOST_SOURCE
VOLUME $GHOST_CONTENT

COPY ghost-upgrade.sh /usr/bin/ghost-upgrade
COPY entrypoint.sh /entrypoint.sh
RUN  chmod +x /entrypoint.sh /usr/bin/ghost-upgrade

EXPOSE 2368 80 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/sbin/my_init"]