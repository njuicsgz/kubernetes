FROM allen01:5000/ubuntu-sshd

MAINTAINER PaaS/allen

ENV ZK_ADDRESS 172.30.50.26:2181
ENV MY_DIR /opt/ndp/facebook-pmd/rdb-services

ADD /bin/ $MY_DIR/bin/
ADD /lib/ $MY_DIR/lib/

WORKDIR $MY_DIR/bin
RUN chmod +x *.sh
RUN echo 'while true; do sleep 10; done' >> start.sh

EXPOSE 9999 

CMD ./start.sh
