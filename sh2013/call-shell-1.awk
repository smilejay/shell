# echo aa | awk -f call-shell-1.awk

{
	var="Jay"
	print "echo Hello " var ";" "echo Hello " $1 | "/bin/bash"
}
