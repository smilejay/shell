#!/bin/bash
#author: yongjie.ren@intel.com
#filename: backup_db.sh
# to back up some databases for a QA system

backup=/home/backup_db
databases="vmm_data bugs bugs_kvm bugs_xen bugs_vgt testlink testlink_txt testlink_yocto kvm-perf kvm_functional mysql information_schema vgt_data"
reserve_days=30
log_file=backup_db.log
log_msg=""
msg_head="["$(date +"%F %T")"]"


#create log file
function create_log()
{
	logsize=$(du -sm $log_file|awk '{print $1}')
	if [ $logsize -gt 1024 ];then
		cp -i $log_file ${log_file}_bk
		cat /dev/null > $log_file     
	fi
	echo -e $log_msg >> $log_file
}

#dump a database
function dump_database()
{
	#quick dump database and add lock when duming
	mysqldump --databases $1 --user=root --password= --max_allowed_packet=40960M -q -c -R>$filename.sql
	if [ $? -eq 0 ];then
		log_msg="$log_msg$msg_head : OK: dump database $1 successfully \n"
		sleep 10
		return 0
	else
		log_msg="$log_msg$msg_head : Fail: failed to dump database $db \n"
		sleep 10
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
		chattr -i $backup 2>/dev/nul
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
chattr +i $backup
log_msg="$log_msg------backup_db.sh ends at $(date)----------------------------------\n"
create_log
