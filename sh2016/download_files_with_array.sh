#!/bin/bash
# download and copy tool0/tool1 to /usr/bin directory

tool0_url='http://192.168.1.111/share/tool0'
tool1_url='http://192.168.1.111/share/tool1'
cmd0="sudo wget -q $tool0_url -O /usr/bin/tool0"
cmd1="sudo wget -q $tool1_url -O /usr/bin/tool1"
array[0]=$cmd0
array[1]=$cmd1
for i in "${array[@]}"
do
    eval $i
    if [ $? -ne 0 ]; then
        echo "Failed to exec cmd: $i"
        exit 1
    else
        echo "Success. $i"
    fi
done
echo "OK. Finished."
