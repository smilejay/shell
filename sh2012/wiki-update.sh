#!/bin/bash

# decide which column should be duplicated.
if [ "X$1" != "X" ]; then
	col=$1;
else
	col=7
fi

# replase "||" by "|", for the good use of AWK script.
cat wiki-data.txt | sed 's/||/|/g' > wiki-data-1.txt

# copy $col column and insert it before $col.
awk -F \| -v col=$col '{
	printf("%s",FS);
	for (i=2; i<col; i++)
		printf("%s%s", $i, FS);
	printf("%s%s", $col, FS);
	for (i=col; i<NF;i++)
		printf("%s%s", $i, FS);
	printf("\n");
}' wiki-data-1.txt > wiki-data-2.txt

# restore the filed separator to use "||" instead of "|"
cat wiki-data-2.txt | sed 's/|/||/g' > wiki-data-after.txt
