awk -v NUM=$1 -v TOPNUM=$2 ' 
# lotto - pick x random numbers out of y 
# main routine 
BEGIN { 
# test command line args; NUM = $1, how many numbers to pick 
#                         TOPNUM = $2, last number in series 
	if (NUM <= 0) 
		NUM = 6 
		if (TOPNUM <= 0) 
			TOPNUM = 30 

# print "Pick x of y" 
	printf("Pick %d of %d\n", NUM, TOPNUM) 

# seed random number using time and date; do this once 
	srand() 

# loop until we have NUM selections 
	for (j = 1; j <= NUM; ++j) { 
	# loop to find a not-yet-seen selection 
		do { 
			select = 1 + int(rand() * TOPNUM) 
		} while (select in pick) 
		pick[select] = select 
	}
 
# loop through array and print picks. 
	for (j in pick) 
		printf("%s ", pick[j]) 

	printf("\n") 
}' 
