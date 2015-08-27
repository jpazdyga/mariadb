FROM jpazdyga/centos7-base
MAINTAINER Jakub Pazdyga <jakub.pazdyga@ft.com>

RUN rpmdb --rebuilddb && \ 
    rpmdb --initdb && \
    yum clean all && \
    yum -y update && \
    yum -y install openssh \
                   openssl \ 
                   openssl-libs \
                   psmisc \
                   openssh-server \
                   PyYAML \
                   python-jinja2 \
                   python-httplib2 \
                   python-keyczar \
                   python-paramiko \
                   python-setuptools \
                   git \
                   python-pip

RUN useradd -d /etc/ansible -G wheel -m -s /bin/bash ansible && \
    su ansible -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa" && \
    ssh-keygen -A && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxLPLjUQf35uzbNGiCiVkOpeXOaO4JdC0GGkRTRhgSeKdu4Nz2iADET5bYBps27OCnk7JmWp3PiNbs6inMazHMylxB8BeV1Q9p+yMZLpuGdziokt4Z8sVDjgMkJPS0Ob74GE2aIfqx/gxTgf2WGQTNlCWP53nb3ccjQXW2b8jK39VCLw5VPE3YMojfGdM9BMhMOUdut3xnIJNnjivuZw9SZM746/PCvxvB/h+nE6u/3QP7D2xhEAXusxnctvOz2LWBf5rXrndAf4ENqOe6JK7LWGVTax2NgXc0pVJ53/+Ghhi2zYBuEaQGiOc7qeblJEUqrMXPij50LcE0ya10cmdAw==" > /etc/ansible/.ssh/authorized_keys && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2t1lWVnWi2wjm8HIjBX+Oetps2nmgCp3jw/CwnXhBZCib35o2nyrZI9JkM5phoZb9XA0M9ZDyrx3bqwjgfrTiF+gFJNd3aeTUGuZUV6T7mALZ9dICy5XYbPRQR3BgLVAfDMMthbWaGiwfeVjxidcLJpDc6wXAj4YiT+80/B2s2TTJM6BIr8n8JoCNsFlheEu7wmAxNj0IpXlt72xTpGuh4LB8ZwiuZzrY5gOYpsfENioHTklHMXr2ucMxbP+mf5Qagtv2R7YrUNSWPRekNbEfYWiqVMTVWxKbRtEIQ7RnoJr2Talum6k5EIJYCrpWKf+2EgykTUyCNymzYaAPLDvT" >> /etc/ansible/.ssh/authorized_keys && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDG3FgQxvXcxTpA+D1oN1FeDp+gy3Dgi5VW/DQhyW+HubmIAs3sbNf65mJv2w/KgzFsfU0P0yvch2VohCY2vYWIMtp+fvUhqTg22uUCfNFoZUkolpWzhqXIVSL8wrsBCtJdyyzoIMSdeA9RYGgPOIjOoO91Nookro+CDp7YUe8zBrlCzBNBBjmxJCIv7vDlMkC35xZBqzeIhmIctD0bzGvOe3n4+vGYT4x0loeXu2OmK25SKaYGK4eLkRP0+OSi+1i0L8pLOC9mf46c5gOxe8IcmSGK4vEm7RLB0icp6UfJMHXAkCb0aeAlzdofRR2W5RApOsPVatAemWj7L04qchU9" > /etc/ansible/.ssh/coreos-appdeploy.pub
RUN sed -i \
	-e 's/^PasswordAuthentication yes/PasswordAuthentication no/g' \
	-e 's/^#PermitRootLogin yes/PermitRootLogin no/g' \
	-e 's/^#UseDNS yes/UseDNS no/g' \
	/etc/ssh/sshd_config
RUN sed -i \
        -e 's/^%wheel\tALL=(ALL)\tALL/#%wheel\tALL=(ALL)\tALL/g' \
        /etc/sudoers && \
        echo -e "%wheel\tALL=(ALL)\tNOPASSWD:\tALL" >> /etc/sudoers

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN yum -y install mariadb-server \
                   mariadb && \
    chown mysql /var/lib/mysql -R
ENV container docker
ENV DATE_TIMEZONE UTC
VOLUME /var/lib/mysql
COPY entrypoint.sh /sbin
ENTRYPOINT ["/sbin/entrypoint.sh"]
EXPOSE 22,3306
CMD ["mysqld_safe"]
