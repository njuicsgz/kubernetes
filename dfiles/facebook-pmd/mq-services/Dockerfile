FROM allen01:5000/u14-ssh-jdk1.7

MAINTAINER PaaS/allen

ENV ZK_ADDRESS 172.30.50.26:2181
ENV MY_DIR /dianyi/app/walle/mq-services

ADD /bin/ $MY_DIR/bin/
ADD /lib/ $MY_DIR/lib/

WORKDIR $MY_DIR/bin
RUN chmod +x *.sh
RUN sed -i 's/-Xms2g/-Xms512m/g' start.sh
RUN echo 'while true; do sleep 10; done' >> start.sh

CMD /usr/sbin/sshd; ./start.sh
