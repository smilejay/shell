#!/bin/bash
# just some powerful shell commands

#1  cout the string of 3rd field
cut -d , -f 3 data1.txt  | sort | uniq -c | sort -k1nr -k2
