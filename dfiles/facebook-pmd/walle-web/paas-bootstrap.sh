#! /bin/bash
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

TARGET_DIR=/ndp/app/walle-web/app/js

# need this environment when run container
# WALLE_JAVA_ADDRESS=172.30.10.122:49999

cd $TARGET_DIR || exit 1
sed -i "s/172.0.0.1:9999/${WALLE_JAVA_ADDRESS}/g" *.js

# start services and as a daemon
service nginx start
/usr/sbin/sshd -D
