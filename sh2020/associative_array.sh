#!/bin/bash
# download some files and check md5

declare -A tgz_array
tgz_array=([file1.tgz]=f1cdbcba49e92618ec4739065d670df1
           [file2.tgz]=f2435c8de754f7d4992a924cbc4e7bf2)
server_ip='127.0.0.1'
for file_name in ${!tgz_array[*]}
do
    echo "file_name:${file_name}  md5:${tgz_array[$file_name]}"
    echo "wget -q http://${server_ip}/$file_name -O /tmp/$file_name"
    wget -q http://${server_ip}/$file_name -O /tmp/$file_name
    if [ $? -eq 0 ]; then
        echo "download file success. $file_name"
    else
        echo "download file failed. $file_name"
        exit 1
    fi
    if ! md5sum /tmp/$file_name | grep -q "${tgz_array[$file_name]}"; then
        echo "error! failed to check file md5. $file_name"
        exit 1
    fi
done
