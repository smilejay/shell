#!/bin/bash
# kernel build for 24 hours

kb_log=/root/kb-24h.log
begin_date=$(date +%s)
end_date=$(($begin_date+86400))
kernel_dir=/root/linux-3.8/

echo "--------kernel build for 24h:  begins at $(date) --------------" > $kb_log
present_date=$(date +%s)
counter=1
while [ $present_date -le $end_date ]
do
	echo "NO. $counter kernel build." >> $kb_log
	cd $kernel_dir
	make clean
	make alldefconfig
	make -j 2
	counter=$(($counter+1))
	present_date=$(date +%s)
	sleep 5
done
echo "--------scp-24.sh  ends at $(date) --------------" >> $kb_log
