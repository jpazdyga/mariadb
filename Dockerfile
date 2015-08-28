FROM jpazdyga/centos7-base
MAINTAINER Jakub Pazdyga <jakub.pazdyga@ft.com>

RUN rpmdb --rebuilddb && \ 
    rpmdb --initdb && \
    yum clean all && \
    yum -y update && \
    yum -y install openssl \ 
                   openssl-libs \
                   psmisc \
                   git

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN yum -y install mariadb-server \
                   mariadb && \
    chown mysql /var/lib/mysql -R
ENV container docker
ENV DATE_TIMEZONE UTC
COPY entrypoint.sh /sbin/entrypoint.sh
COPY supervisord.conf /etc/supervisor.d/supervisord.conf
RUN /sbin/entrypoint.sh
VOLUME /var/lib/mysql
USER root
CMD ["/usr/bin/supervisord", "-n", "-c/etc/supervisor.d/supervisord.conf"]
EXPOSE 3306
