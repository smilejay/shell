#!/bin/bash

logfile='celery_beat.log'
pidfile='celery_beat.pid'
app='myapp'

stop() {
	echo "restart celery beat..."
	if [ -f $pidfile ]; then
		# kill the previous celery beat instance (only one instance.)
		echo "killing previous celery beat instance ... "
		pid=$(cat $pidfile)
		if [ "x$pid" != "x" ]; then
			echo "killing beat instance PID: $pid"
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
	# start the celery beat
	echo "starting the new celery beat instance"
	echo "celery -A $app beat -l info --logfile=$logfile --pidfile=$pidfile --detach"
	celery -A $app beat -l info --logfile=$logfile --pidfile=$pidfile --detach
	sleep 1  # wait for celery beat instance starting
	echo "-------------------------------------------"
	ps -ef | grep celery | grep beat | grep -v grep
	echo "-------------------------------------------"
}

usage() {
	echo "---------- the usage document -----------------------"
	echo "$0 [option]:"
	echo ""
	echo "-r  (default, when no argument) restart celery beat."
	echo "-s  only stop celery beat (NOT start new beat)."
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
		s) stop; echo "'-s', only stop celery beat." ;;
		h) usage; exit 0 ;;
		?) echo "unsupported argument." ;;
	esac
done

echo "---done!---"
