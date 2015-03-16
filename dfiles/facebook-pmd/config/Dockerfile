FROM allen01:5000/paas/u14-ssh-jdk7-tomcat7

MAINTAINER PaaS/allen

#ENV ZK_ADDRESS 172.30.10.165:2181
ENV TOMCAT_DIR /var/lib/tomcat7/webapps
ENV TARGET_DIR /dianyi/app/walle/tomcat7/webapps/config

#RUN echo "export ZK_ADDRESS=${ZK_ADDRESS}" >> /etc/profile

WORKDIR $TARGET_DIR/
ADD /config.war $TARGET_DIR/
RUN jar -xvf config.war
RUN rm -f config.war

WORKDIR $TOMCAT_DIR/
RUN ln -s $TARGET_DIR config


CMD /etc/init.d/tomcat7 start; /usr/sbin/sshd -D;
