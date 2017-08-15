#!/bin/bash
# need to install the following software in the newly-built VPS (CentOS 6.4)
# BTW, when using 'yum install' you can use '-y' option answer any questions with 'yes'.
# -y, --assumeyes
#              Assume yes; assume that the answer to any question which would be asked is yes.
webserver=nginx  # or httpd

yum install -y openssh* openssh-clients
yum install -y $webserver mysql mysql-server php wget php-mysql
yum install -y vim iptraf iftraf iftop sysstat git bc mailx postfix

# use 'system-config-firewall-tui' to config firewall
yum install -y system-config-firewall-tui


# add more packages which have nothing to do with WordPress.
yum install -y pciutils svn glibc-common ntpdate gcc make freetype fontconfig

# for nginx
# http://centos.alt.ru/repository/centos/6/x86_64/nginx-1.5.8-1.el6.x86_64.rpm
# http://www6.atomicorp.com/channels/atomic/centos/6/x86_64/RPMS/GeoIP-1.4.8-1.1.el6.art.x86_64.rpm
yum install -y openssl php-fpm
