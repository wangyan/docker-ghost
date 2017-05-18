#!/bin/bash
set -e

if [ "$APT_MIRRORS" = "aliyun" ];then
    sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
    npm  config set registry https://registry.npm.taobao.org
    yarn config set registry https://registry.npm.taobao.org
    GHOST_URL="http://filecdn.wangyan.org/node/ghost-latest.zip"
else
    GHOST_URL="https://ghost.org/zip/ghost-latest.zip"
fi

if [ ! -d "$GHOST_SOURCE/core" ];then
    wget -q -c -t 10 -T 120 $GHOST_URL && \
    unzip ghost-*.zip && rm -f ghost-*.zip && \
    npm install --production && \
    mkdir -p "$GHOST_CONTENT"
fi

baseDir="$GHOST_SOURCE/content"
for dir in "$baseDir"/* "$baseDir"/themes/*; do
	targetDir="$GHOST_CONTENT${dir#$baseDir}"
	mkdir -p "$targetDir"
	if [ -z "$(ls -A "$targetDir")" ]; then
		tar -c --one-file-system -C "$dir" . | tar xC "$targetDir"
	fi
done

if [ ! -e "$GHOST_CONTENT/config.js" ]; then
	sed -r '
		s/127\.0\.0\.1/0.0.0.0/g;
		s!path.join\(__dirname, (.)/content!path.join(process.env.GHOST_CONTENT, \1!g;
	' "$GHOST_SOURCE/config.example.js" > "$GHOST_CONTENT/config.js"
fi

ln -sf "$GHOST_CONTENT/config.js" "$GHOST_SOURCE/config.js"

echo "export NODE_ENV=production" >> ~/.profile
source ~/.profile
cd $GHOST_SOURCE
pm2 start index.js --name ghost

exec "$@"