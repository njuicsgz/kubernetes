#! /bin/bash
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

TARGET_DIR=/etc/nginx/conf.d/

# need this environment when run container
# REGISTRY_ADDR=172.21.0.50:25000

cd $TARGET_DIR || exit 1
sed -i "s/localhost:5000/${REGISTRY_ADDR}/g" docker-registry.conf 

# start services and as a daemon
service nginx start
/usr/sbin/sshd -D
