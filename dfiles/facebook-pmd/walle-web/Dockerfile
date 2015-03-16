FROM allen01:5000/paas/u14-ssh-nginx1.4.6

MAINTAINER PaaS/allen

ENV TAR_FILE walle-web.tar.gz
ENV NGINX_DIR /etc/nginx
ENV TARGET_DIR /ndp/app

# copy file
WORKDIR $TARGET_DIR/
ADD /$TAR_FILE $TARGET_DIR/

# modify nginx conf
WORKDIR $NGINX_DIR/
ADD /test.facebook.yeahmobi.com.conf $NGINX_DIR/conf.d/
RUN rm -f sites-enabled/*


CMD service nginx start; /usr/sbin/sshd -D;
