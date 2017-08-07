#!/usr/bin/awk

# run it using "awk -f call-shell.awk my.dat"

#{
#while ( ("ls" | getline) >0 )
#      print $0
#print "----------------"
#}

#{
#while ( ("ls" | getline name) >0 )
#      print name
#}
#
/26/
{
cmd="echo Hello "$1;
system(cmd)
}

