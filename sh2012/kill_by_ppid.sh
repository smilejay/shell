#!/bin/bash
set -x
my_ppid=$1
PIDs=$(ps -ef|awk -v awk_ppid="$my_ppid" '{if(awk_ppid==$3) {print $2}}')
for i in $PIDs
do
	kill -9 $i
done

kill -9 $my_ppid

