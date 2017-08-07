#!/bin/bash

df | grep mnt | grep 'vt-nfs:/temp'
if [ $? -ne 0 ]; then
	umount /mnt
	mount vt-nfs:/temp /mnt
fi

project=kvm  # kvm or xen
cd /mnt
if [ ! -d $project ]; then
	mkdir $project
fi
cd $project
rm -rf *

# create files endlessly
for ((i=0; ; i++))
do
	mkdir $i
	cd $i
	# 10000 files at most in a directory
	for ((j=0; j<10000; j++))
	do
		touch $j
	done
done
