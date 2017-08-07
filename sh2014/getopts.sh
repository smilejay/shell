#!/bin/bash
echo $*
while getopts ":a:bc" opt
do
    case $opt in
	a ) echo $OPTARG
	    echo $OPTIND;;
	b ) echo "b $OPTIND";;
	c ) echo "c $OPTIND";;
	? ) echo "error"
	    exit 1;;
    esac
done
echo $OPTIND
shift $(($OPTIND - 1))
# 通过shift $(($OPTIND – 1))的处理，$*中就只保留了除去选项内容的参数，可以在其后进行正常的shell编程处理了。
echo $0
echo $*
