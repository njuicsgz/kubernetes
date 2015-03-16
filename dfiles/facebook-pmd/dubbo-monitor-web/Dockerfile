FROM allen01:5000/paas/u14-ssh-jdk7-tomcat7

MAINTAINER PaaS/allen

ENV ZK_ADDRESS 172.30.50.26:2181
ENV TOMCAT_DIR /var/lib/tomcat7
ENV TARGET_DIR /dianyi/app/walle/tomcat7/webapps

WORKDIR $TARGET_DIR/ROOT/
ADD /ROOT.war $TARGET_DIR/ROOT/
ADD /paas-bootstrap.sh $TARGET_DIR/
RUN jar -xvf ROOT.war
RUN rm -f ROOT.war

WORKDIR $TOMCAT_DIR/
RUN rm -rf webapps
RUN ln -s $TARGET_DIR webapps


CMD bash $TARGET_DIR/paas-bootstrap.sh
