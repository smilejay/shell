#!/bin/bash
# you can add "*/2 * * * * /root/reboot-500times.sh" to /etc/crontab to trigger the script.
# set -x
counter_file=/root/reboot_num
log_file=/root/reboot-500times.log
num=$(cat $counter_file)
echo ${num:=1}
if [ $num -le 500 ]; then
	echo "this is the NO. $num rebooting. $(date) " >> $log_file
	((num++))
	echo $num > $counter_file
	sync
	sleep 5
	reboot
fi
