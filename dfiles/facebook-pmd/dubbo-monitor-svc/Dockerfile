FROM allen01:5000/u14-ssh-jdk1.7

MAINTAINER PaaS/allen

#ENV ZK_ADDRESS 172.30.50.26:2181
ENV MY_DIR /dianyi/app/walle
ENV TAR_DIR_NAME dubbo-monitor-svc
ENV TAR_FILE dubbo-monitor-simple-2.8.3-assembly.tar.gz

WORKDIR $MY_DIR/
ADD /$TAR_FILE $MY_DIR/
RUN mv dubbo-monitor-simple-2.8.3 $TAR_DIR_NAME

ADD /paas-bootstrap.sh $MY_DIR/$TAR_DIR_NAME/bin/

WORKDIR $MY_DIR/$TAR_DIR_NAME/bin
RUN chmod +x *.sh
RUN sed -i 's/-Xms2g/-Xms512m/g' start.sh

EXPOSE 8080 7070

CMD ./paas-bootstrap.sh 
