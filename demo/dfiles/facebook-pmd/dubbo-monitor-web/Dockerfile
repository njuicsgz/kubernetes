FROM allen01:5000/paas/u14-ssh-jdk7-tomcat7

MAINTAINER PaaS/allen

ENV ZK_ADDRESS 172.30.50.26:2181
ENV TOMCAT_DIR /var/lib/tomcat7
ENV TARGET_DIR /dianyi/app/walle/tomcat7/webapps

WORKDIR $TARGET_DIR/ROOT/
ADD /ROOT.war $TARGET_DIR/ROOT/
RUN jar -xvf ROOT.war
RUN rm -f ROOT.war

WORKDIR $TOMCAT_DIR/
RUN rm -rf webapps
RUN ln -s $TARGET_DIR webapps

WORKDIR $TARGET_DIR/ROOT
RUN sed -i 's/^dubbo.registry.address/#dubbo.registry.address/g' WEB-INF/dubbo.properties
RUN echo "" >> WEB-INF/dubbo.properties
RUN echo "dubbo.registry.address=zookeeper://${ZK_ADDRESS}" >> WEB-INF/dubbo.properties

CMD service tomcat7 start; /usr/sbin/sshd -D;
