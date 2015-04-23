FROM xa.repo.ndp.com:5000/paas/u14-ssh-nginx1.4.6 

MAINTAINER PaaS/allen01

ADD postStart.sh /postStart.sh
ADD preStop.sh /preStop.sh

CMD service nginx start; /usr/sbin/sshd -D
