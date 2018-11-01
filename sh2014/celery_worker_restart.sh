#!/bin/bash

logfile='celery_worker.log'
pidfile='celery_worker.pid'
app='myapp'

stop() {
	echo "restart celery worker ..."
	if [ -f $pidfile ]; then
		# kill the previous celery worker instances
		echo "killing previous celery worker instances ... "
		pid=$(cat $pidfile)
		if [ "x$pid" != "x" ]; then
			children=$(ps -eo pid,ppid | awk -v ppid=$pid '{ if ($2==ppid) print $1}')
			for i in $children
			do
				echo "killing PID: $i"
				kill -9 $i
			done
			echo "killing main worker PID: $pid"
			kill -9 $pid
		fi
		# remove the previous pidfile
		echo "removing pidfile: $pidfile"
		rm -f $pidfile
	else
		echo "WARN: pidfile $pidfile doesn't exist ! "
	fi
}


start() {
	# start the celery worker instances
	echo "starting the new celery worker instances ..."
	echo "celery -A $app worker -c 8 -l info --logfile=$logfile --pidfile=$pidfile --detach"
	celery -A $app worker -c 8 -l info --logfile=$logfile --pidfile=$pidfile --detach
	sleep 2  # wait for workers' starting
	echo "-------------------------------------------"
	ps -ef | grep celery | grep worker | grep -v grep
	echo "-------------------------------------------"
}

usage() {
	echo "---------- the usage document -----------------------"
	echo "$0 [option]:"
	echo ""
	echo "-r  (default, when no argument) restart celery workers."
	echo "-s  only stop celery workers (NOT start new workers)."
	echo "-h  show this usage document."
	echo "-----------------------------------------------------"
}

if [ $# -eq 0 ]; then
	stop
	start
fi

while getopts "rsh" opt
do
	case $opt in
		r) stop; start ;;
		s) stop; echo "'-s', only stop workers." ;;
		h) usage; exit 0 ;;
		?) echo "unsupported argument." ;;
	esac
done

echo "---done!---"
