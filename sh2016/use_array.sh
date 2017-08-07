#!/bin/bash
#use array in Bash script
array1=(Alpha Beta Gamma)
echo "array1[0]: ${array1[0]}"
echo "array1[1]: ${array1[1]}"
echo "len of array1: ${#array1[@]}"
echo "len of array1: ${#array1[*]}"
echo "len of array1[0]: ${#array1[0]}"
echo "\${array1[@]}: ${array1[@]}"
echo "\${array1[*]}: ${array1[*]}"
echo "\${array1[@]1}: ${array1[@]:1}"
echo "\${array1[@]1}: ${array1[@]:0:2}"

echo ""
echo "for in \${array1[@]}:"
for i in "${array1[@]}"
do
	echo $i
done
echo ""
echo "for in \${array1[*]}:"
for i in "${array1[*]}"
do
	echo $i
done
echo ""

unset array1[0]
echo "\${array1[@]: ${array1[@]}"
echo ""

array2[0]=11
array2[1]=22
array2[3]=Foo

echo "array2: ${array2[@]}\n"


ls_out=($(ls *.sh))
echo "len of ls_out is ${#ls_out[@]}"
for i in $(seq 0 $((${#ls_out[@]}-1)))
do
	echo "ls_out[${i}] ${ls_out[$i]}"
done
