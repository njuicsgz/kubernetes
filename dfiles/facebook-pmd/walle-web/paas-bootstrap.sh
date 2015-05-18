#! /bin/bash
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

TARGET_DIR=/ndp/app

# need this environment when run container
# WALLE_WEB_CDN_VERSION=1.0.0_015

cd $TARGET_DIR || exit 1
mkdir -p $WALLE_WEB_CDN_VERSION
cp -r app $WALLE_WEB_CDN_VERSION/app
cp tmp_body.html $WALLE_WEB_CDN_VERSION/

# start services and as a daemon
service nginx start
/usr/sbin/sshd -D
