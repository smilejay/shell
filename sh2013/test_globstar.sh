#!/bin/bash

function show()
{
	for i in **
	do
		echo $i
	done
}

cd /root/jay/
echo "------------------------"
echo "disable globstar option:"
# globstar is disabled by default
shopt -u globstar
show
echo "------------------------"
echo "enable globstar option:"
shopt -s globstar
show
