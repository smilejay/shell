#!/bin/bash
# to sync data from a remote sytem and backup all the data

EMAIL=yongjie.ren@intel.com
LOG=/share/vmm-qa/bin/backup.log
LOCAL_DIR=/share/vmm-qa

#only reserve $DAYS_TO_RESERVE days backup tar.gz files.
export DAYS_TO_RESERVE=10

function is_removable()
{
	local fn=$1
	local year=$(echo $fn | awk -F- '{ print $1 }')
	local file_date=$(expr substr $fn  1 10)

	local cur_offset=$(date +%j)
	local file_offset=$(date +%j -d"$file_date")
	local days_diff=0

	[ $year -eq $(date +%Y) ] || cur_offset=$(expr $cur_offset + 365)

	days_diff=$(expr $cur_offset - $file_offset)
	if [ $days_diff -lt $DAYS_TO_RESERVE ]; then
		return 0
	else
		return 1
	fi
}


echo "----backup start: $(date) ----"

# del old archive
echo "remove old archives: $(date)"
cd $LOCAL_DIR/backup/
for f in *
do
	is_removable $f
	if [ $? -eq 1 ]; then
		echo "Remove file $f"
		rm -f $f	
	fi
done

#sync data from server and create tarball
echo "rysnc with vmm-qa: $(date)"
rsync qa-machine-jay:/home/ $LOCAL_DIR/home/ -avz --delete  
if [ $? -ne 0 ]; then
	echo "failed" | mailx -s "failed to rsync with vmm-qa." -a $LOG $EMAIL
	exit 1
fi

# compress the backup files
echo "compress backup files: $(date)"
cd $LOCAL_DIR/home/
for backup in *
do
	backup_file=$(echo $backup|sed 's!/!-!g')
	tar -zcf $LOCAL_DIR/backup/`date "+%F"`$backup_file.gz $backup
done

echo "----backup end: $(date) ----"
