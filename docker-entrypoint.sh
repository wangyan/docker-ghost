#!/bin/bash
set -xe

if [ "$APT_MIRRORS" = "aliyun" ];then
    sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
    npm  config set registry https://registry.npm.taobao.org
    yarn config set registry https://registry.npm.taobao.org
fi

if [ "$MAIL" = "gmail" ];then
    ghost config --no-prompt \
        --url http://127.0.0.1:2368 \
        --port 2368 \
        --ip 0.0.0.0 \
        --db sqlite3 \
        --dbpath $GHOST_CONTENT/data/ghost.db \
        --mail SMTP \
        --mailuser noreply@wangyan.org \
        --mailpass NoReply123 \
        --mailhost smtp.gmail.com \
        --mailport 465 && \
    ghost config paths.contentPath  $GHOST_CONTENT && \
    ghost config mail.from noreply@wangyan.org && \
    ghost config mail.options.secureConnection true
fi

if [ "$MAIL" = "aliyun" ];then
    ghost config --no-prompt \
        --url http://127.0.0.1:2368 \
        --port 2368 \
        --ip 0.0.0.0 \
        --db sqlite3 \
        --dbpath $GHOST_CONTENT/data/ghost.db \
        --mail SMTP \
        --mailuser noreply@dm.mail.wangyan.org \
        --mailpass NoReply123 \
        --mailhost smtpdm.aliyun.com \
        --mailport 465 && \
    ghost config paths.contentPath  $GHOST_CONTENT && \
    ghost config mail.from noreply@dm.mail.wangyan.org && \
    ghost config mail.options.secureConnection true
fi

mv $GHOST_INSTALL/content $GHOST_INSTALL/content.orig && \
mkdir -p $GHOST_CONTENT

baseDir="$GHOST_INSTALL/content.orig"
for src in "$baseDir"/*/ "$baseDir"/themes/*; do
	src="${src%/}"
	target="$GHOST_CONTENT/${src#$baseDir/}"
	mkdir -p "$(dirname "$target")"
	if [ ! -e "$target" ]; then
		tar -cC "$(dirname "$src")" "$(basename "$src")" | tar -xC "$(dirname "$target")"
	fi
done

knex-migrator-migrate --init --mgpath "$GHOST_INSTALL/current"

pm2 start current/index.js --name ghost

exec "$@"