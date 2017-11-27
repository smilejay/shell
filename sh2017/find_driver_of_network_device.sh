#!/bin/bash

# NO.1 solution  (great!)
for f in /sys/class/net/*; do
    dev=$(basename $f)
    driver=$(readlink $f/device/driver/module)
    if [ $driver ]; then
        driver=$(basename $driver)
    fi
    addr=$(cat $f/address)
    operstate=$(cat $f/operstate)
    printf "%10s [%s]: %10s (%s)\n" "$dev" "$addr" "$driver" "$operstate"
done

# NO.2 solution
# ethtool -i eth0

# NO.3 solution
# dmesg | grep -i ethernet

# for detail info of the driver
# modinfo ixgbe    # assume you use ixgbe driver
