#!/bin/bash

#set -x

t1_s=0
t1_ns=0
t2_s=0
t2_ns=0
t_s=0
t_ns=0
t=0

project=kvm  #kvm or xen

df | grep mnt | grep 'vt-nfs:/temp' &> /dev/null
if [ $? -ne 0 ]; then
	umount /mnt
	mount vt-nfs:/temp /mnt
fi

cd /mnt/$project
for i in $(ls -rt)
do
	cd $i
	for j in $(ls -rt)
	do
		t1_string=$(echo $(stat $j) | grep -o 'Modify.*Change' | grep -o '2012.*0800')
		t1_s=$(date -d "$t1_string" +%s)
		t1_ns=$(date -d "$t1_string" +%N)
		k=$((j+1))
		if [ ! -f $k ]; then
			echo "finished!"
			exit 0
		fi
		t2_string=$(echo $(stat $k) | grep -o 'Modify.*Change' | grep -o '2012.*0800')
		t2_s=$(date -d "$t2_string" +%s)
		t2_ns=$(date -d "$t2_string" +%N)
		
		# to avoid something like t1_ns=012345678 ; or use 'bc' to calulate t_ns
		t1_ns="1$t1_ns"
		t2_ns="1$t2_ns"
		t_s=$((t2_s-t1_s))
		t_ns=$((t2_ns-t1_ns))
		t=$(echo "($t_s*1000)+($t_ns/1000000)" | bc )  # interval in ms
		if [ $t -lt 0 ]; then
			echo "Error!! t<0  t:$t ms"
			exit 1
		elif [ $t -ge 500 ]; then
			echo "---------------------------------------------"
			echo "dir:$PWD file:$j and file:$k"
			echo "service down time: $t ms"
			echo "---------------------------------------------"
		elif [ $t -lt 10 ]; then
			echo "Warning! interval is too short. t<10  t:$t ms"
			echo "dir:$PWD file:$j and file:$k"
		fi
	done
done

exit 0
