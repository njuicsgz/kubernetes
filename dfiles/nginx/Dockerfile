FROM allen01:5000/ubuntu-sshd

MAINTAINER PaaS/allen

RUN apt-get update
RUN apt-get install -y nginx

EXPOSE  80 22

CMD service nginx start; /usr/sbin/sshd -D
