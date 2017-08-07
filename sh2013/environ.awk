# environ.awk - print environment variable and do some modification
BEGIN {
	for (env in ENVIRON)
		print env "=" ENVIRON[env]
}

{
	print "modify ENVIRON[\"LOGNAME\"] ..."
	ENVIRON["LOGNAME"] = "Tom"
	print "ENVIRON[\"LOGNAME\"] = "ENVIRON["LOGNAME"]
}
