FROM phusion/baseimage:0.9.21
LABEL authors="WangYan <i@wangyan.org>"

# Setup Nginx
RUN set -xe && \
    apt-get update && \
    apt-get install -y curl wget unzip git net-tools ca-certificates --no-install-recommends && \
    curl -O "http://nginx.org/keys/nginx_signing.key" && \
    apt-key add nginx_signing.key && \
    rm -f nginx_signing.key && \
    echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y ca-certificates nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak && \
    mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak && \
    mkdir -p /var/www/html

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Nginx Runit
RUN mkdir -p /etc/service/nginx && \
    echo '#!/bin/sh' >> /etc/service/nginx/run && \
    echo 'exec 2>&1' >> /etc/service/nginx/run && \
    echo 'exec nginx -g "daemon off;"' >> /etc/service/nginx/run && \
    chmod +x /etc/service/nginx/run

# Setup Node
ENV NODE_VERSION 6.11.4
RUN set -xe && \
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" && \
    tar -zxf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
    rm -f node-v$NODE_VERSION-linux-x64.tar.gz && \
    npm i -g yarn pm2 knex-migrator && \
    yarn global add yarn && \
    npm cache clean && rm -rf /tmp/npm*

# Setup Ghost
ENV NPM_CONFIG_LOGLEVEL warn
ENV NODE_ENV production
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /opt/ghost

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT

RUN npm i -g ghost-cli && \
    ghost install --db sqlite3 --no-setup --no-stack --no-prompt --dir $GHOST_INSTALL && \
    ghost config --url http://127.0.0.1:2368 --port 2368 --ip 0.0.0.0 --db sqlite3 --dbpath $GHOST_CONTENT/data/ghost.db && \
    ghost config paths.contentPath  $GHOST_CONTENT

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN  chmod +x /docker-entrypoint.sh

EXPOSE 2368 80 443
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/sbin/my_init"]