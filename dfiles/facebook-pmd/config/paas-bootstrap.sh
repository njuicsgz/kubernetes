#! /bin/bash
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

TARGET_DIR=/dianyi/app/walle/tomcat7/webapps/config/WEB-INF/classes
TAR_FILE=config.properties

# need those ENV when running this image
# 	ZK_ADDRESS, database_url, database_username, database_password

cd $TARGET_DIR || exit 1
sed -i 's/^database.url/#database.url/g' $TAR_FILE
sed -i 's/^database.username/#database.username/g' $TAR_FILE
sed -i 's/^database.password/#database.password/g' $TAR_FILE
echo "" >> WEB-INF/dubbo.properties
echo "dubbo.registry.address=zookeeper://${ZK_ADDRESS}" >> $TAR_FILE
echo "database.url=${database_url}" >> $TAR_FILE
echo "database.username=${database_username}" >> $TAR_FILE
echo "database.password=${database_password}" >> $TAR_FILE

# start services and as a daemon
/etc/init.d/tomcat7 start
/usr/sbin/sshd -D
