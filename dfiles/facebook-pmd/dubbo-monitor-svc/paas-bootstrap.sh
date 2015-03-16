#!/bin/bash

export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

MY_DIR=/dianyi/app/walle/dubbo-monitor-svc

cd $MY_DIR/conf
sed -i 's/^dubbo.registry.address/#dubbo.registry.address/g' dubbo.properties
echo "" >> dubbo.properties
echo "dubbo.registry.address=zookeeper://${ZK_ADDRESS}" >> dubbo.properties

cd $MY_DIR/bin && sed -i 's/-Xms2g/-Xms512m/g' start.sh

#start service
/usr/sbin/sshd

cd $MY_DIR/bin && ./start.sh

# make as a daemon
while true; do sleep 100; done
