#!/bin/bash
# author: Jay <smile665@gmail.com>
# some examples for playing with floating point number.

# basic usage of 'bc' tool in Bash.
a=3.33
b=3.3
c=$(echo "$a + $b" | bc)
d=$(echo "$a * $b" | bc)
e=$(echo "scale=5; $a / $b" | bc)
echo "c=a+b=$a+$b=$c"
echo "d=a*b=$a*$b=$d"
echo "e=a/b=$a/$b=$e"

# "-l" parameter for 'bc' means using math library.
pi=$(echo "scale=10; 4*a(1)" | bc -l)
s=$(echo "s($pi/6)" | bc -l)
echo "pi=$pi"
echo "s=sin(pi/6)=$s"

# use more options of 'bc' tool
r=$(echo 'ibase=10;obase=2; 15+16' | bc)
echo "binary of (15+16) is $r"

# comparison for floating point numbers using 'bc'
big=100
small=99.9
if [ $(echo "$big > $small" | bc) -eq 1 ]; then
	echo "$big is bigger than $small"
fi

# deal with floating point numbers with 'awk' language
echo $(awk -v x=10 -v y=2.5 'BEGIN {printf "10/2.5=%.2f\n",x/y}')
v=$(echo $big $small | awk '{ printf "%0.8f\n" ,$1/$2}')
echo "$big / $small = $v"

echo $big $small | awk '{if($1>$2) {printf"%f > %f\n",$1,$2} else {printf"%f <%f\n",$1,$2}}'
