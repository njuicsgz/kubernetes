FROM allen01:5000/paas/u14-ssh-jdk7-tomcat7

MAINTAINER PaaS/allen

ENV ZK_ADDRESS 172.30.50.26:2181
ENV MY_DIR /var/lib/tomcat7/webapps/ROOT/


WORKDIR $MY_DIR/
RUN rm -rf *
ADD /ROOT.war $MY_DIR/
RUN jar -xvf ROOT.war
RUN rm -f ROOT.war

RUN sed -i 's/^dubbo.registry.address/#dubbo.registry.address/g' WEB-INF/dubbo.properties
RUN echo "" >> WEB-INF/dubbo.properties
RUN echo "dubbo.registry.address=zookeeper://${ZK_ADDRESS}" >> WEB-INF/dubbo.properties

CMD service tomcat7 start; /usr/sbin/sshd -D;
