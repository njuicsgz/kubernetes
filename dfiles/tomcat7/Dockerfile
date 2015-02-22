FROM allen01:5000/u14-ssh-jdk1.7

MAINTAINER PaaS/allen

RUN apt-get update
RUN apt-get install -y tomcat7

EXPOSE 8080 22

CMD service tomcat7 start; /usr/sbin/sshd -D
