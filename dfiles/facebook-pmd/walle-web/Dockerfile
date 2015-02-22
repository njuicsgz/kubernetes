FROM allen01:5000/paas/u14-ssh-nginx1.4.6

MAINTAINER PaaS/allen

ENV ZK_ADDRESS 172.30.50.26:2181
ENV NGINX_DIR /etc/nginx
ENV TARGET_DIR /ndp/app/walle-web

RUN echo "export ZK_ADDRESS=${ZK_ADDRESS}" >> /etc/profile

# copy file
WORKDIR $TARGET_DIR/
ADD /walle-web $TARGET_DIR/

# modify nginx conf
WORKDIR $NGINX_DIR/
ADD /test.facebook.yeahmobi.com.conf $NGINX_DIR/conf.d/
RUN rm -f sites-enabled/*


CMD service nginx start; /usr/sbin/sshd -D;
