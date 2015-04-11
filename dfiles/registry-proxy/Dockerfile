FROM xa.repo.ndp.com:5000/paas/u14-ssh-nginx1.4.6
MAINTAINER allen.gao

RUN mkdir -p /etc/nginx/certs 
ADD cert.pem /etc/nginx/certs/cert.pem
ADD key.pem /etc/nginx/certs/key.pem

ADD docker-registry.htpasswd /etc/nginx/docker-registry.htpasswd
ADD docker-registry.conf /etc/nginx/conf.d/docker-registry.conf

RUN rm -f /etc/nginx/sites-enabled/default

EXPOSE 443

# should export env REGISTRY_ADDR before run this container
CMD service nginx start; /usr/sbin/sshd -D 
