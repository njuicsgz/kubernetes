FROM allen01:5000/u14-ssh-jdk1.7

MAINTAINER PaaS/allen

ENV ZK_ADDRESS 172.30.50.26:2181
ENV MY_DIR /dianyi/app/walle/dubbo-monitor-svc

ADD /bin/ $MY_DIR/bin/
ADD /lib/ $MY_DIR/lib/
ADD /conf/ $MY_DIR/conf/

WORKDIR $MY_DIR/conf
RUN sed -i 's/^dubbo.registry.address/#dubbo.registry.address/g' dubbo.properties
RUN echo "" >> dubbo.properties
RUN echo "dubbo.registry.address=zookeeper://${ZK_ADDRESS}" >> dubbo.properties

WORKDIR $MY_DIR/bin
RUN chmod +x *.sh
RUN sed -i 's/-Xms2g/-Xms512m/g' start.sh
RUN echo 'while true; do sleep 10; done' >> start.sh

EXPOSE 8080 7070

CMD /usr/sbin/sshd; ./start.sh
