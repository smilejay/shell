#!/bin/bash
date_output=$(sudo ssh root@vt-master "date")
time_zone=$(echo $date_output | awk '{print $5}')
local_tz=$(date | awk '{print $5}')
time=$(echo $date_output | awk '{print $4}')
if [ $time_zone = $local_tz ]; then
	echo "time zone: $time_zone"
	echo "sync time with vt-master"
	sudo date -s $time
fi
exit 0

# The clock of my personal PC is not accurate, but the time on vt-master is alwasy accurate.
# As NTP is blocked in our intranet, I use this script in 'crontab' to sync time from vt-master everyday.
# If NTP can work, I can use "ntpdate vt-master" command to sync time with a remote machine (vt-master).
