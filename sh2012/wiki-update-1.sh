#!/bin/bash

# decide which column should be duplicated.
if [ "X$1" != "X" ]; then
	col=$1;
else
	col=7
fi

# copy $col column and insert it before $col.
# set "||" (re "[|]{2}") as the field separator (FS) in AWK.
# but, if I print out FS, it shows "[1]{2}" not "||".
# So I use another variable myfs instead.
awk --posix -v col=$col '
BEGIN {
	FS="[|]{2}";
	myfs="||";
}
{
	printf("%s", myfs);
	for (i=2; i<col; i++)
		printf("%s%s", $i, myfs);
	printf("%s%s", $col, myfs);
	for (i=col; i<NF;i++)
		printf("%s%s", $i, myfs);
	printf("\n");
}' wiki-data.txt > wiki-data-3.txt
