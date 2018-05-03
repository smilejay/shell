#!/bin/bash
#author: smile665@gmail.com
#filename: backup_db.sh
# to back up some databases

backup=/home/backup_db
databases="testlink dashboard"
reserve_days=30
log_file=backup_db.log
log_msg=""
msg_head="["$(date +"%F %T")"]"
db_pass='123123'


#create log file
function create_log()
{
	if [ ! -f $log_file ]; then
		logsize=0
	else
		logsize=$(du -sm $log_file|awk '{print $1}')
	fi
	logsize=$(du -sm $log_file|awk '{print $1}')
	if [ $logsize -gt 1024 ];then
		cp -i $log_file ${log_file}_bk
		cat /dev/null > $log_file
	fi
	echo -e $log_msg | tee -a $log_file
}

#dump a database
function dump_database()
{
	local dbname=$1
	local filename=$2
	mysqldump --databases $dbname --user=root --password=$db_pass --max_allowed_packet=40960M -q -c -R>$filename.sql
	if [ $? -eq 0 ];then
		log_msg="$log_msg$msg_head : OK: dump database $1 successfully \n"
		sleep 1
		return 0
	else
		log_msg="$log_msg$msg_head : Fail: failed to dump database $db \n"
		sleep 1
		return 1
	fi
}

#compress the backup file
function compress_backupfile()
{
	local filename=$1
	tar -czvf $filename.tar.gz $filename.sql && rm -f $filename.sql
	if [ $? -eq 0 ];then
		log_msg="$log_msg$msg_head : OK: compress backup file $filename.sql successfully\n"
		return 0
	else
		log_msg="$log_msg$msg_head : Fail: failed to compress backup file $filename.sql\n"
		return 1
	fi
}

#remove old file
function remove_oldfile()
{
	for file in $(ls *.tar.gz)
	do
		exist_seconds=$(stat -c %Y $file)
		date_seconds=$(date +%s)
		reserve_seconds=$(($reserve_days * 24 * 3600))
		delta_seconds=$(($date_seconds - $exist_seconds))
		if [ $delta_seconds -gt $reserve_seconds ]; then
			rm -f $file
			if [ $? -eq 0 ]; then
				log_msg="$log_msg$msg_head: OK: remove old backup file $file successfully\n"
			else
				log_msg="$log_msg$msg_head: Fail: failed to remove old backup file $file\n"
			fi
		fi
	done
}

#change attribute of backup dir and 'cd' to backup dir
function cd_backup()
{
	if [ -d $backup ];then
		chattr -i $backup 2>/dev/null
	else
		mkdir -p $backup
	fi
	cd $backup
}

log_msg="$log_msg------backup_db.sh starts at $(date)--------------------------------\n"
cd_backup
for db in $databases
do
	today=$(date +'%Y%m%d')
	filename="$db$today"
	dump_database $db $filename
	compress_backupfile $filename
done
remove_oldfile
log_msg="$log_msg------backup_db.sh ends at $(date)----------------------------------\n"
create_log
chattr +i $backup
