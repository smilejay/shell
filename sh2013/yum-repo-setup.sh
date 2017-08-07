#!/bin/bash
# set up YUM repository
# yum install createrepo  # install 'createrepo' tool
base_dir=/home/yum/pub/6Server
# mkdir -p $base_dir/{SRPMS,i386,x86_64} # create dir if needed
for i in "SRPMS i386 x86_64"
do
	# cp /your-src/*.rpm $base_dir/$i/ # you may copy RPMs to your destination dirctory
	pushd $base_dir/$i > /dev/null 2>&1
		createrepo .
	popd >/dev/null 2>&1
done

