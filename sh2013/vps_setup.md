### some tips about setting up my VPS.   This is for CentOS 6.x system.

[TOC]

### install software:

https://github.com/smilejay/shell/blob/master/sh2013/yum_install.sh
### config services:
```shell
# chkconfig httpd on   # when using apache
 chkconfig mysqld on
 chkconfig postfix on
 chkconfig nginx on
 chkconfig php-fpm on 
 # service mysqld/nginx/php-fpm start 
```

### php config 

vim /etc/php.ini

```ini
engine = On
extension=mysql.so
```

### add rewrite and allow/deny rules in .htaccess file (for apache only)
/var/www/html/.htaccess
https://github.com/smilejay/other-code/blob/master/config/dot_htaccess

### add my monitor script for hourly running  (optional)
 crontab -e:
 02  *  *  *  * /root/vps_monitor.sh
monitor script: 
 https://github.com/smilejay/shell/blob/master/sh2013/vps_monitor.sh

### some modification for web server
#### for apache (httpd)
 https://github.com/smilejay/other-code/blob/master/config/httpd.conf.diff
#### for nginx
 https://github.com/smilejay/other-code/blob/master/config/nginx.conf.diff
#### for php-fpm
 https://github.com/smilejay/other-code/blob/master/config/php-fpm-www.conf.diff

### disable selinux
```shell
# /usr/sbin/sestatus -v  #查看SELinux的运行状态
setenforce 0
```
修改/etc/selinux/config 文件
将SELINUX=enforcing改为SELINUX=disabled


### a command to get top 20 visitors' IP address:
```shell
cat /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -20
```