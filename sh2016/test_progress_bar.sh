#!/bin/bash

for i in $(seq 0 10); do
    echo $i
    sleep 1
done | ./progress_bar.sh -m 10 -w 40 -b "=" -i -t "Example "
echo "Done"
