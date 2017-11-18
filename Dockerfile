FROM phusion/baseimage:0.9.22
LABEL authors="WangYan <i@wangyan.org>"

# Setup Nginx
RUN set -xe; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y curl wget unzip git net-tools ca-certificates --no-install-recommends; \
    curl -O "http://nginx.org/keys/nginx_signing.key"; \
    apt-key add nginx_signing.key; \
    rm -f nginx_signing.key; \
    echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list; \
    echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list; \
    apt-get update; \
    apt-get install --no-install-recommends --no-install-suggests -y ca-certificates nginx; \
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak; \
    mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Nginx Runit
RUN mkdir -p /etc/service/nginx; \
    echo '#!/bin/sh' >> /etc/service/nginx/run; \
    echo 'exec 2>&1' >> /etc/service/nginx/run; \
    echo 'exec nginx -g "daemon off;"' >> /etc/service/nginx/run; \
    chmod +x /etc/service/nginx/run

# Setup Node
ENV NODE_VERSION 8.9.1
RUN set -xe; \
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz"; \
    tar -zxf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1; \
    rm -f "node-v$NODE_VERSION-linux-x64.tar.gz"; \
    node -v 

# Setup Yarn
RUN set -xe; \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list; \
    apt-get update; apt-get -y install yarn --no-install-recommends --no-install-suggests; \
    yarn -v

# Setup Ghost
ENV NODE_ENV production
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content

ENV GHOST_CLI_VERSION 1.3.0
RUN yarn global add "ghost-cli@$GHOST_CLI_VERSION"

RUN set -xe \
    mkdir -p "$GHOST_INSTALL"; \
    ghost install --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"; \
	cd "$GHOST_INSTALL"; \
    ghost config --ip 0.0.0.0 --port 2368 --no-prompt --db sqlite3 --url http://127.0.0.1:2368 --dbpath "$GHOST_CONTENT/data/ghost.db"; \
	ghost config paths.contentPath "$GHOST_CONTENT"; \
    ln -s config.production.json "$GHOST_INSTALL/config.development.json"; \
	readlink -f "$GHOST_INSTALL/config.development.json"; \
    mv "$GHOST_CONTENT" "$GHOST_INSTALL/content.orig"; \
	mkdir -p "$GHOST_CONTENT"; \
    \
    "$GHOST_INSTALL/current/node_modules/knex-migrator/bin/knex-migrator" --version
    ENV PATH $PATH:$GHOST_INSTALL/current/node_modules/knex-migrator/bin

RUN set -eux; \
    cd "$GHOST_INSTALL/current"; \
    sqlite3Version="$(npm view . optionalDependencies.sqlite3)"; \
    apt-get install -y --no-install-recommends python make gcc g++ libc-dev; \
    yarn global add pm2 node-pre-gyp; \
    yarn add "sqlite3@$sqlite3Version" --build-from-source; \
    npm cache clean --force && rm -rf /tmp/npm*; \
    yarn cache clean --force && rm -rf /tmp/yarn*; \
    apt-get purge -y --auto-remove; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN  chmod +x /docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/sbin/my_init"]