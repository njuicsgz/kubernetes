FROM allen01:5000/u14-ssh-jdk1.7

MAINTAINER PaaS/allen

ENV ZK_ADDRESS 172.30.50.26:2181
ENV MY_DIR /dianyi/app/walle/rdb-services

ADD /bin/ $MY_DIR/bin/
ADD /lib/ $MY_DIR/lib/

WORKDIR $MY_DIR/bin
RUN chmod +x *.sh
# RUN echo 'while true; do sleep 10; done' >> start.sh

EXPOSE 9999 

CMD ./start.sh; /usr/sbin/sshd -d
