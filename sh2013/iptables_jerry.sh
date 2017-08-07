#!/bin/bash
# Jay: got the script from http://forum.ubuntu.org.cn/viewtopic.php?t=17619
#	Just make a backup copy in my repo for iptables usage.
#	This script can be used in /ect/init.d/ as a service.
#
#	author: Jerry.
#       This program is used to use start my iptables.
#History :
#     Sat Jun 17 23:22:01 CST 2006    Jerry    Second realease
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:~/bin
export PATH

case "$1" in
start)
        echo -n "Staring to write your Iptbales:..."
        /sbin/iptables -P INPUT DROP
        /sbin/iptables -P OUTPUT ACCEPT
        /sbin/iptables -A INPUT -i lo -j ACCEPT
        /sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j DROP
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 20 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
        /sbin/iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 110 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
        /sbin/iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
        /sbin/iptables -A INPUT -p all -m state --state INVALID,NEW -j DROP
        echo "Ok"

;;
stop)
        echo -n "Cleaning your Iptables:..."
        /sbin/iptables -F
        /sbin/iptables -X
        /sbin/iptables -Z
        echo "Ok"
;;
restart)
        echo -n "Cleaning your Iptables:..."
        /sbin/iptables -F
        /sbin/iptables -X
        /sbin/iptables -Z
        echo "Ok"
        echo -n "Staring to write your Iptbales:..."
        /sbin/iptables -P INPUT DROP
        /sbin/iptables -P OUTPUT ACCEPT
        /sbin/iptables -A INPUT -i lo -j ACCEPT
        /sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j DROP
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 20 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
        /sbin/iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT       
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 110 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
        /sbin/iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
        /sbin/iptables -A INPUT -p all -m state --state INVALID,NEW -j DROP
        echo "Ok"
;;
*)
        echo "Usage: $0          {start|stop|restart}"
esac

exit 0
