FROM xa.repo.ndp.com:5000/paas/u14-ssh-jdk7-tomcat7

MAINTAINER PaaS/allen

ENV TOMCAT_DIR /var/lib/tomcat7/webapps
ENV TARGET_DIR /dianyi/app/walle/tomcat7/webapps/config


WORKDIR $TARGET_DIR/
ADD /config.war $TARGET_DIR/
RUN jar -xvf config.war
RUN rm -f config.war

WORKDIR $TOMCAT_DIR/
RUN ln -s $TARGET_DIR config

ADD /paas-bootstrap.sh /
CMD bash /paas-bootstrap.sh
