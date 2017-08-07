# an example for route setting
service network restart
route del -net link-local netmask 255.255.0.0 dev eth0
route del -net 10.0.0.0 netmask 255.0.0.0 dev eth0
route add -net 10.239.48.0 netmask 255.255.255.0 dev eth0
route

