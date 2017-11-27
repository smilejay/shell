#!/bin/bash
num=$1
for (( i=1; i<=64; i++ ))
do
    low=$(( 2 ** (($i-1)) ))
    high=$(( 2 ** $i ))
    avg=$(( (( $low + $high )) / 2 ))
    if [ $num -le 0 ]; then
        echo "error! we only support positive integer."
        exit 1
    fi
    if [ $num -eq $low -o $num -eq $high ]; then
        echo "num:$num  2-power-num:$num"
        break
    fi
    if [ $num -gt $low -a $num -lt $high ]; then
        if [ $num -lt $avg ]; then
            echo "num:$num  2-power-num:$low"
            break
        else
            echo "num:$num  2-power-num:$high"
            break
        fi
    fi
done
