#!/bin/bash
#author:Yejianjun
#	Yongjie Ren <yongjie.ren@intel.com>
#discrption: print info about the relationship between PCI BDF and NIC interface
#set -x

#print usage info
function print_help()
{
	echo "------you can use this tool as the following command line ---------"
	echo "$script 03:00.0   #print the given bdf_no info"
	echo "$script eth0      #print the given NIC interface info"
	echo "$script           #print all the NIC interfaces and their BDF info"
	echo "$script -h        #print the help info"
}

#print all the NIC interfaces and their BDF info
function print_all()
{
	printf "%s\n" "-----------All the NIC interfaces and bus_info are list below -------"
	printf "%-9s %-13s %-8s %-s\n" "interface" "bus_info" "driver"  "ip"

	for eth in ${eth_arr[@]};
	do
		ip=`ifconfig $eth|grep 'inet addr'|awk '{print $2}'|awk -F: '{print $2}'`
		bus_info=`ethtool -i $eth|grep bus-info|awk '{print $2}'`
		driver=`ethtool -i $eth|grep driver|awk '{print $2}'`
		printf "%-9s %-13s %-8s %-s\n" "$eth" "$bus_info"  "$driver" "$ip"
	done
}

#print info for some options in command line
function print_info()
{
	while getopts "h" options
	do
        	case $options in
			h)	print_help
                		exit 0;;
			*)	print_help
				print_all
				exit 1;;
	        esac
	done
	if [ "x" = "x$1" ]; then
		print_help
		print_all
		exit 1
	fi
}

#print the relationship when found
function print_bdf()
{
	for eth in ${eth_arr[@]};
	do
		ip=`ifconfig $eth|grep 'inet addr'|awk '{print $2}'|awk -F: '{print $2}'`
		bus_info=`ethtool -i $eth|grep bus-info|awk '{print $2}'`
		driver=`ethtool -i $eth|grep driver|awk '{print $2}'`
			
		#find the bdf_no,print it, then exit!
		if [ "$eth" = "$1" -o "${bus_info:(-7)}" = "$1" ]; then
			printf "%-9s %-13s %-8s %-s\n" "interface" "bus_info" "driver"  "ip"
			printf "%-9s %-13s %-8s %-s\n" "$eth" "$bus_info"  "$driver" "$ip"
			exit 0
		fi
	done
}

#print 'not found' error
function print_error()
{
	echo "---Sorry, can't find $1  -----"
	echo "------------------------------"
	print_all
	exit 1
}

export script=$0
export eth_arr=$(ifconfig -a|grep eth|awk '{print $1}')
print_info $1
print_bdf $1
print_error

