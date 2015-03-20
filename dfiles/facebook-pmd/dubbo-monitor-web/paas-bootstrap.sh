#! /bin/bash
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

ENV TARGET_DIR /dianyi/app/walle/tomcat7/webapps

cd $TARGET_DIR/ROOT
sed -i 's/^dubbo.registry.address/#dubbo.registry.address/g' WEB-INF/dubbo.properties
echo "" >> WEB-INF/dubbo.properties
echo "dubbo.registry.address=zookeeper://${ZK_ADDRESS}" >> WEB-INF/dubbo.properties

# start services
service tomcat7 start
/usr/sbin/sshd -D
