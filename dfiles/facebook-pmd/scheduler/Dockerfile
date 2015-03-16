FROM allen01:5000/u14-ssh-jdk1.7

MAINTAINER PaaS/allen

ENV TAR_FILE scheduler_0.1-SNAPSHOT.tar.gz 
ENV MY_DIR /dianyi/app/walle/scheduler

ADD /$TAR_FILE $MY_DIR/

WORKDIR $MY_DIR/bin
RUN chmod +x *.sh
RUN sed -i 's/-Xms2g/-Xms512m/g' start.sh
RUN echo 'while true; do sleep 10; done' >> start.sh

CMD /usr/sbin/sshd; ./start.sh
