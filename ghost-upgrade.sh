#!/bin/bash
set -x

if [ "$APT_MIRRORS" = "aliyun" ];then
    wget -c -t 10 -T 120 http://filecdn.wangyan.org/node/ghost-latest.zip
else
    wget -c -t 10 -T 120 https://ghost.org/zip/ghost-latest.zip
fi

rm -rf /tmp/ghost-temp
cd /var/lib/ghost/
pm2 kill
unzip ghost-latest.zip -d /tmp/ghost-temp
rm -rf /var/lib/ghost/core
cp -R /tmp/ghost-temp/core /var/lib/ghost/
cp -R /tmp/ghost-temp/index.js /var/lib/ghost/
cp -R /tmp/ghost-temp/*.json /var/lib/ghost/
rm -rf /opt/ghost/themes/casper
cp -R /tmp/ghost-temp/content/themes/casper /opt/ghost/themes
npm install --production
pm2 start index.js --name ghost