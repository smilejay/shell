line='inet 192.168.180.24  netmask 255.255.252.0  broadcast 192.168.183.255'
echo "all ip(s):"
echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"
echo "valid ip(s):"
echo "$line" | grep -oE "\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"

echo "ip(s) from ip addr cmd:"
ip addr | grep -Po '(?!(inet 127.\d.\d.1))(inet \K(\d{1,3}\.){3}\d{1,3})'
