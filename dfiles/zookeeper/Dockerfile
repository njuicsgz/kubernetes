FROM repo.paas.com:5000/paas/u14-ssh-jdk1.7:latest 

MAINTAINER PaaS/allen

ADD zookeeper-3.4.6.tar.gz /usr/local/

EXPOSE 2181 

CMD cd /usr/local/zookeeper-3.4.6/bin && ./zkServer.sh start; /usr/sbin/sshd -D
