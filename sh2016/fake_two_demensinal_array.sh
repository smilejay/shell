#!/bin/bash
# The principle is: Creating one associative array where the index is an string like 3,4.
# The benefits:
#    it's possible to use for any-dimension arrays ;) like: 30,40,2 for 3 dimensional.
#    the syntax is close to "C" like arrays ${matrix[2,3]}
# from: http://stackoverflow.com/questions/16487258/how-to-declare-2d-array-in-bash

declare -A matrix
num_rows=4
num_columns=5

for ((i=1;i<=num_rows;i++)) do
    for ((j=1;j<=num_columns;j++)) do
        matrix[$i,$j]=$RANDOM
    done
done

f1="%$((${#num_rows}+1))s"
f2=" %9s"

printf "$f1" ''
for ((i=1;i<=num_rows;i++)) do
    printf "$f2" $i
done
echo

for ((j=1;j<=num_columns;j++)) do
    printf "$f1" $j
    for ((i=1;i<=num_rows;i++)) do
        printf "$f2" ${matrix[$i,$j]}
    done
    echo
done
